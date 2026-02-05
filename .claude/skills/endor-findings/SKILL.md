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

Use the `get_security_findings` MCP tool:

- `filter`: Constructed filter string
- `page_size`: 20 (default, adjustable)

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

## Error Handling

- **No findings**: Could mean no scan has been run. Suggest `/endor-scan`.
- **Auth error**: Suggest `/endor-setup`
- **Filter syntax error**: Show the user the correct filter format
