---
description: Monitor license compliance when adding or updating dependencies
globs: "**/package.json, **/go.mod, **/requirements.txt, **/pyproject.toml, **/Cargo.toml, **/pom.xml, **/build.gradle, **/Gemfile, **/composer.json, **/*.csproj"
alwaysApply: true
---

# License Compliance Rule

Automatically check license compatibility when adding or modifying dependencies.

## Trigger

This rule activates when:
- Adding new dependencies to any manifest file
- Updating dependency versions (new version may have different license)
- Creating new projects with dependencies
- Discussing license compliance

## License Categories

### Permissive (Generally Safe)
- MIT
- Apache-2.0
- BSD-2-Clause
- BSD-3-Clause
- ISC
- Unlicense
- CC0-1.0
- WTFPL

### Weak Copyleft (Review Required)
- LGPL-2.1
- LGPL-3.0
- MPL-2.0
- EPL-2.0
- CDDL-1.0

### Strong Copyleft (High Risk)
- GPL-2.0
- GPL-3.0
- AGPL-3.0
- SSPL
- OSL-3.0

### Unknown/Custom (Block)
- No license
- Custom license
- Proprietary
- UNLICENSED

## Required Actions

### When Adding Dependencies

1. **Check the license** of the new dependency
2. **Evaluate compatibility** with project license
3. **Flag risks** based on category

### License Compatibility Check

For a **commercial/proprietary project:**

| Adding License | Risk | Action |
|----------------|------|--------|
| MIT, Apache, BSD | Low | Allow |
| LGPL | Medium | Warn - review linking |
| GPL | High | Block - copyleft |
| AGPL | Critical | Block - network copyleft |
| Unknown | High | Block - legal review needed |

For an **open source (MIT/Apache) project:**

| Adding License | Risk | Action |
|----------------|------|--------|
| MIT, Apache, BSD | Low | Allow |
| LGPL | Low | Allow |
| GPL | Medium | Warn - affects project license |
| AGPL | High | Block - affects project license |

### Response Format

When adding a dependency:

```markdown
## License Check: {package}@{version}

**License:** {license}
**Category:** {Permissive/Weak Copyleft/Strong Copyleft/Unknown}
**Risk Level:** {Low/Medium/High/Critical}

### Compatibility

| Your Project | This Dependency | Compatible |
|--------------|-----------------|------------|
| Proprietary | {license} | {Yes/No/Review} |

### Assessment

{Assessment based on license type}

### Action

{Allow/Warn/Block with reason}
```

### Handling Copyleft Licenses

**If GPL/LGPL dependency requested:**

```markdown
## License Warning: GPL Dependency

The package `{package}` is licensed under GPL-3.0.

### Implications for Your Project

**If your project is proprietary/commercial:**
- Using this package may require you to:
  - Release your source code under GPL
  - Provide source code to all users
  - License your entire project under GPL

**Alternatives:**

| Package | License | Description |
|---------|---------|-------------|
| {alt1} | MIT | Similar functionality |
| {alt2} | Apache-2.0 | Alternative approach |

### Options

1. **Use an alternative** - Find MIT/Apache licensed package
2. **Isolate usage** - Run as separate process (consult legal)
3. **Accept GPL** - Open source your project
4. **Request exception** - Some maintainers grant exceptions

**Recommendation:** Use alternative unless project will be open-sourced.
```

### Handling Unknown Licenses

```markdown
## License Warning: No License Found

The package `{package}` has no license file.

### What This Means

- No license = No permission to use
- The author retains all rights
- Using this is technically copyright infringement

### Actions Required

1. **Contact maintainer** - Request they add a license
2. **Find alternative** - Use a properly licensed package
3. **Legal review** - If must use, get legal approval

**Recommendation:** Do not use packages without clear licenses.
```

## Transitive Dependencies

Also check transitive dependencies:

```markdown
## Transitive License Check

Adding `{package}` brings these dependencies:

| Package | License | Risk |
|---------|---------|------|
| dep-a | MIT | Low |
| dep-b | Apache-2.0 | Low |
| dep-c | GPL-3.0 | HIGH |

**Warning:** Transitive dependency `dep-c` has GPL license.

Even though `{package}` is MIT, it depends on GPL code.
```

## Do Not Skip

License compliance is a legal requirement. Always check licenses when:
- Adding any new dependency
- Updating dependencies (license may change)
- Preparing for production release
- Open-sourcing internal code
