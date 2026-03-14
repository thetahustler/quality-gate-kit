# Phase 1: Pre-Submit Checklist

All gates run locally before creating a PR. This is the fastest feedback loop and the first line of defense.

---

## Gate 1.1 — Plan/Design Review

| Criteria | Pass | Fail |
|---|---|---|
| Requirements clarified and documented | Design doc exists | No design doc for non-trivial change |
| Stakeholder approval obtained | Explicit approval in writing | Approval assumed or skipped |
| 2-3 approaches considered | Alternatives documented | Single approach without justification |

**Skip condition:** Pure config/typo fixes with no behavior change.

**Output:** Approved design doc in your project's docs directory.

---

## Gate 1.2 — TDD Cycle

| Criteria | Pass | Fail |
|---|---|---|
| Tests written BEFORE implementation | Test file timestamps precede source | Tests written after or alongside code |
| Every new function has >=1 failure test | Failure scenarios tested | Only happy path tested |
| Every new function has >=1 edge case test | Edge cases covered | No edge case tests |
| Mocks include failure scenarios | Timeout, 4xx, 5xx, empty response tested | Mocks only return success |
| Tests capture intent, not implementation | Tests describe WHAT, not HOW | Tests mirror implementation details |
| Tests run green locally | All tests pass with output shown | Any test failure |

**This gate is MANDATORY. No exceptions.**

Why: 60% of AI code faults are silent logic failures. TDD is the primary defense -- tests written before code capture human intent, breaking the circular validation cycle.

---

## Gate 1.2b — Verification Gate

| Criteria | Pass | Fail |
|---|---|---|
| Test command actually executed | Terminal/bash output shown | "I believe tests pass" with no output |
| Output is from real execution | Output includes timing, test counts, coverage | Generic or summarized output |

**Rule:** The command MUST be run and its output shown. Prose descriptions of test results are not valid verification.

---

## Gate 1.2c — Local Security Pre-Check

| Criteria | Pass | Fail |
|---|---|---|
| Secret scan passes locally | `detect-secrets scan` clean | High-entropy strings or secrets detected |
| Static analysis passes | `bandit -r src/ -ll` clean | SQL injection, unsafe deserialization, or exec flagged |
| Gitignore complete | `*token*`, `*.env`, `*secret*`, `*credential*` patterns present | Missing patterns for sensitive file types |

**Why this gate exists:** Security scanners run in CI anyway. Running locally gives instant feedback instead of a multi-minute CI round-trip. In real-world usage, 3 CI failures (hardcoded Drive IDs, f-string SQL, missing gitignore glob) were all detectable locally before the PR was created.

**Automation:** Add `detect-secrets` and `bandit` as pre-commit hooks. See `config/pre-commit-config.yml.template`.

---

## Gate 1.3 — Risk-Based Regression

| Criteria | Pass | Fail |
|---|---|---|
| Changed files identified | List of modified files | Unknown what changed |
| Affected test modules mapped | Import graph analyzed | Random test selection |
| Targeted regression run | Affected tests pass | Affected tests not run |
| Full test suite run | All tests pass | Any failure in full suite |
| Coverage >= current floor | Coverage maintained or increased | Coverage decreased |

---

## Gate 1.3b — Hallucination Check

| Criteria | Pass | Fail |
|---|---|---|
| All imports resolve | `import module` succeeds for all changed modules | ImportError on any module |
| Test discovery succeeds | `--collect-only` (or equivalent) finds all tests | Discovery errors or missing tests |
| No phantom references | All functions referenced in tests exist in source | Tests reference non-existent functions |

---

## Gate 1.4 — UAT (Tiered)

**Select the appropriate tier:**

| Change Type | Required Tier |
|---|---|
| User-facing (UI, messages, commands) | Tier 2: Full manual UAT |
| API/connector changes | Tier 2: Full manual UAT |
| Internal refactors, no behavior change | Tier 3: Skip manual UAT |
| Any change | Tier 1: Automated smoke (always) |

**For Tier 2 UAT, verify all 4 paths:**

| Path | Criteria | Pass | Fail |
|---|---|---|---|
| Happy path | Feature works as expected | Correct behavior | Unexpected behavior |
| Error path | User sees helpful message on failure | Clear error message | Crash, blank screen, or cryptic error |
| Degraded path | App handles dependency outage | Graceful degradation | Hard failure |
| Recovery path | App recovers when dependency returns | Automatic recovery | Requires restart |

**State-dependent testing (if applicable):**
- [ ] Tested as different user roles
- [ ] Tested state transitions in sequence
- [ ] Tested out-of-order operations
- [ ] Tested duplicate/repeated actions

---

## Gate 1.5 — Pre-Submit Code Review

| Criteria | Pass | Fail |
|---|---|---|
| Fresh reviewer (not the author) | Separate agent or person | Self-review only |
| All 15 code anti-patterns checked | Review prompt includes anti-slop checklist | Partial or no anti-slop check |
| Security lens applied | Input validation, secrets, injection reviewed | Security not considered |
| Critical findings fixed | Zero open Critical findings | Any Critical finding unresolved |
| Important findings fixed | Zero open Important findings | Any Important finding unresolved |
| Minor findings addressed | Fixed or documented | Ignored without explanation |

---

## Gate 1.6 — Create PR

| Criteria | Pass | Fail |
|---|---|---|
| Feature branch used | Branch name: `feat/`, `fix/`, `chore/`, etc. | Changes on main |
| PR <= 400 lines changed | `git diff --stat` within limit | Over limit without justification |
| Single concern per PR | All changes serve one purpose | Mixed feature + refactor + bugfix |
| Scope statement present | One sentence in PR description | No scope statement |
| Test plan documented | What was tested, how | No test plan |
| Review results included | Findings and fixes listed | No review evidence |
| UAT evidence included | Screenshots, output, or "Tier 3" | No UAT evidence |
| PR template checkboxes checked | All boxes checked | Unchecked boxes |

---

## Gate 1.7 — Review Response Protocol

| Criteria | Pass | Fail |
|---|---|---|
| All review comments read | All 3 comment sources checked | Missed comment source |
| Every comment has a reply | N comments = N replies | Any comment without reply |
| Max 2 deferrals | <=2 deferred findings | 3+ deferred findings |
| Fixes go through branch | Fix committed to PR branch | Fix pushed to main |
| Summary comment posted | Review Response Summary before merge | No summary |

---

## Quick Reference: What "Done" Means

A change is NOT ready to submit until:

- [ ] Design reviewed (or skip condition met)
- [ ] Tests written first, all passing
- [ ] Verification output shown (not described)
- [ ] Hallucination check passed
- [ ] Full regression green
- [ ] UAT completed (at appropriate tier)
- [ ] Pre-submit review completed, all findings addressed
- [ ] PR created with complete description
- [ ] Review comments responded to
