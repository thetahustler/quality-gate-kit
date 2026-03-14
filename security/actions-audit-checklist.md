# GitHub Actions Audit Checklist

Run this audit quarterly to maintain supply chain security for your CI/CD pipeline.

---

## Quarterly Audit Steps

### Step 1: Inventory All Actions in Use

```bash
# List all third-party actions used across all workflows
grep -rh "uses:" .github/workflows/ | grep -v "#" | sort -u
```

Review the output. For each action:

- [ ] Is it still needed? Remove unused actions.
- [ ] Is it from a trusted source? (GitHub official, well-known org, verified publisher)
- [ ] Has the action been compromised since last audit? Check security advisories.

### Step 2: Verify All Actions Are Pinned to SHA

```bash
# Find actions NOT pinned to SHA (using tags like @v4 instead of @sha)
grep -rn "uses:" .github/workflows/ | grep -v "@[a-f0-9]\{40\}" | grep -v "#"
```

**Every line in the output is a security risk.** Actions pinned to tags can be silently replaced by a compromised maintainer.

Fix each one:

```yaml
# BAD: tag can be moved to point to malicious code
- uses: actions/checkout@v4

# GOOD: SHA is immutable
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
```

To find the SHA for a tag:

```bash
# Get the commit SHA for a specific tag
git ls-remote https://github.com/actions/checkout refs/tags/v4.1.1
```

### Step 3: Check for Known Compromised Actions

Review the following resources for recently compromised actions:

- GitHub Security Advisories: https://github.com/advisories
- OpenSSF Scorecard: https://securityscorecards.dev/
- StepSecurity action-monitor: check for known-bad action versions

Known incidents to verify against:
- tj-actions/changed-files (compromised March 2025)
- reviewdog actions (supply chain attack vector)
- Any action that requests `contents: write` or `pull-requests: write` permissions

### Step 4: Review Workflow Permissions

```bash
# Find workflows with broad permissions
grep -rn "permissions:" .github/workflows/
```

For each workflow:

- [ ] Uses minimum necessary permissions (principle of least privilege)
- [ ] Does NOT use `permissions: write-all`
- [ ] Does NOT use `contents: write` unless actually writing to the repo
- [ ] `GITHUB_TOKEN` permissions are scoped, not default

### Step 5: Review Secrets Usage

```bash
# Find all secrets referenced in workflows
grep -rn "secrets\." .github/workflows/
```

For each secret:

- [ ] Is it still needed?
- [ ] Has it been rotated in the last 90 days?
- [ ] Is it scoped to the minimum necessary repositories?
- [ ] Is there a process to rotate it if compromised?

### Step 6: Review Self-Hosted Runners (if applicable)

- [ ] Runners are ephemeral (fresh environment per job)
- [ ] Runners are not shared across untrusted repositories
- [ ] Runner images are updated and patched
- [ ] No sensitive data persists on runner between jobs

---

## Audit Record Template

```markdown
## GitHub Actions Audit — [Quarter] [Year]

**Date**: YYYY-MM-DD
**Auditor**: [name]

### Summary
- Total actions in use: X
- Actions pinned to SHA: X/X
- Actions removed: X (list)
- Actions updated: X (list)
- Compromised actions found: X (list)
- Permissions issues found: X (list)
- Secrets rotated: X

### Findings

| # | Finding | Severity | Action Taken |
|---|---|---|---|
| 1 | [description] | High/Medium/Low | [what was done] |

### Next Audit
- Scheduled: [date]
- Owner: [name]
```

---

## Automation Suggestions

### Pin Actions Automatically

Use `pin-github-action` to automatically pin actions to SHA:

```bash
npx pin-github-action .github/workflows/*.yml
```

### Scorecard Check

Run OpenSSF Scorecard against your repo:

```bash
scorecard --repo=github.com/your-org/your-repo
```

### Dependabot for Actions

Add to your `dependabot.yml`:

```yaml
- package-ecosystem: "github-actions"
  directory: "/"
  schedule:
    interval: "weekly"
```

This auto-PRs when action versions have security updates.
