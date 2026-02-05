---
name: endor-explain
description: |
  Get detailed information about a specific vulnerability (CVE) or security finding. Provides comprehensive explanation including severity, impact, attack vectors, and remediation.
  - MANDATORY TRIGGERS: endor explain, explain cve, what is cve, vulnerability details, finding details, endor-explain, tell me about cve
---

# Endor Labs Vulnerability Explainer

Provide detailed information about a specific CVE or security finding.

## Prerequisites

- Endor Labs MCP server configured (run `/endor-setup` if not)

## Input Parsing

The user can provide:

1. **CVE ID** - e.g., `CVE-2021-23337`
2. **Finding UUID** - from `/endor-findings` output
3. **Package + vulnerability description** - e.g., "lodash prototype pollution"

## Workflow

### For CVE Lookup

#### Step 1: Get Vulnerability Details

Use `get_endor_vulnerability` MCP tool with the CVE ID.

#### Step 2: Find Affected Projects

Use `get_security_findings` with filter:
```
spec.finding_categories contains FINDING_CATEGORY_VULNERABILITY
```

Search results for the specific CVE to see if it affects the current project.

#### Step 3: Present Explanation

```markdown
## {CVE-ID}: {Title}

### Overview

| Field | Value |
|-------|-------|
| CVE | {cve_id} |
| Severity | {severity} (CVSS: {score}) |
| CWE | {cwe_id} - {cwe_name} |
| Published | {date} |
| Modified | {date} |
| EPSS Score | {score}% probability of exploitation |

### Description

{Detailed description of the vulnerability}

### Impact

{What an attacker could do if this vulnerability is exploited}

### Attack Vector

{How the vulnerability can be exploited - network, local, etc.}

**CVSS Vector:** {vector_string}

| Component | Value |
|-----------|-------|
| Attack Vector | {Network/Adjacent/Local/Physical} |
| Attack Complexity | {Low/High} |
| Privileges Required | {None/Low/High} |
| User Interaction | {None/Required} |

### Affected Versions

| Package | Affected Versions | Fixed Version |
|---------|-------------------|---------------|
| {pkg} | {range} | {fixed} |

### Your Project Impact

{If the CVE affects the current project:}

- **Affected:** Yes
- **Reachable:** {Yes/No}
- **Package:** {package}@{version}
- **Call Path:** {if reachable, show path}

{If not affected:}
- **Affected:** No - this CVE does not affect your current project

### Remediation

1. **Upgrade** to {package}@{fixed_version}
2. **Verify** with `/endor-check {package} {fixed_version}`
3. **Check impact** with `/endor-upgrade {package} {fixed_version}`

### References

{List of reference URLs from the CVE data}
```

### For Finding UUID Lookup

#### Step 1: Get Finding Details

Use `retrieve_single_finding` MCP tool with the UUID.

#### Step 2: Get Code Context (for SAST findings)

If the finding is a SAST finding, use `sast_context` MCP tool to get the code context.

#### Step 3: Present Finding Details

```markdown
## Finding: {title}

### Overview

| Field | Value |
|-------|-------|
| UUID | {uuid} |
| Category | {vulnerability/sast/secrets/license} |
| Severity | {level} |
| Reachable | {yes/no/n/a} |
| Package | {package}@{version} |
| File | {file_path}:{line} |

### Description

{Detailed description}

### Code Context

{For SAST findings, show the vulnerable code with context}

### Remediation

{Specific fix steps for this finding}

### Next Steps

1. **Fix this issue:** `/endor-fix {cve_or_id}`
2. **View related findings:** `/endor-findings`
```

## Error Handling

- **CVE not found**: The CVE may not be in the Endor Labs database. Suggest checking the CVE ID format.
- **Finding UUID not found**: The finding may have been resolved or the UUID is incorrect.
- **Auth error**: Suggest `/endor-setup`
