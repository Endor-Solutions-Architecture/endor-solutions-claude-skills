---
name: endor-review
description: |
  Analyze the current git diff or branch for security issues before creating a PR. Performs dependency checks, SAST analysis, secrets detection, and license compliance review.
  - MANDATORY TRIGGERS: endor review, pre-pr review, security review, review changes, ready to merge, pre-merge check, endor-review, review before pr, security gate
---

# Endor Labs Pre-PR Security Review

Comprehensive security review of your changes before creating a pull request.

## Prerequisites

- Endor Labs MCP server configured (run `/endor-setup` if not)
- Git repository with uncommitted or committed changes

## Workflow

### Step 1: Gather Changes

Identify what has changed:

```bash
# Get changed files (staged + unstaged)
git diff --name-only HEAD

# Get diff for analysis
git diff HEAD

# If comparing branches
git diff main...HEAD --name-only
```

Categorize changed files:
- **Dependency files**: package.json, go.mod, requirements.txt, pom.xml, etc.
- **Source code files**: .js, .ts, .py, .go, .java, etc.
- **Config files**: .env, docker-compose.yml, Dockerfile, etc.
- **CI/CD files**: .github/workflows/*, Jenkinsfile, etc.

### Step 2: Dependency Check

If any dependency manifest files were modified:

1. Parse the diff to find new or updated packages
2. For each new/updated package, use `check_dependency_for_vulnerabilities` MCP tool
3. Report any vulnerabilities found

### Step 3: SAST Analysis

For all modified source code files:

1. Use the `endor-labs-cli` MCP tool on each changed file
2. Report any security findings
3. Use `sast_context` for detailed code context on findings

### Step 4: Secrets Detection

Scan all changed files for secrets:

1. Use the `endor-labs-cli` MCP tool with secrets ruleset on changed files
2. Also manually check for common secret patterns in the diff
3. Flag any exposed credentials

### Step 5: License Check

For new dependencies:

1. Check license of each new dependency
2. Flag copyleft licenses (GPL, AGPL)
3. Warn on unknown licenses

### Step 6: Container Security (if applicable)

If Dockerfile or docker-compose files were modified:

1. Check for security best practices
2. Flag running as root, latest tags, exposed ports
3. Check for secrets in build args

### Step 7: Present Security Review

```markdown
## Pre-PR Security Review

**Branch:** {current_branch}
**Files Changed:** {count}
**Dependency Files Modified:** {yes/no}

---

### 1. Dependency Check {PASS/WARN/BLOCK}

{If dependencies changed:}

| Package | Change | Version | Vulnerabilities | Status |
|---------|--------|---------|-----------------|--------|
| {pkg} | Added | {v} | 0 | PASS |
| {pkg} | Updated | {old}->{new} | 2 (1 Critical) | BLOCK |

{If no dependency changes:}
No dependency files modified.

---

### 2. SAST Analysis {PASS/WARN/BLOCK}

| File | Issues | Severity | Details |
|------|--------|----------|---------|
| {file} | 1 | Critical | SQL Injection at line {n} |
| {file} | 2 | Medium | Information disclosure |

{If no issues:}
No SAST issues found in modified files.

---

### 3. Secrets Scan {PASS/BLOCK}

{If secrets found:}
**SECRETS DETECTED** - {count} exposed credentials found

| Type | File | Line |
|------|------|------|
| API Key | {file} | {line} |

{If clean:}
No secrets detected in changes.

---

### 4. License Check {PASS/WARN/BLOCK}

{If new dependencies:}

| Package | License | Risk |
|---------|---------|------|
| {pkg} | MIT | Low |
| {pkg} | GPL-3.0 | High |

{If no new dependencies:}
No new dependencies added.

---

### Verdict: {PASS / WARN / BLOCK}

{Based on findings:}
```

### Security Gate Criteria

**BLOCK** (must fix before merging):
- Any critical vulnerability in new/updated dependencies
- Any critical SAST finding (SQL injection, command injection)
- Any exposed secrets
- AGPL/SSPL licensed new dependencies in commercial projects

**WARN** (review recommended):
- High severity vulnerabilities (non-reachable)
- Medium/Low SAST findings
- GPL dependencies (review with legal)

**PASS** (safe to merge):
- No critical issues
- No secrets
- No blocking license issues

### Step 8: Provide Actionable Fixes

For each blocking issue, provide a specific fix:

```markdown
### Required Fixes Before Merge

1. **{Issue}** in {file}:{line}
   - **Fix:** {specific remediation}
   - **Command:** `/endor-fix {cve}` for details

2. **{Issue}** in {file}:{line}
   - **Fix:** {specific remediation}
```

## Error Handling

- **No changes detected**: Tell the user there are no changes to review
- **Auth error**: Suggest `/endor-setup`
- **MCP not available**: Perform manual pattern-based review of the diff
