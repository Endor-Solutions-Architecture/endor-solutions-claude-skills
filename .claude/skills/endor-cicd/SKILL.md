---
name: endor-cicd
description: Generate CI/CD pipeline configurations for security scanning with Endor Labs
---

# Endor Labs: CI/CD Integration

Generate CI/CD pipeline configurations for security scanning with Endor Labs.

## Arguments

$ARGUMENTS - CI/CD platform: `github`, `gitlab`, `jenkins`, `azure`, `bitbucket`, `circleci`, or `show` to display current

## Instructions

### Parse Arguments

| Argument | Action |
|----------|--------|
| `github` | Generate GitHub Actions workflow |
| `gitlab` | Generate GitLab CI configuration |
| `jenkins` | Generate Jenkinsfile |
| `azure` | Generate Azure DevOps pipeline |
| `bitbucket` | Generate Bitbucket Pipelines |
| `circleci` | Generate CircleCI config |
| `show` | Show existing CI config if present |
| No argument | Detect CI system and suggest config |

### Detect Existing CI System

Check for these files to detect current CI:
- `.github/workflows/*.yml` → GitHub Actions
- `.gitlab-ci.yml` → GitLab CI
- `Jenkinsfile` → Jenkins
- `azure-pipelines.yml` → Azure DevOps
- `bitbucket-pipelines.yml` → Bitbucket
- `.circleci/config.yml` → CircleCI

### GitHub Actions

Generate `.github/workflows/endor-security.yml`:

```yaml
name: Endor Labs Security Scan

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]
  schedule:
    # Run daily at midnight UTC
    - cron: '0 0 * * *'

permissions:
  contents: read
  security-events: write
  id-token: write  # For OIDC authentication

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Endor Labs
        uses: endorlabs/github-action@v1
        with:
          namespace: ${{ secrets.ENDOR_NAMESPACE }}
          # Use OIDC for keyless auth (recommended)
          # Or use API key: api_key: ${{ secrets.ENDOR_API_KEY }}

      - name: Run Security Scan
        uses: endorlabs/github-action@v1
        with:
          namespace: ${{ secrets.ENDOR_NAMESPACE }}
          scan_summary_output_type: table
          # Fail on critical/high reachable vulnerabilities
          sarif_file: results.sarif

      - name: Upload SARIF results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: results.sarif

  # Optional: Dependency review for PRs
  dependency-review:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Dependency Review
        uses: actions/dependency-review-action@v4
        with:
          fail-on-severity: high
```

**Setup instructions:**
```markdown
## GitHub Actions Setup

1. **Add secrets to your repository:**
   - Go to Settings → Secrets and variables → Actions
   - Add `ENDOR_NAMESPACE`: Your Endor Labs namespace

2. **For API key auth (optional):**
   - Add `ENDOR_API_KEY`: Your API key
   - Add `ENDOR_API_SECRET`: Your API secret

3. **For OIDC auth (recommended):**
   - Configure OIDC in Endor Labs console
   - No secrets needed - uses GitHub's identity

4. **Create the workflow file:**
   ```bash
   mkdir -p .github/workflows
   # Save the above YAML to .github/workflows/endor-security.yml
   ```

5. **Commit and push:**
   ```bash
   git add .github/workflows/endor-security.yml
   git commit -m "Add Endor Labs security scanning"
   git push
   ```
```

### GitLab CI

Generate `.gitlab-ci.yml` additions:

```yaml
stages:
  - test
  - security
  - deploy

variables:
  ENDOR_NAMESPACE: ${ENDOR_NAMESPACE}

endor-security-scan:
  stage: security
  image:
    name: endorlabs/endorctl:latest
    entrypoint: [""]
  script:
    - endorctl scan --path . --output-type sarif --output results.sarif
  artifacts:
    reports:
      sast: results.sarif
    paths:
      - results.sarif
    when: always
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

endor-sbom:
  stage: security
  image:
    name: endorlabs/endorctl:latest
    entrypoint: [""]
  script:
    - endorctl sbom export --format cyclonedx --output sbom.cdx.json
  artifacts:
    paths:
      - sbom.cdx.json
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

# Policy gate - fail pipeline on critical issues
endor-policy-check:
  stage: security
  image:
    name: endorlabs/endorctl:latest
    entrypoint: [""]
  script:
    - |
      endorctl scan --path . --output-type json --output results.json
      CRITICAL=$(jq '[.findings[] | select(.level == "CRITICAL" and .reachable == true)] | length' results.json)
      if [ "$CRITICAL" -gt 0 ]; then
        echo "Found $CRITICAL critical reachable vulnerabilities"
        exit 1
      fi
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
```

**Setup instructions:**
```markdown
## GitLab CI Setup

1. **Add CI/CD variables:**
   - Go to Settings → CI/CD → Variables
   - Add `ENDOR_NAMESPACE`: Your namespace
   - Add `ENDOR_API_KEY` and `ENDOR_API_SECRET`

2. **Merge into existing .gitlab-ci.yml or create new**

3. **Configure merge request approvals:**
   - Require security scan to pass before merge
```

### Jenkins

Generate `Jenkinsfile`:

```groovy
pipeline {
    agent any

    environment {
        ENDOR_NAMESPACE = credentials('endor-namespace')
        ENDOR_API_KEY = credentials('endor-api-key')
        ENDOR_API_SECRET = credentials('endor-api-secret')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Security Scan') {
            steps {
                script {
                    // Install endorctl if not present
                    sh '''
                        if ! command -v endorctl &> /dev/null; then
                            curl -sSL https://api.endorlabs.com/download/latest/endorctl_linux_amd64 -o endorctl
                            chmod +x endorctl
                            mv endorctl /usr/local/bin/
                        fi
                    '''

                    // Run scan
                    sh '''
                        endorctl scan --path . \
                            --namespace $ENDOR_NAMESPACE \
                            --output-type sarif \
                            --output results.sarif
                    '''
                }
            }
            post {
                always {
                    // Archive results
                    archiveArtifacts artifacts: 'results.sarif', fingerprint: true

                    // Publish to Jenkins security dashboard if plugin installed
                    recordIssues(tools: [sarif(pattern: 'results.sarif')])
                }
            }
        }

        stage('Policy Gate') {
            steps {
                script {
                    def result = sh(
                        script: '''
                            endorctl scan --path . --output-type json --output results.json
                            CRITICAL=$(jq '[.findings[] | select(.level == "CRITICAL" and .reachable == true)] | length' results.json)
                            echo $CRITICAL
                        ''',
                        returnStdout: true
                    ).trim()

                    if (result.toInteger() > 0) {
                        error("Found ${result} critical reachable vulnerabilities")
                    }
                }
            }
        }

        stage('Generate SBOM') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    endorctl sbom export \
                        --format cyclonedx \
                        --output sbom.cdx.json
                '''
                archiveArtifacts artifacts: 'sbom.cdx.json', fingerprint: true
            }
        }
    }

    post {
        failure {
            // Notify on security scan failure
            emailext(
                subject: "Security Scan Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Security vulnerabilities found. Check ${env.BUILD_URL}",
                recipientProviders: [developers()]
            )
        }
    }
}
```

### Azure DevOps

Generate `azure-pipelines.yml`:

```yaml
trigger:
  branches:
    include:
      - main
      - master

pr:
  branches:
    include:
      - main
      - master

pool:
  vmImage: 'ubuntu-latest'

variables:
  - group: endor-labs-credentials

stages:
  - stage: Security
    displayName: 'Security Scanning'
    jobs:
      - job: EndorScan
        displayName: 'Endor Labs Scan'
        steps:
          - checkout: self
            fetchDepth: 0

          - script: |
              curl -sSL https://api.endorlabs.com/download/latest/endorctl_linux_amd64 -o endorctl
              chmod +x endorctl
              sudo mv endorctl /usr/local/bin/
            displayName: 'Install endorctl'

          - script: |
              endorctl scan --path $(Build.SourcesDirectory) \
                --namespace $(ENDOR_NAMESPACE) \
                --output-type sarif \
                --output $(Build.ArtifactStagingDirectory)/results.sarif
            displayName: 'Run Security Scan'
            env:
              ENDOR_API_KEY: $(ENDOR_API_KEY)
              ENDOR_API_SECRET: $(ENDOR_API_SECRET)

          - task: PublishBuildArtifacts@1
            inputs:
              pathToPublish: '$(Build.ArtifactStagingDirectory)/results.sarif'
              artifactName: 'SecurityResults'

          - script: |
              endorctl scan --path $(Build.SourcesDirectory) --output-type json --output results.json
              CRITICAL=$(jq '[.findings[] | select(.level == "CRITICAL" and .reachable == true)] | length' results.json)
              if [ "$CRITICAL" -gt 0 ]; then
                echo "##vso[task.logissue type=error]Found $CRITICAL critical reachable vulnerabilities"
                exit 1
              fi
            displayName: 'Policy Gate'
            condition: eq(variables['Build.Reason'], 'PullRequest')
```

### Bitbucket Pipelines

Generate `bitbucket-pipelines.yml`:

```yaml
image: node:18

definitions:
  steps:
    - step: &security-scan
        name: Endor Labs Security Scan
        script:
          - curl -sSL https://api.endorlabs.com/download/latest/endorctl_linux_amd64 -o endorctl
          - chmod +x endorctl
          - ./endorctl scan --path . --output-type sarif --output results.sarif
        artifacts:
          - results.sarif

pipelines:
  pull-requests:
    '**':
      - step: *security-scan
      - step:
          name: Policy Gate
          script:
            - apt-get update && apt-get install -y jq
            - ./endorctl scan --path . --output-type json --output results.json
            - |
              CRITICAL=$(jq '[.findings[] | select(.level == "CRITICAL" and .reachable == true)] | length' results.json)
              if [ "$CRITICAL" -gt 0 ]; then
                echo "Found $CRITICAL critical reachable vulnerabilities"
                exit 1
              fi

  branches:
    main:
      - step: *security-scan
      - step:
          name: Generate SBOM
          script:
            - ./endorctl sbom export --format cyclonedx --output sbom.cdx.json
          artifacts:
            - sbom.cdx.json
```

### CircleCI

Generate `.circleci/config.yml`:

```yaml
version: 2.1

orbs:
  endorlabs: endorlabs/endorctl@1.0

jobs:
  security-scan:
    docker:
      - image: cimg/base:stable
    steps:
      - checkout
      - run:
          name: Install endorctl
          command: |
            curl -sSL https://api.endorlabs.com/download/latest/endorctl_linux_amd64 -o endorctl
            chmod +x endorctl
            sudo mv endorctl /usr/local/bin/
      - run:
          name: Run Security Scan
          command: |
            endorctl scan --path . \
              --namespace $ENDOR_NAMESPACE \
              --output-type sarif \
              --output results.sarif
      - store_artifacts:
          path: results.sarif
          destination: security-results

  policy-gate:
    docker:
      - image: cimg/base:stable
    steps:
      - checkout
      - run:
          name: Install tools
          command: |
            curl -sSL https://api.endorlabs.com/download/latest/endorctl_linux_amd64 -o endorctl
            chmod +x endorctl
            sudo mv endorctl /usr/local/bin/
            sudo apt-get update && sudo apt-get install -y jq
      - run:
          name: Check for Critical Issues
          command: |
            endorctl scan --path . --output-type json --output results.json
            CRITICAL=$(jq '[.findings[] | select(.level == "CRITICAL" and .reachable == true)] | length' results.json)
            if [ "$CRITICAL" -gt 0 ]; then
              echo "Found $CRITICAL critical reachable vulnerabilities"
              exit 1
            fi

workflows:
  security:
    jobs:
      - security-scan
      - policy-gate:
          requires:
            - security-scan
          filters:
            branches:
              ignore: main
```

## Response Format

When generating CI config:

```markdown
## CI/CD Configuration Generated

**Platform:** {platform}
**File:** {filepath}

### Features Included

- Security scanning on push and PR
- SARIF output for security dashboards
- Policy gate to block critical vulnerabilities
- SBOM generation on main branch
- Artifact storage for results

### Setup Steps

1. {step 1}
2. {step 2}
...

### Required Secrets/Variables

| Name | Description |
|------|-------------|
| ENDOR_NAMESPACE | Your Endor Labs namespace |
| ENDOR_API_KEY | API key (if not using OIDC) |
| ENDOR_API_SECRET | API secret |

### Next Steps

1. Review and customize the configuration
2. Add required secrets to your CI system
3. Commit and push the configuration
4. Verify the pipeline runs successfully

Would you like me to create this file now?
```
