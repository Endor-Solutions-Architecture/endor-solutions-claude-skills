# Endor Labs: License Compliance

Analyze license compliance, identify license risks, and generate license reports.

## Arguments

$ARGUMENTS - Action: `scan`, `report`, `check <package>`, `policy`, `notices`

## Instructions

### Parse Arguments

| Argument | Action |
|----------|--------|
| `scan` | Scan project for license issues |
| `report` | Generate full license report |
| `check <package>` | Check specific package license |
| `policy` | Show/configure license policy |
| `notices` | Generate NOTICES/attribution file |
| `export` | Export license data (CSV/JSON) |
| No argument | Quick license summary |

### License Risk Categories

| Risk Level | Licenses | Impact |
|------------|----------|--------|
| **Critical** | AGPL-3.0, SSPL | Network copyleft, SaaS restrictions |
| **High** | GPL-3.0, GPL-2.0, LGPL-3.0 | Copyleft, source disclosure |
| **Medium** | MPL-2.0, EPL-2.0, LGPL-2.1 | File-level copyleft |
| **Low** | Apache-2.0, BSD-3, MIT, ISC | Permissive |
| **Unknown** | No license, Custom | Requires review |

### License Scan

Query findings with license category:
```
Filter: spec.finding_categories contains FINDING_CATEGORY_LICENSE_RISK
```

```markdown
## License Compliance Scan

**Project:** {project_name}
**Total Dependencies:** 156
**Unique Licenses:** 12

---

### License Distribution

```
MIT            ████████████████████████████████ 89 (57%)
Apache-2.0     ████████████████ 45 (29%)
ISC            ████ 12 (8%)
BSD-3-Clause   ██ 5 (3%)
GPL-3.0        █ 3 (2%)
Unknown        █ 2 (1%)
```

---

### License Issues Found

#### Critical Risk (2)

| Package | Version | License | Issue |
|---------|---------|---------|-------|
| mongo-express | 1.0.0 | AGPL-3.0 | Network copyleft - SaaS must open source |
| sspl-lib | 2.3.0 | SSPL | Service provider restrictions |

**Action Required:** These licenses may require you to open-source your application or restrict how you can offer it as a service.

#### High Risk (3)

| Package | Version | License | Issue |
|---------|---------|---------|-------|
| readline-sync | 1.4.10 | GPL-3.0 | Copyleft - derivative works must be GPL |
| gpl-module | 2.0.0 | GPL-2.0 | Copyleft |
| linux-headers | 5.10 | GPL-2.0 | Copyleft (but header exception may apply) |

**Action Required:** Review if these packages are dynamically linked or isolated. Static linking creates derivative work.

#### Unknown Licenses (2)

| Package | Version | License | Issue |
|---------|---------|---------|-------|
| internal-tool | 1.0.0 | UNLICENSED | No license = no rights granted |
| custom-lib | 3.2.1 | Custom | Custom license requires legal review |

**Action Required:** Contact package maintainers or legal team for clarification.

---

### Compliant Packages

| License | Count | Commercial Use | Modification | Distribution |
|---------|-------|----------------|--------------|--------------|
| MIT | 89 | ✅ | ✅ | ✅ |
| Apache-2.0 | 45 | ✅ | ✅ | ✅ (with NOTICE) |
| ISC | 12 | ✅ | ✅ | ✅ |
| BSD-3-Clause | 5 | ✅ | ✅ | ✅ |

---

### Recommendations

1. **Replace AGPL packages** with permissively licensed alternatives
2. **Isolate GPL packages** in separate processes if possible
3. **Add license files** to internal packages
4. **Create NOTICES file** for Apache-2.0 compliance
```

### Full License Report

```markdown
## License Compliance Report

**Generated:** {date}
**Project:** {project_name}
**Branch:** main

---

### Executive Summary

| Metric | Value | Status |
|--------|-------|--------|
| Total Dependencies | 156 | - |
| Compliant | 148 | ✅ |
| Needs Review | 5 | ⚠️ |
| Non-Compliant | 3 | ❌ |
| Compliance Rate | 95% | - |

---

### Full License Inventory

<details>
<summary>MIT Licensed (89 packages)</summary>

| Package | Version | Repository |
|---------|---------|------------|
| lodash | 4.17.21 | github.com/lodash/lodash |
| axios | 1.6.0 | github.com/axios/axios |
| ... | ... | ... |

</details>

<details>
<summary>Apache-2.0 Licensed (45 packages)</summary>

| Package | Version | Repository | NOTICE Required |
|---------|---------|------------|-----------------|
| typescript | 5.0.0 | github.com/microsoft/TypeScript | Yes |
| ... | ... | ... | ... |

</details>

---

### License Compatibility Matrix

For a **Commercial Closed-Source** project:

| License | Compatible | Notes |
|---------|------------|-------|
| MIT | ✅ Yes | Include copyright notice |
| Apache-2.0 | ✅ Yes | Include NOTICE file |
| BSD-3-Clause | ✅ Yes | Include copyright notice |
| ISC | ✅ Yes | Include copyright notice |
| LGPL-2.1 | ⚠️ Maybe | Dynamic linking only |
| GPL-3.0 | ❌ No | Copyleft applies |
| AGPL-3.0 | ❌ No | Network copyleft |

---

### Compliance Actions Required

1. [ ] Remove or replace `mongo-express` (AGPL-3.0)
2. [ ] Review `readline-sync` usage - isolate or replace
3. [ ] Add license to `internal-tool`
4. [ ] Get legal review for `custom-lib`
5. [ ] Generate NOTICES file for Apache-2.0 packages
```

### Check Specific Package

```markdown
## License Check: lodash@4.17.21

**Package:** lodash
**Version:** 4.17.21
**License:** MIT
**SPDX ID:** MIT

---

### License Details

**Full Name:** MIT License
**OSI Approved:** Yes
**FSF Free:** Yes

### Permissions

| Permission | Allowed |
|------------|---------|
| Commercial Use | ✅ Yes |
| Modification | ✅ Yes |
| Distribution | ✅ Yes |
| Private Use | ✅ Yes |
| Sublicensing | ✅ Yes |

### Conditions

| Condition | Required |
|-----------|----------|
| Include Copyright | ✅ Yes |
| Include License | ✅ Yes |
| State Changes | ❌ No |
| Disclose Source | ❌ No |

### Limitations

| Limitation | Applies |
|------------|---------|
| Liability | Excluded |
| Warranty | Excluded |

---

### Verdict

✅ **Safe for commercial use**

Include this in your NOTICES file:
```
lodash
Copyright JS Foundation and other contributors

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software...
```
```

### Generate NOTICES File

```markdown
## Generated NOTICES File

Save to `NOTICES` or `THIRD_PARTY_LICENSES`:

```
THIRD-PARTY SOFTWARE NOTICES AND INFORMATION

This project incorporates components from the projects listed below.

================================================================================

lodash (4.17.21)
https://github.com/lodash/lodash
License: MIT
Copyright JS Foundation and other contributors

The MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction...

================================================================================

axios (1.6.0)
https://github.com/axios/axios
License: MIT
Copyright (c) 2014-present Matt Zabriskie

...

================================================================================

typescript (5.0.0)
https://github.com/microsoft/TypeScript
License: Apache-2.0
Copyright (c) Microsoft Corporation

Licensed under the Apache License, Version 2.0...

NOTICE: This product includes software developed at Microsoft Corporation.

================================================================================
```

**File created:** NOTICES (125 packages documented)
```

### License Policy

```markdown
## License Policy Configuration

### Current Policy

| License Category | Policy |
|-----------------|--------|
| Permissive (MIT, Apache, BSD, ISC) | ✅ Allow |
| Weak Copyleft (LGPL, MPL) | ⚠️ Review required |
| Strong Copyleft (GPL) | ❌ Block |
| Network Copyleft (AGPL, SSPL) | ❌ Block |
| Unknown/Custom | ⚠️ Block pending review |

### Configure Policy

To update license policy in Endor Labs:

1. Go to Policies → License Policies
2. Create or modify policy rules
3. Set enforcement (block/warn/allow)

Or use API:
```bash
endorctl api create --resource Policy --file license-policy.yaml
```

### Exceptions

| Package | License | Reason | Approved By |
|---------|---------|--------|-------------|
| readline-sync | GPL-3.0 | CLI tool only, not distributed | legal-team |
```
