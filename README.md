# CloudFormation Linter Action

# GitHub Action Template Repository

![Built with Kiro](https://img.shields.io/badge/Built%20with-Kiro-blue?style=flat&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTEyIDJMMTMuMDkgOC4yNkwyMCA5TDEzLjA5IDE1Ljc0TDEyIDIyTDEwLjkxIDE1Ljc0TDQgOUwxMC45MSA4LjI2TDEyIDJaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K)&nbsp;![GitHub Action](https://img.shields.io/badge/GitHub-Action-blue?logo=github)&nbsp;![Release](https://github.com/subhamay-bhattacharyya-gha/cfn-lint-action/actions/workflows/release.yaml/badge.svg)&nbsp;![Commit Activity](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![Bash](https://img.shields.io/badge/Language-Bash-green?logo=gnubash)&nbsp;![CloudFormation](https://img.shields.io/badge/AWS-CloudFormation-orange?logo=amazonaws)&nbsp;![Last Commit](https://img.shields.io/github/last-commit/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![Release Date](https://img.shields.io/github/release-date/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![Repo Size](https://img.shields.io/github/repo-size/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![File Count](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![Issues](https://img.shields.io/github/issues/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![Top Language](https://img.shields.io/github/languages/top/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![Custom Endpoint](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/d4ae4b121575f9a0faca6069c791eb48/raw/cfn-lint-action.json?)

A GitHub reusable action that runs CloudFormation linting using cfn-lint with comprehensive reporting and GitHub Step Summary integration.

## CloudFormation Linter

### Description

This GitHub Action provides a reusable composite workflow that validates CloudFormation templates using cfn-lint. The action automatically sets up Python, installs cfn-lint, validates template paths, runs comprehensive linting, and generates detailed GitHub Step Summary reports. It's designed to standardize CloudFormation template validation across multiple repositories with proper error handling and workflow integration.

---

## Inputs

| Name           | Description         | Required | Default        |
|----------------|---------------------|----------|----------------|
| `template-path` | Relative path to CloudFormation template from repository root | Yes | — |

### Input Details

- **template-path**: The relative path from your repository root to the CloudFormation template file you want to lint. Examples: `template.yaml`, `infrastructure/main.yaml`, `cloudformation/stack.json`

## Outputs

This action doesn't produce explicit outputs, but provides comprehensive reporting through:

- **Console Output**: Detailed linting results and status information
- **GitHub Step Summary**: Formatted markdown summary with template name, status, and detailed results
- **Exit Codes**: Preserves cfn-lint exit codes for workflow decision making

### Exit Codes

The action preserves cfn-lint exit codes to allow workflows to make informed decisions:

| Exit Code | Meaning | Description |
|-----------|---------|-------------|
| 0 | Success | No issues found in the template |
| 2 | Warnings | Template has warnings that should be reviewed |
| 4 | Errors | Template has critical errors that must be fixed |
| 6 | Errors + Warnings | Template has both errors and warnings |
| 8 | Invalid CLI | Invalid command line arguments to cfn-lint |
| 16 | Fatal | Fatal errors occurred during execution |

---

## Usage Examples

### Basic Usage

```yaml
name: CloudFormation Validation

on:
  push:
    paths:
      - '**.yaml'
      - '**.yml'
      - '**.json'
  pull_request:
    paths:
      - '**.yaml'
      - '**.yml'
      - '**.json'

jobs:
  lint-cloudformation:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Lint CloudFormation Template
        uses: your-org/cloudformation-linter-action@v1
        with:
          template-path: template.yaml
```

### Multiple Templates

```yaml
name: Validate All CloudFormation Templates

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint-templates:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        template:
          - infrastructure/main.yaml
          - infrastructure/networking.yaml
          - infrastructure/security.yaml
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Lint ${{ matrix.template }}
        uses: your-org/cloudformation-linter-action@v1
        with:
          template-path: ${{ matrix.template }}
```

### With Conditional Execution

```yaml
name: CloudFormation CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Lint CloudFormation Template
        id: lint
        uses: your-org/cloudformation-linter-action@v1
        with:
          template-path: infrastructure/template.yaml
        continue-on-error: true

      - name: Handle Linting Results
        run: |
          if [ ${{ steps.lint.outcome }} == 'success' ]; then
            echo "✅ Template validation passed"
          else
            echo "❌ Template validation failed"
            echo "Check the step summary for detailed results"
            exit 1
          fi
```

### Integration with Deployment Workflow

```yaml
name: Deploy CloudFormation Stack

on:
  push:
    branches: [main]

jobs:
  validate-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Validate CloudFormation Template
        uses: your-org/cloudformation-linter-action@v1
        with:
          template-path: infrastructure/production.yaml

      - name: Deploy to AWS
        if: success()
        run: |
          # Deploy only if validation passes
          aws cloudformation deploy \
            --template-file infrastructure/production.yaml \
            --stack-name my-production-stack \
            --capabilities CAPABILITY_IAM
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Features

- **Automated Setup**: Automatically installs Python and cfn-lint
- **Path Validation**: Validates template file existence with clear error messages
- **Comprehensive Reporting**: Generates detailed GitHub Step Summary with formatted results
- **Error Handling**: Proper error handling that doesn't break workflows unexpectedly
- **Exit Code Preservation**: Maintains cfn-lint exit codes for workflow decision making
- **Cross-Platform**: Works on ubuntu-latest, windows-latest, and macos-latest runners
- **Reusable**: Can be easily consumed across multiple repositories

## Troubleshooting

### Common Issues

#### Template Not Found Error
```
❌ Error: CloudFormation template not found at path: /github/workspace/template.yaml
```
**Solution**: Verify the `template-path` input is correct and relative to your repository root. Ensure the file exists in your repository.

#### cfn-lint Installation Issues
If you encounter Python or pip installation issues, the action automatically handles Python setup using `actions/setup-python@v5`.

#### Large Template Processing
For very large CloudFormation templates, you may need to increase the job timeout:
```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 10  # Increase as needed
```

#### Understanding Exit Codes
The action preserves cfn-lint exit codes. Use `continue-on-error: true` if you want the workflow to continue regardless of linting results, then check the step outcome in subsequent steps.

### Getting Help

- Check the GitHub Step Summary for detailed linting results
- Review the action logs for comprehensive output
- Refer to [cfn-lint documentation](https://github.com/aws-cloudformation/cfn-lint) for template-specific issues

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT
