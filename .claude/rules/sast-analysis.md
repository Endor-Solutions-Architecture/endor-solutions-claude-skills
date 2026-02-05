---
description: Perform static application security testing (SAST) to detect code vulnerabilities
globs: "**/*.js, **/*.ts, **/*.jsx, **/*.tsx, **/*.mjs, **/*.cjs, **/*.py, **/*.go, **/*.java, **/*.rb, **/*.php, **/*.cs, **/*.c, **/*.cpp, **/*.h, **/*.hpp, **/*.rs, **/*.swift, **/*.kt, **/*.scala, **/*.vue, **/*.svelte"
alwaysApply: true
---

# SAST Analysis Rule

Automatically analyze code for security vulnerabilities using static analysis when writing or modifying source code files.

## Trigger

This rule activates when you:
- Create new source code files
- Make significant changes to existing code
- Implement authentication, authorization, or data handling
- Write code that processes user input
- Create API endpoints or database queries

# Static Application Security Testing (SAST) Rule (Endor Labs via MCP)

## Workflow

Whenever a file is modified in the repository, and before the end of an agent session perform the following workflow:

- Run `endor-cli-tools` using the `scan` tool via the MCP server to perform SAST scans as described above.
- If any vulnerabilities or errors are found:
  - Present the issues to the user.
  - The AI agent must attempt to automatically correct all errors and vulnerabilities, including code errors, security issues, and best practice violations, before session completion.
  - Recommend and apply appropriate fixes (e.g., input sanitization, validation, escaping, secure APIs).
  - Continue scanning and correcting until all critical issues have been resolved or no further automated remediation is possible.
- If an error occurs in any MCP server tool call (such as missing required parameters like version, invalid arguments, or tool invocation failures):
  - The AI agent must review the error, determine the cause, and automatically correct the tool call or input parameters.
  - Re-attempt the tool call with the corrected parameters.
  - Continue this process until the tool call succeeds or it is determined that remediation is not possible, in which case the issue and reason must be reported.
- Save scan results and remediation steps in a security log or as comments for audit purposes.
- Do not invoke Opengrep directly.

This rule ensures all code changes are automatically reviewed and remediated for common security vulnerabilities and errors using `endor-cli-tools` and the MCP server, with Opengrep as the underlying engine.

## Vulnerability Categories to Detect

### Injection Vulnerabilities

**SQL Injection**
```javascript
// VULNERABLE
const query = `SELECT * FROM users WHERE id = ${userId}`;
db.query(query);

// SAFE
const query = "SELECT * FROM users WHERE id = ?";
db.query(query, [userId]);
```

**Command Injection**
```python
# VULNERABLE
os.system(f"ls {user_input}")

# SAFE
subprocess.run(["ls", user_input], shell=False)
```

**XSS (Cross-Site Scripting)**
```javascript
// VULNERABLE
element.innerHTML = userInput;

// SAFE
element.textContent = userInput;
// or use a sanitization library
```

**Path Traversal**
```python
# VULNERABLE
with open(f"/uploads/{filename}") as f:
    return f.read()

# SAFE
import os
safe_path = os.path.normpath(os.path.join("/uploads", filename))
if not safe_path.startswith("/uploads/"):
    raise ValueError("Invalid path")
```

### Authentication & Authorization

**Hardcoded Credentials** → See secrets-detection rule

**Weak Cryptography**
```python
# VULNERABLE - MD5 for passwords
import hashlib
hashlib.md5(password.encode()).hexdigest()

# SAFE - Use proper password hashing
import bcrypt
bcrypt.hashpw(password.encode(), bcrypt.gensalt())
```

**Missing Authentication**
```javascript
// VULNERABLE - No auth check
app.get('/admin/users', (req, res) => {
  return db.getAllUsers();
});

// SAFE - Auth middleware
app.get('/admin/users', requireAuth, requireAdmin, (req, res) => {
  return db.getAllUsers();
});
```

**Broken Access Control**
```python
# VULNERABLE - No ownership check
@app.route('/document/<doc_id>')
def get_document(doc_id):
    return Document.query.get(doc_id)

# SAFE - Check ownership
@app.route('/document/<doc_id>')
@login_required
def get_document(doc_id):
    doc = Document.query.get(doc_id)
    if doc.owner_id != current_user.id:
        abort(403)
    return doc
```

### Data Exposure

**Sensitive Data Logging**
```java
// VULNERABLE
logger.info("User login: " + username + ", password: " + password);

// SAFE
logger.info("User login: " + username);
```

**Information Disclosure in Errors**
```python
# VULNERABLE
except Exception as e:
    return {"error": str(e), "stack": traceback.format_exc()}

# SAFE
except Exception as e:
    logger.error(f"Error: {e}", exc_info=True)
    return {"error": "An internal error occurred"}
```

### Insecure Configurations

**Debug Mode in Production**
```python
# VULNERABLE
app.run(debug=True)

# SAFE
app.run(debug=os.environ.get('DEBUG', 'False').lower() == 'true')
```

**CORS Misconfiguration**
```javascript
// VULNERABLE
app.use(cors({ origin: '*' }));

// SAFE
app.use(cors({ origin: process.env.ALLOWED_ORIGINS.split(',') }));
```

**Missing Security Headers**
```javascript
// Add security headers
app.use(helmet());
```

### Unsafe Deserialization

```python
# VULNERABLE
import pickle
data = pickle.loads(user_input)

# SAFE - Use JSON or validate strictly
import json
data = json.loads(user_input)
```

```java
// VULNERABLE
ObjectInputStream ois = new ObjectInputStream(userInput);
Object obj = ois.readObject();

// SAFE - Use allowlist or JSON
ObjectMapper mapper = new ObjectMapper();
SafeClass obj = mapper.readValue(userInput, SafeClass.class);
```

## Required Actions

### When Writing New Code

1. **Before implementing sensitive operations:**
   - Authentication/authorization logic
   - Database queries
   - File operations
   - External command execution
   - User input processing

2. **Apply secure coding patterns:**
   - Use parameterized queries for database operations
   - Validate and sanitize all user input
   - Use proper encoding for output contexts
   - Implement proper error handling without data leakage
   - Use secure defaults for configurations

### After Writing Code

1. **Run SAST scan on the modified file:**
   ```
   Use endor-labs-cli MCP tool with:
   - path: path to the modified file
   - (default rulesets will be applied)
   ```

2. **For comprehensive scan:**
   ```
   Use scan_repository MCP tool
   - Check findings with category: FINDING_CATEGORY_SAST
   ```

3. **Review and fix any findings before proceeding**

## Language-Specific Patterns

### JavaScript/TypeScript
- Use `===` instead of `==` for comparisons
- Avoid `eval()`, `Function()`, `setTimeout(string)`
- Use `new URL()` for URL parsing, not string manipulation
- Use `crypto.randomUUID()` not `Math.random()` for IDs

### Python
- Use `secrets` module for cryptographic operations
- Use `shlex.quote()` for shell arguments
- Use `defusedxml` instead of `xml.etree`
- Avoid `exec()`, `eval()`, `__import__()`

### Go
- Use `html/template` not `text/template` for HTML
- Use `crypto/rand` not `math/rand` for security
- Check errors from `Close()` calls
- Use `filepath.Clean()` for path operations

### Java
- Use PreparedStatement for SQL
- Use `java.security.SecureRandom`
- Avoid `Runtime.exec()` with user input
- Use try-with-resources for streams

## Scan Integration

After significant code changes, automatically check for SAST issues:

```
1. Use endor-labs-cli tool for quick file-level scan
2. Use get_security_findings with filter:
   spec.finding_categories contains FINDING_CATEGORY_SAST
3. For findings, use sast_context to get detailed context
```

## Response Format

When SAST issues are found:

```markdown
## SAST Analysis Results

### Critical Issues

#### SQL Injection in user_service.py:45
**Severity:** CRITICAL
**CWE:** CWE-89

**Vulnerable Code:**
```python
query = f"SELECT * FROM users WHERE email = '{email}'"
```

**Recommended Fix:**
```python
query = "SELECT * FROM users WHERE email = %s"
cursor.execute(query, (email,))
```

### Summary
- 1 Critical (SQL Injection)
- 2 High (XSS, Path Traversal)
- 3 Medium (Information Disclosure)

Run `/endor-fix` to get remediation guidance.
```

## Do Not Skip

Even for internal tools or prototypes, apply secure coding practices. Vulnerabilities in "temporary" code often make it to production.
