# Quality Gate Kit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A diamond-grade CI/CD quality gate process for AI-assisted development. Battle-tested against real production incidents, validated against 44 industry best practices, and designed to prevent broken code from ever reaching production.

## Key Stats

- **15 layers of defense** — independent and complementary gates across 3 phases
- **38 gaps identified and closed** — through 22 adversarial pressure test scenarios
- **44 best practices covered** — from 2026 industry standards, Anthropic guidelines, agentic development, and AI security research
- **21 anti-patterns codified** — 15 code patterns + 6 process patterns with detection and fixes

## Why This Exists

AI-assisted development is fast but fragile. Industry data shows:
- 45% of AI-generated code contains security flaws
- 60% of AI code faults are silent logic failures — tests pass but code is wrong
- AI tests its own assumptions (circular validation, not intent verification)
- No single guardrail is sufficient — layered controls are required

This kit provides the layered defense system that makes AI-assisted development production-safe.

## Quick Start (5 Steps)

### 1. Clone

```bash
git clone https://github.com/thetahustler/quality-gate-kit.git
cd quality-gate-kit
```

### 2. Configure

Edit template files in `workflows/`, `config/`, and `checklists/` — replace language-specific markers with your stack:

```yaml
# === LANGUAGE-SPECIFIC SECTION ===
# Python:  pytest --cov=src --cov-fail-under=90
# Node.js: npx jest --coverage --coverageThreshold='{"global":{"lines":90}}'
# Go:      go test -coverprofile=coverage.out ./...
# Rust:    cargo tarpaulin --fail-under 90
test_command: "pytest --cov=src --cov-fail-under=90"  # <-- CHANGE THIS
# === END LANGUAGE-SPECIFIC ===
```

### 3. Activate

```bash
# Copy workflows to your project
cp workflows/*.yml.template your-project/.github/workflows/
# Rename .template files to .yml

# Copy PR template
cp checklists/pr-checklist.md your-project/.github/pull_request_template.md

# Copy pre-commit config
cp config/pre-commit-config.yml.template your-project/.pre-commit-config.yaml
```

### 4. Protect Your Branch

Enable branch protection on `main`:
- Require status checks to pass (test, security, review)
- Require PR reviews (team mode) or just status checks (solo mode)
- No direct pushes to main

### 5. First PR

Run through the full process once with a small change to validate everything works. Follow the checklist in `checklists/new-project-setup.md`.

## Repository Structure

```
quality-gate-kit/
|-- README.md                          This file
|-- LICENSE                            MIT License
|-- process.md                         Full process doc (project-agnostic)
|-- anti-slop/
|   |-- code-anti-patterns.md          15 code anti-patterns with examples
|   |-- process-anti-patterns.md       6 process anti-patterns
|   `-- review-prompt-template.md      Drop-in AI review prompt
|-- gates/
|   |-- pre-submit-checklist.md        Phase 1: local gates
|   |-- ci-gates.md                    Phase 2: CI pipeline gates
|   |-- post-deploy-gates.md           Phase 3: post-merge gates
|   `-- review-response-protocol.md    How to respond to review findings
|-- security/
|   |-- adversarial-input-patterns.md  Attack vector test fixtures
|   |-- actions-audit-checklist.md     Quarterly GitHub Actions review
|   |-- mcp-safety-guidelines.md       Safe MCP usage for AI agents
|   `-- unicode-sanitization-check.sh  PR content sanitization script
|-- workflows/
|   |-- test.yml.template              Test + coverage ratchet
|   |-- security.yml.template          Security scanning
|   |-- review.yml.template            AI code review
|   |-- pr-size.yml.template           PR size check
|   `-- post-deploy.yml.template       Post-deploy smoke test
|-- config/
|   |-- pytest.ini.template            Python test config
|   |-- jest.config.template           Node.js test config
|   |-- pre-commit-config.yml.template Pre-commit hooks
|   `-- dependabot.yml.template        Dependency automation
`-- checklists/
    |-- pr-checklist.md                PR template (copy to .github/)
    |-- new-project-setup.md           5-step adoption guide
    |-- developer-onboarding.md        10-minute new dev guide
    |-- uat-checklist.md               UAT by change type
    |-- quarterly-health-check.md      Process retrospective template
    `-- emergency-hotfix.md            Hotfix protocol
```

## Documentation

Full documentation is available in the [wiki](https://github.com/thetahustler/quality-gate-kit/wiki):

- [Process Overview](https://github.com/thetahustler/quality-gate-kit/wiki/Process-Overview) — 3-phase pipeline diagram
- [Phase 1: Pre-Submit](https://github.com/thetahustler/quality-gate-kit/wiki/Phase-1-Pre-Submit) — Local gates
- [Phase 2: CI Gates](https://github.com/thetahustler/quality-gate-kit/wiki/Phase-2-CI-Gates) — Pipeline configuration
- [Phase 3: Post-Deploy](https://github.com/thetahustler/quality-gate-kit/wiki/Phase-3-Post-Deploy) — Smoke tests and rollback
- [Anti-AI Slop](https://github.com/thetahustler/quality-gate-kit/wiki/Anti-AI-Slop) — All 21 anti-patterns
- [Security](https://github.com/thetahustler/quality-gate-kit/wiki/Security) — Hardening guidelines
- [Adoption Guide](https://github.com/thetahustler/quality-gate-kit/wiki/Adoption-Guide) — Step-by-step setup
- [FAQ](https://github.com/thetahustler/quality-gate-kit/wiki/FAQ) — Common questions

## Team Mode vs Solo Mode

| Feature | Team Mode | Solo Mode |
|---|---|---|
| Human review required | Yes | No (AI reviews sufficient) |
| Branch protection: require reviewer | Yes | No |
| Branch protection: require status checks | Yes | Yes |
| AI code review (superpowers) | Required | Required |
| AI code review (CI) | Required | Required |
| UAT | Required | Required |

## Research Foundation

This process is validated against four research areas:

| Research Area | Practices | Covered | Score |
|---|---|---|---|
| 2026 Industry Best Practices | 14 | 14 | 100% |
| Anthropic / Claude Best Practices | 10 | 10 | 100% |
| Agentic Development Best Practices | 8 | 8 | 100% |
| 2026 AI Security Research | 12 | 12 | 100% |
| **Total** | **44** | **44** | **100%** |

## License

MIT License. See [LICENSE](LICENSE) for details.

Copyright (c) 2026 JP3 Investment Manager, LLC
