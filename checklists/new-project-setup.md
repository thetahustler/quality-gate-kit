# New Project Setup Guide

Adopt the quality gate process in 5 steps. Estimated time: 30 minutes.

---

## Step 1: Clone the Kit

```bash
git clone https://github.com/thetahustler/quality-gate-kit.git /tmp/quality-gate-kit
```

---

## Step 2: Configure Templates

### 2a. Choose Your Language

Open each template file and uncomment/configure the section for your language:

| File | What to Configure |
|---|---|
| `workflows/test.yml.template` | Test command, coverage tool, language setup |
| `workflows/security.yml.template` | Static analysis tool, dependency audit tool |
| `config/pytest.ini.template` OR `config/jest.config.template` | Coverage floor, test paths |
| `config/pre-commit-config.yml.template` | Language-specific hooks |
| `config/dependabot.yml.template` | Package ecosystem |

### 2b. Set Your Coverage Floor

Check your current coverage:

```bash
# Python
pytest --cov=src --cov-report=term

# Node.js
npx jest --coverage

# Go
go test -cover ./...
```

Set `--cov-fail-under` (or equivalent) to your current coverage percentage. The ratchet will enforce it only goes up.

### 2c. Set Your PR Size Limit

Default is 400 lines. Adjust in `workflows/pr-size.yml.template` if needed.

### 2d. Configure Notifications

In `workflows/post-deploy.yml.template`, set:
- `APP_URL` to your production URL
- Uncomment your notification channel (Slack, Telegram, email)

---

## Step 3: Activate

### 3a. Copy Workflows

```bash
# Create workflows directory if it doesn't exist
mkdir -p .github/workflows

# Copy and rename templates
cp /tmp/quality-gate-kit/workflows/test.yml.template .github/workflows/test.yml
cp /tmp/quality-gate-kit/workflows/security.yml.template .github/workflows/security.yml
cp /tmp/quality-gate-kit/workflows/review.yml.template .github/workflows/review.yml
cp /tmp/quality-gate-kit/workflows/pr-size.yml.template .github/workflows/pr-size.yml
cp /tmp/quality-gate-kit/workflows/post-deploy.yml.template .github/workflows/post-deploy.yml
```

### 3b. Copy PR Template

```bash
mkdir -p .github
cp /tmp/quality-gate-kit/checklists/pr-checklist.md .github/pull_request_template.md
```

### 3c. Copy Config Files

```bash
# Python
cp /tmp/quality-gate-kit/config/pytest.ini.template pytest.ini
cp /tmp/quality-gate-kit/config/pre-commit-config.yml.template .pre-commit-config.yaml

# Node.js
cp /tmp/quality-gate-kit/config/jest.config.template jest.config.js
cp /tmp/quality-gate-kit/config/pre-commit-config.yml.template .pre-commit-config.yaml

# Dependabot (all languages)
mkdir -p .github
cp /tmp/quality-gate-kit/config/dependabot.yml.template .github/dependabot.yml
```

### 3d. Install Pre-commit Hooks

```bash
pip install pre-commit  # or: brew install pre-commit
pre-commit install
```

### 3e. Copy Security Script

```bash
cp /tmp/quality-gate-kit/security/unicode-sanitization-check.sh scripts/
chmod +x scripts/unicode-sanitization-check.sh
```

---

## Step 4: Set Branch Protection

Go to: **Settings > Branches > Branch protection rules > Add rule**

Branch name pattern: `main`

### Team Mode
- [x] Require a pull request before merging
  - [x] Require approvals (1)
- [x] Require status checks to pass before merging
  - Add: `test`, `security`, `review`, `pr-size`
- [x] Require branches to be up to date before merging
- [x] Do not allow bypassing the above settings

### Solo Mode
- [ ] Require a pull request before merging (unchecked — no reviewer needed)
- [x] Require status checks to pass before merging
  - Add: `test`, `security`, `review`, `pr-size`
- [x] Require branches to be up to date before merging
- [x] Do not allow bypassing the above settings

---

## Step 5: First PR

Create a small change to validate the full pipeline:

```bash
# Create feature branch
git checkout -b feat/quality-gate-setup

# Add the files you just configured
git add .github/ pytest.ini .pre-commit-config.yaml  # adjust for your stack

# Commit
git commit -m "chore: adopt quality gate process"

# Push and create PR
git push -u origin feat/quality-gate-setup
gh pr create --title "chore: adopt quality gate process" --body "Initial setup of quality gates."
```

Watch the CI run. All gates should pass. If any fail, fix before merging.

---

## Verification Checklist

After setup, verify:

- [ ] CI workflows run on PR creation
- [ ] Test workflow passes and reports coverage
- [ ] Security workflow passes all 5 layers
- [ ] PR size check reports line count
- [ ] PR template appears when creating new PRs
- [ ] Pre-commit hooks run on `git commit`
- [ ] Branch protection prevents direct push to main
- [ ] Dependabot creates its first PR within a week
