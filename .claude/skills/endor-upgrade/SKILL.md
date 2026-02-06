---
name: endor-upgrade
description: |
  Analyze the impact of upgrading a dependency before you do it. Uses Change Impact Analysis (CIA) to predict breaking changes, API changes, and remediation risk.
  - MANDATORY TRIGGERS: endor upgrade, upgrade impact, breaking changes, change impact, dependency upgrade, upgrade analysis, endor-upgrade, should I upgrade
---

# Endor Labs Upgrade Impact Analysis

Predict breaking changes and assess risk before upgrading dependencies using Change Impact Analysis (CIA).

## Prerequisites

- Endor Labs MCP server configured (run `/endor-setup` if not)
- A project that has been scanned at least once

## Input Parsing

Parse the user's input to extract:

1. **Package name** (required) - e.g., `lodash`, `express`
2. **Target version** (optional) - e.g., `4.17.21`. If not specified, analyze upgrade to latest safe version.
3. **Language** (optional) - auto-detect from context

## Workflow

### Step 1: Identify Current State

1. Detect the current version of the dependency from the project's manifest file (e.g., `package.json`, `go.mod`, `requirements.txt`)
2. Check current vulnerabilities using `check_dependency_for_vulnerabilities` MCP tool with `ecosystem`, `dependency_name`, and `version`

### Step 2: Get Upgrade Analysis

**Approach 1 - MCP Tools (Preferred):**

1. Use `check_dependency_for_vulnerabilities` MCP tool to check both the current and target versions:
   - `ecosystem`: Package ecosystem (`npm`, `python`, `go`, `java`, `maven`)
   - `dependency_name`: Package name (for Maven: `groupid:artifactid`)
   - `version`: Current version, then target version

2. Use `get_resource` MCP tool to get package version details:
   - `resource_type`: `PackageVersion`
   - `name`: `{ecosystem}://{package}@{version}`

3. Use `get_resource` to get package metrics for scoring:
   - `resource_type`: `Metric`
   - `name`: `package_version_scorecard` (with the package UUID as parent)

**Approach 2 - CLI (Fallback):**

```bash
# Get upgrade recommendations with Change Impact Analysis
npx -y endorctl recommend dependency-upgrades --security-only --use-cia --persist --project-uuid=$PROJECT_UUID -n $ENDOR_NAMESPACE 2>/dev/null

# Or query version upgrade service via API
npx -y endorctl api create --resource VersionUpgrade -n $ENDOR_NAMESPACE --data '{
  "context": {"type": "project", "id": "{project_uuid}"},
  "request": {"package_version": "{ecosystem}://{package}@{current_version}", "target_version": "{target_version}"}
}' 2>/dev/null
```

**Important:** Always use `2>/dev/null` when piping CLI output to a JSON parser (stderr contains progress messages that corrupt JSON parsing).

### Step 3: Present Analysis

```markdown
## Upgrade Impact Analysis

### {package} {current_version} -> {target_version}

| Metric | Value |
|--------|-------|
| Security Impact | {HIGH/MEDIUM/LOW} - Fixes {n} CVEs |
| Remediation Risk | {HIGH/MEDIUM/LOW} |
| Confidence | {HIGH/MEDIUM/LOW} |
| Breaking Changes | {count} detected |
| API Changes | {count} |
| Deprecated APIs | {count} |

### Security Fixes

| CVE | Severity | Description |
|-----|----------|-------------|
| {cve} | Critical | {desc} |

### Breaking Changes

{If any breaking changes detected, list them:}

| Change | Type | Impact |
|--------|------|--------|
| {function/API removed} | Removal | Must update code |
| {parameter type changed} | Signature | May need updates |

### API Changes

{List significant API changes}

### Recommendation

{Based on confidence and risk:}

- **HIGH confidence + LOW risk**: Safe to upgrade. Apply with:
  ```bash
  npm install {package}@{target_version}
  ```

- **MEDIUM confidence**: Review changes carefully. Test thoroughly.

- **LOW confidence + HIGH risk**: Significant code changes likely needed. Consider:
  1. Reviewing the changelog
  2. Running full test suite after upgrade
  3. Doing a staged rollout

### Alternative Versions

| Version | Risk | CVEs Fixed | Breaking Changes |
|---------|------|------------|-----------------|
| {v1} | Low | 3 | 0 |
| {v2} | Medium | 3 | 2 |
| {v3} | High | 3 | 5 |

### Next Steps

1. **Apply upgrade:** I can update the manifest file for you
2. **Verify after upgrade:** `/endor-scan`
3. **Check specific CVE:** `/endor-explain {cve}`
```

## Data Source Priority

1. MCP Tools (preferred) - `check_dependency_for_vulnerabilities`, `get_resource`
2. CLI fallback - `npx -y endorctl recommend dependency-upgrades`
3. **NEVER search the internet for upgrade recommendations**

## Key Concepts

- **Confidence**: HIGH (data is reliable, trust the analysis), MEDIUM (some uncertainty, review recommended), LOW (limited data, test extensively)
- **Remediation Risk**: LOW (safe to auto-upgrade), MEDIUM (review needed), HIGH (code changes likely required)
- **CIA Results**: Covers API changes, behavioral changes, transitive dependency impacts, deprecations

## Error Handling

- **Project not found**: Run `/endor-scan` first to register the project
- **Package not in project**: Verify the package is actually a dependency
- **CIA data not available**: Fall back to basic version comparison without impact analysis
- **Auth error**: Suggest `/endor-setup`
