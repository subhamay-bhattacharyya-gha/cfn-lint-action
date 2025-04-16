# GitHub Template Repository - Composite Action

![Commit Activity](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![Last Commit](https://img.shields.io/github/last-commit/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![Release Date](https://img.shields.io/github/release-date/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![Repo Size](https://img.shields.io/github/repo-size/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![File Count](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![Issues](https://img.shields.io/github/issues/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![Top Language](https://img.shields.io/github/languages/top/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![Monthly Commit Activity](https://img.shields.io/github/commit-activity/m/subhamay-bhattacharyya-gha/cfn-lint-action)&nbsp;![Custom Endpoint](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/11847791f620cf0efb14c90ed9bbc2dc/raw/cfn-lint-action.json?)

## CloudFormation Linter GitHub Action

Lint your AWS CloudFormation templates with [cfn-lint](https://github.com/aws-cloudformation/cfn-lint) directly in your GitHub Actions workflows.

This composite action sets up Python, installs `cfn-lint`, and scans CloudFormation templates (`.yaml` / `.yml`) for errors and warnings. Results are written to the GitHub Actions **Job Summary**.

## Features

- Automatically detects and scans all YAML templates in the specified directory
- Optionally fails the workflow on warnings
- Outputs human-readable lint results in the GitHub Actions Summary

## Usage

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Lint CloudFormation templates
        uses: subhamay-bhattacharyya-gha/cfn-lint-action@main
        with:
          template-dir: 'cfn'         # Optional, default is '.'
          fail-on-warnings: 'true'          # Optional, default is 'false'


## License

MIT
