# Quarterly Health Check

Process retrospective template. Run every quarter to detect process decay and improve the quality gate system.

---

## Meeting Setup

- **Frequency**: Quarterly
- **Duration**: 60 minutes
- **Attendees**: All developers + project lead
- **Preparation**: Gather metrics for the quarter before the meeting

---

## Part 1: Metrics Review (15 min)

### Coverage Trend

| Month | Coverage % | Test Count | Delta |
|---|---|---|---|
| Month 1 | ___ | ___ | ___ |
| Month 2 | ___ | ___ | ___ |
| Month 3 | ___ | ___ | ___ |

- [ ] Coverage trending up or stable?
- [ ] Test count growing with codebase?

### PR Metrics

| Metric | Average This Quarter | Previous Quarter | Trend |
|---|---|---|---|
| PR size (lines) | ___ | ___ | ___ |
| Review findings per PR | ___ | ___ | ___ |
| Findings fixed (%) | ___ | ___ | ___ |
| Findings deferred (%) | ___ | ___ | ___ |
| PRs merged without review | ___ | ___ | ___ |

- [ ] PR sizes staying under limit?
- [ ] Deferral ratio under 30%?

### Deployment Health

| Metric | This Quarter | Previous Quarter | Trend |
|---|---|---|---|
| Total deploys | ___ | ___ | ___ |
| Smoke test failures | ___ | ___ | ___ |
| Rollbacks | ___ | ___ | ___ |
| Hotfixes | ___ | ___ | ___ |
| Mean time to recover | ___ | ___ | ___ |

- [ ] Hotfixes <= 2 per month?
- [ ] Smoke test failure rate decreasing?

---

## Part 2: What Saved Us (15 min)

List concrete examples where a gate caught a real issue this quarter.

| Gate | What It Caught | Impact Prevented |
|---|---|---|
| ___ | ___ | ___ |
| ___ | ___ | ___ |
| ___ | ___ | ___ |

These examples justify the process cost. If no gate saved us, either the code quality is excellent or the gates aren't catching real issues.

---

## Part 3: What Slowed Us (10 min)

List gates or process steps that caused friction without proportional value.

| Gate/Step | Friction | Suggestion |
|---|---|---|
| ___ | ___ | ___ |
| ___ | ___ | ___ |

For each item, decide:
- **Keep**: The friction is worth it for the protection
- **Automate**: The gate is valuable but could be less manual
- **Simplify**: The gate is too complex for the value
- **Remove**: The gate adds no value (rare -- be careful)

---

## Part 4: New Failure Modes (10 min)

Were there any incidents or near-misses that the current gates would NOT have caught?

| Incident | What Happened | Proposed New Gate/Check |
|---|---|---|
| ___ | ___ | ___ |
| ___ | ___ | ___ |

---

## Part 5: Process Decay Check (10 min)

Signs the process is eroding. Check for each:

- [ ] PRs without UAT evidence -- increasing?
- [ ] Review comments going unanswered -- happening?
- [ ] Hotfix frequency -- increasing?
- [ ] Coverage trend -- flattening or declining?
- [ ] Deferral ratio -- increasing?
- [ ] Direct pushes to main -- any?
- [ ] Tests being weakened to pass -- any?
- [ ] Pre-commit hooks being skipped -- happening?

If 3+ items are checked, the process needs immediate attention.

---

## Part 6: GitHub Actions Audit (quarterly)

Complete the audit checklist from `security/actions-audit-checklist.md`:

- [ ] All third-party actions inventoried
- [ ] All actions pinned to SHA (not tags)
- [ ] Checked for known compromised actions
- [ ] Removed unused actions
- [ ] Reviewed workflow permissions (least privilege)
- [ ] Secrets rotated (if >90 days old)

---

## Part 7: Deferred Issue Sweep

Review all open issues labeled `deferred-from-review`:

| Issue | Age | Action |
|---|---|---|
| #___ | ___ days | Fix / Close / Extend |
| #___ | ___ days | Fix / Close / Extend |

- Issues >30 days: escalate or close with justification
- Deferral ratio: ___ / ___ = ___% (target: <30%)

---

## Action Items

| # | Action | Owner | Due Date |
|---|---|---|---|
| 1 | ___ | ___ | ___ |
| 2 | ___ | ___ | ___ |
| 3 | ___ | ___ | ___ |

---

## Next Health Check

- **Date**: ___
- **Owner**: ___
