# UAT Checklist

User Acceptance Testing requirements by change type.

---

## Tier Selection

| Change Type | UAT Tier | What to Do |
|---|---|---|
| User-facing (UI, messages, commands, dashboards) | **Tier 2: Full manual UAT** | Test all 4 paths + state-dependent testing |
| API/connector changes | **Tier 2: Full manual UAT** | Test with real API calls or recorded responses |
| Internal refactors with no behavior change | **Tier 3: Skip manual UAT** | Rely on regression tests + post-deploy smoke |
| Any change (regardless of type) | **Tier 1: Automated smoke** | Always runs post-deploy |

---

## Tier 2: Full Manual UAT

### 4 Paths to Verify

#### Path 1: Happy Path
- [ ] Feature works as expected with normal input
- [ ] Output/response is correct and complete
- [ ] Performance is acceptable (no visible lag)
- [ ] UI displays correctly (if applicable)

#### Path 2: Error Path
- [ ] User sees a clear, helpful error message on failure
- [ ] Error message suggests what to do next
- [ ] No crash, blank screen, or cryptic error
- [ ] Error is logged with sufficient context for debugging

#### Path 3: Degraded Path
- [ ] App handles dependency outage gracefully
- [ ] User sees a degraded experience (not a crash)
- [ ] Other features continue working
- [ ] No data corruption during outage

#### Path 4: Recovery Path
- [ ] App recovers automatically when dependency returns
- [ ] No manual restart required
- [ ] Data integrity maintained through outage and recovery
- [ ] User is notified when service is restored (if applicable)

### State-Dependent Testing (if applicable)

- [ ] Tested as different user roles (admin, user, guest)
- [ ] Tested state transitions in sequence (e.g., draft -> pending -> approved)
- [ ] Tested out-of-order operations (what if step 3 is done before step 1?)
- [ ] Tested duplicate/repeated actions (what if the same button is clicked twice?)
- [ ] Tested concurrent access (what if two users modify the same resource?)

### UAT Tool Priority

| Priority | Method | When to Use |
|---|---|---|
| 1 | Browser automation (Playwright, Cypress, Chrome MCP) | Preferred for web UIs |
| 2 | API client (curl, httpx, Postman) | For API endpoints |
| 3 | CLI testing | For command-line tools |
| 4 | Manual human testing | Last resort |

Document which method was used. If #1 is unavailable, fall through to #2, etc.

---

## Tier 1: Automated Smoke (All Changes)

This runs automatically post-deploy. Verify these are configured:

- [ ] Health endpoint responds with 200
- [ ] Critical API endpoints respond
- [ ] External service connectivity verified
- [ ] Critical user flow exercised

---

## UAT Evidence Template

Include this in your PR description:

```markdown
## UAT Results

**Tier**: [1 / 2 / 3]
**Method**: [Browser automation / API client / CLI / Manual]

### Happy Path
- [description of what was tested]
- Result: PASS / FAIL

### Error Path
- [description of error scenario tested]
- Result: PASS / FAIL

### Degraded Path
- [description of outage scenario tested]
- Result: PASS / FAIL

### Recovery Path
- [description of recovery scenario tested]
- Result: PASS / FAIL

### Evidence
[Screenshots, command output, or "Tier 3: internal refactor — relying on regression + smoke"]
```

---

## Change Type Decision Tree

```
Is the change user-facing?
  YES -> Tier 2 (full UAT)
  NO  -> Does it change API behavior?
           YES -> Tier 2 (full UAT)
           NO  -> Does it change external integrations?
                    YES -> Tier 2 (full UAT)
                    NO  -> Tier 3 (skip manual, rely on regression + smoke)

All changes -> Tier 1 (automated smoke, always)
```
