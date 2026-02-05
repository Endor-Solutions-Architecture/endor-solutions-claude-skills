---
name: endor-score
description: View Endor Labs health scores for open source packages
---

# Endor Labs: Package Health Scores

View Endor Labs health scores for open source packages - evaluate packages before adding them as dependencies.

## Arguments

$ARGUMENTS - Package name with optional version: `lodash`, `lodash@4.17.21`, `npm:lodash`, `pypi:requests`

## Instructions

### Parse Package Input

| Input | Interpretation |
|-------|----------------|
| `lodash` | Detect language from context, get latest |
| `lodash@4.17.21` | Specific version |
| `npm:lodash` | Explicit npm package |
| `pypi:requests` | Explicit PyPI package |
| `go:github.com/gin-gonic/gin` | Go module |
| `maven:com.google.guava:guava` | Maven artifact |

### Get Package Scores

**Step 1: Find the PackageVersion in OSS namespace**

```
GET /v1/namespaces/oss/package-versions
Filter: meta.name==npm://lodash@4.17.21
```

**Step 2: Get the Scorecard Metric**

```
GET /v1/namespaces/oss/metrics
Filter: meta.name==package_version_scorecard and meta.parent_uuid=={package_uuid}
```

### Endor Scores Explained

| Score | Description | Weight |
|-------|-------------|--------|
| **Activity** | Commit frequency, release cadence, contributor activity | 25% |
| **Popularity** | Downloads, stars, forks, dependents | 25% |
| **Security** | Vulnerabilities, security practices, OSSF scorecard | 30% |
| **Code Quality** | Test coverage, code smells, documentation | 20% |

### Present Results

```markdown
## Package Health Report: lodash

**Package:** lodash
**Version:** 4.17.21 (latest)
**Ecosystem:** npm
**License:** MIT

---

### Endor Score: 78/100

```
Overall    [████████████████░░░░] 78/100
           ├─ Activity  [████████████████████] 95/100
           ├─ Popularity [████████████████████] 98/100
           ├─ Security   [████████████░░░░░░░░] 62/100
           └─ Quality    [██████████████░░░░░░] 72/100
```

---

### Activity Score: 95/100

| Metric | Value | Assessment |
|--------|-------|------------|
| Last Commit | 2 weeks ago | Active |
| Commits (90d) | 45 | High activity |
| Contributors | 312 | Large community |
| Release Frequency | Monthly | Regular |
| Issue Response Time | 2 days | Responsive |

**Assessment:** Actively maintained with regular updates.

---

### Popularity Score: 98/100

| Metric | Value | Assessment |
|--------|-------|------------|
| Weekly Downloads | 45M | Extremely popular |
| GitHub Stars | 58k | Well-known |
| Dependents | 150k+ | Widely used |
| Forks | 7k | Community interest |

**Assessment:** Industry-standard utility library.

---

### Security Score: 62/100

| Metric | Value | Assessment |
|--------|-------|------------|
| Known Vulnerabilities | 0 (in latest) | Clean |
| Historical CVEs | 5 | Some past issues |
| Security Policy | Yes | Has SECURITY.md |
| Signed Releases | No | Not signed |
| 2FA Enforced | Unknown | - |
| OSSF Scorecard | 6.5/10 | Average |

**Assessment:** No current vulnerabilities, but has had past security issues. Consider the specific version carefully.

**Historical Vulnerabilities:**
| CVE | Severity | Fixed In |
|-----|----------|----------|
| CVE-2021-23337 | CRITICAL | 4.17.21 |
| CVE-2020-8203 | HIGH | 4.17.19 |
| CVE-2019-10744 | HIGH | 4.17.12 |

---

### Code Quality Score: 72/100

| Metric | Value | Assessment |
|--------|-------|------------|
| Test Coverage | 85% | Good |
| Documentation | Excellent | Full API docs |
| TypeScript Support | Yes | @types/lodash |
| Bundle Size | 69.9 kB | Consider alternatives |
| Tree Shaking | Limited | lodash-es better |

**Assessment:** Well-documented with good test coverage. Consider `lodash-es` for better tree-shaking.

---

### Recommendation

**Verdict:** ✅ **Safe to use** (with version 4.17.21+)

**Considerations:**
1. Always use version 4.17.21 or later to avoid known CVEs
2. Consider `lodash-es` for ES modules and better tree-shaking
3. For specific functions, consider individual imports: `lodash.debounce`

---

### Alternatives

| Package | Score | Size | Notes |
|---------|-------|------|-------|
| lodash-es | 80/100 | 69 kB | ES module version |
| underscore | 72/100 | 16 kB | Lighter, less features |
| ramda | 75/100 | 46 kB | Functional style |
| Native JS | - | 0 | Modern JS has many built-ins |

---

### Version Comparison

| Version | Score | Vulnerabilities | Recommendation |
|---------|-------|-----------------|----------------|
| 4.17.21 | 78 | 0 | ✅ Use this |
| 4.17.20 | 72 | 1 HIGH | ⚠️ Upgrade |
| 4.17.15 | 55 | 3 CRITICAL | ❌ Don't use |
| 3.10.1 | 40 | 5+ | ❌ Outdated |
```

### Compare Multiple Packages

When user asks to compare packages:

```markdown
## Package Comparison

Comparing alternatives for: HTTP client library

| Metric | axios | node-fetch | got | ky |
|--------|-------|------------|-----|-----|
| **Endor Score** | 75 | 72 | 82 | 78 |
| Activity | 70 | 65 | 90 | 85 |
| Popularity | 95 | 88 | 75 | 60 |
| Security | 65 | 70 | 85 | 80 |
| Quality | 70 | 65 | 78 | 87 |
| **Size** | 13 kB | 3 kB | 48 kB | 7 kB |
| **Vulnerabilities** | 1 | 0 | 0 | 0 |
| **TypeScript** | Built-in | @types | Built-in | Built-in |
| **Browser Support** | Yes | No | No | Yes |

### Recommendation

**For Node.js:** `got` - Highest security score, active maintenance
**For Browser:** `ky` - Modern, tiny, TypeScript native
**For Universal:** `axios` - Most popular, but review CVE-2021-3749

```

### Quick Score Check

For fast evaluation:

```markdown
## Quick Score: axios@1.6.0

**Endor Score:** 75/100
**Verdict:** ⚠️ Acceptable with caveats

- ✅ Very popular (95M weekly downloads)
- ✅ Actively maintained
- ⚠️ 1 historical CVE (fixed in 0.21.1)
- ✅ TypeScript support
- ✅ MIT License

**Use this version?** Yes, 1.6.0 is safe.
```

### Evaluate Before Adding

When user wants to add a new dependency:

```markdown
## Dependency Evaluation: zod

Before adding `zod` to your project:

| Check | Status | Notes |
|-------|--------|-------|
| Endor Score | 88/100 | Excellent |
| Vulnerabilities | 0 | Clean |
| License | MIT | Compatible |
| Maintained | Yes | Very active |
| TypeScript | Native | First-class |

**Verdict:** ✅ Highly recommended

```bash
npm install zod
```

This package has excellent security posture and is actively maintained.
```
