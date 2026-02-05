---
name: endor-explain
description: Get detailed information about a specific vulnerability or security finding
---

# Endor Labs: Explain Vulnerability

Get detailed information about a specific vulnerability or security finding.

## Arguments

$ARGUMENTS - CVE ID (e.g., CVE-2021-23337) or finding UUID

## Instructions

1. Determine input type:
   - Starts with `CVE-` → Vulnerability lookup
   - UUID format → Finding lookup

### For CVE lookup:

1. Call `get_endor_vulnerability` with the CVE ID

2. Also search findings to see if it affects any projects:
   `spec.finding_metadata.vulnerability.spec.aliases contains CVE-2021-23337`

3. Present comprehensive explanation:

```markdown
## CVE-2021-23337: Prototype Pollution in lodash

### Overview
| Field | Value |
|-------|-------|
| CVE ID | CVE-2021-23337 |
| Severity | CRITICAL (9.8) |
| CWE | CWE-1321 (Prototype Pollution) |
| Published | 2021-02-15 |
| Fixed In | lodash >= 4.17.21 |

### Description

The `lodash` library before version 4.17.21 is vulnerable to prototype pollution
via the `setWith` and `set` functions. An attacker can modify the prototype of
Object, potentially leading to:

- Remote Code Execution (RCE)
- Denial of Service (DoS)
- Property injection

### Affected Versions
- lodash < 4.17.21

### Attack Vector

```javascript
// Malicious payload
const payload = JSON.parse('{"__proto__": {"polluted": true}}');
_.set({}, payload, "value");

// Now all objects have .polluted = true
console.log({}.polluted); // true
```

### Impact in Your Projects

| Project | Package | Version | Reachable |
|---------|---------|---------|-----------|
| my-app | lodash | 4.17.15 | Yes |
| api-service | lodash | 4.17.19 | No |

### Remediation

**Immediate:** Upgrade to lodash@4.17.21 or later

```bash
npm install lodash@4.17.21
```

**Alternative:** If upgrade not possible, avoid using `set` and `setWith` with
user-controlled input.

### References
- [NVD Entry](https://nvd.nist.gov/vuln/detail/CVE-2021-23337)
- [GitHub Advisory](https://github.com/advisories/GHSA-35jh-r3h4-6jhm)
- [Snyk Advisory](https://snyk.io/vuln/SNYK-JS-LODASH-1040724)
```

### For Finding UUID lookup:

1. Call `retrieve_single_finding` with the UUID

2. Get full context including:
   - Affected function and file
   - Call graph (if reachable)
   - Related findings

3. If it's a SAST finding, call `sast_context` for code context

4. Present detailed finding:

```markdown
## Finding Details

### Summary
| Field | Value |
|-------|-------|
| Finding ID | {uuid} |
| Type | Vulnerability |
| Severity | CRITICAL |
| Category | SCA |
| Reachable | Yes |

### Affected Code

**Package:** lodash@4.17.15
**Vulnerable Function:** `_.set()`
**Your Code Path:**
```
src/api/user.js:45 → userController.update()
  ↓ calls
node_modules/lodash/set.js:23 → set()  [VULNERABLE]
```

### Reachability Analysis

This vulnerability IS reachable from your code:

1. `src/api/user.js` line 45 calls `_.set()` with user input
2. User input flows to the vulnerable function without sanitization
3. An attacker could exploit this via the `/api/user` endpoint

### Code Context

```javascript
// src/api/user.js:43-50
async function updateUser(req, res) {
  const updates = req.body;
  _.set(user, updates.path, updates.value);  // VULNERABLE
  await user.save();
}
```

### Recommended Fix

```javascript
// Safe alternative using allowlist
const allowedPaths = ['name', 'email', 'settings.theme'];
if (allowedPaths.includes(updates.path)) {
  _.set(user, updates.path, updates.value);
}
```

Or upgrade lodash to fix the vulnerability at the source.
```
