---
name: endor-demo
description: Try Endor Labs features with sample data - no account required
---

# Endor Labs: Interactive Demo

Try Endor Labs features without needing an account or full setup. Perfect for learning what Endor Labs can do before committing to setup.

## Arguments

$ARGUMENTS - Demo type: `scan`, `check`, `fix`, `score`, `sbom`, `all`

## Instructions

### Parse Arguments

| Argument | Demo |
|----------|------|
| (none) | Show demo menu |
| `scan` | Simulated repository scan with sample findings |
| `check` | Demo package vulnerability check |
| `fix` | Demo remediation workflow |
| `score` | Demo package health scores |
| `sbom` | Demo SBOM output |
| `all` | Run through all demos |

### Demo Menu (No argument)

```markdown
# Endor Labs Interactive Demo

See what Endor Labs can do before setting up! Choose a demo:

## Available Demos

| Demo | Command | What You'll See |
|------|---------|-----------------|
| Security Scan | `/endor-demo scan` | How scan results look |
| Package Check | `/endor-demo check` | Vulnerability checking |
| Remediation | `/endor-demo fix` | How we help you fix issues |
| Health Scores | `/endor-demo score` | Package quality metrics |
| SBOM Export | `/endor-demo sbom` | Software bill of materials |
| Full Tour | `/endor-demo all` | See everything |

## Quick Start

After the demo, run `/endor-setup` to start using Endor Labs with your own projects!
```

### Demo: Scan Results

```markdown
# Demo: Security Scan Results

*This is a demo showing what a real scan would look like.*

---

## Security Scan Results

**Repository:** demo-ecommerce-app
**Languages:** JavaScript, TypeScript
**Scan Time:** {current timestamp}

### Critical Issues (2 reachable - Fix Now)

| Package | Version | CVE | Description | Reachable |
|---------|---------|-----|-------------|-----------|
| lodash | 4.17.15 | CVE-2021-23337 | Prototype Pollution | Yes |
| axios | 0.21.0 | CVE-2021-3749 | Server-Side Request Forgery | Yes |

### High Priority (3 total, 1 reachable)

| Package | Version | CVE | Description | Reachable |
|---------|---------|-----|-------------|-----------|
| minimist | 1.2.5 | CVE-2021-44906 | Prototype Pollution | No |
| node-fetch | 2.6.0 | CVE-2022-0235 | Exposure of Sensitive Information | No |
| jsonwebtoken | 8.5.0 | CVE-2022-23529 | Unrestricted Key Type | Yes |

### SAST Findings (2)

| File | Line | Issue | Severity |
|------|------|-------|----------|
| src/api/users.js | 45 | SQL Injection | CRITICAL |
| src/auth/login.js | 23 | Weak Password Hashing | HIGH |

### Secrets Found (1)

| File | Type | Status |
|------|------|--------|
| config/dev.env | AWS Access Key | Exposed |

### Summary
- 2 Critical (2 reachable) - **Immediate action required**
- 3 High (1 reachable) - Fix this sprint
- 5 Medium - Plan for next release
- 8 Low - Technical debt

### Key Insight: Reachability Matters!

Notice how some vulnerabilities are marked "Reachable" and others aren't?

**Reachable** means your code actually calls the vulnerable function - these are the real threats.

**Unreachable** means the vulnerable code exists in the package, but your application never executes it.

This is Endor Labs' superpower: **focus on what's actually exploitable**, not just what's theoretically vulnerable.

---

**Ready to scan your own code?** Run `/endor-setup` to get started!
```

### Demo: Package Check

```markdown
# Demo: Package Vulnerability Check

*This is a demo showing what checking a package looks like.*

---

## Checking: lodash@4.17.15

**Language:** JavaScript (npm)
**Status:** VULNERABLE

### Vulnerabilities Found (3)

| CVE | Severity | Description | Fixed In |
|-----|----------|-------------|----------|
| CVE-2021-23337 | CRITICAL | Prototype Pollution in set/setWith | 4.17.21 |
| CVE-2020-8203 | HIGH | Prototype Pollution in zipObjectDeep | 4.17.19 |
| CVE-2019-10744 | HIGH | Prototype Pollution in defaultsDeep | 4.17.12 |

### What This Means

**CVE-2021-23337 (Critical):**
An attacker can modify the prototype of Object, potentially leading to:
- Remote code execution
- Denial of service
- Data manipulation

### Recommendation

**Upgrade to lodash@4.17.21** to fix all known vulnerabilities.

```bash
npm install lodash@4.17.21
```

### Comparison: Safe Version

| Version | CVEs | Status |
|---------|------|--------|
| 4.17.15 (current) | 3 | Vulnerable |
| 4.17.19 | 2 | Vulnerable |
| 4.17.21 (recommended) | 0 | Safe |

---

**Want to check your actual dependencies?** Run `/endor-setup` to get started!
```

### Demo: Fix Workflow

```markdown
# Demo: Remediation Workflow

*This is a demo showing how Endor Labs helps you fix vulnerabilities.*

---

## Remediation Plan

Based on a typical JavaScript project with vulnerabilities:

### Priority 1: Critical + Reachable (Fix Today)

#### lodash 4.17.15 → 4.17.21

**Risk:** Your code at `src/utils/data.js:42` calls `_.set()` which is vulnerable to prototype pollution.

**Impact:** Same major version - low risk of breaking changes.

**Fix:**
```bash
npm install lodash@4.17.21
```

**Verification:** Re-run `/endor scan` after updating.

---

### Priority 2: High + Reachable (Fix This Week)

#### jsonwebtoken 8.5.0 → 9.0.0

**Risk:** Your auth middleware uses unrestricted key types.

**Impact:** Major version change - review breaking changes:
- `algorithms` parameter now required
- Some deprecated options removed

**Fix:**
```bash
npm install jsonwebtoken@9.0.0
```

**Code changes may be needed** - see migration guide.

---

### Priority 3: High + Unreachable (Plan for Sprint)

#### minimist 1.2.5 → 1.2.8

**Risk:** Vulnerable, but your code doesn't use the affected function.

**Impact:** Patch version - safe to update.

**Fix:**
```bash
npm install minimist@1.2.8
```

---

### Bulk Fix Script

For all safe (non-breaking) updates:

```bash
npm install lodash@4.17.21 minimist@1.2.8 node-fetch@2.6.9
```

### After Fixing

1. Run your test suite
2. Run `/endor scan` to verify fixes
3. Commit with message: `fix: remediate security vulnerabilities`

---

**Want remediation guidance for your actual code?** Run `/endor-setup` to get started!
```

### Demo: Package Scores

```markdown
# Demo: Package Health Scores

*This is a demo showing Endor Labs' package intelligence.*

---

## Package: axios

**Version:** 1.6.0
**License:** MIT
**Overall Score:** 85/100 (Excellent)

### Endor Scores

| Category | Score | Details |
|----------|-------|---------|
| Activity | 92/100 | Updated 2 weeks ago, active maintenance |
| Popularity | 98/100 | 40M weekly downloads, 100K+ GitHub stars |
| Security | 78/100 | 2 past CVEs (all fixed), good response time |
| Quality | 72/100 | 95% test coverage, well documented |

### Score Breakdown

**Activity (92/100)**
- Last commit: 14 days ago
- Commits last 90 days: 47
- Active maintainers: 5
- Issue response time: 2 days avg

**Popularity (98/100)**
- Weekly npm downloads: 40,234,892
- GitHub stars: 103,456
- Dependent packages: 156,789
- Used by major projects: Yes

**Security (78/100)**
- Historical CVEs: 2
- Average fix time: 5 days
- Security policy: Yes
- No current vulnerabilities

**Quality (72/100)**
- Test coverage: 95%
- Documentation: Comprehensive
- TypeScript support: Yes
- Bundle size: 13.4kB (good)

### Comparison: Similar Packages

| Package | Overall | Security | Activity |
|---------|---------|----------|----------|
| axios | 85 | 78 | 92 |
| node-fetch | 76 | 82 | 68 |
| got | 81 | 85 | 79 |
| ky | 73 | 90 | 65 |

### Recommendation

**axios is a solid choice** - high popularity means issues are found and fixed quickly, good maintenance activity, and acceptable security history.

---

**Want to check scores for packages you use?** Run `/endor-setup` to get started!
```

### Demo: SBOM

```markdown
# Demo: Software Bill of Materials (SBOM)

*This is a demo showing SBOM generation.*

---

## SBOM Export: demo-ecommerce-app

**Format:** CycloneDX 1.4
**Generated:** {current timestamp}
**Components:** 847

### Summary

| Category | Count |
|----------|-------|
| Direct dependencies | 42 |
| Transitive dependencies | 805 |
| Total components | 847 |

### Top-Level Dependencies (sample)

| Component | Version | License | Vulnerabilities |
|-----------|---------|---------|-----------------|
| express | 4.18.2 | MIT | 0 |
| react | 18.2.0 | MIT | 0 |
| lodash | 4.17.15 | MIT | 3 |
| axios | 0.21.0 | MIT | 1 |
| mongoose | 7.0.0 | MIT | 0 |

### License Distribution

| License | Count | Percentage |
|---------|-------|------------|
| MIT | 712 | 84.1% |
| Apache-2.0 | 89 | 10.5% |
| ISC | 32 | 3.8% |
| BSD-3-Clause | 11 | 1.3% |
| Other | 3 | 0.3% |

### Vulnerability Summary

| Severity | Count |
|----------|-------|
| Critical | 2 |
| High | 4 |
| Medium | 8 |
| Low | 12 |

### Export Formats Available

```bash
# CycloneDX (recommended for security)
/endor-sbom export --format cyclonedx

# SPDX (for compliance)
/endor-sbom export --format spdx

# JSON (for custom processing)
/endor-sbom export --format json
```

### Use Cases

**Compliance:** Many regulations require SBOM for software products.

**Security:** Track exactly what's in your software supply chain.

**Incident Response:** Quickly identify if you're affected by a new CVE.

---

**Want to generate SBOMs for your projects?** Run `/endor-setup` to get started!
```

### Demo: All (Full Tour)

When user runs `/endor-demo all`, run through each demo in sequence:

```markdown
# Endor Labs Feature Tour

Let me walk you through what Endor Labs can do for your security.

---

[Run scan demo]

---

[Run check demo]

---

[Run fix demo]

---

[Run score demo]

---

[Run sbom demo]

---

## What's Next?

You've seen what Endor Labs can do:

- **Scan repositories** for vulnerabilities, SAST issues, and secrets
- **Check packages** before adding dependencies
- **Get remediation guidance** with safe upgrade paths
- **Evaluate package health** with comprehensive scores
- **Generate SBOMs** for compliance and tracking

### Ready to Use Endor Labs?

```
/endor-setup
```

This will get you set up in about 5 minutes!

### Questions?

```
/endor-help
```

See all available commands and get answers.
```

### Key UX Principles

1. **Make demos feel real** - Use realistic data and scenarios
2. **Highlight value** - Show what makes Endor Labs special (reachability, scores)
3. **Clear call to action** - Every demo ends with "run `/endor-setup`"
4. **Educational** - Explain concepts like reachability while demonstrating
5. **Quick exit** - Users can try one demo or all without commitment
