---
name: endor-help
description: Discover Endor Labs commands, get usage examples, and troubleshoot issues
---

# Endor Labs: Help & Discovery

Help users discover available commands, understand when to use each one, and troubleshoot common issues.

## Arguments

$ARGUMENTS - Optional: topic like `scan`, `dependencies`, `ci`, `troubleshoot`, or a question

## Instructions

### Parse Arguments

| Argument | Action |
|----------|--------|
| (none) | Show command overview grouped by use case |
| `getting-started` | First-time user guide |
| `scan` or `scanning` | Scanning commands deep-dive |
| `dependencies` or `deps` | Dependency checking commands |
| `secrets` | Secrets scanning help |
| `sast` or `code` | SAST/code analysis help |
| `license` or `licenses` | License compliance help |
| `cicd` or `ci` or `cd` | CI/CD integration help |
| `container` or `docker` | Container scanning help |
| `policy` or `policies` | Policy management help |
| `upgrade` or `upgrades` or `breaking` | Upgrade impact analysis help |
| `troubleshoot` or `debug` | Troubleshooting guide |
| `examples` | Real-world usage examples |
| Any question | Answer the question with relevant commands |

### Default: Command Overview

```markdown
# Endor Labs Security Commands

## Quick Start
| Command | Description | When to Use |
|---------|-------------|-------------|
| `/endor-setup` | Setup wizard | First time using Endor Labs |
| `/endor scan` | Quick security scan | Daily security check |
| `/endor check pkg@ver` | Check a package | Before adding a dependency |

## By Use Case

### Finding Vulnerabilities
| Command | Description |
|---------|-------------|
| `/endor-scan` | Fast repository scan |
| `/endor-scan-full` | Deep scan with call graphs |
| `/endor-check lodash@4.17.20` | Check specific package |
| `/endor-findings` | View all findings |

### Fixing Issues
| Command | Description |
|---------|-------------|
| `/endor-fix` | Get remediation guidance |
| `/endor-fix CVE-2021-23337` | Fix specific CVE |
| `/endor-upgrade` | Analyze upgrade impact with breaking change detection |
| `/endor-upgrade safe` | Show only safe upgrades (no breaking changes) |
| `/endor-explain CVE-2021-23337` | Understand a vulnerability |

### Code Analysis
| Command | Description |
|---------|-------------|
| `/endor-sast` | Static code analysis |
| `/endor-secrets` | Find exposed credentials |
| `/endor-review` | Pre-PR security review |

### Package Intelligence
| Command | Description |
|---------|-------------|
| `/endor-score axios` | Package health score |
| `/endor-license` | License compliance |

### DevOps & Compliance
| Command | Description |
|---------|-------------|
| `/endor-cicd github` | Generate CI/CD workflow |
| `/endor-sbom export` | Generate SBOM |
| `/endor-container nginx` | Scan container image |
| `/endor-policy` | Manage security policies |

### Advanced
| Command | Description |
|---------|-------------|
| `/endor-api` | Direct API queries |

## Tips

- **Natural language works too:** Just describe what you need!
  - "scan this project" → runs `/endor-scan`
  - "is axios safe?" → runs `/endor-check`
  - "help me fix vulnerabilities" → runs `/endor-fix`

- **Get more help:** `/endor-help <topic>` for detailed guides
  - `/endor-help scan` - All about scanning
  - `/endor-help ci` - CI/CD integration
  - `/endor-help troubleshoot` - Fix common issues
```

### Topic: Getting Started

```markdown
# Getting Started with Endor Labs

## 5-Minute Quick Start

### 1. Setup (one time)
```
/endor-setup
```
This walks you through installation and authentication.

### 2. Your First Scan
```
/endor scan
```
See your project's security posture immediately.

### 3. Check a Package Before Adding It
```
/endor check lodash@4.17.20
```
Always verify packages before adding to your project.

### 4. Fix What You Find
```
/endor-fix
```
Get guidance on remediating vulnerabilities.

## Learning Path

| Day | Learn | Command |
|-----|-------|---------|
| 1 | Run your first scan | `/endor scan` |
| 2 | Check packages | `/endor check` |
| 3 | Understand reachability | `/endor-scan-full` |
| 4 | Set up CI/CD | `/endor-cicd github` |
| 5 | Create policies | `/endor-policy create` |

## Key Concepts

### Reachability Analysis
Not all vulnerabilities are exploitable. Endor Labs analyzes your actual code paths to show which vulnerabilities can actually be reached.

- **Reachable:** Your code calls the vulnerable function → High priority
- **Unreachable:** Vulnerable code exists but isn't called → Lower priority

### Endor Scores
Package health scores based on:
- **Activity:** Is the package maintained?
- **Popularity:** Is it widely used?
- **Security:** History of vulnerabilities?
- **Quality:** Code quality indicators

## Common Workflows

### Daily Development
1. Write code
2. Run `/endor scan` before committing
3. Fix any critical findings
4. Commit with confidence

### Adding Dependencies
1. `/endor check package@version` before installing
2. Check the Endor Score
3. Verify license compatibility
4. Install if safe

### Pre-PR Review
1. Run `/endor-review` on your branch
2. Address any findings
3. Create PR with security approval
```

### Topic: Scanning

```markdown
# Scanning with Endor Labs

## Scan Types

### Quick Scan (`/endor-scan`)
- **Speed:** Seconds
- **What it finds:** Known CVEs, SAST issues, secrets
- **Best for:** Daily checks, quick feedback

### Full Scan (`/endor-scan-full`)
- **Speed:** Minutes
- **What it finds:** Everything + full call graph analysis
- **Best for:** Release preparation, security audits
- **Extra features:**
  - Complete reachability analysis
  - Call paths from entry points to vulnerabilities
  - Function-level impact assessment

## Scan Examples

```
# Basic scan of current directory
/endor scan

# Full analysis with call graphs
/endor-scan-full

# Scan and show only critical issues
/endor-findings critical
```

## Understanding Results

### Severity Levels
| Level | Meaning | Action |
|-------|---------|--------|
| CRITICAL | Severe vulnerability | Fix immediately |
| HIGH | Significant risk | Fix soon |
| MEDIUM | Moderate risk | Plan to fix |
| LOW | Minor issue | Track as debt |

### Reachability Tags
| Tag | Meaning |
|-----|---------|
| Reachable | Your code can trigger this vulnerability |
| Unreachable | Vulnerable code exists but isn't called |
| Test Dependency | Only affects test code, not production |

## Scanning Specific Paths

Just mention the path in your request:
- "scan the api directory" → scans ./api
- "check src/auth for secrets" → runs secrets scan on ./src/auth
```

### Topic: CI/CD

```markdown
# CI/CD Integration

## Quick Setup

### GitHub Actions
```
/endor-cicd github
```
Generates a complete security workflow:
- Scans on every PR
- Blocks critical vulnerabilities
- Posts results as PR comments

### GitLab CI
```
/endor-cicd gitlab
```

### Jenkins
```
/endor-cicd jenkins
```

### Azure DevOps
```
/endor-cicd azure
```

## What Gets Generated

A complete workflow that:
1. Installs endorctl
2. Authenticates using secrets
3. Runs security scan
4. Reports findings
5. Fails build on critical issues (configurable)

## Required Secrets

You'll need to add these secrets to your CI platform:

| Secret | Description |
|--------|-------------|
| `ENDOR_NAMESPACE` | Your Endor Labs namespace |
| `ENDOR_API_KEY_ID` | API key ID (from Endor Labs UI) |
| `ENDOR_API_KEY_SECRET` | API key secret |

### Creating API Keys
1. Go to app.endorlabs.com
2. Settings → API Keys
3. Create new key with appropriate permissions
4. Add to your CI/CD secrets

## Customization

After generating, you can customize:
- When scans run (PR, push, schedule)
- Which branches to scan
- Severity thresholds for failing builds
- Notification channels
```

### Topic: Upgrades

```markdown
# Upgrade Impact Analysis

## Overview

Endor Labs' Upgrade Impact Analysis predicts breaking changes **before** you upgrade, helping you make informed decisions about remediation.

## Commands

| Command | Description |
|---------|-------------|
| `/endor-upgrade` | Analyze all upgrades with impact assessment |
| `/endor-upgrade lodash` | Analyze specific package upgrade options |
| `/endor-upgrade safe` | Show only low-risk upgrades |
| `/endor-upgrade risky` | Show upgrades with potential breaking changes |

## Understanding Risk Levels

| Risk | Meaning | Action |
|------|---------|--------|
| LOW | No breaking changes detected | Safe to auto-upgrade |
| MEDIUM | Potential breaking changes | Review before upgrading |
| HIGH | Breaking changes likely | Plan code changes |

## Understanding Confidence

| Confidence | Meaning |
|------------|---------|
| HIGH | Strong evidence - trust the prediction |
| MEDIUM | Some uncertainty - test carefully |
| LOW | Limited data - extensive testing needed |

## What Gets Analyzed

Endor Labs examines:
- **API Changes**: Function signatures, return types
- **Behavioral Changes**: Different execution outcomes
- **Transitive Dependencies**: Conflicts in dependency tree
- **Deprecation Removals**: APIs that are removed
- **Your Code**: Which changed APIs you actually use

## Best Practices

1. **Start with safe upgrades:** `/endor-upgrade safe` - quick wins
2. **Review medium risk:** Check what code changes are needed
3. **Plan high risk:** Schedule time for major version upgrades
4. **Test thoroughly:** Even "safe" upgrades should be tested
5. **Verify fixes:** Run `/endor-scan` after upgrading

## Example Workflow

```bash
# 1. See all upgrade recommendations
/endor-upgrade

# 2. Apply safe upgrades (no breaking changes)
/endor-upgrade safe
npm install lodash@4.17.21 minimist@1.2.8

# 3. Analyze risky upgrade in detail
/endor-upgrade axios

# 4. Plan and implement code changes for major upgrades

# 5. Verify all vulnerabilities are fixed
/endor-scan
```
```

### Topic: Troubleshooting

```markdown
# Troubleshooting Guide

## Quick Diagnostics

```
/endor-setup check
```
Shows status of all components.

## Common Issues

### "endorctl: command not found"

**Fix:** Install endorctl

```bash
# Homebrew
brew install endorlabs/tap/endorctl

# npm
npm install -g endorctl

# Or download directly from https://api.endorlabs.com/download/latest/
```

### "Authentication failed" or "401 Unauthorized"

**Fix:** Re-authenticate

```bash
endorctl init
```

### "Namespace not found" or "403 Forbidden"

**Possible causes:**
1. ENDOR_NAMESPACE not set
2. No access to the namespace
3. Typo in namespace name

**Fix:**
```bash
# Check current setting
echo $ENDOR_NAMESPACE

# List available namespaces
endorctl api list --resource Namespace

# Set the correct namespace
export ENDOR_NAMESPACE=correct-namespace
```

### "No findings returned"

**Possible causes:**
1. Project not scanned yet
2. Wrong namespace
3. No vulnerabilities (good news!)

**Fix:**
```bash
# Run an initial scan
endorctl scan --path . --output-type summary

# Then try again
/endor-findings
```

### "MCP server connection failed"

**Possible causes:**
1. endorctl not in PATH
2. MCP server configuration issue

**Fix:**
1. Verify endorctl location: `which endorctl`
2. Check settings.json has correct path
3. Restart Claude Code

### "Scan takes too long"

**Tips:**
- Use `/endor-scan` for quick checks (faster)
- Use `/endor-scan-full` only when you need call graphs
- Large monorepos may take longer - consider scanning specific paths

## Getting More Help

- **Endor Labs Docs:** https://docs.endorlabs.com
- **API Reference:** https://docs.api.endorlabs.com
- **Support:** Contact through Endor Labs dashboard
```

### Topic: Examples

```markdown
# Real-World Examples

## Scenario 1: New Developer Onboarding

```
# First, set up Endor Labs
/endor-setup

# Scan the project to understand security posture
/endor scan

# See what critical issues exist
/endor-findings critical
```

## Scenario 2: Adding a New Dependency

```
# Before installing, check if it's safe
/endor check lodash@4.17.20

# Also check the package health
/endor-score lodash

# Check license compatibility
/endor-license check lodash
```

## Scenario 3: Pre-Release Security Audit

```
# Run full analysis with call graphs
/endor-scan-full

# Review all findings
/endor-findings

# Generate SBOM for compliance
/endor-sbom export

# Check license compliance
/endor-license
```

## Scenario 4: Fixing Vulnerabilities Sprint

```
# See all fixable vulnerabilities
/endor-fix

# Get safe upgrade paths (no breaking changes)
/endor-fix --safe

# Fix a specific CVE
/endor-fix CVE-2021-23337
```

## Scenario 5: Setting Up CI/CD

```
# Generate GitHub Actions workflow
/endor-cicd github

# Create policies for enforcement
/endor-policy create finding
```

## Scenario 6: Container Deployment

```
# Scan your Docker image
/endor-container myapp:latest

# Check base image security
/endor-container node:18-alpine
```
```

### Handle Questions

When the user asks a question instead of specifying a topic, answer it directly and suggest relevant commands.

**Examples:**

User: "how do I check if a package is safe?"
```markdown
To check if a package is safe, use:

```
/endor check <package>@<version>
```

For example:
```
/endor check axios@1.6.0
```

This will show:
- Known vulnerabilities (CVEs)
- Severity levels
- Safe versions to use

**Also helpful:**
- `/endor-score <package>` - Get overall health score
- `/endor-license check <package>` - Verify license compatibility
```

User: "what's the difference between scan and scan-full?"
```markdown
## Quick Scan vs Full Scan

| Feature | `/endor-scan` | `/endor-scan-full` |
|---------|---------------|-------------------|
| Speed | Seconds | Minutes |
| Vulnerabilities | Yes | Yes |
| SAST | Yes | Yes |
| Secrets | Yes | Yes |
| Call Graphs | No | Yes |
| Reachability Proof | Basic | Complete paths |
| Entry Point Analysis | No | Yes |

**Use Quick Scan when:**
- Daily development checks
- Quick feedback needed
- Initial triage

**Use Full Scan when:**
- Preparing for release
- Security audits
- Need to prove reachability
- Investigating specific vulnerabilities
```
