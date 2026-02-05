---
name: endor-scan
description: Perform a fast security scan of the current repository
---

# Endor Labs: Quick Scan

Perform a fast security scan of the current repository. This scan provides rapid vulnerability detection without full call graph analysis.

**For comprehensive reachability analysis**, use `/endor-scan-full` instead.

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

### Next Steps
1. **Fix critical issues:** Run `/endor-fix` to get remediation guidance
2. **Deep analysis:** Run `/endor-scan-full` for complete call graph analysis
3. **Check specific CVE:** Run `/endor-explain CVE-XXXX` for details
```

5. If no vulnerabilities found:
```markdown
## Scan Complete - No Issues Found!

**Path:** {path}
**Languages:** {languages}

Great news - no known vulnerabilities detected in your dependencies.

### Recommendations
- Re-scan periodically or after adding new dependencies
- Set up CI/CD scanning with `/endor-cicd github`
- Run `/endor-scan-full` for comprehensive analysis including SAST
```

## Error Handling

### Authentication Error
If the scan fails with authentication issues:
```markdown
## Authentication Required

The scan couldn't complete because Endor Labs authentication is missing or expired.

**Quick fix:**
```bash
endorctl init
```

This opens your browser to log in.

**Or run the setup wizard:**
```
/endor-setup
```
```

### Namespace Error
If the scan fails with namespace issues:
```markdown
## Namespace Not Configured

Endor Labs needs to know which namespace (organization) to use.

**Set your namespace:**
```bash
export ENDOR_NAMESPACE=your-namespace-here
```

**Find your namespaces:**
```bash
endorctl api list --resource Namespace
```

**Or run the setup wizard:**
```
/endor-setup
```
```

### No Languages Detected
If no supported languages are found:
```markdown
## No Supported Languages Found

I couldn't detect any supported language manifest files in this directory.

**Supported languages:**
- JavaScript/TypeScript (package.json)
- Python (requirements.txt, pyproject.toml, setup.py)
- Go (go.mod)
- Java/Kotlin (pom.xml, build.gradle)
- Rust (Cargo.toml)
- .NET (*.csproj)
- Ruby (Gemfile)
- PHP (composer.json)

**Are you in the right directory?**
Current path: {cwd}

Try navigating to your project root or specify the path:
```
/endor scan /path/to/project
```
```

### MCP Server Not Available
If the MCP server cannot be reached:
```markdown
## Endor Labs Not Available

The Endor Labs MCP server couldn't be reached. This usually means endorctl isn't installed or configured.

**Check installation:**
```bash
which endorctl
endorctl version
```

**Install if needed:**
```bash
brew install endorlabs/tap/endorctl
# or
npm install -g endorctl
```

**Run the setup wizard for guided installation:**
```
/endor-setup
```
```

## Quick Scan vs Full Scan

| Feature | Quick Scan | Full Scan |
|---------|-----------|-----------|
| Speed | Seconds | Minutes |
| Reachability | Basic | Full call graph |
| Call Paths | No | Yes |
| Use Case | Daily checks | Security audits |
