# Process Anti-Patterns (6 Patterns)

These patterns bypass the quality gate process itself. They are more dangerous than code anti-patterns because they undermine the entire safety net.

---

## Pattern 1: Asserting "Tests Pass" Without Output

**What it looks like:** Claiming tests pass without showing actual terminal output.

**Example:**
```
"I believe all tests pass."
"Tests should be green."
"I ran the tests and they all passed." (without showing output)
```

**Why it's dangerous:** Fabricated verification. The tests may not have actually been run, or they may have failed with output that was ignored.

**How to detect:** In code review or agent action logs, look for test claims without accompanying terminal output. The verification gate (Gate 1.2b) requires actual execution output.

**How to enforce:**
- Require test output in PR description or agent action log
- CI is the independent witness -- but local verification output provides faster feedback
- If using AI agents: the agent must show the bash/terminal output, not describe it in prose

---

## Pattern 2: Skipping Review Because "It's Simple"

**What it looks like:** Bypassing the review process for changes deemed too small to matter.

**Example:**
```
"This is just a typo fix, no need for review."
"It's only a one-line change."
"Config-only change, safe to merge directly."
```

**Why it's dangerous:** Simple changes break things too. A typo in a config file can take down production. A "one-line change" can introduce a subtle logic error.

**How to detect:** PRs merged without review approval or review comments. CI status checks not required.

**How to enforce:**
- Branch protection: require status checks for ALL PRs
- No exceptions for "simple" changes
- If it's truly trivial, the review will be fast anyway

---

## Pattern 3: Pushing Directly to Main

**What it looks like:** Committing and pushing directly to the main/master branch, bypassing the PR process entirely.

**Example:**
```bash
git commit -m "quick fix"
git push origin main
```

**Why it's dangerous:** Bypasses ALL gates -- tests, review, security scan, PR size check, everything. The change goes directly to production without any verification.

**How to detect:** Git log shows commits on main that don't correspond to merged PRs.

**How to enforce:**
- GitHub branch protection: "Restrict who can push to matching branches"
- Require PRs for all changes to main
- Even hotfixes use branches (see Emergency Hotfix Protocol)

---

## Pattern 4: Merging Without Reading Review Comments

**What it looks like:** CI is green, so the PR is merged without reading or responding to review comments.

**Example:**
```
"All checks pass, merging now."
(Review has 5 unread comments with valid findings)
```

**Why it's dangerous:** Unreviewed code ships. The review process exists to catch things CI cannot (logic errors, design issues, security concerns). Ignoring it defeats the purpose.

**How to detect:** PRs with unresolved review comments that were merged. Review Response Protocol requires a summary comment before merge.

**How to enforce:**
- Review Response Protocol: every comment gets a reply
- Summary comment required before merge
- Check all 3 comment sources (inline, review summaries, issue-level)

---

## Pattern 5: "While I'm Here" Scope Creep

**What it looks like:** A PR that starts as one thing but picks up unrelated changes along the way.

**Example:**
```
PR title: "Fix login button color"
PR contents:
  - Fix login button color (intended change)
  - Refactor auth module (unrelated)
  - Update 3 dependencies (unrelated)
  - Fix typo in README (unrelated)
```

**Why it's dangerous:** The unrelated changes haven't gone through the same design/planning process. They may not have adequate tests. The PR becomes harder to review because the reviewer must separate intended changes from incidental ones. If something breaks, it's harder to identify which change caused it.

**How to detect:** PR title/scope statement doesn't match all changed files. Multiple unrelated concerns in one PR.

**How to enforce:**
- PR template requires a single-sentence scope statement
- PR size check (Gate 2.5) limits total changes
- During review: "Does every changed file serve the PR's stated scope?"
- Split unrelated changes into separate PRs

---

## Pattern 6: Fixing Review Nits Directly to Main

**What it looks like:** After a PR is merged, pushing follow-up fixes directly to main instead of through a new PR.

**Example:**
```
PR #42 merged with review comment: "rename variable for clarity"
Developer pushes rename directly to main without a new PR.
```

**Why it's dangerous:** The fix bypasses the pipeline. Even a variable rename can introduce bugs (typo in the new name, missed reference, broken import). The pipeline exists to catch these.

**How to detect:** Commits on main that reference a PR number or review comment but don't have their own PR.

**How to enforce:**
- Branch protection prevents direct pushes to main
- All fixes, no matter how small, go through branches and PRs
- Review Response Protocol: fixes go in the same PR branch before merge
