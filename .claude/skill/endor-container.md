# Endor Labs: Container Security

Scan container images for vulnerabilities, misconfigurations, and compliance issues.

## Arguments

$ARGUMENTS - Image reference or action: `<image:tag>`, `scan`, `registry`, `dockerfile`

## Instructions

### Parse Arguments

| Argument | Action |
|----------|--------|
| `<image:tag>` | Scan specific image |
| `scan` | Scan image from current Dockerfile |
| `registry` | Scan images from connected registry |
| `dockerfile` | Analyze Dockerfile for issues |
| `sbom` | Generate container SBOM |
| No argument | Detect and scan local images |

### Scan Container Image

Use endorctl container commands:

```bash
# Scan a specific image
endorctl container scan --image nginx:1.25

# Scan from registry
endorctl container scan --image ghcr.io/org/app:latest

# Scan with SBOM output
endorctl container scan --image app:latest --sbom-output sbom.json
```

### Present Scan Results

```markdown
## Container Security Scan

**Image:** nginx:1.25-alpine
**Digest:** sha256:abc123...
**Size:** 42.5 MB
**Created:** 2024-01-15

---

### Summary

| Category | Critical | High | Medium | Low |
|----------|----------|------|--------|-----|
| OS Vulnerabilities | 0 | 2 | 8 | 15 |
| App Dependencies | 1 | 3 | 5 | 10 |
| Misconfigurations | 0 | 1 | 2 | 0 |
| Secrets | 0 | 0 | 0 | 0 |

**Overall Risk:** ⚠️ HIGH (6 high+ severity issues)

---

### Base Image Analysis

| Property | Value | Assessment |
|----------|-------|------------|
| Base Image | alpine:3.18 | Up to date |
| OS | Alpine Linux 3.18 | Supported |
| Last Updated | 30 days ago | Recent |
| Size | 7.8 MB | Minimal |

**Recommendation:** Base image is current. Consider `alpine:3.19` for latest patches.

---

### OS Vulnerabilities (25)

#### Critical (0)
None found.

#### High (2)

| CVE | Package | Installed | Fixed | Description |
|-----|---------|-----------|-------|-------------|
| CVE-2024-1234 | openssl | 3.1.0-r1 | 3.1.0-r4 | Buffer overflow |
| CVE-2024-5678 | curl | 8.4.0-r0 | 8.5.0-r0 | HSTS bypass |

**Fix:** Update base image or run:
```dockerfile
RUN apk upgrade --no-cache openssl curl
```

---

### Application Dependencies (19)

Detected package manager: npm (node_modules)

#### Critical (1)

| Package | Version | CVE | Severity | Fixed In |
|---------|---------|-----|----------|----------|
| lodash | 4.17.15 | CVE-2021-23337 | CRITICAL | 4.17.21 |

#### High (3)

| Package | Version | CVE | Fixed In |
|---------|---------|-----|----------|
| axios | 0.21.0 | CVE-2021-3749 | 0.21.1 |
| minimist | 1.2.5 | CVE-2021-44906 | 1.2.6 |
| node-fetch | 2.6.0 | CVE-2022-0235 | 2.6.7 |

---

### Misconfigurations (3)

#### High (1)

**Running as root**
```dockerfile
# Current (insecure)
USER root

# Recommended
USER nginx
```

#### Medium (2)

**No health check defined**
```dockerfile
# Add health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q --spider http://localhost/ || exit 1
```

**Sensitive port exposed**
```dockerfile
# Current
EXPOSE 22

# Remove SSH if not needed
# EXPOSE 22
```

---

### Secrets Detection

No secrets detected in image layers.

**Checked:**
- Environment variables
- Configuration files
- Image history/layers
- Embedded credentials

---

### Image Layers Analysis

| Layer | Size | Command | Issues |
|-------|------|---------|--------|
| 1 | 7.8 MB | FROM alpine:3.18 | 0 |
| 2 | 2.1 MB | RUN apk add nginx | 0 |
| 3 | 32 MB | COPY node_modules | 4 vulns |
| 4 | 0.5 MB | COPY app | 0 |

**Largest layer:** Layer 3 (node_modules) - consider multi-stage build

---

### Recommendations

1. **Immediate:** Update lodash to fix critical CVE
2. **High Priority:** Update base image packages
3. **Security:** Run as non-root user
4. **Best Practice:** Add health check
5. **Optimization:** Use multi-stage build to reduce size

---

### Remediated Dockerfile

```dockerfile
# Multi-stage build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM alpine:3.19
RUN apk add --no-cache nginx && \
    adduser -D -H -s /sbin/nologin appuser

COPY --from=builder /app/node_modules ./node_modules
COPY --chown=appuser:appuser . .

USER appuser
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
```
```

### Dockerfile Analysis

Analyze Dockerfile without building:

```markdown
## Dockerfile Analysis

**File:** Dockerfile
**Lines:** 25

---

### Issues Found

#### High Severity

**1. Using `latest` tag (line 1)**
```dockerfile
FROM node:latest
```
**Issue:** Non-deterministic builds, security unpredictable
**Fix:** `FROM node:20-alpine`

**2. Running as root (no USER directive)**
**Issue:** Container runs with root privileges
**Fix:** Add `USER node` or create non-root user

---

#### Medium Severity

**3. Package manager cache not cleaned (line 8)**
```dockerfile
RUN apt-get update && apt-get install -y curl
```
**Issue:** Cache increases image size, stale packages
**Fix:**
```dockerfile
RUN apt-get update && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*
```

**4. Multiple RUN commands (lines 5-12)**
**Issue:** Creates unnecessary layers
**Fix:** Combine into single RUN

---

#### Low Severity

**5. No .dockerignore file**
**Issue:** May copy unnecessary files
**Fix:** Create `.dockerignore`:
```
node_modules
.git
*.md
.env
```

---

### Best Practices Checklist

| Practice | Status |
|----------|--------|
| Specific base image tag | ❌ Using :latest |
| Non-root user | ❌ Not configured |
| Multi-stage build | ❌ Not used |
| Minimal base image | ⚠️ Could use alpine |
| Layer optimization | ⚠️ Multiple RUN commands |
| No secrets in build | ✅ None detected |
| Health check | ❌ Not defined |
| Security scanning | ⚠️ Not in CI |

---

### Optimized Dockerfile

```dockerfile
# syntax=docker/dockerfile:1
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:20-alpine

# Security: non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
COPY --from=builder --chown=appuser:appuser /app/node_modules ./node_modules
COPY --chown=appuser:appuser . .

USER appuser
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1

CMD ["node", "server.js"]
```
```

### Registry Scan

```markdown
## Container Registry Scan

**Registry:** ghcr.io/myorg
**Images Scanned:** 15
**Scan Date:** {date}

---

### Summary by Repository

| Repository | Images | Critical | High | Medium |
|------------|--------|----------|------|--------|
| myorg/api | 5 | 2 | 8 | 15 |
| myorg/web | 3 | 0 | 3 | 10 |
| myorg/worker | 4 | 1 | 5 | 8 |
| myorg/tools | 3 | 0 | 2 | 5 |

---

### Critical Findings

| Image | Tag | CVE | Package | Fixed |
|-------|-----|-----|---------|-------|
| api | v1.2.3 | CVE-2021-23337 | lodash | 4.17.21 |
| api | v1.2.2 | CVE-2021-23337 | lodash | 4.17.21 |
| worker | latest | CVE-2024-1234 | openssl | 3.1.0-r4 |

---

### Recommendations

1. Rebuild `api:v1.2.3` with updated dependencies
2. Update `worker:latest` base image
3. Remove deprecated tags older than 90 days
4. Enable automatic scanning in registry settings
```

### Generate Container SBOM

```bash
endorctl container scan --image app:latest --sbom-output container-sbom.json --sbom-format cyclonedx
```

```markdown
## Container SBOM Generated

**Image:** app:latest
**Format:** CycloneDX 1.5
**File:** container-sbom.json

### Contents

| Category | Count |
|----------|-------|
| OS Packages | 45 |
| Application Dependencies | 156 |
| System Libraries | 23 |
| **Total Components** | 224 |

### Use Cases

- Supply chain compliance
- Vulnerability tracking
- License compliance
- Incident response
```
