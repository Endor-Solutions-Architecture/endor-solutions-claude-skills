---
name: endor-sbom
description: Manage Software Bill of Materials (SBOM) - export, import, analyze, and compare
---

# Endor Labs: SBOM Management

Manage Software Bill of Materials (SBOM) - export, import, analyze, and compare SBOMs.

## Arguments

$ARGUMENTS - Action and options: `export`, `import`, `analyze`, `compare`, `validate`

## Instructions

### Parse Arguments

| Argument | Action |
|----------|--------|
| `export` | Export SBOM from a project |
| `export cyclonedx` | Export in CycloneDX format |
| `export spdx` | Export in SPDX format |
| `import <file>` | Import an SBOM file |
| `analyze` | Analyze current project's SBOM |
| `compare <sbom1> <sbom2>` | Compare two SBOMs |
| `validate <file>` | Validate SBOM format |
| No argument | Show SBOM summary for current project |

### Export SBOM

Use endorctl CLI for SBOM export:

```bash
# Get project UUID first
endorctl api list --resource Project --filter "meta.name==project-name"

# Export CycloneDX (default)
endorctl sbom export --project-uuid {uuid} --format cyclonedx --output sbom.json

# Export SPDX
endorctl sbom export --project-uuid {uuid} --format spdx --output sbom.spdx.json
```

**Present export options:**
```markdown
## SBOM Export

**Project:** {project_name}
**Available Formats:**

| Format | File | Use Case |
|--------|------|----------|
| CycloneDX 1.5 | sbom.cdx.json | Industry standard, vulnerability tracking |
| SPDX 2.3 | sbom.spdx.json | License compliance, legal requirements |

**Command to export:**
```bash
endorctl sbom export --project-uuid {uuid} --format cyclonedx --output sbom.cdx.json
```

**Include in build pipeline:**
```yaml
- name: Generate SBOM
  run: endorctl sbom export --project-uuid $PROJECT_UUID --format cyclonedx --output sbom.json

- name: Upload SBOM artifact
  uses: actions/upload-artifact@v4
  with:
    name: sbom
    path: sbom.json
```
```

### Import SBOM

```bash
# Import and analyze an external SBOM
endorctl sbom import --file sbom.json --namespace $ENDOR_NAMESPACE
```

**After import, analyze for vulnerabilities:**
```markdown
## SBOM Import Results

**File:** {filename}
**Format:** {detected_format}
**Components:** {count}

### Vulnerability Analysis

After importing, I'll scan the SBOM components for known vulnerabilities.

| Component | Version | Vulnerabilities | Severity |
|-----------|---------|-----------------|----------|
| lodash | 4.17.15 | 3 | CRITICAL |
| axios | 0.21.0 | 1 | HIGH |
| express | 4.17.1 | 0 | - |

### License Summary

| License | Count | Risk |
|---------|-------|------|
| MIT | 45 | Low |
| Apache-2.0 | 23 | Low |
| GPL-3.0 | 2 | High (copyleft) |
```

### Analyze SBOM

Query the project's dependency information:

1. Use `get_security_findings` to get vulnerability data
2. Use API to get package-versions for the project
3. Compile component inventory

```markdown
## SBOM Analysis

**Project:** {project_name}
**Total Components:** {count}
**Direct Dependencies:** {direct_count}
**Transitive Dependencies:** {transitive_count}

### Component Breakdown by Language

| Language | Components | Percentage |
|----------|------------|------------|
| JavaScript | 156 | 62% |
| Python | 45 | 18% |
| Go | 50 | 20% |

### Security Status

| Severity | Vulnerable Components |
|----------|----------------------|
| Critical | 2 |
| High | 5 |
| Medium | 12 |
| Low | 8 |

### Top Risk Components

| Component | Version | Issues | Risk Score |
|-----------|---------|--------|------------|
| lodash | 4.17.15 | 3 CVEs | 9.8 |
| minimist | 1.2.5 | 1 CVE | 7.5 |

### License Distribution

| License | Count | Commercial Use |
|---------|-------|----------------|
| MIT | 89 | Allowed |
| Apache-2.0 | 45 | Allowed |
| ISC | 12 | Allowed |
| GPL-3.0 | 2 | Restricted |

### Recommendations

1. Update lodash to 4.17.21 to fix critical vulnerabilities
2. Review GPL-3.0 components for license compliance
3. Consider generating SBOM for compliance requirements
```

### Compare SBOMs

Compare two SBOMs to identify differences (useful for tracking changes):

```markdown
## SBOM Comparison

**Baseline:** sbom-v1.0.json ({date})
**Current:** sbom-v1.1.json ({date})

### Summary

| Metric | Baseline | Current | Change |
|--------|----------|---------|--------|
| Total Components | 145 | 152 | +7 |
| Direct Dependencies | 25 | 27 | +2 |
| Vulnerabilities | 8 | 3 | -5 |

### Added Components

| Component | Version | License | Vulnerabilities |
|-----------|---------|---------|-----------------|
| zod | 3.22.0 | MIT | 0 |
| @tanstack/query | 5.0.0 | MIT | 0 |

### Removed Components

| Component | Version | Reason |
|-----------|---------|--------|
| moment | 2.29.1 | Replaced with date-fns |

### Updated Components

| Component | Old Version | New Version | CVEs Fixed |
|-----------|-------------|-------------|------------|
| lodash | 4.17.15 | 4.17.21 | 3 |
| axios | 0.21.0 | 1.6.0 | 1 |

### New Vulnerabilities

None introduced.

### Fixed Vulnerabilities

| CVE | Component | Severity |
|-----|-----------|----------|
| CVE-2021-23337 | lodash | CRITICAL |
| CVE-2020-8203 | lodash | HIGH |
```

### Validate SBOM

Check if an SBOM file is valid and complete:

```markdown
## SBOM Validation Results

**File:** {filename}
**Format:** CycloneDX 1.5
**Status:** Valid

### Validation Checks

| Check | Status | Notes |
|-------|--------|-------|
| Schema Valid | ✅ Pass | Conforms to CycloneDX 1.5 |
| Required Fields | ✅ Pass | All required fields present |
| Component Names | ✅ Pass | All components have valid names |
| Version Format | ✅ Pass | Versions follow semver |
| License Info | ⚠️ Partial | 12 components missing license |
| PURL Format | ✅ Pass | Package URLs are valid |
| Hash Integrity | ✅ Pass | SHA-256 hashes present |

### Missing Information

**Components without license data:**
- custom-internal-lib@1.0.0
- legacy-module@2.3.4
- ...

### Recommendations

1. Add license information to internal components
2. Consider adding supplier information for compliance
3. Include vulnerability data for NTIA minimum elements
```

## SBOM Compliance Standards

### NTIA Minimum Elements
- Supplier Name
- Component Name
- Version
- Unique Identifier
- Dependency Relationship
- Author of SBOM Data
- Timestamp

### Executive Order 14028 Requirements
- Machine-readable format (CycloneDX or SPDX)
- Generated at build time
- Include all dependencies (direct and transitive)
- Signed or integrity-verified

## Integration Examples

### GitHub Actions
```yaml
- name: Generate SBOM
  run: |
    endorctl scan --path . --output-type sbom

- name: Upload to Dependency Graph
  uses: actions/upload-artifact@v4
  with:
    name: sbom
    path: sbom.cdx.json
```

### GitLab CI
```yaml
sbom:
  stage: build
  script:
    - endorctl sbom export --format cyclonedx --output sbom.json
  artifacts:
    paths:
      - sbom.json
```
