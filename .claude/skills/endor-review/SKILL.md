---
name: endor-review
description: Analyze the current git diff or branch for security issues before creating a PR
---

# Endor Labs: PR Security Review

Analyze the current git diff or branch for security issues before creating a PR.

## Arguments

$ARGUMENTS - Optional: `--branch <name>`, `--base <branch>`, `--full`, `--quick`

## Instructions

### Determine Scope

1. **Default (no args):** Review uncommitted changes + commits not in base branch
2. **--branch <name>:** Review specific branch vs main
3. **--base <branch>:** Compare against specific base branch
4. **--full:** Full security scan of changed files
5. **--quick:** Fast scan, skip deep analysis

### Step 1: Get the Diff

```bash
# Get changed files
git diff --name-only HEAD origin/main

# Get the actual diff
git diff origin/main...HEAD

# For uncommitted changes
git diff HEAD
```

### Step 2: Analyze Changes

**For each changed file, check:**

1. **Dependency Changes** (package.json, go.mod, requirements.txt, etc.)
   - New dependencies added?
   - Version changes?
   - Use `check_dependency_for_vulnerabilities` for each

2. **Code Changes**
   - Security-sensitive patterns?
   - Use `opengrep` for SAST on changed files

3. **Configuration Changes**
   - Secrets exposed?
   - Security settings modified?

4. **Infrastructure Changes** (Terraform, Dockerfile, k8s manifests)
   - Security misconfigurations?

### Step 3: Present Review Results

```markdown
## PR Security Review

**Branch:** feature/user-auth
**Base:** main
**Changed Files:** 15
**Commits:** 3

---

### Dependency Analysis

#### New Dependencies Added

| Package | Version | Vulnerabilities | Endor Score | Recommendation |
|---------|---------|-----------------|-------------|----------------|
| jsonwebtoken | 9.0.0 | 0 | 85/100 | Safe to use |
| bcrypt | 5.1.0 | 0 | 92/100 | Recommended |

#### Updated Dependencies

| Package | Old | New | CVEs Fixed | Breaking Changes |
|---------|-----|-----|------------|------------------|
| lodash | 4.17.15 | 4.17.21 | 3 | None |

#### Removed Dependencies

| Package | Note |
|---------|------|
| moment | Replaced with date-fns |

---

### SAST Findings

#### Critical Issues (Block Merge)

##### SQL Injection Risk - src/api/users.js:45

```javascript
// Line 45
const query = `SELECT * FROM users WHERE id = ${req.params.id}`;
```

**Risk:** User input directly interpolated into SQL query.

**Fix:**
```javascript
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [req.params.id]);
```

---

#### High Issues

##### Potential XSS - src/components/Profile.jsx:89

```jsx
<div dangerouslySetInnerHTML={{__html: user.bio}} />
```

**Risk:** User-controlled HTML rendered without sanitization.

**Fix:**
```jsx
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{__html: DOMPurify.sanitize(user.bio)}} />
```

---

### Secrets Detection

| File | Type | Line | Status |
|------|------|------|--------|
| .env.example | Example values | - | OK |

No real secrets detected.

---

### Configuration Changes

#### Dockerfile Modified

```diff
- FROM node:16-alpine
+ FROM node:20-alpine
```

**Analysis:** Base image update - good security practice.

#### Security Headers Added

```diff
+ app.use(helmet());
+ app.use(cors({ origin: allowedOrigins }));
```

**Analysis:** Security improvement.

---

### Infrastructure Analysis

No Terraform/Kubernetes changes detected.

---

## Summary

| Category | Critical | High | Medium | Low |
|----------|----------|------|--------|-----|
| Vulnerabilities | 0 | 0 | 0 | 0 |
| SAST | 1 | 1 | 2 | 3 |
| Secrets | 0 | 0 | 0 | 0 |
| Config | 0 | 0 | 0 | 0 |

### Verdict

**BLOCK** - 1 critical SAST issue must be resolved before merge.

### Required Actions

1. Fix SQL injection in `src/api/users.js:45`
2. Consider fixing XSS in `src/components/Profile.jsx:89`

### Recommended Actions

1. Add input validation for user parameters
2. Consider adding rate limiting to auth endpoints

---

Would you like me to help fix these issues?
```

### Quick Review Mode

For `--quick` flag, perform fast checks only:

```markdown
## Quick PR Security Review

**Branch:** feature/user-auth
**Files Changed:** 15

### Dependency Check
- 2 new dependencies: All safe
- 1 updated: lodash 4.17.15 → 4.17.21 (3 CVEs fixed)

### Quick SAST
- 1 potential SQL injection
- 1 potential XSS

### Secrets Scan
- No secrets detected

**Quick Verdict:** Review needed - 2 potential issues found.

Run `/endor-review --full` for detailed analysis.
```

### Integration with Git Workflow

**Pre-commit hook suggestion:**
```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running Endor Labs security check..."
endorctl scan --path . --quick --changed-only

if [ $? -ne 0 ]; then
    echo "Security issues found. Please fix before committing."
    exit 1
fi
```

**Pre-push hook suggestion:**
```bash
#!/bin/bash
# .git/hooks/pre-push

echo "Running full security review..."
endorctl scan --path . --output-type summary

# Check for critical issues
CRITICAL=$(endorctl scan --path . --output-type json | jq '[.findings[] | select(.level == "CRITICAL")] | length')
if [ "$CRITICAL" -gt 0 ]; then
    echo "Critical security issues found. Push blocked."
    exit 1
fi
```

### Automatic PR Comment

When integrated with GitHub/GitLab, generate a PR comment:

```markdown
## Endor Labs Security Review

| Check | Status | Details |
|-------|--------|---------|
| Vulnerabilities | ✅ Pass | No new vulnerabilities |
| SAST | ⚠️ Warning | 2 issues found |
| Secrets | ✅ Pass | No secrets detected |
| License | ✅ Pass | All licenses compliant |

### Findings

<details>
<summary>SAST Issues (2)</summary>

- **HIGH** SQL Injection in `src/api/users.js:45`
- **MEDIUM** Missing input validation in `src/api/auth.js:23`

</details>

### Dependency Changes

- ➕ Added `jsonwebtoken@9.0.0` - Safe
- ⬆️ Updated `lodash` 4.17.15 → 4.17.21 - 3 CVEs fixed

---
*Powered by [Endor Labs](https://endorlabs.com)*
```

### Review Checklist

At the end of review, provide a checklist:

```markdown
## Pre-Merge Checklist

- [ ] All critical SAST issues resolved
- [ ] All high-severity vulnerabilities addressed
- [ ] No secrets in code
- [ ] New dependencies reviewed for security
- [ ] License compliance verified
- [ ] Security tests pass
- [ ] Code review completed
```
