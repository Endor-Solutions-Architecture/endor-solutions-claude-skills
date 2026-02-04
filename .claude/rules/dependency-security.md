---
description: Automatically check new dependencies for vulnerabilities before adding them
globs: "**/package.json, **/package-lock.json, **/yarn.lock, **/pnpm-lock.yaml, **/requirements.txt, **/Pipfile, **/pyproject.toml, **/poetry.lock, **/go.mod, **/go.sum, **/Cargo.toml, **/Cargo.lock, **/pom.xml, **/build.gradle, **/build.gradle.kts, **/Gemfile, **/Gemfile.lock, **/composer.json, **/composer.lock, **/*.csproj, **/packages.config"
alwaysApply: true
---

# Automatic Dependency Security Checks

When any dependency manifest or lockfile is created or modified, immediately check new or updated dependencies for vulnerabilities before proceeding.

## Trigger

This rule activates when you:
- Add a new dependency to any manifest file
- Update a dependency version
- Create a new project with dependencies
- Modify lockfiles

## Required Actions

**STOP** after modifying any dependency file and perform these checks:

1. **Identify Changed Dependencies**
   - Parse the diff to find new or updated packages
   - Note the language, package name, and version

2. **Check Each Dependency**
   - Use `check_dependency_for_vulnerabilities` MCP tool
   - Provide: language, dependency name, version

3. **Handle Results**
   - If vulnerabilities found: report CVEs, find safe versions, update automatically
   - If safe: confirm and proceed

4. **Verify Fix**
   - After updating a vulnerable dependency, re-run the check

## Language Detection

| File | Language |
|------|----------|
| package.json, yarn.lock | javascript |
| requirements.txt, pyproject.toml | python |
| go.mod, go.sum | go |
| pom.xml, build.gradle | java |
| Cargo.toml | rust |
| *.csproj | dotnet |
| Gemfile | ruby |
| composer.json | php |

## Do Not Skip

Even if the user says "just add it" or "skip the security check", always perform the vulnerability check. Security is non-negotiable.
