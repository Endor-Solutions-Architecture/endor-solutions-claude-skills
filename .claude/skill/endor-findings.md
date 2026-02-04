# Endor Labs: Show Findings

Display security findings from the Endor Labs platform.

## Arguments

$ARGUMENTS - Optional filters: `critical`, `high`, `reachable`, `sast`, `secrets`, `all`

## Instructions

1. Parse filter arguments:
   - `critical` → `spec.level==FINDING_LEVEL_CRITICAL`
   - `high` → `spec.level==FINDING_LEVEL_HIGH`
   - `reachable` → `spec.finding_tags contains FINDING_TAGS_REACHABLE_FUNCTION`
   - `sast` → `spec.finding_categories contains FINDING_CATEGORY_SAST`
   - `secrets` → `spec.finding_categories contains FINDING_CATEGORY_SECRETS`
   - `vulns` → `spec.finding_categories contains FINDING_CATEGORY_VULNERABILITY`
   - `license` → `spec.finding_categories contains FINDING_CATEGORY_LICENSE_RISK`
   - No filter → Show summary of all, details of critical+reachable

2. Build the filter string (combine with ` and `):
   - Default: `spec.level==FINDING_LEVEL_CRITICAL and spec.finding_tags contains FINDING_TAGS_REACHABLE_FUNCTION`

3. Call `get_security_findings` MCP tool with the filter

4. Format results by category:

```markdown
## Security Findings

**Namespace:** {namespace}
**Filter:** {applied_filters}
**Total:** {count} findings

### Vulnerabilities ({count})

| Package | Version | CVE | Severity | Reachable | Project |
|---------|---------|-----|----------|-----------|---------|
| lodash | 4.17.15 | CVE-2021-23337 | CRITICAL | Yes | my-app |

### SAST Findings ({count})

| Rule | Severity | File | Line | Description |
|------|----------|------|------|-------------|
| sql-injection | HIGH | db.js | 45 | SQL injection risk |

### Secrets ({count})

| Type | File | Line | Status |
|------|------|------|--------|
| AWS Key | config.js | 12 | Active |

### License Issues ({count})

| Package | License | Risk | Reason |
|---------|---------|------|--------|
| gpl-lib | GPL-3.0 | HIGH | Copyleft in commercial project |
```

5. Provide actionable next steps based on findings.
