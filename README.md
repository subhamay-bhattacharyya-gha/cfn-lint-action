# GitHub Composite Action: CloudFormation Linter

<!-- Row 1: Status - Most Important -->
[![Release](https://github.com/subhamay-bhattacharyya-gha/cfn-lint-action/actions/workflows/release.yaml/badge.svg)](https://github.com/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;[![GitHub Action](https://img.shields.io/badge/GitHub-Action-blue?logo=github)](https://github.com/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;[![Issues](https://img.shields.io/github/issues/subhamay-bhattacharyya-gha/cfn-lint-action)](https://github.com/subhamay-bhattacharyya-gha/cfn-lint-action/issues)&nbsp;[![Last Commit](https://img.shields.io/github/last-commit/subhamay-bhattacharyya-gha/cfn-lint-action)](https://github.com/subhamay-bhattacharyya-gha/cfn-lint-action/commits)

<!-- Row 2: Code Quality -->
[![Top Language](https://img.shields.io/github/languages/top/subhamay-bhattacharyya-gha/cfn-lint-action)](https://github.com/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;[![Commits](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya-gha/cfn-lint-action)](https://github.com/subhamay-bhattacharyya-gha/cfn-lint-action/commits)

<!-- Row 3: Tech Stack -->
[![CloudFormation](https://img.shields.io/badge/CloudFormation-IaC-FF9900?logo=amazon&logoColor=white)](https://aws.amazon.com/cloudformation/)&nbsp;[![Built with Claude Code](https://img.shields.io/badge/Built_with-Claude_Code-D97757?logo=anthropic&logoColor=white)](https://claude.ai/)

<!-- Row 4: Repository Info -->
[![Files](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya-gha/cfn-lint-action)](https://github.com/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;[![Repo Size](https://img.shields.io/github/repo-size/subhamay-bhattacharyya-gha/cfn-lint-action)](https://github.com/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;[![Release Date](https://img.shields.io/github/release-date/subhamay-bhattacharyya-gha/cfn-lint-action)](https://github.com/subhamay-bhattacharyya-gha/cfn-lint-action/releases)

<!-- Row 5: Custom Metrics -->
[![Custom Endpoint](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/f8d744c4789f8e9e3f6c191f3d37fd34/raw/cfn-lint-action.json)](https://gist.github.com/bsubhamay/f8d744c4789f8e9e3f6c191f3d37fd34)

A GitHub composite action that validates CloudFormation templates using [cfn-lint](https://github.com/aws-cloudformation/cfn-lint) with comprehensive reporting and GitHub Step Summary integration.

## Overview

This action provides a reusable, standardized way to validate CloudFormation templates across your GitHub workflows. It automatically sets up Python, installs cfn-lint, validates template existence, performs comprehensive linting, and generates detailed GitHub Step Summary reports for easy visibility in your GitHub Actions workflow runs.

### What This Action Does

- ✅ **Automatic Setup**: Installs Python and cfn-lint without manual configuration
- ✅ **Template Validation**: Checks that CloudFormation template files exist before linting
- ✅ **Comprehensive Linting**: Runs cfn-lint to detect:
  - Invalid CloudFormation syntax
  - Resource property errors
  - Security best practice violations
  - Performance and compliance issues
- ✅ **Detailed Reporting**: Generates both console output and GitHub Step Summary
- ✅ **Smart Exit Codes**: Preserves cfn-lint exit codes for workflow decision making
- ✅ **Cross-Platform**: Works on Ubuntu, Windows, and macOS runners

---

## Inputs

| Name            | Description                                                   | Required | Default  |
| --------------- | ------------------------------------------------------------- | -------- | -------- |
| `template-path` | Relative path to CloudFormation template from repository root | Yes      | —        |

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
| --------- | ------- | ----------- |
| 0 | Success | No issues found in the template |
| 2 | Warnings | Template has warnings that should be reviewed |
| 4 | Errors | Template has critical errors that must be fixed |
| 6 | Errors + Warnings | Template has both errors and warnings |
| 8 | Invalid CLI | Invalid command line arguments to cfn-lint |
| 16 | Fatal | Fatal errors occurred during execution |

---

## Installation

This is a **composite GitHub Action** that you can use in any repository. Simply reference it in your GitHub Actions workflow:

```yaml
- name: Validate CloudFormation
  uses: subhamay-bhattacharyya-gha/cfn-lint-action@v1
  with:
    template-path: path/to/template.yaml
```

For specific versions, see the [releases page](https://github.com/subhamay-bhattacharyya-gha/cfn-lint-action/releases).

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
    runs-on: ubuntu-26.04
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Lint CloudFormation Template
        uses: subhamay-bhattacharyya-gha/cfn-lint-action@v1
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
    runs-on: ubuntu-26.04
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
        uses: subhamay-bhattacharyya-gha/cfn-lint-action@v1
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
    runs-on: ubuntu-26.04
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
    runs-on: ubuntu-26.04
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

- **Automated Setup**: Automatically installs Python (via `actions/setup-python@v7`) and cfn-lint via pip
- **Path Validation**: Validates template file existence before linting with clear error messages
- **Comprehensive Linting**: Detects CloudFormation syntax errors, security issues, and best practice violations
- **Rich Reporting**:
  - Console output with detailed linting results and exit code meanings
  - GitHub Step Summary with formatted markdown for easy visibility
  - Color-coded status indicators (✅, ⚠️, ❌)
- **Exit Code Preservation**: Maintains cfn-lint exit codes (0, 2, 4, 6, 8, 16) for workflow decision making
- **Cross-Platform**: Works on ubuntu-latest, windows-latest, and macos-latest runners
- **Composite Action**: Pure Bash implementation, no compiled dependencies
- **Reusable**: Can be easily consumed across multiple repositories as a GitHub Action

## Troubleshooting

### Common Issues

#### Template Not Found Error

```text
❌ Error: CloudFormation template not found at path: /github/workspace/template.yaml
```

**Solution**: Verify the `template-path` input is correct and relative to your repository root. Ensure the file exists in your repository.

#### cfn-lint Installation Issues

If you encounter Python or pip installation issues, the action automatically handles Python setup using `actions/setup-python@v7`. Ensure you have network connectivity to download cfn-lint from PyPI.

#### Large Template Processing

For very large CloudFormation templates, you may need to increase the job timeout:

```yaml
jobs:
  lint:
    runs-on: ubuntu-26.04
    timeout-minutes: 10  # Increase as needed
```

#### Understanding Exit Codes

The action preserves cfn-lint exit codes. Use `continue-on-error: true` if you want the workflow to continue regardless of linting results, then check the step outcome in subsequent steps.

### Getting Help

- Check the GitHub Step Summary for detailed linting results
- Review the action logs for comprehensive output
- Refer to [cfn-lint documentation](https://github.com/aws-cloudformation/cfn-lint) for template-specific issues

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes and test thoroughly
4. Commit with conventional commits (`git commit -m "feat: description"`)
5. Push to your fork and submit a Pull Request

For more details, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License. See [LICENSE](LICENSE) for details.

## Related Resources

- [cfn-lint on GitHub](https://github.com/aws-cloudformation/cfn-lint) — The linting engine behind this action
- [CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/) — AWS CloudFormation best practices
- [GitHub Actions Documentation](https://docs.github.com/en/actions) — Learn more about GitHub Actions
