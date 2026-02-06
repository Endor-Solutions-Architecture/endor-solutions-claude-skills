---
name: endor-scan
description: |
  Perform a fast security scan of the current repository using Endor Labs. Identifies vulnerabilities, license issues, and secrets without full reachability analysis.
  - MANDATORY TRIGGERS: endor scan, quick scan, security scan, scan repo, scan repository, scan my code, endor-scan
---

# Endor Labs Quick Scan

Perform a fast security scan of the current repository. This provides a rapid overview without full reachability analysis.

## Prerequisites

- Endor Labs MCP server configured (run `/endor-setup` if not)
- Current directory is a repository with source code

## Workflow

### Step 1: Detect Repository Context

Identify the repository being scanned:

1. Check the current working directory
2. Detect languages by looking for manifest files:
   - `package.json` / `yarn.lock` -> JavaScript/TypeScript
   - `go.mod` / `go.sum` -> Go
   - `requirements.txt` / `pyproject.toml` / `setup.py` -> Python
   - `pom.xml` / `build.gradle` -> Java
   - `Cargo.toml` -> Rust
   - `*.csproj` -> .NET
   - `Gemfile` -> Ruby
   - `composer.json` -> PHP

### Step 2: Run Scan

Use the `scan` MCP tool with **all scan types** enabled:

- `path`: Current working directory (or user-specified path)
- `scan_types`: `["vulnerabilities", "dependencies", "sast", "secrets"]`

**IMPORTANT:** Always include `"sast"` in `scan_types`. Without it, SAST findings will not be returned.

If the user explicitly requests specific scan types (e.g. "only SCA" or "only SAST"), adjust `scan_types` accordingly, but the default should always include all four types above.

If the MCP tool is not available or fails due to auth errors, fall back to CLI:

```bash
endorctl scan --path . --quick-scan --dependencies --sast --secrets --output-type summary
```

**IMPORTANT:** The `--sast` flag must be explicitly passed to the CLI. Without it, only SCA/dependency findings are returned. Similarly, `--secrets` must be explicit. The `--dependencies` flag enables SCA scanning.

### Step 3: Present Results

Format the scan results using this structure:

```markdown
## Security Scan Complete

**Path:** {scanned path}
**Languages:** {detected languages}
**Scan Type:** Quick (no reachability analysis)

### Vulnerability Summary

| Severity | Count | Action |
|----------|-------|--------|
| Critical | {n} | Fix immediately |
| High | {n} | Fix urgently |
| Medium | {n} | Plan remediation |
| Low | {n} | Track as debt |

### Top Critical/High Findings

| # | Package | CVE | Severity | Description |
|---|---------|-----|----------|-------------|
| 1 | {pkg} | {cve} | Critical | {desc} |
| 2 | {pkg} | {cve} | High | {desc} |

### Other Issues

- **Secrets found:** {count} (run `/endor-secrets` for details)
- **SAST issues:** {count} (run `/endor-sast` for details)
- **License risks:** {count} (run `/endor-license` for details)

### Next Steps

1. **Fix critical issues:** `/endor-fix {top-cve}`
2. **Deep analysis:** `/endor-scan-full` for reachability analysis
3. **View all findings:** `/endor-findings`
```

### Priority Order

Present findings in this order:
1. Critical vulnerabilities
2. High vulnerabilities
3. Secrets/credentials
4. SAST critical/high
5. License issues
6. Medium/Low findings

## Error Handling

- **Auth error**: Suggest `/endor-setup`
- **No manifest found**: Tell user no supported project detected, list supported languages
- **Scan timeout**: Suggest `/endor-scan-full` which handles larger repos better
- **MCP not available**: Fall back to CLI command
