---
name: endor-scan-full
description: Comprehensive security scan with full reachability analysis to identify exploitable vulnerabilities
---

# Endor Labs: Full Scan with Reachability

Perform a comprehensive security scan of the repository with full reachability analysis to identify exploitable vulnerabilities.

## Arguments

$ARGUMENTS - Optional: path to scan (defaults to current working directory)

## Instructions

1. **Detect the project root directory**
   - Use provided path or current working directory
   - Verify it's a valid project directory

2. **Identify programming languages** by checking for manifest files:
   - `package.json` → JavaScript/TypeScript
   - `go.mod` → Go
   - `requirements.txt`, `pyproject.toml`, `setup.py` → Python
   - `pom.xml`, `build.gradle`, `build.gradle.kts` → Java
   - `Cargo.toml` → Rust
   - `*.csproj`, `*.sln` → .NET
   - `Gemfile` → Ruby
   - `composer.json` → PHP

3. **Inform the user** that this is a comprehensive scan:
   ```
   Starting full security scan with reachability analysis...
   This performs deep call graph analysis to identify which vulnerabilities
   are actually exploitable in your code. This may take longer than a quick scan.
   ```

4. **Call the `scan_repository` MCP tool** with:
   - `path`: absolute path to repository root
   - `languages`: detected languages (comma-separated)
   - `reachability`: true (enable full reachability analysis)

5. **While scan is running**, inform the user:
   - Reachability analysis builds a call graph of the entire codebase
   - It traces from entry points (HTTP handlers, main functions, exports) to vulnerable functions
   - Vulnerabilities that can be reached from your code are marked as "reachable"

6. **Present results with reachability focus**:

```markdown
## Full Security Scan Complete

**Path:** {path}
**Languages:** {languages}
**Scan Type:** Full with Reachability Analysis

### Exploitable Vulnerabilities (Reachable) - Fix Immediately

These vulnerabilities can be triggered through your code's execution paths:

| Package | Version | CVE | Severity | Entry Point | Call Path |
|---------|---------|-----|----------|-------------|-----------|
| lodash | 4.17.15 | CVE-2021-23337 | CRITICAL | app.js:handleRequest() | app.js → utils.js → lodash.template() |

### Reachability Details

For each reachable vulnerability, show the call path:
```
Entry Point: src/api/handler.js:processInput()
    ↓ calls src/utils/transform.js:transform()
    ↓ calls node_modules/lodash/template.js:template()
    ✗ VULNERABLE: CVE-2021-23337 (Prototype Pollution)
```

### Non-Reachable Vulnerabilities - Lower Priority

These vulnerabilities exist in your dependencies but cannot be triggered from your code:

| Package | Version | CVE | Severity | Reason |
|---------|---------|-----|----------|--------|
| minimist | 1.2.5 | CVE-2021-44906 | HIGH | No call path from application code |

### Summary by Reachability

| Category | Reachable | Not Reachable | Total |
|----------|-----------|---------------|-------|
| Critical | X | Y | Z |
| High | X | Y | Z |
| Medium | X | Y | Z |
| Low | X | Y | Z |

### Priority Actions

1. **Immediate (Reachable Critical/High):** {count} issues
   - These are actively exploitable - fix now

2. **Soon (Non-Reachable Critical):** {count} issues
   - Not currently exploitable but could become so

3. **Monitor (Non-Reachable High/Medium):** {count} issues
   - Track for future remediation

### Remediation

Run `/endor-fix` to get upgrade paths for reachable vulnerabilities.
```

7. **If reachable vulnerabilities found**, offer to:
   - Show detailed call paths using `getCallers` MCP tool
   - Get upgrade options using `get_dependency_upgrade_opts`
   - Create Jira tickets for tracking

8. **If no reachable vulnerabilities**, congratulate the user:
   ```markdown
   ## Great News!

   No reachable vulnerabilities found in your codebase.

   While there are {count} vulnerabilities in your dependencies,
   none of them can be triggered through your application's code paths.

   **Recommendations:**
   - Consider upgrading dependencies during regular maintenance
   - Re-scan after adding new code that might use vulnerable functions
   - Run `/endor-scan-full` periodically to check for new vulnerabilities
   ```

## Comparison: Quick Scan vs Full Scan

| Feature | Quick Scan (`/endor-scan`) | Full Scan (`/endor-scan-full`) |
|---------|---------------------------|-------------------------------|
| Speed | Fast (seconds) | Slower (minutes) |
| Vulnerability Detection | Yes | Yes |
| Reachability Analysis | Basic | Full call graph |
| Call Path Details | No | Yes |
| Entry Point Mapping | No | Yes |
| Recommended For | Quick checks, CI/CD | Pre-release, security audits |

## When to Use Full Scan

- Before major releases or deployments
- During security audits
- When you need to prioritize fixes based on actual risk
- When reporting to stakeholders (reachability provides context)
- When evaluating if a new CVE affects your application
