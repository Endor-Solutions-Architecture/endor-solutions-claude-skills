---
name: endor-scan
description: |
  Perform a fast security scan of the current repository using Endor Labs. Identifies vulnerabilities, license issues, and secrets without full reachability analysis.
  - MANDATORY TRIGGERS: endor scan, quick scan, security scan, scan repo, scan repository, scan my code, endor-scan
---

# Endor Labs Quick Scan

Perform a fast security scan of the current repository.

## Prerequisites

- Endor Labs MCP server configured (run `/endor-setup` if not)
- Current directory is a repository with source code

## Workflow

### Step 1: Detect Repository Context

Identify the repository being scanned:

1. Determine the **absolute path** to the current working directory (the scan tool requires fully qualified paths)
2. Detect languages by looking for manifest files:
   - `package.json` / `yarn.lock` -> JavaScript/TypeScript
   - `go.mod` / `go.sum` -> Go
   - `requirements.txt` / `pyproject.toml` / `setup.py` -> Python
   - `pom.xml` / `build.gradle` -> Java
   - `Cargo.toml` -> Rust

### Step 2: Run Scan

Use the `scan` MCP tool with **all scan types** enabled:

- `path`: The **absolute path** to the repository root (required - must be fully qualified, not relative)
- `scan_types`: `["vulnerabilities", "dependencies", "sast", "secrets"]`
- `scan_options`: `{ "quick_scan": true }`

**IMPORTANT:** Always include `"sast"` in `scan_types`. Without it, SAST findings will not be returned.

If the user explicitly requests specific scan types (e.g. "only SCA" or "only SAST"), adjust `scan_types` accordingly, but the default should always include all four types above.

If the MCP tool is not available or fails due to auth errors, fall back to CLI:

```bash
endorctl scan --path . --quick-scan --dependencies --sast --secrets --output-type summary
```

**IMPORTANT:** The `--sast` flag must be explicitly passed to the CLI. Without it, only SCA/dependency findings are returned. Similarly, `--secrets` must be explicit. The `--dependencies` flag enables SCA scanning.

### Step 3: Retrieve Finding Details

The scan tool returns a list of finding UUIDs sorted by severity. For each critical/high finding, use the `get_resource` MCP tool to retrieve details:

- `uuid`: The finding UUID from the scan results
- `resource_type`: `Finding`

### Step 4: Present Results

```markdown
## Security Scan Complete

**Path:** {scanned path}
**Languages:** {detected languages}
**Scan Type:** Quick

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

### Next Steps

1. **Fix critical issues:** `/endor-fix {top-cve}`
2. **Deep analysis:** `/endor-scan-full` for full reachability analysis
3. **Check a specific package:** `/endor-check {package}`
4. **View vulnerability details:** `/endor-explain {cve}`
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

- **Auth error / browser opens**: Expected on first use. Tell user to complete browser login, then retry.
- **No manifest found**: Tell user no supported project detected, list supported languages
- **Scan timeout**: Suggest using fewer scan_types or scanning a subdirectory
- **MCP not available**: Fall back to CLI command, suggest `/endor-setup`
