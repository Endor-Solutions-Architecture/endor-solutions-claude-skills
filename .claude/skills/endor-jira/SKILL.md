---
name: endor-jira
description: Create Jira tickets from security findings, sync status, and manage security issues
---

# Endor Labs: Jira Integration

Create Jira tickets from security findings, sync status, and manage security issues.

## Arguments

$ARGUMENTS - Action: `create`, `sync`, `link <finding>`, `status`, `bulk`

## Instructions

### Parse Arguments

| Argument | Action |
|----------|--------|
| `create` | Create ticket from finding |
| `create <CVE>` | Create ticket for specific CVE |
| `create critical` | Create tickets for all critical findings |
| `sync` | Sync ticket status with findings |
| `link <finding-id>` | Link existing ticket to finding |
| `status` | Show Jira integration status |
| `bulk` | Bulk create tickets |
| No argument | Show pending findings without tickets |

### MCP Tool Available

The `create_jira_ticket` MCP tool is available for direct ticket creation.

### Create Ticket from Finding

**Step 1: Get finding details**
Use `retrieve_single_finding` or `get_security_findings` to get finding info.

**Step 2: Create ticket using MCP tool**
```json
{
  "finding_uuid": "finding-uuid-here",
  "project_key": "SEC",
  "issue_type": "Bug",
  "priority": "Highest"
}
```

### Present Ticket Creation

```markdown
## Create Jira Ticket

**Finding:** CVE-2021-23337 in lodash@4.17.15
**Severity:** CRITICAL
**Reachable:** Yes

---

### Ticket Details

| Field | Value |
|-------|-------|
| Project | SEC (Security) |
| Type | Bug |
| Priority | Highest |
| Summary | [CRITICAL] CVE-2021-23337: Prototype Pollution in lodash |
| Labels | security, vulnerability, critical, reachable |

### Description

```
h2. Vulnerability Details

*CVE:* CVE-2021-23337
*Severity:* CRITICAL (CVSS 9.8)
*Package:* lodash@4.17.15
*Reachable:* Yes - exploitable from application code

h2. Description

Lodash versions prior to 4.17.21 are vulnerable to Prototype Pollution via the set and setWith functions.

h2. Impact

An attacker could manipulate the prototype of Object, leading to:
* Remote Code Execution
* Denial of Service
* Property injection attacks

h2. Remediation

Upgrade lodash to version 4.17.21 or later:

{code}
npm install lodash@4.17.21
{code}

h2. References

* [NVD|https://nvd.nist.gov/vuln/detail/CVE-2021-23337]
* [Endor Labs Finding|https://app.endorlabs.com/findings/{uuid}]

h2. Affected Code

{code}
src/api/users.js:45 → _.set(user, path, value)
{code}

---
_Created by Endor Labs Security Scanner_
```

---

### Confirmation

Create this ticket?
- Project: SEC
- Priority: Highest
- Assignee: (auto-assign based on code owners)

**[Create Ticket]**
```

### Ticket Created Response

```markdown
## Jira Ticket Created

**Ticket:** [SEC-1234](https://jira.company.com/browse/SEC-1234)
**Status:** Open
**Assignee:** security-team

### Finding Linked

The finding has been linked to this ticket in Endor Labs.

| Finding | Ticket | Status |
|---------|--------|--------|
| CVE-2021-23337 (lodash) | SEC-1234 | Open |

### Next Steps

1. Ticket assigned to security team
2. Fix will be tracked in Jira
3. When ticket is resolved, finding will be marked as addressed
```

### Bulk Create Tickets

```markdown
## Bulk Ticket Creation

**Filter:** Critical + Reachable vulnerabilities without tickets
**Findings:** 5

---

### Tickets to Create

| # | Finding | Package | CVE | Priority | Project |
|---|---------|---------|-----|----------|---------|
| 1 | Prototype Pollution | lodash@4.17.15 | CVE-2021-23337 | Highest | SEC |
| 2 | SSRF | axios@0.21.0 | CVE-2021-3749 | Highest | SEC |
| 3 | Prototype Pollution | minimist@1.2.5 | CVE-2021-44906 | High | SEC |
| 4 | SQL Injection | (SAST) | - | Highest | SEC |
| 5 | XSS | (SAST) | - | High | SEC |

---

### Options

- [ ] Create all 5 tickets
- [ ] Create only Critical (3 tickets)
- [ ] Create only CVEs (3 tickets)
- [ ] Create only SAST (2 tickets)

### Ticket Template

All tickets will use:
- Project: SEC
- Type: Bug
- Labels: security, endor-labs, {severity}
- Link: Endor Labs finding URL

**Proceed with bulk creation?**
```

### Sync Status

```markdown
## Jira Sync Status

**Last Sync:** 2024-02-15 14:30 UTC
**Tickets Tracked:** 12

---

### Status Overview

| Status | Count | Action |
|--------|-------|--------|
| Open | 5 | Pending fix |
| In Progress | 3 | Being worked on |
| Resolved | 4 | Verify in next scan |

---

### Tickets by Status

#### Open (5)

| Ticket | Finding | Age | Assignee |
|--------|---------|-----|----------|
| [SEC-1234](link) | CVE-2021-23337 | 5 days | @dev1 |
| [SEC-1235](link) | CVE-2021-3749 | 5 days | @dev2 |
| [SEC-1236](link) | SQL Injection | 3 days | @dev1 |
| [SEC-1237](link) | CVE-2021-44906 | 2 days | Unassigned |
| [SEC-1238](link) | XSS | 1 day | @dev3 |

#### In Progress (3)

| Ticket | Finding | Started | Assignee |
|--------|---------|---------|----------|
| [SEC-1230](link) | CVE-2020-8203 | 3 days ago | @dev1 |
| [SEC-1231](link) | Secrets exposure | 2 days ago | @dev2 |
| [SEC-1232](link) | AGPL License | 1 day ago | @legal |

#### Resolved - Pending Verification (4)

| Ticket | Finding | Resolved | Verify In |
|--------|---------|----------|-----------|
| [SEC-1220](link) | CVE-2019-10744 | 1 day ago | Next scan |
| [SEC-1221](link) | Hardcoded password | 1 day ago | Next scan |
| [SEC-1222](link) | Debug enabled | 2 days ago | Next scan |
| [SEC-1223](link) | Missing auth | 2 days ago | Next scan |

---

### Findings Without Tickets

| Finding | Severity | Age | Action |
|---------|----------|-----|--------|
| CVE-2024-1234 | HIGH | New | [Create ticket] |
| Path traversal | MEDIUM | 5 days | [Create ticket] |

---

### Recommendations

1. Assign SEC-1237 to a team member
2. Follow up on SEC-1230 (3 days in progress)
3. Run scan to verify 4 resolved tickets
```

### Link Existing Ticket

```markdown
## Link Finding to Jira Ticket

**Finding:** CVE-2021-23337 in lodash
**UUID:** finding-abc123

---

### Enter Ticket Details

**Jira Ticket Key:** SEC-1234

### Verification

| Field | Ticket Value |
|-------|--------------|
| Project | SEC |
| Summary | Fix lodash vulnerability |
| Status | In Progress |
| Assignee | @developer |

**Link this finding to SEC-1234?**

Once linked:
- Finding status will sync with ticket
- Ticket will show in Endor Labs UI
- Resolution will be tracked
```

### Integration Status

```markdown
## Jira Integration Status

### Connection

| Setting | Value | Status |
|---------|-------|--------|
| Jira URL | jira.company.com | ✅ Connected |
| Project | SEC | ✅ Accessible |
| API Token | ****...1234 | ✅ Valid |
| Webhook | Configured | ✅ Active |

### Configuration

| Feature | Status |
|---------|--------|
| Auto-create tickets | Enabled (Critical only) |
| Sync resolution | Enabled |
| Bidirectional sync | Enabled |
| Custom fields | Configured |

### Field Mapping

| Endor Labs | Jira Field |
|------------|------------|
| Severity | Priority |
| CVE ID | Labels |
| Package | Component |
| Description | Description |
| Remediation | Comment |

### Recent Activity

| Time | Action |
|------|--------|
| 2 hours ago | Created SEC-1238 |
| 5 hours ago | Synced SEC-1230 status |
| 1 day ago | Resolved SEC-1220 verified |

### Troubleshooting

If tickets aren't syncing:
1. Check API token permissions
2. Verify webhook URL is accessible
3. Check Jira project permissions
4. Review Endor Labs notification settings
```

### Jira Workflow Integration

```yaml
# Example: Auto-create tickets in CI/CD
name: Security Scan with Jira

on: [push]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: endorlabs/github-action@v1
        with:
          namespace: ${{ secrets.ENDOR_NAMESPACE }}

      - name: Create Jira tickets for critical findings
        run: |
          endorctl api list --resource Finding \
            --filter "spec.level==FINDING_LEVEL_CRITICAL and spec.jira_ticket==null" \
            --output json | \
          jq -r '.objects[].uuid' | \
          while read uuid; do
            endorctl jira create --finding-uuid $uuid --project SEC
          done
```
