---
name: endor-api
description: |
  Execute custom queries against the Endor Labs API for advanced use cases. Provides direct access to findings, projects, packages, and metrics endpoints.
  - MANDATORY TRIGGERS: endor api, custom query, raw api, api query, endor-api, direct api, advanced query
---

# Endor Labs Direct API Access

Execute custom queries against the Endor Labs API for advanced use cases.

## Prerequisites

- Endor Labs MCP server configured (run `/endor-setup` if not)
- Node.js v18+ with `npx` available

## API Endpoints

### Base URL

```
https://api.endorlabs.com
```

### Common Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /v1/namespaces/{ns}/findings` | Query findings |
| `GET /v1/namespaces/{ns}/projects` | List projects |
| `GET /v1/namespaces/{ns}/package-versions` | Package versions |
| `GET /v1/namespaces/oss/metrics` | OSS package metrics |
| `POST /v1/namespaces/{ns}/version-upgrades` | Upgrade analysis |
| `GET /v1/namespaces/{ns}/version-upgrades/{uuid}` | Upgrade results |

## Workflow

### Step 1: Understand the Query

Parse the user's request to determine:

1. **Resource type**: findings, projects, packages, metrics, etc.
2. **Filter**: What to filter by (severity, category, package, date, etc.)
3. **Output**: What data to return

### Step 2: Execute Query

**Using MCP Tools (Preferred for supported operations):**

The following MCP tools are available and should be used when applicable:

| MCP Tool | Use For |
|----------|---------|
| `scan` | Scan repository for vulnerabilities, secrets, SAST, dependencies |
| `get_resource` | Retrieve any resource by UUID or name (Finding, Project, PackageVersion, Metric, etc.) |
| `check_dependency_for_vulnerabilities` | Check a specific package version for known CVEs |
| `get_endor_vulnerability` | Get detailed info about a CVE or GHSA |

**Using endorctl CLI (for operations not covered by MCP tools):**

```bash
# List resources with filter
npx -y endorctl api list --resource {Resource} -n $ENDOR_NAMESPACE --filter "{filter}"

# Get a single resource
npx -y endorctl api get --resource {Resource} -n $ENDOR_NAMESPACE --uuid {uuid}

# Create a resource
npx -y endorctl api create --resource {Resource} -n $ENDOR_NAMESPACE --data '{json}'
```

**Common Resource Types:**

| Resource | Description |
|----------|-------------|
| `Finding` | Security findings |
| `Project` | Scanned projects |
| `PackageVersion` | Package versions |
| `DependencyMetadata` | Dependency info |
| `FindingPolicy` | Security policies |
| `ExceptionPolicy` | Policy exceptions |
| `RepositoryScan` | Scan results |

### Step 3: Filter Syntax

The Endor Labs API uses a filter syntax:

```
# Equality
field==value

# Contains
field contains value

# Not contains
field not contains value

# Multiple conditions (AND)
field1==value1 and field2==value2

# In list
field in [value1, value2]

# Comparison
field > value
field < value
```

**Common filter examples:**

```bash
# Critical reachable vulnerabilities
npx -y endorctl api list --resource Finding -n $ENDOR_NAMESPACE \
  --filter "spec.level==FINDING_LEVEL_CRITICAL and spec.finding_tags contains FINDING_TAGS_REACHABLE_FUNCTION"

# Findings for a specific project
npx -y endorctl api list --resource Finding -n $ENDOR_NAMESPACE \
  --filter "spec.project_uuid=={project_uuid}"

# Projects by name
npx -y endorctl api list --resource Project -n $ENDOR_NAMESPACE \
  --filter "meta.name contains '{name}'"

# Package metrics
npx -y endorctl api list --resource Metric -n oss \
  --filter "meta.name==package_version_scorecard and meta.parent_uuid=={pkg_uuid}"
```

### Step 4: Present Results

Format the API response based on the resource type:

```markdown
## API Query Results

**Resource:** {resource_type}
**Filter:** {filter}
**Results:** {count}

### Data

{Formatted table or structured output based on the response}

### Raw Response

{If the user wants raw data, provide the JSON}
```

## Example Queries

### Find all critical findings
```bash
npx -y endorctl api list --resource Finding -n $ENDOR_NAMESPACE \
  --filter "spec.level==FINDING_LEVEL_CRITICAL" \
  --page-size 20
```

### Get project details
```bash
npx -y endorctl api list --resource Project -n $ENDOR_NAMESPACE \
  --filter "meta.name contains 'my-project'"
```

### Check upgrade options
```bash
npx -y endorctl api create --resource VersionUpgrade -n $ENDOR_NAMESPACE \
  --data '{
    "context": {"type": "project", "id": "{project_uuid}"},
    "request": {"package_version": "npm://lodash@4.17.15", "target_version": "4.17.21"}
  }'
```

### Get package score from OSS namespace
```bash
npx -y endorctl api list --resource Metric -n oss \
  --filter "meta.name==package_version_scorecard and meta.parent_uuid=={package_uuid}"
```

## Error Handling

- **Invalid filter syntax**: Show the correct syntax with examples
- **Resource not found**: Verify the resource type and namespace
- **Permission denied**: Check namespace access
- **Auth error**: Suggest `/endor-setup`
- **Rate limited**: Wait and retry, or reduce page size

## Safety Notes

- This skill only executes read operations (list/get) by default
- Create/update/delete operations require explicit user confirmation
- Never pass sensitive data in filter strings that might be logged
