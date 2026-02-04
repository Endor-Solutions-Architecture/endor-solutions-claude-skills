# Endor Labs: Secrets Scanner

Scan for exposed secrets, credentials, API keys, and sensitive data in your codebase.

## Arguments

$ARGUMENTS - Optional: specific file path, directory, or "all" for full scan

## Instructions

### Determine Scan Scope

1. If file path provided → scan that specific file
2. If directory provided → scan that directory
3. If "all" or no argument → scan entire repository

### Execute Secrets Scan

**Option 1: Using opengrep with secrets rules**
```json
{
  "path": "/path/to/scan",
  "ruleset": "secrets"
}
```

**Option 2: Using full repository scan**
```json
{
  "path": "/path/to/repo"
}
```
Then filter findings: `spec.finding_categories contains FINDING_CATEGORY_SECRETS`

### Secret Types to Identify

| Type | Pattern | Risk |
|------|---------|------|
| AWS Access Key | `AKIA[0-9A-Z]{16}` | Cloud compromise |
| AWS Secret Key | 40-char base64 | Cloud compromise |
| GitHub Token | `ghp_`, `gho_`, etc. | Repo access |
| Private Key | `-----BEGIN.*PRIVATE KEY-----` | Auth bypass |
| Database URL | `postgres://`, `mysql://` with creds | Data breach |
| API Key | Various `_key`, `_token` patterns | Service abuse |
| JWT Secret | Context-based | Auth bypass |
| Password | `password\s*=` assignments | Account takeover |

### Present Results

```markdown
## Secrets Scan Results

**Scope:** {path}
**Files Scanned:** {count}

### Exposed Secrets Found ({count})

#### 1. AWS Access Key
- **File:** config/aws.js:12
- **Type:** AWS Access Key ID
- **Risk:** CRITICAL - Could allow full AWS account access
- **Value:** `AKIA...` (partially redacted)

**Remediation:**
1. Rotate this key immediately in AWS IAM
2. Replace with environment variable:
   ```javascript
   const accessKey = process.env.AWS_ACCESS_KEY_ID;
   ```
3. Add to `.gitignore`: `*.env`

#### 2. Database Password
- **File:** docker-compose.yml:25
- **Type:** Hardcoded password
- **Risk:** HIGH - Database compromise

**Remediation:**
1. Use Docker secrets or environment variables
2. Replace:
   ```yaml
   environment:
     - POSTGRES_PASSWORD=${DB_PASSWORD}
   ```

### Files to Add to .gitignore

```
.env
.env.*
*.pem
*.key
credentials.json
secrets.yaml
```

### Immediate Actions Required

1. **Rotate all exposed secrets** - assume they are compromised
2. **Check git history** - secrets may exist in previous commits
3. **Use git-filter-repo** to remove secrets from history if needed
4. **Enable secret scanning** in your repository settings

### Git History Warning

If these files were previously committed, the secrets exist in git history.
To fully remove:
```bash
# Remove from history (USE WITH CAUTION)
git filter-repo --invert-paths --path config/aws.js

# Or use BFG Repo-Cleaner
bfg --delete-files config/aws.js
```
```

### If No Secrets Found

```markdown
## Secrets Scan Results

**Scope:** {path}
**Status:** No secrets detected

Your codebase appears clean of hardcoded secrets.

### Best Practices Reminder

- Use environment variables for all secrets
- Use a secrets manager (AWS Secrets Manager, HashiCorp Vault, etc.)
- Add `.env` files to `.gitignore`
- Enable GitHub secret scanning
- Run secrets scans in CI/CD pipeline
```

### Integration with CI/CD

Suggest adding secrets scanning to CI pipeline:

```yaml
# GitHub Actions example
- name: Scan for secrets
  run: |
    endorctl scan --secrets-only --path .

# Or with Endor Labs GitHub App
# Secrets scanning is automatic on every PR
```
