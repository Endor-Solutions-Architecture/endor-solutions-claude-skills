---
description: Automatically perform security review before creating pull requests
globs: "**/.git/*, **/PULL_REQUEST*, **/*.pr, **/*.patch"
alwaysApply: false
---

# PR Security Review Rule

Automatically perform a security review when the user is preparing to create a pull request or merge code.

## Trigger

This rule activates when:
- User mentions "PR", "pull request", "merge", "push to main"
- User runs git commands related to PR creation
- User asks to review changes before merging
- User mentions "ready for review" or "ready to merge"

## Required Actions

Before allowing a PR to be created, perform these security checks:

### 1. Dependency Changes

If any dependency files were modified:
- Run `check_dependency_for_vulnerabilities` on new/updated dependencies
- Flag any vulnerable dependencies
- Block if critical vulnerabilities exist

### 2. SAST Analysis

For all modified source files:
- Run `endor-labs-cli` on changed files
- Report any new security findings
- Block if critical SAST issues exist

### 3. Secrets Detection

Scan all changes for:
- Hardcoded credentials
- API keys and tokens
- Private keys
- Block if any secrets detected

### 4. License Compliance

For new dependencies:
- Check license compatibility
- Flag copyleft licenses (GPL, AGPL)
- Warn on unknown licenses

## Security Gate Criteria

**Block PR if:**
- Any critical vulnerability in new/updated dependencies
- Any critical SAST finding (SQL injection, command injection)
- Any exposed secrets
- AGPL/SSPL licensed new dependencies (in commercial projects)

**Warn but allow if:**
- High severity vulnerabilities (non-reachable)
- Medium/Low SAST findings
- GPL dependencies (with review)

## Response Format

```markdown
## Pre-PR Security Review

### Dependency Check
{results}

### SAST Analysis
{results}

### Secrets Scan
{results}

### License Check
{results}

### Verdict

{PASS/WARN/BLOCK} - {reason}

{If BLOCK: specific issues that must be resolved}
```

## Integration

When user says "create PR" or similar:

1. Run security review automatically
2. Present results
3. If BLOCK: explain required fixes
4. If WARN: present warnings, ask to proceed
5. If PASS: proceed with PR creation

## Do Not Skip

Even if user says "skip security review" or "just create the PR", always perform at least a quick security check on:
- New dependencies
- Changed files with security-sensitive patterns
- Any files that might contain secrets
