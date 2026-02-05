---
name: endor-sast
description: Perform static application security testing to find code vulnerabilities
---

# Endor Labs: SAST Analysis

Perform static application security testing to find code vulnerabilities.

## Arguments

$ARGUMENTS - Optional: specific file path, directory, language filter, or vulnerability type

## Instructions

### Parse Arguments

- File path → scan specific file
- Directory → scan directory
- Language (js, python, go, java, etc.) → filter by language
- Vuln type (sqli, xss, injection, auth) → filter by category
- No arguments → scan current repository

### Execute SAST Scan

**For specific file or quick scan:**
```
Use opengrep MCP tool with:
- path: target file or directory
- (applies default security rules)
```

**For comprehensive scan:**
```
Use scan_repository MCP tool with full path
Then filter: spec.finding_categories contains FINDING_CATEGORY_SAST
```

**For detailed finding context:**
```
Use sast_context MCP tool with finding UUID
Returns: surrounding code, data flow, remediation hints
```

### Vulnerability Categories

| Category | CWE | Description |
|----------|-----|-------------|
| SQL Injection | CWE-89 | Unsanitized input in SQL queries |
| XSS | CWE-79 | Unsanitized output in HTML context |
| Command Injection | CWE-78 | User input in system commands |
| Path Traversal | CWE-22 | User input in file paths |
| SSRF | CWE-918 | User-controlled URLs in requests |
| Insecure Deserialization | CWE-502 | Deserializing untrusted data |
| XXE | CWE-611 | XML external entity processing |
| Hardcoded Secrets | CWE-798 | Credentials in source code |
| Weak Crypto | CWE-327 | Insecure cryptographic algorithms |
| Missing Auth | CWE-306 | Endpoints without authentication |

### Present Results by Severity

```markdown
## SAST Analysis Results

**Scope:** {path}
**Languages:** {detected_languages}
**Rules Applied:** {rule_count}

### Critical Vulnerabilities ({count})

#### SQL Injection - user_controller.py:89

**CWE:** CWE-89 - SQL Injection
**CVSS:** 9.8 (Critical)

**Vulnerable Code:**
```python
# Line 89
def get_user(user_id):
    query = f"SELECT * FROM users WHERE id = {user_id}"  # VULNERABLE
    return db.execute(query)
```

**Data Flow:**
```
user_id (request parameter)
  → get_user() parameter
  → f-string interpolation
  → SQL query execution
```

**Fix:**
```python
def get_user(user_id):
    query = "SELECT * FROM users WHERE id = %s"
    return db.execute(query, (user_id,))
```

**Why This Matters:**
An attacker can manipulate the `user_id` parameter to:
- Extract all data from the database
- Modify or delete records
- Potentially execute system commands (depending on DB)

---

#### XSS - templates/profile.html:45

**CWE:** CWE-79 - Cross-Site Scripting
**CVSS:** 6.1 (Medium)

**Vulnerable Code:**
```html
<!-- Line 45 -->
<div class="username">{{ username | safe }}</div>  <!-- VULNERABLE -->
```

**Fix:**
```html
<div class="username">{{ username }}</div>  <!-- Auto-escaped -->
```

---

### High Vulnerabilities ({count})

[Similar format...]

### Summary

| Severity | Count | Categories |
|----------|-------|------------|
| Critical | 2 | SQL Injection, Command Injection |
| High | 5 | XSS (3), Path Traversal (2) |
| Medium | 8 | Information Disclosure, Weak Crypto |
| Low | 12 | Code Quality, Best Practices |

### Priority Remediation Order

1. **SQL Injection in user_controller.py** - Direct database access risk
2. **Command Injection in deploy.py** - Remote code execution risk
3. **XSS in profile.html** - User session hijacking risk
4. **Path Traversal in file_handler.py** - File system access risk

### Quick Fixes Available

Run `/endor-fix` to get detailed remediation for each issue.
```

### Language-Specific Guidance

**JavaScript/TypeScript:**
```markdown
### JS/TS Security Patterns

**Instead of:**
```javascript
element.innerHTML = userInput;
eval(code);
new Function(code);
```

**Use:**
```javascript
element.textContent = userInput;
// Avoid eval entirely, use JSON.parse for data
```
```

**Python:**
```markdown
### Python Security Patterns

**Instead of:**
```python
os.system(f"cmd {user_input}")
pickle.loads(data)
exec(code)
```

**Use:**
```python
subprocess.run(["cmd", user_input], shell=False)
json.loads(data)
# Avoid exec, use safe alternatives
```
```

**Go:**
```markdown
### Go Security Patterns

**Instead of:**
```go
template.HTML(userInput)
exec.Command("sh", "-c", userInput)
```

**Use:**
```go
template.HTMLEscapeString(userInput)
exec.Command("cmd", userInput) // No shell
```
```

### Call Graph Analysis

For reachability context, show how vulnerabilities connect to entry points:

```markdown
### Reachability Analysis

The SQL Injection in `user_controller.py:89` is reachable from:

```
HTTP POST /api/users/{id}
  → routes.py:45 user_routes()
  → user_controller.py:89 get_user(id)  ← VULNERABLE
  → database.py:23 execute(query)
```

**Exploitability:** HIGH - Directly reachable from unauthenticated endpoint
```

### If No Issues Found

```markdown
## SAST Analysis Results

**Scope:** {path}
**Status:** No security vulnerabilities detected

Your code follows secure coding practices.

### Continuous Security

- Keep this scan in your CI/CD pipeline
- Update security rules regularly
- Review new code with security in mind
- Consider threat modeling for new features
```
