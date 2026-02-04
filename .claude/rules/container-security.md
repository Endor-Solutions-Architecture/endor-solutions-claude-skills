---
description: Analyze Dockerfiles and container configurations for security issues
globs: "**/Dockerfile, **/Dockerfile.*, **/*.dockerfile, **/docker-compose*.yml, **/docker-compose*.yaml, **/.dockerignore, **/container*.yml, **/container*.yaml"
alwaysApply: true
---

# Container Security Rule

Automatically analyze Dockerfiles and container configurations for security best practices and vulnerabilities.

## Trigger

This rule activates when:
- Creating or modifying a Dockerfile
- Creating or modifying docker-compose files
- Working with container configurations
- Discussing container security

## Security Checks

### Dockerfile Analysis

**Critical Issues:**
1. **Running as root** - No USER directive
2. **Using latest tag** - Non-deterministic builds
3. **Secrets in build args** - Exposed in history
4. **Sensitive data in COPY/ADD** - Credentials in image

**High Issues:**
1. **Privileged containers** - Full host access
2. **Unnecessary capabilities** - Expanded attack surface
3. **Missing health checks** - No liveness monitoring
4. **Exposed sensitive ports** - SSH, database ports

**Medium Issues:**
1. **Package cache not cleaned** - Larger image, stale packages
2. **Multiple RUN commands** - Unnecessary layers
3. **No .dockerignore** - Copying unnecessary files
4. **Using ADD instead of COPY** - Unexpected behavior with URLs

### Docker Compose Analysis

**Security Checks:**
1. Environment variables with secrets
2. Privileged mode enabled
3. Host network mode
4. Sensitive volume mounts (/etc, /var/run/docker.sock)
5. Missing resource limits
6. Exposed ports to 0.0.0.0

## Required Actions

When creating/modifying container files:

### 1. Validate Dockerfile

```dockerfile
# Check for these patterns:

# BAD: Running as root (no USER directive)
# GOOD: USER nonroot

# BAD: FROM node:latest
# GOOD: FROM node:20-alpine

# BAD: ARG PASSWORD=secret
# GOOD: Use runtime secrets

# BAD: COPY . .
# GOOD: COPY --chown=user:group specific-files .
```

### 2. Suggest Secure Patterns

Always recommend:
```dockerfile
# Use specific version tags
FROM node:20-alpine

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy only necessary files
COPY --chown=appuser:appgroup package*.json ./
RUN npm ci --only=production

COPY --chown=appuser:appgroup . .

# Run as non-root
USER appuser

# Add health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q --spider http://localhost:3000/health || exit 1

# Don't expose unnecessary ports
EXPOSE 3000

CMD ["node", "server.js"]
```

### 3. Docker Compose Security

```yaml
version: '3.8'
services:
  app:
    image: app:1.0.0
    # Don't use privileged mode
    # privileged: true  # REMOVE THIS

    # Use read-only filesystem where possible
    read_only: true
    tmpfs:
      - /tmp

    # Drop all capabilities, add only needed
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE

    # Set resource limits
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

    # Use secrets instead of env vars
    secrets:
      - db_password

    # Limit network exposure
    ports:
      - "127.0.0.1:3000:3000"  # Not 0.0.0.0

secrets:
  db_password:
    external: true
```

## Response When Issues Found

```markdown
## Dockerfile Security Analysis

### Issues Found

**Critical:**
- Line 1: Using `:latest` tag - use specific version
- No USER directive - container runs as root

**High:**
- Line 15: No health check defined
- Line 3: Package cache not cleaned

### Secure Dockerfile

Here's a secured version:

{secured dockerfile}

### Checklist
- [ ] Use specific base image tag
- [ ] Create and use non-root user
- [ ] Add health check
- [ ] Clean package manager cache
- [ ] Use multi-stage build
- [ ] Add .dockerignore
```

## Do Not Ignore

Even for development Dockerfiles, apply security best practices. Insecure patterns in dev often make it to production.
