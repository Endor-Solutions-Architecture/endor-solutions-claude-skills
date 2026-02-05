---
description: Detect and prevent secrets, credentials, and API keys from being committed to code
globs: "**/*.js, **/*.ts, **/*.jsx, **/*.tsx, **/*.py, **/*.go, **/*.java, **/*.rb, **/*.php, **/*.cs, **/*.rs, **/*.swift, **/*.kt, **/*.scala, **/*.sh, **/*.bash, **/*.zsh, **/*.env, **/*.env.*, **/*.config, **/*.conf, **/*.cfg, **/*.ini, **/*.yaml, **/*.yml, **/*.json, **/*.xml, **/*.properties, **/*.toml, **/Dockerfile, **/docker-compose*.yml, **/*.tf, **/*.tfvars, **/serverless.yml, **/.npmrc, **/.pypirc, **/credentials*, **/secrets*, **/*secret*, **/*credential*, **/*password*, **/*apikey*, **/*api_key*, **/*token*"
alwaysApply: true
---

# Secrets Detection Rule

Automatically scan for exposed secrets, credentials, and sensitive data when creating or modifying files that commonly contain secrets.

## Trigger

This rule activates when you:
- Create or modify configuration files
- Write code that handles authentication
- Create environment files or templates
- Modify CI/CD configurations
- Write infrastructure-as-code (Terraform, CloudFormation, etc.)

## Secret Patterns to Detect

### API Keys & Tokens
- AWS Access Keys: `AKIA[0-9A-Z]{16}`
- AWS Secret Keys: 40-character base64 strings
- GitHub Tokens: `ghp_`, `gho_`, `ghu_`, `ghs_`, `ghr_` prefixes
- GitLab Tokens: `glpat-` prefix
- Slack Tokens: `xox[baprs]-` prefix
- Stripe Keys: `sk_live_`, `pk_live_`, `sk_test_`
- Google API Keys: `AIza[0-9A-Za-z-_]{35}`
- Azure Keys: Various patterns with `azure` context
- NPM Tokens: `npm_` prefix
- PyPI Tokens: `pypi-` prefix

### Credentials
- Passwords in code: `password\s*=\s*["'][^"']+["']`
- Connection strings with embedded credentials
- Basic auth in URLs: `https://user:pass@`
- Private keys: `-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----`
- Certificates with keys

### Cloud & Infrastructure
- AWS ARNs with account IDs
- Database connection strings
- Redis/MongoDB URIs with passwords
- JDBC URLs with credentials
- SSH private keys

### Third-Party Services
- SendGrid, Mailchimp, Twilio API keys
- Firebase configurations with keys
- OAuth client secrets
- JWT secrets

## Required Actions

**BEFORE writing any code or config that might contain secrets:**

1. **Check for Hardcoded Secrets**
   - Scan the content you're about to write for secret patterns
   - Look for variables named: `password`, `secret`, `key`, `token`, `credential`, `auth`

2. **If Secrets Detected:**
   - STOP immediately
   - Do NOT write the file with hardcoded secrets
   - Replace with environment variable references
   - Suggest using a secrets manager

3. **Use Secure Alternatives:**
   ```javascript
   // BAD - hardcoded secret
   const apiKey = "sk_live_abc123xyz";

   // GOOD - environment variable
   const apiKey = process.env.API_KEY;
   ```

   ```python
   # BAD - hardcoded password
   password = "super_secret_123"

   # GOOD - environment variable
   import os
   password = os.environ.get("DB_PASSWORD")
   ```

   ```yaml
   # BAD - secret in config
   api_key: sk_live_abc123xyz

   # GOOD - reference to secret
   api_key: ${API_KEY}
   ```

4. **Run Secrets Scan After Writing**
   - Use `endor-labs-cli` MCP tool with secrets rules
   - Or run `scan_repository` to check for exposed secrets

## Environment File Handling

When creating `.env` files:
1. Create `.env.example` with placeholder values instead
2. Add `.env` to `.gitignore`
3. Never commit actual secrets

```bash
# .env.example (safe to commit)
DATABASE_URL=postgresql://user:password@localhost:5432/db
API_KEY=your_api_key_here
SECRET_KEY=generate_a_random_key

# .env (NEVER commit)
DATABASE_URL=postgresql://admin:real_password@prod.db.com:5432/mydb
API_KEY=sk_live_actual_key_here
SECRET_KEY=abc123realkey456
```

## Scan for Secrets

After writing files, proactively scan:

```
Use endor-labs-cli MCP tool with:
- ruleset: "secrets"
- path: path to file or directory
```

Or use the full scan:
```
Use scan_repository MCP tool
- Check findings with category: FINDING_CATEGORY_SECRETS
```

## Response When Secrets Found

If you detect a potential secret:

1. **Alert the user immediately:**
   ```
   ⚠️ POTENTIAL SECRET DETECTED

   I found what appears to be a hardcoded secret:
   - File: config/database.js
   - Line: 15
   - Type: Database password

   This should NOT be committed to version control.
   ```

2. **Provide secure alternative:**
   ```
   Replace with:
   const dbPassword = process.env.DB_PASSWORD;

   And add to your .env file (not committed):
   DB_PASSWORD=your_actual_password
   ```

3. **Check git status:**
   - If file with secrets is staged, warn about unstaging
   - Suggest adding to .gitignore if appropriate

## Do Not Commit Secrets

Even if the user says:
- "It's just for testing"
- "I'll change it later"
- "It's not a real secret"

Always use environment variables or secrets management. Test secrets still shouldn't be hardcoded as they often end up in production.
