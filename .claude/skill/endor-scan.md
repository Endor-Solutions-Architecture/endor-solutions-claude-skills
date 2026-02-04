# Endor Labs: Quick Scan

Perform a quick security scan of the current repository.

## Instructions

1. Detect the project root directory (current working directory)
2. Identify programming languages by checking for manifest files:
   - `package.json` → JavaScript/TypeScript
   - `go.mod` → Go
   - `requirements.txt`, `pyproject.toml` → Python
   - `pom.xml`, `build.gradle` → Java
   - `Cargo.toml` → Rust
   - `*.csproj` → .NET

3. Call the `scan_repository` MCP tool with:
   - `path`: absolute path to repository root
   - `languages`: detected languages (comma-separated)

4. Present results in this format:

```markdown
## Scan Complete

**Path:** {path}
**Languages:** {languages}

### Critical (Reachable) - Fix Now
| Package | CVE | Description |
|---------|-----|-------------|
| ... | ... | ... |

### High Priority
| Package | CVE | Severity | Reachable |
|---------|-----|----------|-----------|
| ... | ... | ... | ... |

### Summary
- X Critical (Y reachable)
- X High (Y reachable)
- X Medium
- X Low

Next: Run `/endor fix` to remediate critical issues.
```

5. If no vulnerabilities found, congratulate the user and suggest periodic re-scanning.
