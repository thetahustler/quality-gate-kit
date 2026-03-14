# Phase 3: Post-Deploy Gates

Automated gates that run after merge to main and deployment. These catch production-only failures that local testing and CI cannot detect.

---

## Gate 3.1 — Deploy

| Criteria | Pass | Fail |
|---|---|---|
| All Phase 2 gates green | CI fully passed | Any CI gate failed |
| Deploy target accepts build | Deployment initiated | Deploy rejected |
| Build completes | App starts successfully | Build or startup failure |

### Configuration

Your deploy target should be configured to wait for CI before deploying:

```yaml
# Example: deploy only after CI passes
# GitHub Actions: use "needs" to chain workflows
# Platform-specific: enable "Wait for CI" or equivalent setting
```

---

## Gate 3.2 — Automated Smoke Test

The most critical post-deploy gate. Verifies that the deployed application actually works in production.

### What to Test

| Check | Method | Expected Result |
|---|---|---|
| App is up | `GET /health` or equivalent | 200 OK |
| Self-test passes | Run self-test command | All subsystems operational |
| External services responding | Test connectivity to critical dependencies | All services reachable |
| Critical user flows work | Exercise primary feature paths | Expected responses |

### Resilience

```
Smoke Test Retry Logic:

1. Run all smoke checks
2. If any check fails:
   a. Classify: "app won't start" → immediate rollback (no retry)
   b. Classify: "API timeout" → retry
3. Retry up to 3x with 30-second gaps
4. If still failing after 3 retries → trigger rollback
5. If a specific check fails >3 deploys without code changes → quarantine
```

### Configuration

```yaml
# === CONFIGURATION ===
health_endpoint: "https://your-app.example.com/health"
smoke_test_timeout: 30  # seconds per check
smoke_test_retries: 3
smoke_test_retry_delay: 30  # seconds between retries
# === END CONFIGURATION ===
```

### Example Smoke Test Script

```bash
#!/bin/bash
set -e

APP_URL="${APP_URL:?APP_URL must be set}"
MAX_RETRIES=3
RETRY_DELAY=30

for attempt in $(seq 1 $MAX_RETRIES); do
    echo "Smoke test attempt $attempt/$MAX_RETRIES"

    # Check 1: Health endpoint
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL/health" --max-time 10)
    if [ "$HTTP_CODE" != "200" ]; then
        echo "Health check failed: HTTP $HTTP_CODE"
        if [ "$attempt" -lt "$MAX_RETRIES" ]; then
            sleep $RETRY_DELAY
            continue
        fi
        echo "SMOKE TEST FAILED after $MAX_RETRIES attempts"
        exit 1
    fi

    # Check 2: Critical endpoint responds
    RESPONSE=$(curl -s "$APP_URL/api/status" --max-time 10)
    if [ -z "$RESPONSE" ]; then
        echo "Status endpoint returned empty response"
        if [ "$attempt" -lt "$MAX_RETRIES" ]; then
            sleep $RETRY_DELAY
            continue
        fi
        exit 1
    fi

    echo "All smoke tests passed on attempt $attempt"
    exit 0
done
```

---

## Gate 3.3 — Auto-Rollback

| Criteria | Action |
|---|---|
| Smoke test fails after 3 retries | Rollback to previous deployment |
| "App won't start" failure | Immediate rollback (no retry) |
| Rollback succeeds | Verify previous version is serving |
| Rollback fails | Escalate to human immediately |

### Rollback Methods by Platform

```yaml
# === PLATFORM-SPECIFIC ===
# Railway:   railway rollback (or API call)
# Heroku:    heroku rollback
# AWS ECS:   aws ecs update-service --force-new-deployment (with previous task def)
# Kubernetes: kubectl rollout undo deployment/your-app
# Vercel:    vercel rollback
# === END PLATFORM-SPECIFIC ===
```

---

## Gate 3.4 — Alert and Escalate

### Alert Content

Every smoke test failure notification should include:

```
DEPLOY ALERT: Smoke Test Failed

What failed: [specific check that failed]
Deploy: [commit SHA or deploy ID]
Action taken: [rolled back to previous / retrying]
Environment: [production / staging]
Time: [timestamp]

Investigate: [link to CI logs or deploy dashboard]
```

### Escalation Rules

| Condition | Action |
|---|---|
| First smoke failure | Alert team, investigate |
| Smoke fails 2 consecutive deploys | Block further deploys until investigated |
| Rollback fails | Page on-call, this is an active incident |
| Same check fails >3 deploys (no code changes) | Quarantine check, investigate infrastructure |

### Channel Configuration

```yaml
# === NOTIFICATION CHANNEL ===
# Slack:    Use Slack webhook or GitHub Actions slack-notify
# Teams:    Use Teams webhook
# Email:    Use SendGrid or SES
# Telegram: Use Telegram Bot API
# PagerDuty: Use PagerDuty Events API
alert_channel: "your-notification-method"  # <-- CHANGE THIS
# === END NOTIFICATION CHANNEL ===
```

---

## Gate 3.5 — Metrics Logged

### Per-Deploy Metrics

| Metric | Source | Target |
|---|---|---|
| Coverage % | CI coverage report | Trending up |
| Test count | CI test output | Trending up |
| Test pass rate | CI test output | 100% |
| Deploy duration | Deploy platform | Stable or decreasing |
| Smoke test result | Post-deploy workflow | Pass |

### Per-PR Metrics

| Metric | Source | Target |
|---|---|---|
| Lines changed | `git diff --stat` | <=400 |
| Review findings count | Review comments | Trending down |
| Findings fixed | Review responses | >80% of findings |
| Findings deferred | Review responses | <=2 per PR |
| Coverage delta | Coverage ratchet | >= 0 |

### Storage

Store metrics in a format that supports trend analysis:

```yaml
# === STORAGE OPTIONS ===
# JSON file:  Append to metrics.json in repo (simple)
# Database:   Write to SQLite or Postgres (queryable)
# Dashboard:  Push to Grafana, Datadog, or equivalent
# Spreadsheet: Append to Google Sheets (accessible)
# === END STORAGE OPTIONS ===
```

---

## Post-Deploy Checklist

After every deploy to production:

- [ ] Smoke test passed (all checks green)
- [ ] No rollback triggered
- [ ] Metrics logged (coverage, test count, pass rate)
- [ ] Alert channels verified (can receive notifications)
- [ ] No new error patterns in logs (check first 15 minutes)
