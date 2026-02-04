# Endor Labs: Fix Vulnerabilities

Help remediate security vulnerabilities by finding safe upgrade paths.

## Arguments

$ARGUMENTS - Optional: specific CVE ID, package name, or "all" for critical issues

## Instructions

### If specific CVE provided (e.g., "CVE-2021-23337"):

1. Call `get_security_findings` with filter:
   `spec.finding_metadata.vulnerability.spec.aliases contains CVE-2021-23337`

2. Extract the affected package and version

3. Call `get_dependency_upgrade_opts` for that package

4. Present the fix:
```markdown
## Fix for CVE-2021-23337

**Package:** lodash
**Current Version:** 4.17.15
**Vulnerability:** Prototype Pollution

### Safe Versions
- **4.17.21** (recommended) - Fixes this CVE and 2 others
- 4.17.20 - Fixes this CVE only

### How to Fix

**npm:**
```bash
npm install lodash@4.17.21
```

**yarn:**
```bash
yarn add lodash@4.17.21
```

**package.json:**
```json
"dependencies": {
  "lodash": "^4.17.21"
}
```

### Verify
After updating, run `/endor scan` to confirm the fix.
```

### If package name provided (e.g., "lodash"):

1. Call `get_security_findings` filtering for that package
2. List all vulnerabilities affecting it
3. Call `get_dependency_upgrade_opts` to find the version that fixes all issues
4. Present comprehensive upgrade path

### If "all" or no argument:

1. Call `get_security_findings` with:
   `spec.level==FINDING_LEVEL_CRITICAL and spec.finding_tags contains FINDING_TAGS_REACHABLE_FUNCTION`

2. Group findings by package

3. For each package, call `get_dependency_upgrade_opts`

4. Present a remediation plan:
```markdown
## Remediation Plan

### Priority 1: Critical Reachable (Fix Immediately)

#### lodash (4.17.15 → 4.17.21)
- Fixes: CVE-2021-23337, CVE-2020-8203
- Risk: Prototype pollution, actively exploitable
- Command: `npm install lodash@4.17.21`

#### axios (0.21.0 → 1.6.0)
- Fixes: CVE-2021-3749
- Risk: SSRF vulnerability
- Command: `npm install axios@1.6.0`

### Bulk Fix Script

```bash
npm install lodash@4.17.21 axios@1.6.0
```

### After Fixing
1. Run your test suite
2. Run `/endor scan` to verify
3. Commit changes with message: "fix: remediate critical vulnerabilities"
```

### Breaking Changes Warning

If an upgrade involves a major version change:
```markdown
**Warning:** axios 0.21.0 → 1.6.0 is a major version upgrade.

Breaking changes to review:
- Response structure changed
- Some config options renamed

Consider: Test thoroughly or use axios@0.27.2 for a minor upgrade path.
```
