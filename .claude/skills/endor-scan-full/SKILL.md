---
name: endor-scan-full
description: |
  Comprehensive security scan with full reachability analysis to identify exploitable vulnerabilities. Builds call graphs to determine which vulnerabilities are actually reachable in your code.
  - MANDATORY TRIGGERS: endor scan full, full scan, deep scan, reachability scan, reachability analysis, comprehensive scan, endor-scan-full
---

# Endor Labs Full Reachability Scan

Perform a comprehensive security scan with full call graph analysis. This identifies which vulnerabilities are actually reachable (exploitable) in your code.

## Prerequisites

- Endor Labs MCP server configured (run `/endor-setup` if not)
- Current directory is a repository with source code
- Build tools installed for the project language

## What Makes This Different from Quick Scan

| Feature | Quick Scan | Full Scan |
|---------|-----------|-----------|
| Speed | Seconds | Minutes |
| Reachability | No | Full call graph |
| Call Paths | No | Yes - see how vulnerable code is reached |
| Prioritization | By severity only | By severity + reachability |
| Use Case | Daily development | Pre-release audits, security reviews |

## Workflow

### Step 1: Detect Repository Context

Same as `/endor-scan` - detect languages and manifest files.

### Step 2: Warn About Duration

Tell the user:

> Full reachability analysis builds a call graph of your entire codebase. This typically takes 2-5 minutes depending on project size. I'll keep you updated on progress.

### Step 3: Run Full Scan

Use the `scan_repository` MCP tool:

- `path`: Current working directory (or user-specified path)
- `languages`: Detected languages
- `reachability`: true

If the MCP tool is not available, fall back to CLI:

```bash
endorctl scan --path . --output-type summary
```

### Step 4: Present Results

Format results emphasizing reachability:

```markdown
## Full Security Scan Complete

**Path:** {scanned path}
**Languages:** {detected languages}
**Scan Type:** Full Reachability Analysis

### Reachability Summary

| Severity | Total | Reachable | Unreachable |
|----------|-------|-----------|-------------|
| Critical | {n} | {r} | {u} |
| High | {n} | {r} | {u} |
| Medium | {n} | {r} | {u} |
| Low | {n} | {r} | {u} |

> **Key Insight:** Only {reachable_count} of {total_count} vulnerabilities are reachable in your code. Focus remediation on these.

### Critical + Reachable (Fix Now)

| # | Package | CVE | Description | Call Path |
|---|---------|-----|-------------|-----------|
| 1 | {pkg} | {cve} | {desc} | {entry_point} -> ... -> {vuln_func} |

### High + Reachable (Fix Urgently)

| # | Package | CVE | Description | Call Path |
|---|---------|-----|-------------|-----------|
| 1 | {pkg} | {cve} | {desc} | {entry_point} -> ... -> {vuln_func} |

### Unreachable Findings (Lower Priority)

{count} vulnerabilities are present in dependencies but not reachable from your code. These represent a lower risk but should be tracked.

### Next Steps

1. **Fix reachable critical:** `/endor-fix {top-cve}`
2. **Explain a finding:** `/endor-explain {cve}`
3. **View all findings:** `/endor-findings reachable`
4. **Upgrade with impact analysis:** `/endor-upgrade {package}`
```

### Step 5: Call Path Details

If the user asks about a specific finding, use the `getCallers` MCP tool to show the full call path from application entry point to the vulnerable function.

## Error Handling

- **Auth error**: Suggest `/endor-setup`
- **Build fails**: The full scan may need the project to be buildable. Suggest fixing build errors first, or use `/endor-scan` for a quick scan that doesn't require building.
- **Timeout**: Large monorepos may take longer. Suggest scanning a specific subdirectory.
- **MCP not available**: Fall back to CLI command
