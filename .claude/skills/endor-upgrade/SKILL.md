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

1. Find the project UUID using `projects_by_name` or `get_repository_uuid` MCP tool
2. Detect the current version of the dependency from the project's manifest file

### Step 2: Get Upgrade Analysis

**Approach 1 - MCP Tools (Preferred):**

Use `get_dependency_upgrade_opts` to get available upgrade options with CIA data.

**Approach 2 - API Call (Fallback):**

Call the VersionUpgradeService API:

```
POST /v1/namespaces/{namespace}/version-upgrades
```

Request body:
```json
{
  "context": {
    "type": "project",
    "id": "{project_uuid}"
  },
  "request": {
    "package_version": "{ecosystem}://{package}@{current_version}",
    "target_version": "{target_version}"
  }
}
```

Then poll for results:
```
GET /v1/namespaces/{namespace}/version-upgrades/{uuid}
```

**Approach 3 - CLI Fallback:**

```bash
endorctl recommend dependency-upgrades --security-only --use-cia --persist --project-uuid=$PROJECT_UUID -n $ENDOR_NAMESPACE
```

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

1. MCP Tools (preferred) - `get_dependency_upgrade_opts`, `get_security_findings`
2. API calls - VersionUpgradeService endpoints
3. CLI fallback - `endorctl recommend dependency-upgrades`
4. **NEVER search the internet for upgrade recommendations**

## Key Concepts

- **Confidence**: HIGH (data is reliable, trust the analysis), MEDIUM (some uncertainty, review recommended), LOW (limited data, test extensively)
- **Remediation Risk**: LOW (safe to auto-upgrade), MEDIUM (review needed), HIGH (code changes likely required)
- **CIA Results**: Covers API changes, behavioral changes, transitive dependency impacts, deprecations

## Error Handling

- **Project not found**: Run `/endor-scan` first to register the project
- **Package not in project**: Verify the package is actually a dependency
- **CIA data not available**: Fall back to basic version comparison without impact analysis
- **Auth error**: Suggest `/endor-setup`
