---
name: endor-check
description: Check if a specific dependency has known vulnerabilities
---

# Endor Labs: Check Dependency

Check if a specific dependency has known vulnerabilities before adding it to your project.

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
   - Common JavaScript: `lodash`, `axios`, `react`, `express`, `moment`, `jquery`
   - Common Python: `requests`, `django`, `flask`, `numpy`, `pandas`, `tensorflow`
   - Common Go: Typically has domain prefix like `github.com/`
   - If uncertain, check for manifest files in current directory to infer language

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
## Vulnerability Check: {package}@{version}

**Status:** VULNERABLE
**Language:** {language}

### Vulnerabilities Found ({count})

| CVE | Severity | Description | Fixed In |
|-----|----------|-------------|----------|
| CVE-2021-XXXXX | CRITICAL | Brief description | {version} |
| CVE-2020-XXXXX | HIGH | Brief description | {version} |

### What This Means

{Brief explanation of the most severe vulnerability and its impact}

### Recommendation

**Upgrade to {safe_version}** which fixes all known vulnerabilities.

```bash
# npm
npm install {package}@{safe_version}

# yarn
yarn add {package}@{safe_version}

# pnpm
pnpm add {package}@{safe_version}
```

### Want More Details?

- `/endor-explain CVE-XXXX` - Get detailed CVE information
- `/endor-score {package}` - Check overall package health
```

**If safe:**
```markdown
## Vulnerability Check: {package}@{version}

**Status:** No known vulnerabilities
**Language:** {language}

This version has no known security vulnerabilities.

### Additional Checks

For a complete evaluation, also consider:
- `/endor-score {package}` - Check package health scores
- `/endor-license check {package}` - Verify license compatibility
```

5. If version not provided:
```markdown
## Vulnerability Check: {package}

**Note:** No version specified - checking latest version.

{results}

### Recommendation

Always pin dependency versions in production. Using `latest` or unpinned versions can introduce vulnerabilities when packages update.

```json
// package.json - Good
"{package}": "4.17.21"

// package.json - Risky
"{package}": "latest"
"{package}": "^4.0.0"
```
```

## Error Handling

### Package Not Found
```markdown
## Package Not Found

I couldn't find a package called `{package}` in the {language} ecosystem.

**Possible issues:**
- Typo in the package name
- Wrong language/ecosystem assumed
- Private or unpublished package

**Try:**
- Double-check the spelling
- Specify the language: `/endor check python:requests@2.28.0`
- Check the package registry directly
```

### Version Not Found
```markdown
## Version Not Found

The package `{package}` exists, but version `{version}` wasn't found.

**Available versions include:**
- {latest_version} (latest)
- {other_versions}...

**Try:**
```
/endor check {package}@{latest_version}
```
```

### Language Ambiguous
If language cannot be determined:
```markdown
## Which Language?

I found `{package}` in multiple ecosystems:
- JavaScript (npm)
- Python (PyPI)

**Specify the language:**
```
/endor check javascript:{package}@{version}
/endor check python:{package}@{version}
```

**Or:** I can check your project's manifest files to determine the language.
```

### Authentication/Setup Errors
```markdown
## Setup Required

The check couldn't complete. Run `/endor-setup` to configure Endor Labs.
```

## Examples

```
/endor check lodash@4.17.20       # Check specific version
/endor check axios                 # Check latest version
/endor check @babel/core@7.20.0   # Scoped npm package
/endor check python:requests@2.28 # Explicit language
/endor check github.com/gin-gonic/gin@1.9.0  # Go package
```
