---
name: endor-upgrade
description: Analyze upgrade impact and get safe remediation paths with breaking change detection
---

# Endor Labs: Upgrade Impact Analysis

Analyze the impact of dependency upgrades before making changes. This skill uses Endor Labs' Change Impact Analysis (CIA) to predict breaking changes and recommend safe upgrade paths.

## Arguments

$ARGUMENTS - Package name, "all", "safe", or specific options

## Instructions

### Parse Arguments

| Argument | Action |
|----------|--------|
| (none) | Show upgrade recommendations for all dependencies with vulnerabilities |
| `<package>` | Analyze upgrade impact for specific package |
| `<package>@<version>` | Analyze upgrade to specific version |
| `all` | Show all available upgrades with impact analysis |
| `safe` | Show only low-risk upgrades (high confidence no breaking changes) |
| `risky` | Show upgrades with potential breaking changes |
| `--project <name>` | Analyze specific project |

### API Endpoint

Use the VersionUpgradeService endpoint to get upgrade recommendations:

```
POST /v1/namespaces/{namespace}/version-upgrades
```

**Request body:**
```json
{
  "context": {
    "type": "project",
    "id": "{project_uuid}"
  },
  "request": {
    "package_version": "npm://lodash@4.17.15",
    "target_version": "4.17.21"
  }
}
```

**Key response fields to extract:**
- `list.objects[].spec.prioritized_upgrades` - Ranked upgrade recommendations
- `list.objects[].spec.stats` - Statistics about the upgrade
- `list.objects[].spec.cia_results` - Change Impact Analysis results
- `list.objects[].spec.confidence` - Confidence level in the recommendation
- `list.objects[].spec.breaking_changes` - Detected breaking changes
- `list.objects[].spec.remediation_risk` - Risk level (HIGH/MEDIUM/LOW)

### Understanding CIA Results

**Change Impact Analysis (CIA)** examines:
1. **API Changes**: Function signatures, return types, parameter changes
2. **Behavioral Changes**: Different execution outcomes
3. **Transitive Dependencies**: Changes in the dependency tree
4. **Deprecation Removals**: Deprecated APIs that are removed
5. **Configuration Changes**: Config file format or option changes
6. **Platform Support**: Changes in supported platforms/runtimes

### Understanding Confidence Levels

| Confidence | Meaning | Action |
|------------|---------|--------|
| HIGH | Strong evidence of outcome prediction | Trust the recommendation |
| MEDIUM | Some evidence but uncertainty exists | Review carefully |
| LOW | Limited data for prediction | Extensive testing recommended |

### Understanding Remediation Risk

| Risk Level | Meaning | Typical Scenario |
|------------|---------|------------------|
| LOW | Minimal breaking change risk | Patch/minor updates, no API changes |
| MEDIUM | Potential breaking changes | Minor version with deprecations, some conflicts |
| HIGH | High breaking change risk | Major version update, significant API changes |

### Present Results

**Default View (prioritized upgrades):**
```markdown
## Upgrade Impact Analysis

**Project:** {project_name}
**Analysis Time:** {timestamp}

### Prioritized Upgrade Recommendations

These upgrades are ranked by security impact vs. breaking change risk:

#### 1. lodash 4.17.15 → 4.17.21

| Metric | Value |
|--------|-------|
| Security Impact | HIGH - Fixes 3 CVEs |
| Remediation Risk | LOW |
| Confidence | HIGH |
| Breaking Changes | None detected |

**CVEs Fixed:**
- CVE-2021-23337 (CRITICAL) - Prototype Pollution
- CVE-2020-8203 (HIGH) - Prototype Pollution
- CVE-2019-10744 (HIGH) - Prototype Pollution

**CIA Results:**
- API Compatibility: ✅ No breaking changes
- Transitive Dependencies: ✅ Compatible
- Deprecations: ⚠️ 1 deprecated function removal (not used in your code)

**Recommendation:** SAFE TO UPGRADE - Same major version, all tests expected to pass.

```bash
npm install lodash@4.17.21
```

---

#### 2. axios 0.21.0 → 1.6.0

| Metric | Value |
|--------|-------|
| Security Impact | HIGH - Fixes 1 CVE |
| Remediation Risk | HIGH |
| Confidence | MEDIUM |
| Breaking Changes | 3 detected |

**CVEs Fixed:**
- CVE-2021-3749 (HIGH) - SSRF vulnerability

**CIA Results:**
- API Compatibility: ❌ Breaking changes detected
- Transitive Dependencies: ⚠️ 2 conflicts
- Deprecations: ❌ 5 deprecated APIs removed

**Breaking Changes Detected:**

| Change | Impact | Your Code |
|--------|--------|-----------|
| Response structure changed | HIGH | src/api/client.js:45 uses old format |
| `axios.create()` options renamed | MEDIUM | src/config/http.js:12 |
| CancelToken deprecated → AbortController | LOW | Not used |

**Recommendation:** REVIEW REQUIRED - Major version upgrade with breaking changes.

**Alternative Options:**
- axios@0.27.2 - Fixes CVE with lower risk (minor version)
- axios@0.28.0 - Latest 0.x with most fixes

---

### Summary by Risk Level

| Risk | Count | Recommendation |
|------|-------|----------------|
| LOW | 5 | Auto-upgrade safe |
| MEDIUM | 3 | Review before upgrade |
| HIGH | 2 | Requires code changes |

### Bulk Safe Upgrades

These upgrades have LOW remediation risk and HIGH confidence:

```bash
npm install lodash@4.17.21 minimist@1.2.8 node-fetch@2.6.9 semver@7.5.4 json5@2.2.3
```

### Next Steps

1. **Apply safe upgrades:** Run the bulk command above
2. **Review medium risk:** `/endor-upgrade axios --detailed`
3. **Plan high risk:** Schedule time for code changes
4. **Verify:** Run `/endor-scan` after upgrades
```

**Detailed Package View:**
```markdown
## Upgrade Impact Analysis: axios

**Current Version:** 0.21.0
**Vulnerabilities:** 1 (CVE-2021-3749)

### Available Upgrade Paths

| Target | Risk | Confidence | CVEs Fixed | Breaking Changes |
|--------|------|------------|------------|------------------|
| 0.21.4 | LOW | HIGH | 0 | 0 |
| 0.27.2 | LOW | HIGH | 1 | 0 |
| 0.28.0 | MEDIUM | MEDIUM | 1 | 2 |
| 1.6.0 | HIGH | MEDIUM | 1 | 5 |
| 1.7.2 (latest) | HIGH | MEDIUM | 1 | 5 |

### Recommended: axios@0.27.2

**Why this version?**
- Fixes CVE-2021-3749 (the vulnerability you have)
- Same major version (0.x) - minimal breaking change risk
- HIGH confidence no code changes needed

**CIA Analysis:**
```
API Changes: None
Behavioral Changes: None
Transitive Dependencies: All compatible
Deprecations Removed: None
```

### Alternative: axios@1.6.0 (Latest Stable)

**Why consider this?**
- Fixes all known vulnerabilities
- Active development, better long-term support
- Modern features (native AbortController support)

**Breaking Changes You'll Need to Handle:**

#### 1. Response Data Structure
```javascript
// Before (0.x)
const data = response.data;

// After (1.x) - Same, but error handling changed
try {
  const data = response.data;
} catch (error) {
  // error.response structure is different
  console.error(error.response?.data);  // Note: optional chaining needed
}
```

#### 2. Configuration Options
```javascript
// Before (0.x)
axios.create({
  baseUrl: 'https://api.example.com',  // typo accepted
});

// After (1.x)
axios.create({
  baseURL: 'https://api.example.com',  // Only correct spelling
});
```

#### 3. CancelToken → AbortController
```javascript
// Before (0.x)
const source = axios.CancelToken.source();
axios.get('/api', { cancelToken: source.token });
source.cancel();

// After (1.x)
const controller = new AbortController();
axios.get('/api', { signal: controller.signal });
controller.abort();
```

### Files That Need Changes

Based on CIA analysis, these files reference affected APIs:

| File | Line | Issue | Effort |
|------|------|-------|--------|
| src/api/client.js | 45 | Uses old error format | 5 min |
| src/config/http.js | 12 | Uses baseUrl typo | 1 min |
| src/utils/request.js | 78 | CancelToken usage | 15 min |

**Estimated Effort:** ~30 minutes of code changes

### Decision Matrix

| Goal | Recommended Version |
|------|---------------------|
| Fix vuln with minimal effort | 0.27.2 |
| Fix vuln + stay current | 1.6.0 |
| Maximum stability | 0.27.2 |
| Long-term maintainability | 1.6.0 |
```

**Safe Upgrades View:**
```markdown
## Safe Upgrades Available

These upgrades have been analyzed and are safe to apply with HIGH confidence:

| Package | Current | Target | CVEs Fixed | Risk |
|---------|---------|--------|------------|------|
| lodash | 4.17.15 | 4.17.21 | 3 | LOW |
| minimist | 1.2.5 | 1.2.8 | 1 | LOW |
| json5 | 2.2.0 | 2.2.3 | 1 | LOW |
| semver | 7.0.0 | 7.5.4 | 1 | LOW |

### Apply All Safe Upgrades

```bash
npm install lodash@4.17.21 minimist@1.2.8 json5@2.2.3 semver@7.5.4
```

### What Makes These "Safe"?

All upgrades meet these criteria:
- ✅ Remediation Risk: LOW
- ✅ Confidence: HIGH
- ✅ Breaking Changes: None detected
- ✅ Same major version OR no API changes
- ✅ No transitive dependency conflicts
```

## Error Handling

### No Upgrades Available
```markdown
## No Upgrade Recommendations

All your dependencies are either:
- Already on the latest secure version
- Have no known vulnerabilities

**Great job keeping your dependencies updated!**

Run `/endor-scan` periodically to check for new vulnerabilities.
```

### Project Not Found
```markdown
## Project Not Found

Couldn't find upgrade data for this project. This might mean:
- Project hasn't been scanned yet
- Project name doesn't match

**Try:**
1. Run `/endor-scan` to scan the project first
2. Check project name: `/endor-api list projects`
```

### Setup Required
```markdown
## Setup Required

Upgrade Impact Analysis requires a configured Endor Labs connection.

Run `/endor-setup` to get started.
```

## Integration with Other Skills

This skill works best when combined with:
- `/endor-scan` - Find vulnerabilities first
- `/endor-fix` - Apply recommended upgrades
- `/endor-check` - Verify individual packages

## Key Concepts

### Why Upgrade Impact Analysis Matters

Traditional vulnerability scanners tell you "this package is vulnerable, upgrade it."

Endor Labs goes further:
1. **Predicts breaking changes** before you upgrade
2. **Ranks upgrades** by security impact vs. effort
3. **Shows affected code** so you know what to fix
4. **Suggests alternatives** when major upgrades are risky

### How CIA Works

Endor Labs analyzes:
1. **Your code** - What APIs do you actually use?
2. **Package changes** - What changed between versions?
3. **Historical data** - What broke for other users?
4. **Dependency tree** - Will transitive deps conflict?

This produces a confidence score for each upgrade recommendation.

### Best Practices

1. **Apply safe upgrades first** - Low-hanging fruit with high security impact
2. **Plan risky upgrades** - Schedule time for code changes and testing
3. **Test thoroughly** - Even "safe" upgrades should be tested
4. **Scan after upgrading** - Verify vulnerabilities are resolved
