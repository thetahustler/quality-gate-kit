# Phase 2: CI Gates

All gates run in GitHub Actions (or equivalent CI system) on every PR. All must pass before merge is allowed. These are independent of the developer and cannot be fabricated.

---

## Gate 2.1 — Test Suite (Tiered)

| Tier | Trigger | What Runs | Time Target |
|---|---|---|---|
| Fast | Every push | Unit tests only | <5 min |
| Full | Every PR | Unit + integration tests | <15 min |
| Complete | Before merge to main | Unit + integration + slow tests | <30 min |

### Configuration

```yaml
# === LANGUAGE-SPECIFIC SECTION ===
# Python:  pytest tests/ -v --timeout=300
# Node.js: npx jest --ci --forceExit
# Go:      go test ./... -timeout 5m
# Rust:    cargo test --release
test_command: "pytest tests/ -v --timeout=300"  # <-- CHANGE THIS
# === END LANGUAGE-SPECIFIC ===
```

### Pass/Fail Criteria

| Criteria | Pass | Fail |
|---|---|---|
| All tests pass | Exit code 0, 100% pass rate | Any test failure |
| No new flaky tests | Consistent results across runs | Test passes sometimes, fails sometimes |
| Test execution completes | Within time target | Timeout exceeded |

---

## Gate 2.1b — Integration Tests

Integration tests hit real APIs (with test credentials) or use recorded responses (VCR cassettes). They catch "mocks don't match reality" failures.

| Criteria | Pass | Fail |
|---|---|---|
| Integration tests pass | All integration tests green | Any integration test failure |
| API contracts valid | Responses match expected schemas | Schema mismatch |
| Recorded responses current | VCR cassettes updated within 30 days | Stale cassettes |

---

## Gate 2.2 — Coverage Ratchet

The coverage floor only goes up. Every PR must maintain or increase coverage.

### Mechanism

1. Checkout `main`, run coverage -> get current floor
2. Checkout PR branch, run coverage -> compare to main's floor
3. PR coverage must be >= main coverage

### Configuration

```yaml
# === LANGUAGE-SPECIFIC SECTION ===
# Python:
#   pip install pytest-cov
#   pytest --cov=src --cov-report=json
#   Compare coverage-main.json vs coverage-pr.json
#
# Node.js:
#   npx jest --coverage --coverageReporters=json-summary
#   Compare coverage-summary.json files
#
# Go:
#   go test -coverprofile=coverage.out ./...
#   go tool cover -func=coverage.out | tail -1
#
# Rust:
#   cargo tarpaulin --out json
#   Compare tarpaulin-report.json files
# === END LANGUAGE-SPECIFIC ===
```

### Dead Code Removal Override

When removing dead code (net lines deleted > lines added), coverage may decrease. This is allowed ONLY when:

1. Net line delta is negative (more deletions than additions)
2. A comment explains why coverage decreased
3. CI verifies the net line count actually decreased

### Pass/Fail Criteria

| Criteria | Pass | Fail |
|---|---|---|
| PR coverage >= main coverage | Coverage maintained or increased | Coverage decreased |
| Or: dead code removal override | Net lines negative + explanation | Coverage decreased without justification |

---

## Gate 2.3 — Security Scan

Five layers of security scanning, all must pass.

### Layer 1: Secret Detection

```yaml
# === LANGUAGE-SPECIFIC SECTION ===
# Python:  detect-secrets scan --all-files --exclude-files '\.git/.*'
# Node.js: detect-secrets scan --all-files --exclude-files 'node_modules/.*'
# Go:      detect-secrets scan --all-files --exclude-files 'vendor/.*'
# Any:     trufflehog filesystem . --no-update
# === END LANGUAGE-SPECIFIC ===
```

### Layer 2: Static Analysis

```yaml
# === LANGUAGE-SPECIFIC SECTION ===
# Python:  bandit -r src/ -ll (MEDIUM and above block)
# Node.js: npx eslint --plugin security src/
# Go:      gosec ./...
# Rust:    cargo audit
# === END LANGUAGE-SPECIFIC ===
```

### Layer 3: Dependency Audit

```yaml
# === LANGUAGE-SPECIFIC SECTION ===
# Python:  pip-audit --strict
# Node.js: npm audit --audit-level=moderate
# Go:      govulncheck ./...
# Rust:    cargo audit
# === END LANGUAGE-SPECIFIC ===
```

### Layer 4: Advanced SAST

```yaml
# All languages: semgrep scan --config=auto --error
```

### Layer 5: Config Integrity

```bash
# Verify no secrets files are tracked
git ls-files | grep -E '\.env$|credentials|\.key$|\.pem$' && exit 1 || true

# Verify .gitignore includes common secret patterns
grep -q '\.env' .gitignore || echo "WARNING: .env not in .gitignore"
```

### Pass/Fail Criteria

| Criteria | Pass | Fail |
|---|---|---|
| No hardcoded secrets | Zero secret detections | Any secret found |
| No security vulnerabilities | Zero MEDIUM+ findings | Any MEDIUM+ finding |
| No vulnerable dependencies | Zero known vulnerabilities | Any known vulnerability |
| No SAST findings | Zero semgrep errors | Any semgrep error |
| Config files clean | No secrets files tracked | Secrets files in git |

---

## Gate 2.4 — AI Code Review

An AI agent reviews the PR diff with a security and anti-slop focus.

### Configuration

Use the review prompt from `anti-slop/review-prompt-template.md` as the base prompt.

### Pass/Fail Criteria

| Criteria | Pass | Fail |
|---|---|---|
| Review completed | Review body present | No review output |
| No Critical findings | Zero Critical severity | Any Critical finding |
| No unaddressed Important findings | All Important fixed or responded to | Unaddressed Important findings |

---

## Gate 2.4b — Review Content Validation

Prevents silently passing reviews (the review runs but produces no substance).

| Criteria | Pass | Fail |
|---|---|---|
| Review body > 100 characters | Substantive review content | Empty or trivial review |
| Review references specific files | File names mentioned | Generic review with no file references |
| Review includes findings or explicit approval | Clear assessment | Ambiguous or empty |

---

## Gate 2.5 — PR Size Check

| Criteria | Pass | Fail |
|---|---|---|
| Lines changed <= threshold (default: 400) | Within limit | Over limit |
| Or: override with justification | Comment explains why (migration, schema, generated code) | Over limit without justification |

### Configuration

```yaml
pr_size_limit: 400  # <-- CHANGE THIS (lines added + deleted)
```

---

## Gate 2.6 — Flaky Test Detection

| Criteria | Pass | Fail |
|---|---|---|
| No new flaky tests | Tests consistent across runs | Test fails >2x in 10 runs without code changes |
| Flaky tests quarantined | Known flaky tests tracked | Flaky tests in main suite |

---

## Gate 2.7 — Dependency Freshness

| Criteria | Pass | Fail |
|---|---|---|
| No known security vulnerabilities | All dependencies clean | Vulnerable dependency |
| Dependencies reasonably current | No dependencies >1 major version behind | Critical dependency severely outdated |

---

## Gate 2.8 — PR Content Sanitization

| Criteria | Pass | Fail |
|---|---|---|
| No zero-width characters | Clean PR title, body, comments | Zero-width chars detected |
| No Unicode homoglyphs in code | Variable names use standard ASCII | Homoglyphs in identifiers |
| Non-ASCII flagged | Only in string literals/comments | Non-ASCII in code logic |

See `security/unicode-sanitization-check.sh` for the detection script.

---

## Branch Protection Settings

### Team Mode

- [x] Require pull request reviews before merging (1+ reviewer)
- [x] Require status checks to pass before merging
- [x] Require branches to be up to date before merging
- [x] Restrict who can push to matching branches
- [x] Do not allow bypassing the above settings

### Solo Mode

- [ ] Require pull request reviews (not required for solo devs)
- [x] Require status checks to pass before merging
- [x] Require branches to be up to date before merging
- [x] Restrict who can push to matching branches
- [x] Do not allow bypassing the above settings

Required status checks (both modes):
- `test` (Gate 2.1)
- `security` (Gate 2.3)
- `review` (Gate 2.4)
- `pr-size` (Gate 2.5)
