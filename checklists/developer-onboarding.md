# Developer Onboarding Guide

Get up to speed with the quality gate process in 10 minutes.

---

## What Is This?

A 3-phase quality gate process that prevents broken code from reaching production. Every change goes through 15 layers of defense before it ships.

```
PHASE 1: PRE-SUBMIT (you do this locally)
    |
    v
PHASE 2: CI GATES (automated, runs on every PR)
    |
    v
PHASE 3: POST-MERGE (automated, runs after deploy)
```

---

## The 5-Minute Version

### Before You Code

1. **Plan** -- for non-trivial changes, write a brief design doc
2. **Write tests FIRST** -- this is mandatory, not optional (TDD)

### While You Code

3. **Run tests often** -- verify locally before pushing
4. **Keep it small** -- PRs under 400 lines, one concern per PR
5. **Handle errors** -- every external call needs timeout, retry, graceful degradation

### Before You Submit

6. **Run the full test suite** -- show actual output, don't just say "tests pass"
7. **Get a review** -- use a fresh AI agent or colleague to review your changes
8. **Create a PR** -- use the template, fill in ALL sections

### After You Submit

9. **Watch CI** -- all gates must pass
10. **Respond to reviews** -- every comment gets a reply (see response types below)

---

## Review Response Quick Reference

When you get review comments, reply with one of these:

| Response | When | Example |
|---|---|---|
| **Fixed** | Valid finding, you fixed it | `Fixed in abc1234 -- added timeout` |
| **Already addressed** | Already handled elsewhere | `Already addressed -- see middleware at line 42` |
| **Deferred** | Valid but out of scope | `Deferred to issue #47 -- separate concern` |
| **Won't fix** | Disagree with evidence | `Won't fix -- code is correct because [evidence]` |

Rules:
- Every comment gets a reply (no silent ignoring)
- Max 2 deferrals per PR
- Post a summary comment before merging

---

## Anti-Patterns to Avoid

### Code (Top 5 to Watch)

1. **Happy-path-only tests** -- always include failure and edge case tests
2. **Bare except blocks** -- always log errors with context
3. **Copy-paste between files** -- extract to shared utilities
4. **Unsanitized user input** -- never pass external input directly to SQL, paths, or commands
5. **Success-only mocks** -- always mock failure scenarios too

### Process (Top 3 to Watch)

1. **Claiming "tests pass" without output** -- show the terminal output
2. **Pushing directly to main** -- always use feature branches and PRs
3. **Merging without reading reviews** -- read and respond to every comment

---

## Common Commands

```bash
# Run tests locally
pytest tests/ -v                         # Python
npx jest                                 # Node.js
go test ./...                            # Go
cargo test                               # Rust

# Run tests with coverage
pytest --cov=src --cov-report=term -v    # Python
npx jest --coverage                      # Node.js
go test -cover ./...                     # Go
cargo tarpaulin                          # Rust

# Create a feature branch
git checkout -b feat/my-feature

# Create a PR
gh pr create --title "feat: my feature" --body "Description here"

# Check PR status
gh pr status

# View review comments
gh pr view <PR_NUMBER> --comments
```

---

## Branch Naming

| Prefix | When |
|---|---|
| `feat/` | New feature or capability |
| `fix/` | Bug fix |
| `chore/` | Maintenance, config, dependencies |
| `test/` | Test additions or improvements |
| `docs/` | Documentation only |

---

## Emergency Hotfix

Production is down? Follow this protocol:

1. Fix on a branch (NEVER main -- even in emergencies)
2. Write a minimum viable test
3. Push -- CI runs tests + security (skip AI review for speed)
4. Merge when CI is green
5. Post-deploy smoke test is MANDATORY
6. Within 24 hours: full test coverage, retroactive review, root cause analysis

Max 2 hotfixes per month. More means the process has gaps.

---

## Where to Find Things

| What | Where |
|---|---|
| Full process doc | `process.md` |
| Anti-pattern reference | `anti-slop/` |
| Gate details | `gates/` |
| Security guidelines | `security/` |
| Workflow templates | `workflows/` |
| Config templates | `config/` |
| All checklists | `checklists/` |
| Detailed wiki | [Wiki](https://github.com/thetahustler/quality-gate-kit/wiki) |

---

## Questions?

Check the [FAQ](https://github.com/thetahustler/quality-gate-kit/wiki/FAQ) in the wiki, or open an issue on the repo.
