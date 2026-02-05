---
name: endor-setup
description: Quick setup wizard to get started with Endor Labs in under 5 minutes
---

# Endor Labs: Quick Setup

Get started with Endor Labs security scanning in under 5 minutes. This wizard will guide you through setup and verify everything works.

## Arguments

$ARGUMENTS - Optional: `check`, `fix`, `reset`

## Instructions

### Parse Arguments

| Argument | Action |
|----------|--------|
| (none) | Run interactive setup wizard |
| `check` | Verify current setup is working |
| `status` | Show setup status without fixing |
| `fix` | Auto-fix common setup issues |
| `reset` | Reset and reconfigure |

### Interactive Setup Wizard

Present this friendly welcome:

```markdown
# Welcome to Endor Labs Security Scanning

I'll help you get set up in about 5 minutes. Here's what we'll do:

1. **Check Prerequisites** - Verify endorctl is installed
2. **Authenticate** - Connect to your Endor Labs account
3. **Configure Namespace** - Set your organization namespace
4. **Test Scan** - Run a quick scan to verify everything works

Let's get started!
```

### Step 1: Check Prerequisites

**Check if endorctl is installed:**
```bash
which endorctl || command -v endorctl
endorctl version
```

**If NOT installed, provide installation options:**
```markdown
## Install endorctl

Choose your installation method:

### Option A: Homebrew (macOS/Linux) - Recommended
```bash
brew install endorlabs/tap/endorctl
```

### Option B: npm (Cross-platform)
```bash
npm install -g endorctl
```

### Option C: Direct Download
```bash
# macOS (Intel)
curl -sSL https://api.endorlabs.com/download/latest/endorctl_darwin_amd64 -o endorctl

# macOS (Apple Silicon)
curl -sSL https://api.endorlabs.com/download/latest/endorctl_darwin_arm64 -o endorctl

# Linux
curl -sSL https://api.endorlabs.com/download/latest/endorctl_linux_amd64 -o endorctl

# Then make executable and move to PATH
chmod +x endorctl
sudo mv endorctl /usr/local/bin/
```

After installing, run `/endor-setup` again to continue.
```

**If installed, show version and continue:**
```markdown
## Prerequisites

**endorctl version:** {version}
**Status:** Installed

Proceeding to authentication...
```

### Step 2: Authentication

**Check if already authenticated:**
```bash
endorctl auth status 2>&1 || echo "not_authenticated"
```

**If NOT authenticated:**
```markdown
## Authentication Required

Run this command to log in:

```bash
endorctl init
```

This will open your browser to authenticate with Endor Labs.

**Don't have an account yet?**
1. Go to [app.endorlabs.com](https://app.endorlabs.com)
2. Sign up for free (GitHub login works!)
3. Come back and run `endorctl init`

After authenticating, run `/endor-setup` again to continue.
```

**If authenticated:**
```markdown
## Authentication

**Status:** Authenticated
**User:** {user info if available}

Proceeding to namespace configuration...
```

### Step 3: Configure Namespace

**Check current namespace:**
```bash
echo $ENDOR_NAMESPACE
endorctl api list --resource Namespace --count 2>/dev/null || echo "no_namespaces"
```

**If ENDOR_NAMESPACE not set:**
```markdown
## Configure Your Namespace

Your namespace is your organization identifier in Endor Labs.

**Available namespaces:**
{list namespaces from API}

**Set your namespace:**

```bash
# For this session:
export ENDOR_NAMESPACE=your-namespace-here

# To make permanent, add to your shell profile:
echo 'export ENDOR_NAMESPACE=your-namespace-here' >> ~/.bashrc
# or for zsh:
echo 'export ENDOR_NAMESPACE=your-namespace-here' >> ~/.zshrc
```

**Tip:** If you only have one namespace, I recommend setting it permanently.

After setting your namespace, run `/endor-setup` again to continue.
```

**If namespace is set:**
```markdown
## Namespace Configuration

**Namespace:** {ENDOR_NAMESPACE}
**Status:** Configured

Proceeding to test scan...
```

### Step 4: Test Scan

**Run a quick verification:**

```markdown
## Testing Your Setup

Let me run a quick scan to verify everything is working...
```

Use the `scan_repository` MCP tool with the current directory.

**If successful:**
```markdown
## Setup Complete!

**Everything is working!** Here's what I found in your initial scan:

{Brief summary of any findings}

### What's Next?

| Command | What It Does |
|---------|--------------|
| `/endor scan` | Quick security scan |
| `/endor check lodash` | Check a specific package |
| `/endor-help` | See all available commands |

### Quick Tips

1. **Daily workflow:** Run `/endor scan` before committing
2. **Checking packages:** Run `/endor check <package>@<version>` before adding dependencies
3. **CI/CD:** Run `/endor-cicd github` to generate a security workflow

You're all set! Start with `/endor scan` to see your security posture.
```

**If scan fails:**
```markdown
## Setup Issue Detected

The scan couldn't complete. Here's what might be wrong:

### Common Issues

1. **Namespace not accessible**
   - Verify you have access: `endorctl api list --resource Namespace`

2. **No project in namespace**
   - First-time users: The initial scan creates the project
   - Try: `endorctl scan --path . --output-type summary`

3. **Authentication expired**
   - Re-authenticate: `endorctl init`

### Need Help?

- Run `/endor-setup fix` to auto-fix common issues
- Check [docs.endorlabs.com](https://docs.endorlabs.com) for detailed guides
- Run `/endor-help troubleshoot` for more debugging steps
```

### Check Status (check argument)

```markdown
## Endor Labs Setup Status

| Component | Status | Details |
|-----------|--------|---------|
| endorctl | {Installed/Not Found} | {version or install instructions} |
| Authentication | {Active/Expired/Missing} | {user or login instructions} |
| Namespace | {Set/Not Set} | {namespace value or instructions} |
| MCP Server | {Connected/Not Connected} | {status} |

### Overall Status: {Ready/Setup Required}

{If not ready: specific instructions for what to fix}
```

### Fix Common Issues (fix argument)

```markdown
## Auto-Fix Results

I'll attempt to fix common setup issues:

### Checking...

1. **endorctl installation:** {status}
2. **Authentication:** {status}
3. **Namespace:** {status}
4. **MCP connection:** {status}

### Actions Taken

{List any fixes applied}

### Manual Steps Required

{List any issues that need manual intervention}
```

### Key UX Principles

1. **Never leave users stuck** - Always provide a clear next action
2. **Detect and adapt** - Check what's already set up, skip completed steps
3. **Provide escape hatches** - Let users check status, fix issues, or reset
4. **Celebrate success** - When setup works, acknowledge it clearly
5. **Be specific about errors** - Don't just say "failed", say what and why
