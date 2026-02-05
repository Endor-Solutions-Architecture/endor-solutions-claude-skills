---
name: endor-policy
description: Create, view, and manage security policies for automated enforcement
---

# Endor Labs: Policy Management

Create, view, and manage security policies for automated enforcement.

## Arguments

$ARGUMENTS - Action: `list`, `show <name>`, `create`, `templates`, `validate`, `import`, `export`

## Instructions

### Parse Arguments

| Argument | Action |
|----------|--------|
| `list` | List all policies in namespace |
| `show <name>` | Show details of a specific policy |
| `create` | Interactive policy creation |
| `create finding` | Create a finding policy |
| `create exception` | Create an exception policy |
| `create action` | Create an action policy |
| `templates` | Show policy templates |
| `validate` | Validate policies against current findings |
| `import <file>` | Import policy from file |
| `export <name>` | Export policy to file |
| No argument | Show policy summary |

### Policy Types

**1. Finding Policies**
Define what security issues should be flagged and at what severity.

**2. Exception Policies**
Create exceptions for specific findings (false positives, accepted risks).

**3. Action Policies**
Define automated actions when findings match criteria (block PR, notify, create ticket).

### List Policies

Use API to list policies:
```
GET /v1/namespaces/{namespace}/policies
```

Present as:
```markdown
## Security Policies

**Namespace:** {namespace}
**Total Policies:** {count}

### Finding Policies ({count})

| Name | Severity | Categories | Status |
|------|----------|------------|--------|
| block-critical-reachable | CRITICAL | Vulnerability | Active |
| warn-high-severity | HIGH | All | Active |
| license-compliance | HIGH | License | Active |

### Exception Policies ({count})

| Name | Finding | Reason | Expires |
|------|---------|--------|---------|
| lodash-accepted-risk | CVE-2021-23337 | Not exploitable in our context | 2024-12-31 |
| internal-tool-exception | SAST-001 | False positive | Never |

### Action Policies ({count})

| Name | Trigger | Action | Status |
|------|---------|--------|--------|
| pr-block-critical | Critical + Reachable | Block merge | Active |
| slack-notify-high | High severity | Slack notification | Active |
| webhook-critical | Critical | Webhook notification | Active |
```

### Show Policy Details

```markdown
## Policy: block-critical-reachable

**Type:** Finding Policy
**Status:** Active
**Created:** 2024-01-15
**Last Modified:** 2024-02-20

### Criteria

```yaml
match:
  severity: CRITICAL
  reachable: true
  categories:
    - VULNERABILITY
    - SAST
  exclude_tags:
    - TEST_DEPENDENCY
```

### Actions

- Block PR merge
- Add PR comment with findings
- Notify security team via Slack

### Current Matches

This policy currently matches **3 findings** in your namespace:

| Finding | Package | CVE |
|---------|---------|-----|
| F-001 | lodash@4.17.15 | CVE-2021-23337 |
| F-002 | axios@0.21.0 | CVE-2021-3749 |
| F-003 | minimist@1.2.5 | CVE-2021-44906 |
```

### Create Finding Policy

Interactive policy creation:

```markdown
## Create Finding Policy

I'll help you create a finding policy. Let me ask a few questions:

1. **What should trigger this policy?**
   - Severity: CRITICAL / HIGH / MEDIUM / LOW / Any
   - Categories: Vulnerability / SAST / Secrets / License / All
   - Reachability: Reachable only / All

2. **What action should be taken?**
   - Block (fail CI/prevent merge)
   - Warn (allow but flag)
   - Notify (send alerts)
   - Create ticket (GitHub issue)

3. **Any exceptions?**
   - Exclude test dependencies
   - Exclude specific packages
   - Exclude specific CVEs
```

**Generated policy:**
```yaml
apiVersion: v1
kind: FindingPolicy
metadata:
  name: block-critical-vulnerabilities
  namespace: {namespace}
spec:
  description: "Block critical reachable vulnerabilities"
  enabled: true
  match:
    severity:
      - FINDING_LEVEL_CRITICAL
    categories:
      - FINDING_CATEGORY_VULNERABILITY
    tags:
      include:
        - FINDING_TAGS_REACHABLE_FUNCTION
      exclude:
        - FINDING_TAGS_TEST_DEPENDENCY
  action:
    type: BLOCK
    notification:
      slack:
        channel: "#security-alerts"
      email:
        recipients:
          - security@company.com
```

### Create Exception Policy

```markdown
## Create Exception Policy

**What finding should be excepted?**
- CVE ID: CVE-2021-23337
- Package: lodash@4.17.15
- Finding UUID: F-001

**Reason for exception:**
- [ ] False positive
- [ ] Accepted risk (with mitigation)
- [ ] Not applicable to our use case
- [ ] Pending fix in next release

**Exception details:**
- Justification: {user provided}
- Approved by: {user}
- Expiration: {date or never}
```

**Generated policy:**
```yaml
apiVersion: v1
kind: ExceptionPolicy
metadata:
  name: lodash-cve-2021-23337-exception
  namespace: {namespace}
spec:
  description: "Exception for CVE-2021-23337 in lodash"
  enabled: true
  match:
    cve: CVE-2021-23337
    package: lodash
    version: ">=4.17.0 <4.17.21"
  exception:
    reason: ACCEPTED_RISK
    justification: |
      The vulnerable function _.set() is not used with user-controlled input
      in our codebase. Verified by code review on 2024-02-15.
    approved_by: security-team
    expires: "2024-12-31"
    ticket: GH-1234
```

### Create Action Policy

```markdown
## Create Action Policy

**Trigger conditions:**
- When: New critical finding discovered
- Scope: Production branches only

**Actions to perform:**
1. [ ] Block PR/merge
2. [ ] Post PR comment
3. [ ] Send Slack notification
4. [ ] Send email alert
5. [ ] Create GitHub issue
6. [ ] Webhook call
```

**Generated policy:**
```yaml
apiVersion: v1
kind: ActionPolicy
metadata:
  name: critical-finding-response
  namespace: {namespace}
spec:
  description: "Automated response to critical findings"
  enabled: true
  trigger:
    finding:
      severity: CRITICAL
      reachable: true
    branch_pattern: "^(main|master|release/.*)$"
  actions:
    - type: BLOCK_MERGE
      message: "Critical vulnerability detected. Please remediate before merging."
    - type: PR_COMMENT
      template: |
        ## Security Alert

        A critical reachable vulnerability was detected:
        - **CVE:** {{.CVE}}
        - **Package:** {{.Package}}
        - **Severity:** {{.Severity}}

        Please update to a fixed version before merging.
    - type: SLACK_NOTIFICATION
      channel: "#security-alerts"
      template: |
        :warning: Critical vulnerability in {{.Repository}}
        CVE: {{.CVE}} | Package: {{.Package}}
    - type: GITHUB_ISSUE
      repository: "{{.Repository}}"
      labels:
        - security
        - critical
```

### Policy Templates

```markdown
## Policy Templates

### 1. Block Critical Reachable
Block merges when critical reachable vulnerabilities exist.
```
/endor-policy create from-template block-critical
```

### 2. License Compliance
Enforce license policies (block GPL in commercial projects).
```
/endor-policy create from-template license-compliance
```

### 3. SAST Required
Require SAST scans pass before merge.
```
/endor-policy create from-template sast-required
```

### 4. Secrets Prevention
Block any exposed secrets from being committed.
```
/endor-policy create from-template no-secrets
```

### 5. SBOM Required
Require SBOM generation for releases.
```
/endor-policy create from-template sbom-required
```

### 6. Dependency Age
Flag dependencies that haven't been updated in 2+ years.
```
/endor-policy create from-template dependency-age
```
```

### Validate Policies

Check policies against current state:

```markdown
## Policy Validation Results

### block-critical-reachable
**Status:** 3 findings would be blocked

| Finding | Package | Status |
|---------|---------|--------|
| CVE-2021-23337 | lodash | Would block |
| CVE-2021-3749 | axios | Would block |
| CVE-2021-44906 | minimist | Would block |

### license-compliance
**Status:** 2 findings flagged

| Package | License | Issue |
|---------|---------|-------|
| gpl-lib | GPL-3.0 | Copyleft in commercial project |
| agpl-tool | AGPL-3.0 | Network copyleft |

### Exceptions Applied

| Exception | Finding | Status |
|-----------|---------|--------|
| lodash-accepted-risk | CVE-2021-23337 | Active (expires 2024-12-31) |

### Recommendations

1. Resolve 3 critical vulnerabilities to pass `block-critical-reachable`
2. Review GPL dependencies for `license-compliance`
3. Update exception `lodash-accepted-risk` - consider upgrading instead
```

### Import/Export

```bash
# Export policy
endorctl api get --resource Policy --name block-critical > policy.yaml

# Import policy
endorctl api create --resource Policy --file policy.yaml
```
