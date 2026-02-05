---
name: endor-setup
description: |
  Onboarding wizard for Endor Labs. Guides users through installing endorctl, authenticating, configuring namespace, and running their first scan.
  - MANDATORY TRIGGERS: endor setup, endor onboarding, endor configure, endor auth, endor install, setup endor
---

# Endor Labs Setup Wizard

Guide the user from zero to scanning in 5 minutes.

## Step 1: Check Prerequisites

### 1.1 Check if endorctl is installed

```bash
endorctl --version 2>/dev/null
```

If not installed, provide installation instructions:

```bash
# macOS (Homebrew)
brew install endorlabs/tap/endorctl

# macOS / Linux (curl)
curl https://api.endorlabs.com/download/latest/endorctl_linux_amd64 -o endorctl
chmod +x endorctl
sudo mv endorctl /usr/local/bin/

# Verify installation
endorctl --version
```

### 1.2 Check if MCP server is configured

Check if the MCP server configuration exists. Look for `endor-mcp-server` in the project's `.claude/settings.json` or the user's global Claude settings.

If not configured, create or update `.claude/settings.json`:

```json
{
  "mcpServers": {
    "endor-mcp-server": {
      "command": "endorctl",
      "args": ["ai-tools", "mcp-server"],
      "env": {
        "ENDOR_NAMESPACE": "${ENDOR_NAMESPACE}",
        "ENDOR_API": "https://api.endorlabs.com"
      }
    }
  }
}
```

Tell the user they need to restart Claude Code after updating settings.json for the MCP server to become available.

## Step 2: Authenticate

### 2.1 Check authentication status

```bash
endorctl auth status
```

### 2.2 If not authenticated, guide login

```bash
# Interactive browser login (recommended for first-time)
endorctl auth login

# Or use API key (for CI/CD or headless environments)
export ENDOR_API_CREDENTIALS_KEY=<your-api-key>
export ENDOR_API_CREDENTIALS_SECRET=<your-api-secret>
```

**Important:** Never ask the user to paste their API key or secret into chat. Instruct them to set environment variables themselves.

## Step 3: Configure Namespace

### 3.1 Check current namespace

```bash
echo $ENDOR_NAMESPACE
```

### 3.2 If not set, help the user find their namespace

Ask the user for their Endor Labs namespace (organization name). Then:

```bash
export ENDOR_NAMESPACE=<their-namespace>
```

Suggest adding this to their shell profile (`.bashrc`, `.zshrc`) for persistence.

## Step 4: Run Test Scan

Run a quick scan to verify everything works:

```bash
endorctl scan --path . --output-type summary
```

If this succeeds, the setup is complete.

## Step 5: Success

Congratulate the user and suggest next steps:

1. **Quick scan**: Run `/endor-scan` for a fast security overview
2. **Full scan**: Run `/endor-scan-full` for deep reachability analysis
3. **Check a package**: Run `/endor-check` to check a specific dependency
4. **See all commands**: Run `/endor-help` for a complete command reference

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `endorctl: command not found` | Install endorctl (see Step 1) |
| `authentication required` | Run `endorctl auth login` |
| `namespace not found` | Verify ENDOR_NAMESPACE is correct |
| `MCP tools not available` | Check settings.json and restart Claude Code |
| `permission denied` | Verify your account has access to the namespace |
