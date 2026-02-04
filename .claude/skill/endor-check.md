# Endor Labs: Check Dependency

Check if a specific dependency has known vulnerabilities.

## Arguments

$ARGUMENTS - The dependency to check in format: `package@version` or `package version` or just `package`

## Instructions

1. Parse the input to extract:
   - Package name
   - Version (if provided, otherwise check latest)
   - Language (infer from package name patterns or ask)

2. Language inference:
   - Starts with `@` → JavaScript (scoped npm package)
   - Contains `/` with no `@` → Could be Go or other
   - Common names: `lodash`, `axios`, `react` → JavaScript
   - Common names: `requests`, `django`, `flask` → Python
   - If uncertain, check for manifest files in current directory

3. Call `check_dependency_for_vulnerabilities` MCP tool:
```json
{
  "language": "javascript|python|go|java|rust|dotnet|ruby|php",
  "dependency": "package-name",
  "version": "1.2.3"
}
```

4. Present results:

**If vulnerable:**
```markdown
## Vulnerability Found

**Package:** {package}@{version}
**Language:** {language}

### Vulnerabilities

| CVE | Severity | Description |
|-----|----------|-------------|
| CVE-2021-XXXXX | CRITICAL | Brief description |

### Recommendation

Upgrade to **{safe_version}** which fixes all known vulnerabilities.

```bash
# For npm
npm install {package}@{safe_version}

# For yarn
yarn add {package}@{safe_version}
```
```

**If safe:**
```markdown
## No Vulnerabilities Found

**Package:** {package}@{version}
**Status:** Safe to use

No known vulnerabilities in this version.
```

5. If version not provided, warn that checking "latest" and recommend pinning versions.
