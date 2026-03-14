# Emergency Hotfix Protocol

For production-down situations where the full quality gate process is too slow.

---

## Decision Tree: Is This an Emergency?

```
Is production down?
  NO  -> Use the normal PR process. This is NOT an emergency.
  YES -> Are users actively impacted?
           NO  -> Can it wait 1 hour? If yes, use normal process.
           YES -> PROCEED WITH HOTFIX PROTOCOL
```

**"It would be nice to fix this quickly" is NOT an emergency.** Only use this protocol when production is down AND users are actively impacted.

---

## Hotfix Steps

### Step 1: Fix on a Branch (NEVER Main)

```bash
git checkout -b fix/hotfix-description
```

Even in emergencies, NEVER push directly to main. A branch takes 10 seconds and preserves the safety net.

### Step 2: Write Minimum Viable Test

```bash
# Write ONE test that verifies the fix works
# This can be expanded later, but the fix must have at least one test
```

The test should verify:
- The specific bug is fixed
- The fix doesn't introduce an obvious regression

### Step 3: Push and Run CI

```bash
git push -u origin fix/hotfix-description
gh pr create --title "fix: [HOTFIX] description" --body "Production hotfix. Full review to follow within 24 hours."
```

CI runs: tests + security. Skip AI review for speed.

### Step 4: Merge When CI Green

- For solo devs: merge when CI passes (no human review needed)
- For teams: get one quick approval or merge with solo-dev rules

### Step 5: Post-Deploy Smoke Test (MANDATORY)

The smoke test is even MORE critical for hotfixes because:
- The fix was written under pressure
- Less testing was done
- The risk of introducing new issues is higher

Verify:
- [ ] App is up and responding
- [ ] The specific bug is fixed in production
- [ ] No new errors in logs
- [ ] Critical user flows still working

### Step 6: Within 24 Hours

These are NOT optional. They must be completed within 24 hours:

- [ ] **Full test coverage** -- expand the minimum viable test to full coverage (failure tests, edge cases)
- [ ] **Pre-submit review retroactively** -- have a fresh reviewer check the hotfix code
- [ ] **Root cause analysis** -- document what happened, why, and what the timeline was
- [ ] **Gate gap analysis** -- answer: "What gate SHOULD have prevented this?"

---

## Root Cause Analysis Template

```markdown
## Hotfix Root Cause Analysis

**Date**: YYYY-MM-DD
**Duration**: [time from discovery to fix]
**Impact**: [what users experienced]

### What Happened
[Description of the production failure]

### Root Cause
[Why the failure occurred]

### Fix Applied
[What the hotfix did, commit SHA]

### Why It Wasn't Caught
[Which gates failed and why]

### Gate Gap Analysis
| Gate | Should Have Caught It? | Why It Didn't |
|---|---|---|
| TDD | Yes/No | [explanation] |
| Regression | Yes/No | [explanation] |
| UAT | Yes/No | [explanation] |
| CI Tests | Yes/No | [explanation] |
| Security Scan | Yes/No | [explanation] |
| AI Review | Yes/No | [explanation] |
| Smoke Test | Yes/No | [explanation] |

### Process Improvements
[What changes to the process would prevent this in the future]

### Follow-Up Items
- [ ] Full test coverage for hotfix
- [ ] Retroactive code review
- [ ] Process improvement implemented
```

---

## Hotfix Frequency Monitoring

| Threshold | Status | Action |
|---|---|---|
| 0 hotfixes/month | Ideal | Process is working |
| 1 hotfix/month | Acceptable | Review in retrospective |
| 2 hotfixes/month | Warning | Investigate gaps immediately |
| 3+ hotfixes/month | Critical | Process has systemic gaps. Stop and fix. |

Track hotfix frequency in your quarterly health check. More than 2 per month means the quality gate process has gaps that need to be addressed.

---

## What the Hotfix Protocol Skips

| Normal Gate | Hotfix Gate | Risk Accepted |
|---|---|---|
| Design review | Skipped | Fix might not be optimal |
| Full TDD cycle | Minimum viable test | Less test coverage |
| Pre-submit AI review | Skipped (retroactive within 24h) | Code quality may be lower |
| PR size check | Skipped | Fix may exceed line limit |
| Full UAT | Focused on fix only | Other paths not tested |

Everything else still runs:
- CI tests (must pass)
- Security scan (must pass)
- Post-deploy smoke test (mandatory)
- Branch-based workflow (never push to main)

---

## Checklist

Before using this protocol:

- [ ] Production is actually down
- [ ] Users are actively impacted
- [ ] The normal process would take too long

During the hotfix:

- [ ] Working on a branch (not main)
- [ ] At least one test for the fix
- [ ] CI tests pass
- [ ] Security scan passes
- [ ] PR created (even if merged quickly)

After the hotfix:

- [ ] Smoke test passed in production
- [ ] Bug is confirmed fixed
- [ ] No new errors introduced

Within 24 hours:

- [ ] Full test coverage added
- [ ] Retroactive code review completed
- [ ] Root cause analysis documented
- [ ] Gate gap analysis completed
- [ ] Process improvements identified
