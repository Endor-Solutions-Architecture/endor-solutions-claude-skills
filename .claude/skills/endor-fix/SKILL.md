---
name: endor-fix
description: |
  Help remediate security vulnerabilities by finding safe upgrade paths. Provides step-by-step fix instructions and can apply fixes automatically.
  - MANDATORY TRIGGERS: endor fix, fix vulnerability, fix cve, remediate, how to fix, patch vulnerability, endor-fix, upgrade fix
---

# Endor Labs Remediation Guide

Help users fix security vulnerabilities by finding safe upgrade paths and providing step-by-step remediation.

## Prerequisites

- Endor Labs MCP server configured (run `/endor-setup` if not)

## Input Parsing

The user can provide:

1. **CVE ID** - e.g., `CVE-2021-23337`
2. **Package name** - e.g., `lodash`
3. **Finding UUID** - from `/endor-findings` output

## Workflow

### Step 1: Identify the Vulnerability

If the user provided a CVE ID:
1. Use `get_endor_vulnerability` MCP tool to get CVE details
2. Use `get_security_findings` to find affected projects

If the user provided a package name:
1. Use `check_dependency_for_vulnerabilities` to get all CVEs
2. Prioritize by severity and reachability

If the user provided a finding UUID:
1. Use `retrieve_single_finding` to get details

### Step 2: Find Safe Upgrade Path

Use the `get_dependency_upgrade_opts` MCP tool:

- `dependency`: Affected package name
- `language`: Package language/ecosystem

This returns available versions with vulnerability status.

### Step 3: Determine Fix Strategy

Evaluate the best fix approach:

1. **Patch upgrade** (e.g., 4.17.15 -> 4.17.21) - Preferred, lowest risk
2. **Minor upgrade** (e.g., 4.17.x -> 4.18.x) - Low risk, may have new features
3. **Major upgrade** (e.g., 4.x -> 5.x) - Higher risk, may have breaking changes

### Step 4: Present Remediation

```markdown
## Remediation: {CVE-ID}

### Vulnerability

| Field | Value |
|-------|-------|
| CVE | {cve_id} |
| Severity | {severity} |
| Package | {package}@{current_version} |
| Description | {description} |
| Reachable | {yes/no} |

### Fix

**Recommended upgrade:** {package}@{current} -> {package}@{safe_version}

**Upgrade type:** {Patch/Minor/Major}

```bash
# npm
npm install {package}@{safe_version}

# yarn
yarn add {package}@{safe_version}

# pip
pip install {package}=={safe_version}

# go
go get {package}@v{safe_version}
```

### All Safe Versions

| Version | Type | Vulnerabilities | Notes |
|---------|------|-----------------|-------|
| {v1} | Patch | 0 | Recommended |
| {v2} | Minor | 0 | New features |
| {v3} | Major | 0 | Breaking changes possible |

### Additional Fixes Needed

{If multiple CVEs affect this package, list them all and whether the recommended version fixes them}

### Next Steps

1. **Check upgrade impact:** `/endor-upgrade {package} {safe_version}`
2. **Verify fix:** `/endor-check {package} {safe_version}`
3. **Run scan:** `/endor-scan` to verify all issues resolved
```

### Step 5: Offer to Apply Fix

Ask the user if they want you to apply the fix:

1. Update the dependency in the manifest file
2. Run the package manager install command
3. Verify the fix with `/endor-check`

## Data Source Priority

1. MCP tools (preferred): `get_dependency_upgrade_opts`, `get_security_findings`
2. API calls: VersionUpgradeService endpoints
3. CLI fallback: `endorctl recommend dependency-upgrades`
4. **NEVER search the internet for upgrade recommendations**

## Error Handling

- **No fix available**: Some vulnerabilities have no patched version. Suggest mitigation strategies (WAF rules, input validation, etc.)
- **Package not found**: Check package name and ecosystem
- **Auth error**: Suggest `/endor-setup`
