---
name: endor-findings
description: |
  Display security findings from the Endor Labs platform. Supports filtering by severity, reachability, category, and more.
  - MANDATORY TRIGGERS: endor findings, show findings, list findings, show vulnerabilities, list vulnerabilities, security findings, endor-findings
---

# Endor Labs Findings Viewer

Query and display security findings with filtering support.

## Prerequisites

- Endor Labs MCP server configured (run `/endor-setup` if not)
- A scan has been run previously (findings are stored on the platform)

## Filter Reference

Parse the user's input to build filters. Common filter keywords:

| User Says | API Filter |
|-----------|-----------|
| `critical` | `spec.level==FINDING_LEVEL_CRITICAL` |
| `high` | `spec.level==FINDING_LEVEL_HIGH` |
| `medium` | `spec.level==FINDING_LEVEL_MEDIUM` |
| `low` | `spec.level==FINDING_LEVEL_LOW` |
| `reachable` | `spec.finding_tags contains FINDING_TAGS_REACHABLE_FUNCTION` |
| `unreachable` | `spec.finding_tags not contains FINDING_TAGS_REACHABLE_FUNCTION` |
| `vulnerability`, `vuln` | `spec.finding_categories contains FINDING_CATEGORY_VULNERABILITY` |
| `sast` | `spec.finding_categories contains FINDING_CATEGORY_SAST` |
| `secrets`, `secret` | `spec.finding_categories contains FINDING_CATEGORY_SECRETS` |
| `license` | `spec.finding_categories contains FINDING_CATEGORY_LICENSE_RISK` |
| `no-test`, `exclude test` | `spec.finding_tags not contains FINDING_TAGS_TEST_DEPENDENCY` |

### Combining Filters

Multiple filters are combined with `and`. For example:

- `critical reachable` -> `spec.level==FINDING_LEVEL_CRITICAL and spec.finding_tags contains FINDING_TAGS_REACHABLE_FUNCTION`
- `high vulnerability no-test` -> `spec.level==FINDING_LEVEL_HIGH and spec.finding_categories contains FINDING_CATEGORY_VULNERABILITY and spec.finding_tags not contains FINDING_TAGS_TEST_DEPENDENCY`

## Workflow

### Step 1: Build Filter

Parse user input and construct the API filter string. If no filters specified, default to:

- Critical and High severity
- Excluding test dependencies

### Step 2: Query Findings

**Option A - After a scan:** The `scan` MCP tool returns finding UUIDs sorted by severity. Use these UUIDs with `get_resource` (resource_type: `Finding`) to retrieve details.

**Option B - From platform data:** Run a scan first with `/endor-scan`, then retrieve individual findings using the `get_resource` MCP tool:
- `resource_type`: `Finding`
- `uuid`: Finding UUID from scan results

**Option C - CLI fallback:** Use the endorctl CLI to list findings:
```bash
npx -y endorctl api list --resource Finding -n $ENDOR_NAMESPACE --filter "{filter_string}" 2>/dev/null
```

**Important:** Always redirect stderr with `2>/dev/null` when piping to a JSON parser, as endorctl writes progress messages to stderr that will corrupt the JSON output.

#### CLI Response Structure

The CLI returns JSON with this structure. Use these exact field paths when parsing:

```
{
  "list": {
    "objects": [
      {
        "uuid": "...",
        "meta": {
          "description": "GHSA-xxxx: Human-readable title",  // <-- Use for display title
          "name": "finding_type_name"
        },
        "spec": {
          "level": "FINDING_LEVEL_CRITICAL",                  // <-- Severity level
          "extra_key": "GHSA-xxxx-xxxx-xxxx",                 // <-- GHSA/CVE identifier
          "target_dependency_package_name": "pypi://pkg@1.0", // <-- NOTE: includes ecosystem prefix
          "target_dependency_version": "1.0",
          "finding_categories": ["FINDING_CATEGORY_VULNERABILITY", ...],
          "finding_tags": ["FINDING_TAGS_REACHABLE_FUNCTION", ...],
          "remediation": "Update project to use pkg version 1.2.3 (current: 1.0, latest: 2.0).",  // <-- Plain string, NOT a nested object
          "finding_metadata": {
            "vulnerability": {
              "meta": { "name": "GHSA-xxxx-xxxx-xxxx" },     // <-- GHSA ID
              "spec": {
                "summary": "Short vulnerability description",
                "cvss_v3_severity": { "score": 9.8 }          // <-- CVSS score
              }
            }
          }
        }
      }
    ]
  }
}
```

**Key gotchas when parsing CLI output:**
- `spec.remediation` is a **plain string** (e.g., `"Update ... to use pkg version X.Y.Z"`), NOT a nested object
- `spec.target_dependency_package_name` includes the ecosystem prefix (e.g., `pypi://django@4.2`). Strip the prefix for display.
- The CVE/GHSA ID is in `spec.extra_key` or `spec.finding_metadata.vulnerability.meta.name`
- CVSS score is at `spec.finding_metadata.vulnerability.spec.cvss_v3_severity.score`

### Step 3: Present Results

```markdown
## Security Findings

**Filter:** {human-readable filter description}
**Total:** {count} findings

### Findings

| # | Severity | Category | Package | CVE/Issue | Reachable | Description |
|---|----------|----------|---------|-----------|-----------|-------------|
| 1 | Critical | Vuln | {pkg} | {cve} | Yes | {desc} |
| 2 | High | SAST | {file} | {rule} | N/A | {desc} |
| 3 | High | Vuln | {pkg} | {cve} | No | {desc} |

### Summary

- {n} Critical ({r} reachable)
- {n} High ({r} reachable)
- {n} Secrets
- {n} SAST issues
- {n} License risks

### Next Steps

1. **Fix top issue:** `/endor-fix {top-cve}`
2. **Explain a finding:** `/endor-explain {cve}`
3. **Narrow results:** `/endor-findings critical reachable`
4. **View SAST details:** `/endor-findings sast`
```

### Step 4: Pagination

If more results are available, inform the user and offer to show the next page.

## Priority Order

Always present findings in this priority:

1. Critical + Reachable
2. High + Reachable
3. Secrets/Credentials
4. Critical + Unreachable
5. SAST Critical/High
6. License issues
7. Medium/Low

## Data Sources — Endor Labs Only

**CRITICAL: NEVER use external websites for finding details or vulnerability information.** All data MUST come from Endor Labs MCP tools or the `endorctl` CLI. Do NOT search the web or visit external vulnerability databases. If data is unavailable, tell the user and suggest [app.endorlabs.com](https://app.endorlabs.com).

## Error Handling

- **No findings**: Could mean no scan has been run. Suggest `/endor-scan`.
- **Auth error**: Suggest `/endor-setup`
- **Filter syntax error**: Show the user the correct filter format
