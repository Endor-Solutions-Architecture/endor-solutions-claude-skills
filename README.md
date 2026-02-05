# Endor Labs Claude Code Skill

A Claude Code skill that integrates Endor Labs security scanning into your development workflow. Scan for vulnerabilities, check dependencies, and get remediation guidance directly from Claude.

## Quick Start (5 minutes)

**New to Endor Labs?** Get started in 3 steps:

```bash
# 1. Install the CLI
brew install endorlabs/tap/endorctl   # or: npm install -g endorctl

# 2. Authenticate (opens browser)
endorctl init

# 3. Set your namespace
export ENDOR_NAMESPACE=your-namespace
```

Then run `/endor-setup` in Claude Code to verify everything works!

**Just want to see what it does?** Run `/endor-demo` - no account needed.

## Features

### Security Scanning
- **Repository Scanning**: Full SCA, SAST, and secrets scanning
- **Dependency Checking**: Verify packages before adding them
- **Reachability Analysis**: Focus on actually exploitable vulnerabilities
- **SAST Analysis**: Find code vulnerabilities (SQL injection, XSS, etc.)
- **Secrets Detection**: Find exposed API keys, passwords, and credentials
- **Container Scanning**: Scan Docker images for vulnerabilities

### Intelligence & Compliance
- **Package Health Scores**: Evaluate packages with Endor Scores (activity, popularity, security, quality)
- **License Compliance**: Check license compatibility, flag copyleft issues
- **SBOM Management**: Generate, import, and analyze Software Bill of Materials

### DevOps Integration
- **CI/CD Pipelines**: Generate security workflows for GitHub, GitLab, Jenkins, Azure DevOps
- **PR Security Review**: Pre-merge security checks
- **Policy Management**: Create and manage security policies

### Automation
- **Automatic Rules**: Auto-check dependencies, secrets, and code as you write
- **Remediation Guidance**: Get upgrade paths and fix suggestions
- **Code Navigation**: Understand call graphs and vulnerability context

## Prerequisites

1. **Endor Labs Account**: Sign up at [endorlabs.com](https://www.endorlabs.com)
2. **endorctl CLI**: The Endor Labs command-line tool
3. **Claude Code**: The Claude CLI tool

## Installation

### Step 1: Install endorctl

**macOS/Linux (Homebrew):**
```bash
brew install endorlabs/tap/endorctl
```

**npm:**
```bash
npm install -g endorctl
```

**Direct download:**
```bash
# macOS
curl -sSL https://api.endorlabs.com/download/latest/endorctl_darwin_amd64 -o endorctl

# Linux
curl -sSL https://api.endorlabs.com/download/latest/endorctl_linux_amd64 -o endorctl

chmod +x endorctl
sudo mv endorctl /usr/local/bin/
```

### Step 2: Authenticate with Endor Labs

```bash
endorctl init
```

This opens a browser for authentication. Follow the prompts to log in.

### Step 3: Set Your Namespace

```bash
export ENDOR_NAMESPACE=your-namespace-here
```

Add this to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.) for persistence.

### Step 4: Install the Claude Code Skill

**Option A: Copy to your project (recommended for teams)**
```bash
# Copy the .claude directory to your project
cp -r /path/to/endor-labs-claude-skill/.claude /path/to/your/project/

# Copy CLAUDE.md for project-level instructions
cp /path/to/endor-labs-claude-skill/CLAUDE.md /path/to/your/project/
```

**Option B: Install globally for all projects**
```bash
# Copy to your home directory for global access
cp -r /path/to/endor-labs-claude-skill/.claude ~/.claude
```

**Option C: Configure MCP server manually**

Add to your Claude Code settings (`~/.claude/settings.json` or project `.claude/settings.json`):

```json
{
  "mcpServers": {
    "endor-mcp-server": {
      "command": "endorctl",
      "args": ["ai-tools", "mcp-server"],
      "env": {
        "ENDOR_NAMESPACE": "your-namespace",
        "ENDOR_API": "https://api.endorlabs.com"
      }
    }
  }
}
```

## Usage

### Getting Started Commands

| Command | Description |
|---------|-------------|
| `/endor-setup` | **Start here!** Interactive setup wizard |
| `/endor-demo` | Try features without an account |
| `/endor-help` | Discover all commands and get guidance |

### Available Commands

#### Core Security
| Command | Description |
|---------|-------------|
| `/endor` | Main assistant - natural language security queries |
| `/endor-scan` | Quick repository scan for all security issues |
| `/endor-scan-full` | Full scan with reachability analysis (call graphs, entry points) |
| `/endor-check <pkg>@<ver>` | Check a specific dependency for vulnerabilities |
| `/endor-findings` | Show all security findings with filters |
| `/endor-fix <CVE>` | Get remediation guidance for a vulnerability |
| `/endor-upgrade` | Analyze upgrade impact with breaking change detection |
| `/endor-explain <CVE>` | Get detailed explanation of a CVE |

#### Code Analysis
| Command | Description |
|---------|-------------|
| `/endor-secrets` | Scan for exposed secrets and credentials |
| `/endor-sast` | Run static application security testing |
| `/endor-review` | Pre-PR security review of changes |

#### Package Intelligence
| Command | Description |
|---------|-------------|
| `/endor-score <pkg>` | Get package health scores (Endor Scores) |
| `/endor-license` | Analyze license compliance |

#### DevOps Integration
| Command | Description |
|---------|-------------|
| `/endor-sbom` | SBOM management (export, import, analyze) |
| `/endor-cicd <platform>` | Generate CI/CD security pipeline (github, gitlab, jenkins, etc.) |
| `/endor-container <image>` | Scan container images |

#### Administration
| Command | Description |
|---------|-------------|
| `/endor-policy` | Manage security policies |
| `/endor-api` | Direct API access for advanced queries |

### Quick Examples

```
/endor scan                        # Quick security scan
/endor-scan-full                   # Full scan with reachability analysis
/endor check lodash@4.17.20        # Check specific package
/endor findings critical reachable # Filter findings
/endor fix CVE-2021-23337          # Get fix guidance
/endor secrets                     # Scan for secrets
/endor sast src/api/               # SAST on specific path
/endor score axios                 # Get package health score
/endor license                     # Check license compliance
/endor sbom export                 # Generate SBOM
/endor cicd github                 # Generate GitHub Actions workflow
/endor container nginx:latest      # Scan container image
/endor review                      # Pre-PR security review
```

### Natural Language

You can also just describe what you want - Claude will automatically use the appropriate Endor Labs tools:

- "Scan this project for vulnerabilities"
- "Is axios version 0.21.0 safe to use?"
- "Show me all critical security findings"
- "Help me fix vulnerabilities without breaking changes"
- "What's the Endor score for lodash?"
- "Check my Dockerfile for security issues"
- "Generate a GitHub Actions security workflow"
- "Are there any license issues in my dependencies?"
- "Generate a security policy for critical vulnerabilities"

### Example Session

```
You: /endor scan

Claude: I'll scan your repository for security issues.

## Security Scan Results

**Repository:** /home/user/my-project
**Languages:** JavaScript, TypeScript

### Critical Issues (1 reachable)

| Package | Version | CVE | Severity | Reachable |
|---------|---------|-----|----------|-----------|
| lodash | 4.17.15 | CVE-2021-23337 | CRITICAL | Yes |

### High Priority (3 total, 0 reachable)

| Package | Version | CVE | Severity |
|---------|---------|-----|----------|
| axios | 0.21.0 | CVE-2021-3749 | HIGH |
| minimist | 1.2.5 | CVE-2021-44906 | HIGH |
| node-fetch | 2.6.0 | CVE-2022-0235 | HIGH |

### Summary
- 1 Critical (1 reachable) - **Fix immediately**
- 3 High (0 reachable)
- 8 Medium
- 12 Low

**Recommendation:** The lodash vulnerability is reachable from your code.
I can help you upgrade to a safe version. Would you like me to show the fix?

You: Yes, fix the lodash issue

Claude: I'll get the upgrade options for lodash.

**Current:** lodash@4.17.15
**Recommended:** lodash@4.17.21 (fixes CVE-2021-23337, CVE-2020-8203, CVE-2019-10744)

To fix, update your package.json:

```json
"dependencies": {
  "lodash": "^4.17.21"
}
```

Then run:
```bash
npm install
```

After updating, I recommend re-running `/endor scan` to verify the fix.
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ENDOR_NAMESPACE` | Your Endor Labs namespace | Required |
| `ENDOR_API` | API endpoint | `https://api.endorlabs.com` |
| `ENDOR_TOKEN` | Auth token (optional, use `endorctl init` instead) | - |

### MCP Server Options

The MCP server supports additional configuration:

```json
{
  "mcpServers": {
    "endor-mcp-server": {
      "command": "endorctl",
      "args": ["ai-tools", "mcp-server"],
      "env": {
        "ENDOR_NAMESPACE": "your-namespace",
        "ENDOR_API": "https://api.endorlabs.com",
        "MCP_ENDOR_SCAN_PATH": "/path/to/scan",
        "MCP_ENDOR_SCAN_LANGUAGES": "javascript,python"
      }
    }
  }
}
```

## Available MCP Tools

The skill uses these tools from the Endor Labs MCP server:

### Scanning
| Tool | Description |
|------|-------------|
| `scan_repository` | Full repository security scan |

### Vulnerability Analysis
| Tool | Description |
|------|-------------|
| `check_dependency_for_vulnerabilities` | Check a specific package for CVEs |
| `get_endor_vulnerability` | Get detailed CVE information |
| `get_all_vulnerabilities` | List all known vulnerabilities |
| `get_dependency_upgrade_opts` | Find safe upgrade versions |

### Findings Management
| Tool | Description |
|------|-------------|
| `get_security_findings` | Query findings with filters |
| `retrieve_single_finding` | Get detailed finding info |
| `sast_context` | Get code context for SAST findings |

### Code Navigation
| Tool | Description |
|------|-------------|
| `getCallers` | Find what calls a function (reachability) |
| `getCallees` | Find what a function calls |
| `searchSymbol` | Search for code symbols |

### Projects
| Tool | Description |
|------|-------------|
| `projects_by_name` | Find projects by name |
| `get_repository_uuid` | Get project UUID |

## Automatic Rules

The skill includes rules that run automatically:

| Rule | Trigger | Action |
|------|---------|--------|
| Dependency Security | package.json, go.mod, etc. | Check new deps for vulnerabilities |
| Secrets Detection | All code/config files | Detect hardcoded secrets |
| SAST Analysis | Source code files | Check for code vulnerabilities |
| License Compliance | Dependency manifests | Check license compatibility |
| Container Security | Dockerfile, docker-compose | Analyze for misconfigurations |
| PR Security Review | PR/merge discussions | Pre-merge security check |

## Troubleshooting

### "MCP server not found"

Ensure endorctl is in your PATH:
```bash
which endorctl
```

If not found, reinstall or add to PATH.

### "Authentication failed"

Re-authenticate:
```bash
endorctl init
```

### "Namespace not found"

Check your namespace is set:
```bash
echo $ENDOR_NAMESPACE
```

List available namespaces:
```bash
endorctl api list --resource Namespace
```

### "No findings returned"

- Ensure the project has been scanned in Endor Labs
- Check the namespace has the project
- Try scanning first: `/endor scan`

## API Reference

For advanced usage, the Endor Labs REST API is available:

**Base URL:** `https://api.endorlabs.com`

**Authentication:**
```bash
# Get token
endorctl auth --print-access-token

# Use in requests
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.endorlabs.com/v1/namespaces/$NAMESPACE/findings"
```

**Filter Examples:**
```bash
# Critical vulnerabilities
?list_parameters.filter=spec.level==FINDING_LEVEL_CRITICAL

# Reachable issues
?list_parameters.filter=spec.finding_tags contains FINDING_TAGS_REACHABLE_FUNCTION

# Specific CVE
?list_parameters.filter=spec.finding_metadata.vulnerability.spec.aliases contains CVE-2024-1234
```

## Contributing

Contributions welcome! Please submit issues and PRs to improve the skill.

## License

MIT License - See LICENSE file for details.

## Support

- **Endor Labs Docs:** https://docs.endorlabs.com
- **API Reference:** https://docs.endorlabs.com/api/
- **Issues:** File issues in this repository
