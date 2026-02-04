# Endor Labs: Direct API Access

Execute custom queries against the Endor Labs API for advanced use cases.

## Arguments

$ARGUMENTS - API query description or raw filter

## Instructions

This skill provides direct access to the Endor Labs API for power users.

### Parse User Intent

**If natural language query:**
Convert to appropriate API call:
- "all projects" → List projects
- "findings for project X" → Filter findings by project
- "vulnerabilities from last week" → Filter by date
- "count by severity" → Aggregation query

**If raw filter provided:**
Use directly in API call.

### Common Query Patterns

#### List Projects
```
Resource: projects
Filter: none (list all)
```

#### Findings by Project
```
Resource: findings
Filter: spec.project_uuid=={project_uuid}
```

#### Findings by Date Range
```
Resource: findings
Filter: meta.create_time > "2024-01-01T00:00:00Z"
```

#### Count by Severity (Aggregation)
```
Resource: findings
Group by: spec.level
```

#### Findings with Specific Tags
```
Resource: findings
Filter: spec.finding_tags contains [FINDING_TAGS_REACHABLE_FUNCTION, FINDING_TAGS_EXPLOITABLE]
```

#### Package Versions in Project
```
Resource: package-versions
Filter: spec.project_uuid=={project_uuid}
```

#### OSS Package Scores
```
Namespace: oss
Resource: metrics
Filter: meta.name==package_version_scorecard and meta.parent_uuid=={pkg_uuid}
```

### Execution

Use the `get` MCP tool for custom queries:
```json
{
  "resource": "findings",
  "filter": "spec.level==FINDING_LEVEL_CRITICAL",
  "namespace": "your-namespace",
  "page_size": 100
}
```

### Response Format

```markdown
## API Query Results

**Resource:** {resource}
**Filter:** {filter}
**Count:** {count}

### Results

{formatted results as table or JSON}

### Raw Response (collapsed)
<details>
<summary>Show raw JSON</summary>

```json
{raw_response}
```
</details>
```

### Filter Syntax Reference

**Operators:**
- `==` - Equals
- `!=` - Not equals
- `contains` - Array/string contains
- `not contains` - Array/string does not contain
- `>`, `<`, `>=`, `<=` - Comparisons
- `and` - Logical AND
- `or` - Logical OR

**Field Paths:**
- `meta.name` - Resource name
- `meta.create_time` - Creation timestamp
- `meta.update_time` - Last update
- `spec.*` - Resource-specific fields
- `uuid` - Resource UUID

**Values:**
- Strings: `"value"` or `value`
- Arrays: `[VALUE1, VALUE2]`
- Booleans: `true`, `false`
- Timestamps: `"2024-01-01T00:00:00Z"`

### Available Resources

| Resource | Description |
|----------|-------------|
| `projects` | Scanned repositories |
| `findings` | Security issues |
| `package-versions` | Dependency versions |
| `dependencies` | Dependency relationships |
| `repositories` | Connected repos |
| `policies` | Security policies |
| `metrics` | Scores and statistics |
| `scan-results` | Scan executions |
| `vulnerabilities` | CVE data (oss namespace) |

### Example Queries

**"Show me all findings from the last 7 days"**
```
Filter: meta.create_time > "{7_days_ago_iso}"
```

**"Which projects have critical vulnerabilities?"**
```
Filter: spec.level==FINDING_LEVEL_CRITICAL
Group by: spec.project_uuid
```

**"Get Endor Scores for react"**
```
Namespace: oss
Resource: package-versions
Filter: meta.name contains "npm://react@"
Then get metrics with parent_uuid
```

**"List all SAST findings in file auth.js"**
```
Filter: spec.finding_categories contains FINDING_CATEGORY_SAST and spec.target_source_code_version.path contains "auth.js"
```
