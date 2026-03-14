<!-- PR Template — Copy to .github/pull_request_template.md -->

## Scope

<!-- One sentence: what this PR does and nothing else -->

## Test Plan

<!-- What was tested, how, and results -->

- [ ] Tests written FIRST (TDD)
- [ ] All new functions have >=1 failure test + >=1 edge case test
- [ ] Mocks include failure scenarios (timeout, 4xx, 5xx, empty)
- [ ] Full test suite passing locally (output shown, not described)
- [ ] Coverage maintained or increased

## UAT

<!-- Tier 1: automated smoke | Tier 2: full manual | Tier 3: internal refactor (skip) -->

- UAT Tier: <!-- 1 / 2 / 3 -->
- [ ] Happy path verified
- [ ] Error path verified
- [ ] Degraded path verified (dependency down)
- [ ] Recovery path verified (dependency returns)

## Pre-Submit Review

- [ ] Fresh reviewer (not the author) reviewed changes
- [ ] All Critical findings: fixed
- [ ] All Important findings: fixed
- [ ] Minor findings: fixed or documented

## Anti-Slop Checklist

- [ ] No copy-paste duplication across files
- [ ] No pass-through wrapper functions
- [ ] No file exceeds 400 lines
- [ ] No happy-path-only tests
- [ ] No success-only mocks
- [ ] No bare except blocks
- [ ] No TODO/placeholder for critical features
- [ ] No existing tests weakened or deleted
- [ ] No reinvented standard library functions
- [ ] No hallucinated imports or APIs
- [ ] No unsanitized user input
- [ ] Adversarial input tests for external-facing functions

## Security

- [ ] No hardcoded secrets, tokens, or credentials
- [ ] User input sanitized (SQL, paths, URLs, commands)
- [ ] New dependencies pinned to specific versions
- [ ] Error messages don't expose internals

## PR Hygiene

- [ ] Feature branch (not main)
- [ ] Single concern (no mixed feature + refactor)
- [ ] PR <= 400 lines changed (or justified with `size-override:`)
- [ ] All changed files serve the stated scope

## Agent Action Log

<!-- Files changed, commands run, decisions made -->

```
<!-- paste agent action summary here -->
```
