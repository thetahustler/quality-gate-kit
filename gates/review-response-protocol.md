# Review Response Protocol

How to respond to code review findings. Every comment gets a response. No exceptions.

---

## 4 Response Types

Every code review finding gets ONE of these responses, posted as a reply comment:

### 1. Fixed

The finding is valid. A fix has been committed.

```
Fixed in abc1234 -- [what was changed]
```

Example:
```
Fixed in a7f3b21 -- Added timeout to API call, was missing per Gate 2.3
```

### 2. Already Addressed

The finding was already handled elsewhere in the PR or codebase.

```
Already addressed -- [explanation with evidence]
```

Example:
```
Already addressed -- Input sanitization is handled by the validate_input() middleware
at src/middleware/validation.py:42, which runs before this endpoint is reached.
```

### 3. Deferred

Valid finding, but out of scope for this PR.

```
Deferred to issue #XX -- [justification]
```

Example:
```
Deferred to issue #47 -- This endpoint needs rate limiting, but it's a separate
concern from the auth fix in this PR. Created issue with acceptance criteria.
```

**Requirements:**
- A tracking issue MUST be created (not just a TODO comment)
- The issue must be linked in the response
- Max 2 deferrals per PR (if you need 3+, the PR scope is wrong)

### 4. Won't Fix

Disagree with the finding. The current code is correct.

```
Won't fix -- [technical justification with evidence]
```

Example:
```
Won't fix -- The reviewer flagged this as a bare except, but it's actually
`except ValidationError as e:` with full logging at line 87. The error is
logged with context (user_id, input_data) and a user-friendly message is returned.
```

**Requirements:**
- Must include technical justification (not just "I disagree")
- Must include evidence (code references, documentation, test output)

---

## 7 Rules

1. **Every comment gets a reply.** 7 comments = 7 replies. No silent ignoring.

2. **Default is fix.** Unless there's a strong technical reason not to, fix the finding.

3. **"Won't fix" requires justification.** Not "I disagree" but "here's why the current code is correct, with evidence."

4. **"Deferred" requires a tracking issue.** Create the issue, link it. No loose TODOs. The issue must have acceptance criteria.

5. **Max 2 deferrals per PR.** If you need to defer 3 or more findings, the PR scope is wrong. Split it.

6. **All fixes go through the pipeline.** Fix in the PR branch, push, CI re-runs. Never push fixes directly to main.

7. **Post a summary comment before merge:**

```
## Review Response Summary
- X findings total
- N fixed (commits abc1234, def5678)
- N already addressed
- N deferred to issues #47, #48
- N won't fix (with justification above)
```

---

## 3 Comment Sources

Review comments may appear in multiple locations on GitHub. ALL THREE must be checked:

### Source 1: Inline PR Comments (Line-Level)

```bash
gh api repos/{owner}/{repo}/pulls/{PR}/comments
```

These are comments attached to specific lines in the diff.

### Source 2: Review Summaries

```bash
gh api repos/{owner}/{repo}/pulls/{PR}/reviews
```

These are the overall review assessments (approve, request changes, comment).

### Source 3: Issue-Level Comments

```bash
gh api repos/{owner}/{repo}/issues/{PR}/comments
```

These are general comments on the PR (not attached to specific lines).

**Missing any source = unreviewed code.** A reviewer might post findings in any of these locations.

---

## When Is It OK to Not Fix?

Only two cases:

### False Positive

The reviewer flagged something that's actually correct.

- Reply with "Won't fix"
- Show evidence that the code is correct
- Example: reviewer flagged a "bare except" that is actually a specific exception type

### Out of Scope

Valid finding, but unrelated to this PR's purpose.

- Reply with "Deferred"
- Create a tracking issue with acceptance criteria
- Link the issue in your reply

### Never OK to Skip

The following findings must ALWAYS be fixed before merge:

- Security findings (injection, secrets, auth bypass)
- Test quality issues (tautological tests, missing failure tests)
- Anti-pattern detections (any of the 21 anti-patterns)
- Violations of project governance docs or constitution

---

## Summary Template

Post this as a comment on the PR before merging:

```markdown
## Review Response Summary

**Reviewer:** [AI review / human reviewer name]
**PR:** #[number] — [title]

### Findings

| # | Finding | Severity | Response | Reference |
|---|---|---|---|---|
| 1 | [description] | Critical | Fixed in abc1234 | [link] |
| 2 | [description] | Important | Already addressed | [link] |
| 3 | [description] | Minor | Deferred to #47 | [link] |
| 4 | [description] | Minor | Won't fix — [reason] | [link] |

### Totals
- **X** findings total
- **N** fixed
- **N** already addressed
- **N** deferred (issues: #47, #48)
- **N** won't fix

### Deferral Budget
- Used: N/2 maximum deferrals
```

---

## Checklist

Before merging any PR:

- [ ] Read all comments from all 3 sources
- [ ] Replied to every comment with one of 4 response types
- [ ] All Critical and Important findings fixed
- [ ] Max 2 deferrals used (each with a linked issue)
- [ ] All fixes committed to PR branch (not main)
- [ ] CI re-ran and passed after fixes
- [ ] Summary comment posted on the PR
