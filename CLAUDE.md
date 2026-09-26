# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**cfn-lint-action** is a reusable GitHub Action that validates CloudFormation templates using [cfn-lint](https://github.com/aws-cloudformation/cfn-lint). The action:

- Automatically sets up Python and installs cfn-lint
- Validates template file existence
- Runs comprehensive linting with detailed error reporting
- Generates GitHub Step Summary with formatted results
- Preserves cfn-lint exit codes for workflow decision-making
- Works cross-platform (ubuntu-latest, windows-latest, macos-latest)

This is a **composite action** (pure Bash, no compiled code) designed to be consumed by other repositories via GitHub Actions.

## Architecture & Key Files

### Core Action Implementation

- **`action.yaml`** — The action entry point defining inputs, outputs, and the composite workflow steps. The main logic runs linting, validates paths, and generates GitHub Step Summary markdown.
- **Action.yaml flow:**
  1. Sets up Python via `actions/setup-python@v7`
  2. Installs cfn-lint via pip
  3. Validates template file existence
  4. Runs `cfn-lint --format parseable` on the template
  5. Maps exit codes (0, 2, 4, 6, 8, 16) to human-readable statuses
  6. Generates markdown summary appended to `$GITHUB_STEP_SUMMARY`
  7. Exits with cfn-lint's exit code to allow workflow conditionals

### Test & Validation

- **`.github/scripts/templates/`** — CloudFormation templates for testing:
  - `valid-template.yaml` — No issues (exit code 0)
  - `template-with-warnings.yaml` — Has warnings (exit code 2)
  - `invalid-template.yaml` — Has errors (exit code 4)
  - `test-template.yaml` — Legacy template for backward compatibility
  - `test-invalid-template.yaml` — Legacy invalid template for testing
- **`.github/workflows/test-action.yml`** — Primary integration tests covering:
  - Valid template validation
  - Warning detection
  - Error detection
  - File not found error handling
  - Nested path handling
  - GitHub Step Summary generation
  - Cross-platform compatibility (Windows, macOS, Ubuntu)
- **Shell scripts** (`.github/scripts/test-*.sh`) — Standalone test scripts:
  - `test-comprehensive.sh` — Full end-to-end tests
  - `test-exit-codes.sh` — Validates all exit code scenarios
  - `test-file-not-found.sh` — Tests missing file handling
  - `test-step-summary.sh` — Validates GitHub Step Summary formatting
  - `test-step-summary-validation.sh` — Deep validation of summary structure

### Release & Publishing

- **`package.json`** — npm scripts and dependencies:
  - `npm run release` — Triggers semantic-release to publish new versions
  - Dependencies: semantic-release, @semantic-release/*, commitizen
- **`.releaserc.json`** & **`scripts/plugins/release.config.js`** — Semantic versioning config:
  - Analyzes commit messages (conventional commits) to determine version bumps
  - Updates `CHANGELOG.md` automatically
  - Publishes releases to GitHub
  - Commits release notes back to main branch
- **Conventional commits required:**
  - `fix:` → patch version bump
  - `feat:` → minor version bump
  - `BREAKING CHANGE:` footer → major version bump
  - Use `npx cz commit` for interactive commit wizard

### Documentation

- **`README.md`** — User-facing documentation with usage examples, features, troubleshooting
- **`CONTRIBUTING.md`** — Contributor guidelines
- **`.github/CODEOWNERS`** — Code ownership for review routing

## Key Commands

### Development & Testing

```bash
# Run all integration tests (requires bash)
./.github/workflows/test-action.yml  # Run via GitHub Actions workflow_dispatch

# Run specific test scenarios
./.github/scripts/test-comprehensive.sh              # Full end-to-end tests
./.github/scripts/test-exit-codes.sh                 # Test all exit code scenarios
./.github/scripts/test-step-summary.sh               # Test Step Summary generation

# Verify action locally (requires checkout and action.yaml in place)
# The action is tested via GitHub Actions; local execution is limited to bash scripts
```

```bash
# Install dependencies (one-time setup)
npm install

# Publish a new release (conventional commits must exist)
npm run release

# Make a conventional commit
npx cz commit                         # Interactive prompt for commit message
# OR manually: git commit -m "feat: description of feature"
```

### Code Quality

The action is validated through:

1. **Workflow tests** (`.github/workflows/test-action.yml`) — Runs on every PR/push
2. **Shell script tests** — Standalone validation scripts
3. **Manual testing** — Test templates provided for cfn-lint validation

## Development Workflow

### Making Changes

1. **Edit `action.yaml`** for logic changes (the main implementation)
2. **Add test templates** to `.github/scripts/templates/` if needed
3. **Update shell test scripts** if testing new scenarios
4. **Test locally** via `./.github/scripts/test-*.sh` scripts or push to trigger `.github/workflows/test-action.yml`
5. **Commit with conventional message:**

   ```bash
   git commit -m "fix: description"  # patch version
   git commit -m "feat: description" # minor version
   ```

6. **Push to main** — GitHub Actions workflow runs tests
7. **Release** via `npm run release` (publishes GitHub release + updates CHANGELOG.md)

### Testing Strategy

- **Unit-like tests:** Shell scripts (`.github/scripts/test-*.sh`) validate specific scenarios
- **Integration tests:** GitHub Actions workflow tests the action in realistic GitHub context
- **Cross-platform:** Matrix testing across ubuntu-latest, windows-latest, macos-latest
- **Scenarios covered:** Valid templates, warnings, errors, missing files, nested paths, step summary generation

### Exit Code Preservation

The action intentionally exits with cfn-lint's exit codes:

- `0` → Success
- `2` → Warnings
- `4` → Errors
- `6` → Errors + Warnings
- `8` → Invalid CLI arguments
- `16` → Fatal errors

This allows consuming workflows to use `continue-on-error: true` or conditional steps based on exit codes.

## Important Implementation Details

### GitHub Step Summary

The action appends to `$GITHUB_STEP_SUMMARY` (GitHub-provided env var). This summary is displayed below the step in GitHub Actions UI:

- Shows template name and status
- For non-zero exit codes: includes cfn-lint output in markdown code blocks
- Shows exit code reference table for understanding results

### Path Handling

- Input: relative path from repository root (e.g., `template.yaml`, `infra/main.yaml`)
- Resolved to: `${{ github.workspace }}/<template-path>`
- Must exist as a file or the action exits with code 1

### Error Handling

- Non-existent files → exit code 1 (custom)
- cfn-lint validation issues → exit codes from cfn-lint (0, 2, 4, 6, 8, 16)
- `set +e` / `set -e` used to capture cfn-lint exit code without stopping the script

## Repository State Notes

- Currently on branch `feature/GHA-0029-chore-repository-housekeep`
- Semantic versioning enabled; all releases are automated
- GitHub Actions workflows handle testing and releasing
- No local build step required (action is pure Bash/GitHub Actions)

## Useful Links

- [cfn-lint documentation](https://github.com/aws-cloudformation/cfn-lint)
- [Semantic Release docs](https://semantic-release.gitbook.io/)
- [GitHub Actions composite action docs](https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions#using-composite-actions)
- [Conventional Commits](https://www.conventionalcommits.org/)
