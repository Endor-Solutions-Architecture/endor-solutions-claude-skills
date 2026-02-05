---
name: endor-findings
description: Display security findings from the Endor Labs platform
---

# Endor Labs: Show Findings

Display and filter security findings from the Endor Labs platform.

## Arguments

$ARGUMENTS - Optional filters: `critical`, `high`, `reachable`, `sast`, `secrets`, `license`, `container`, `all`

Multiple filters can be combined: `/endor-findings critical reachable`

## Instructions

### Parse Filter Arguments

| Argument | Filter Applied |
|----------|---------------|
| `critical` | `spec.level==FINDING_LEVEL_CRITICAL` |
| `high` | `spec.level==FINDING_LEVEL_HIGH` |
| `medium` | `spec.level==FINDING_LEVEL_MEDIUM` |
| `reachable` | `spec.finding_tags contains FINDING_TAGS_REACHABLE_FUNCTION` |
| `unreachable` | `spec.finding_tags not contains FINDING_TAGS_REACHABLE_FUNCTION` |
| `sast` | `spec.finding_categories contains FINDING_CATEGORY_SAST` |
| `secrets` | `spec.finding_categories contains FINDING_CATEGORY_SECRETS` |
| `vulns` | `spec.finding_categories contains FINDING_CATEGORY_VULNERABILITY` |
| `license` | `spec.finding_categories contains FINDING_CATEGORY_LICENSE_RISK` |
| `container` | `spec.finding_categories contains FINDING_CATEGORY_CONTAINER` |
| `no-test` | `spec.finding_tags not contains FINDING_TAGS_TEST_DEPENDENCY` |
| `all` | No filter (show everything) |
| (none) | Show summary + critical reachable details |

### Build Filter String

Combine multiple filters with ` and `:
```
spec.level==FINDING_LEVEL_CRITICAL and spec.finding_tags contains FINDING_TAGS_REACHABLE_FUNCTION
```

### Call API

Use `get_security_findings` MCP tool with the constructed filter.

### Present Results

**Default View (no arguments):**
```markdown
## Security Findings Summary

**Namespace:** {namespace}
**Last Updated:** {timestamp}

### Overview

| Category | Critical | High | Medium | Low | Total |
|----------|----------|------|--------|-----|-------|
| Vulnerabilities | 2 (1 reachable) | 5 | 12 | 8 | 27 |
| SAST | 1 | 3 | 8 | 15 | 27 |
| Secrets | 1 | 0 | 0 | 0 | 1 |
| License | 0 | 2 | 0 | 0 | 2 |

### Priority: Critical + Reachable ({count})

These need immediate attention - they're exploitable in your code.

| Finding | Package/File | CVE/Rule | Description |
|---------|-------------|----------|-------------|
| Prototype Pollution | lodash@4.17.15 | CVE-2021-23337 | Reachable via src/utils.js:42 |
| SQL Injection | src/api/db.js:45 | CWE-89 | User input flows to query |

### Quick Actions

| Action | Command |
|--------|---------|
| Fix critical issues | `/endor-fix` |
| See all critical | `/endor-findings critical` |
| See only reachable | `/endor-findings reachable` |
| Deep dive on CVE | `/endor-explain CVE-XXXX` |
```

**Filtered View:**
```markdown
## Security Findings: {filter_description}

**Filter:** {raw_filter}
**Results:** {count} findings

### Findings

| # | Type | Finding | Severity | Details |
|---|------|---------|----------|---------|
| 1 | Vulnerability | CVE-2021-23337 in lodash@4.17.15 | CRITICAL | Prototype Pollution |
| 2 | Vulnerability | CVE-2021-3749 in axios@0.21.0 | HIGH | SSRF |
| 3 | SAST | SQL Injection in db.js:45 | CRITICAL | CWE-89 |

### Finding Details

#### 1. CVE-2021-23337 (lodash)
- **Severity:** CRITICAL
- **Reachable:** Yes - called from `src/utils/data.js:42`
- **Description:** Prototype Pollution vulnerability in set/setWith functions
- **Fix:** Upgrade to lodash@4.17.21

---

### Next Steps

1. **Fix these issues:** `/endor-fix`
2. **Get more details:** `/endor-explain CVE-2021-23337`
3. **Refine search:** `/endor-findings critical reachable no-test`
```

**No Results:**
```markdown
## No Findings Match Your Filter

**Filter applied:** {filter}

This could mean:
1. Great news - no issues match this filter!
2. The project hasn't been scanned yet
3. The filter is too restrictive

### Try These Alternatives

| To See | Command |
|--------|---------|
| All findings | `/endor-findings all` |
| Just critical | `/endor-findings critical` |
| All vulnerabilities | `/endor-findings vulns` |
| Run a new scan | `/endor-scan` |
```

## Error Handling

### No Project Found
```markdown
## No Findings Available

No security findings found for this namespace. This usually means:

1. **Project not scanned yet** - Run `/endor-scan` first
2. **Wrong namespace** - Check `echo $ENDOR_NAMESPACE`
3. **No issues** - Your project might be clean!

**To scan now:**
```
/endor-scan
```
```

### Authentication Error
```markdown
## Authentication Required

Can't retrieve findings - please authenticate first.

```bash
endorctl init
```

Or run `/endor-setup` for guided setup.
```

### Invalid Filter
```markdown
## Invalid Filter

The filter `{filter}` isn't recognized.

**Valid filters:**
- Severity: `critical`, `high`, `medium`, `low`
- Type: `vulns`, `sast`, `secrets`, `license`, `container`
- Reachability: `reachable`, `unreachable`
- Scope: `no-test`, `all`

**Examples:**
```
/endor-findings critical reachable
/endor-findings sast high
/endor-findings secrets
```
```

## Filter Combinations

### Common Useful Filters

| Use Case | Command |
|----------|---------|
| Exploitable now | `/endor-findings critical reachable` |
| All critical | `/endor-findings critical` |
| Production issues only | `/endor-findings critical no-test` |
| Code vulnerabilities | `/endor-findings sast` |
| Credential leaks | `/endor-findings secrets` |
| License problems | `/endor-findings license` |
| Container issues | `/endor-findings container` |
| Everything | `/endor-findings all` |
