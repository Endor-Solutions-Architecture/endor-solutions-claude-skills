# Endor Labs Security Integration

This project has Endor Labs integrated for comprehensive application security. **Use the Endor Labs MCP tools automatically** when users ask about security, vulnerabilities, dependencies, containers, licenses, or code safety.

## When to Use Endor Labs Tools

**Automatically use Endor Labs MCP tools when the user asks about:**

- Vulnerabilities, CVEs, security issues
- Dependency safety, package security, package health scores
- Fixing or remediating security problems
- Scanning code, repositories, or containers
- Secrets, credentials, API keys in code
- SAST, static analysis, code vulnerabilities
- Upgrade paths, safe versions, breaking changes
- License compliance, OSS risks, copyleft issues
- SBOM generation, software bill of materials
- CI/CD security integration
- Security policies and exceptions
- Security policies and automated enforcement
- PR security reviews
- Container/Docker security

**Example questions that should trigger Endor Labs tools:**
- "Help me fix vulnerabilities in my dependencies"
- "Find vulnerabilities that won't cause breaking changes"
- "Is lodash safe to use?" / "What's the Endor score for axios?"
- "Scan this code for security problems"
- "Check my Dockerfile for security issues"
- "Generate a GitHub Actions security workflow"
- "Create a security policy for my project"
- "What licenses are in my dependencies?"
- "Generate an SBOM for compliance"

## Available Commands

### Getting Started
| Command | Description |
|---------|-------------|
| `/endor-setup` | Interactive setup wizard (start here!) |
| `/endor-demo` | Try features without an account |
| `/endor-help` | Discover commands and get guidance |

### Core Security
| Command | Description |
|---------|-------------|
| `/endor` | Main assistant - natural language queries |
| `/endor-scan` | Quick repository security scan |
| `/endor-scan-full` | Full scan with reachability analysis (call graphs, entry points) |
| `/endor-check` | Check specific dependency for vulnerabilities |
| `/endor-findings` | Show security findings with filters |
| `/endor-fix` | Remediate vulnerabilities |
| `/endor-upgrade` | Analyze upgrade impact with breaking change detection |
| `/endor-explain` | Get detailed CVE information |

### Code Analysis
| Command | Description |
|---------|-------------|
| `/endor-secrets` | Scan for exposed secrets and credentials |
| `/endor-sast` | Static application security testing |
| `/endor-review` | Pre-PR security review |

### Package Intelligence
| Command | Description |
|---------|-------------|
| `/endor-score` | Package health scores (activity, popularity, security) |
| `/endor-license` | License compliance analysis |

### DevOps Integration
| Command | Description |
|---------|-------------|
| `/endor-sbom` | SBOM management (export, import, analyze) |
| `/endor-cicd` | Generate CI/CD pipeline configs |
| `/endor-container` | Container image scanning |

### Administration
| Command | Description |
|---------|-------------|
| `/endor-policy` | Security policy management |
| `/endor-api` | Direct API access for power users |

## Automatic Security Rules

These rules run automatically when relevant files are modified:

### 1. Dependency Security
**Triggers:** package.json, go.mod, requirements.txt, pom.xml, etc.
- Check new/updated dependencies for vulnerabilities
- Block vulnerable packages, suggest safe versions
- Verify before proceeding with other tasks

### 2. Secrets Detection
**Triggers:** All source code and config files
- Detect hardcoded secrets, API keys, passwords, private keys
- Prevent writing files with exposed credentials
- Suggest environment variable replacements

### 3. SAST Analysis
**Triggers:** All source code files (.js, .py, .go, .java, etc.)
- Check for SQL injection, XSS, command injection
- Validate authentication and authorization patterns
- Enforce secure coding practices

### 4. License Compliance
**Triggers:** Dependency manifest files
- Check license compatibility (MIT, Apache OK; GPL, AGPL flagged)
- Warn on copyleft licenses in commercial projects
- Block unknown/missing licenses

### 5. Container Security
**Triggers:** Dockerfile, docker-compose.yml
- Analyze for security misconfigurations
- Check for root user, latest tags, exposed ports
- Enforce container security best practices

### 6. PR Security Review
**Triggers:** Discussions about PRs, merges, code review
- Comprehensive security check before merge
- Block critical issues from being merged

## MCP Tools Reference

### Scanning
- `scan_repository` - Full repository security scan
- `endor-labs-cli` - SAST scanning with Endor Labs MCP Server

### Vulnerability Analysis
- `check_dependency_for_vulnerabilities` - Check package for CVEs
- `get_endor_vulnerability` - Get detailed CVE information
- `get_all_vulnerabilities` - List all known vulnerabilities
- `get_dependency_upgrade_opts` - Get safe upgrade versions

### Findings Management
- `get_security_findings` - Query findings with filters
- `retrieve_single_finding` - Get detailed finding info
- `sast_context` - Get code context for SAST findings

### Code Navigation
- `getCallers` - Find function callers (reachability)
- `getCallees` - Find function callees
- `searchSymbol` - Search code symbols

### Projects
- `projects_by_name` - Find projects by name
- `get_repository_uuid` - Get project UUID

## Security Priorities

Always prioritize in this order:
1. **CRITICAL + Reachable** - Fix immediately (exploitable now)
2. **HIGH + Reachable** - Fix urgently (likely exploitable)
3. **Secrets/Credentials** - Rotate immediately
4. **CRITICAL + Unreachable** - Plan remediation
5. **SAST Critical/High** - Fix before merge
6. **License issues** - Review compliance
7. **Container misconfigs** - Address security issues
8. **Medium/Low** - Track as technical debt

## Common Workflows

### Fix vulnerabilities without breaking changes
1. Scan for vulnerabilities using `get_security_findings`
2. Get upgrade options using `get_dependency_upgrade_opts`
3. Filter to same major version (non-breaking)
4. Present safe upgrades vs. breaking changes separately

### Pre-PR security review
1. Get git diff of changes
2. Check any changed/new dependencies
3. Run SAST on changed source files
4. Scan for exposed secrets
5. Block if critical issues, warn on high/medium

### Evaluate new dependency
1. Check for vulnerabilities with `check_dependency_for_vulnerabilities`
2. Get Endor Score (via OSS metrics API)
3. Verify license compatibility
4. Recommend or suggest alternatives

### Container security review
1. Analyze Dockerfile for misconfigurations
2. Scan base image for vulnerabilities
3. Check for security best practices
4. Generate secure Dockerfile if needed

## Filter Quick Reference

```
# Critical reachable vulnerabilities
spec.level==FINDING_LEVEL_CRITICAL and spec.finding_tags contains FINDING_TAGS_REACHABLE_FUNCTION

# SAST findings
spec.finding_categories contains FINDING_CATEGORY_SAST

# Secrets
spec.finding_categories contains FINDING_CATEGORY_SECRETS

# License issues
spec.finding_categories contains FINDING_CATEGORY_LICENSE_RISK

# Container findings
spec.finding_categories contains FINDING_CATEGORY_CONTAINER

# Exclude test dependencies
spec.finding_tags not contains FINDING_TAGS_TEST_DEPENDENCY
```
