# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-01-22

### 🎉 Major Release: Gold Standard Implementation

This release introduces comprehensive testing, validation, and automation features that bring MDD to production-ready quality.

### ✨ Added

#### Gold Standard Features
- **Git Hooks Integration**
  - Pre-commit hook for state validation (`scripts/validate-state.sh`)
  - Commit-msg hook for Conventional Commits validation (`scripts/validate-commit-message.sh`)
  - Automatic hook installation script (`scripts/install-pre-commit-hook.sh`)
  - Bootstrap Mode awareness (hooks skip when no active features)

- **Environment Parity**
  - CI/test configuration verification (`scripts/verify-env-parity.sh`)
  - Ensures local and CI environments match
  - Automatic detection of configuration mismatches

- **Conventional Commits**
  - Commit message format validation
  - Support for all standard types (feat, fix, docs, style, refactor, test, chore, perf, ci, build)
  - Merge and revert commit handling
  - GitHub Actions workflow integration

- **Affected Tests Detection**
  - Smart test selection (`scripts/detect-affected-tests.sh`)
  - Optimizes CI execution by running only relevant tests
  - Maps file changes to test categories

#### Comprehensive Testing
- **E2E Test Suite** (`scripts/e2e-test.sh`)
  - 50 comprehensive end-to-end tests
  - 6 test categories (A-F):
    - Category A: Git Hooks Integration (8 tests)
    - Category B: Environment Parity (4 tests)
    - Category C: Conventional Commits (6 tests)
    - Category D: Affected Tests Detection (5 tests)
    - Category E: Full Workflow with Gold Standard (5 tests)
    - Category F: Hook Installation Script (6 tests)
  - All tests passing ✅

- **Active Mode Test Suite** (`scripts/test-active-mode.sh`)
  - 41 test cases across 10 categories
  - Complete Active Mode functionality coverage
  - Isolated test environments
  - CI/CD integration

- **Test Fixtures** (`tests/fixtures/`)
  - 8 comprehensive test fixtures
  - Edge case scenarios
  - Documentation

#### CI/CD Integration
- GitHub Actions workflows:
  - `test-active-mode.yml` - Full test suite on push/PR
  - `test-on-commit.yml` - Quick critical tests
  - `validate-commits.yml` - Conventional Commits validation
  - `auto-rollback.yml` - Automatic rollback on main failure
- Scheduled daily tests (2 AM UTC)
- Manual workflow triggers

#### Enhanced mdd Wrapper
- New Gold Standard commands:
  - `mdd validatestate` / `mdd validate-state`
  - `mdd verifyenvparity` / `mdd verify-env-parity`
  - `mdd detectaffectedtests` / `mdd detect-affected-tests`
  - `mdd installhooks` / `mdd install-hooks`
  - `mdd validatecommit` / `mdd validate-commit`
- New testing commands:
  - `mdd testactivemode` / `mdd test-active-mode`
  - `mdd e2etest` / `mdd e2e-test`
- Improved help documentation

#### Documentation
- `docs/GOLD_STANDARD_IMPLEMENTATION.md` - Complete Gold Standard guide
- `docs/PRE_COMMIT_SETUP.md` - Hook installation guide
- `docs/DEVELOPER_WORKFLOW_DIAGRAM.md` - Updated workflow diagrams
- `tests/README.md` - Comprehensive test documentation
- `ACTIVE_MODE_TEST_SUMMARY.md` - Quick test reference
- `IMPLEMENTATION_COMPLETE.md` - Implementation status

#### Cursor Rules
- `.cursor/rules/state-tracking.mdc` - State tracking enforcement
- `.cursor/rules/fresh-chat-protocol.mdc` - Fresh Chat integration
- `.cursor/rules/memory-management.mdc` - Enhanced memory management

### 🔧 Changed

- **validate-state.sh**: Now checks staged changes when run as pre-commit hook
- **e2e-test.sh**: Extended with 34 new tests (from 14 to 50 total)
- **README.md**: Updated with Gold Standard features and new commands
- **mdd wrapper**: Enhanced with new command mappings and help text

### 🐛 Fixed

- Pre-commit hook now correctly validates staged changes (not just last commit)
- Script detection in e2e tests now uses `$PROJECT_ROOT` for reliability
- `detect-affected-tests.sh` now checks staged changes in pre-commit context
- Test output parsing fixed (using `tail -1` instead of `head -1`)
- E1 and E5 workflow tests now properly copy template files

### 📊 Statistics

- **Total Tests**: 91 (50 E2E + 41 Active Mode)
- **Test Pass Rate**: 100% ✅
- **New Scripts**: 6 (validation, hooks, testing)
- **New Documentation**: 5+ files
- **CI/CD Workflows**: 4 workflows

### 🚀 Migration Guide

If upgrading from v1.0.0:

1. **Install Git Hooks** (recommended):
   ```bash
   ./mdd installhooks
   # or
   ./scripts/install-pre-commit-hook.sh
   ```

2. **Verify Environment Parity**:
   ```bash
   ./mdd verifyenvparity
   ```

3. **Run Tests** to verify everything works:
   ```bash
   ./mdd e2etest
   ./mdd testactivemode
   ```

4. **Update CI/CD** (if using GitHub Actions):
   - The new workflows are automatically available
   - Review `.github/workflows/` for new options

### 🔗 Related

- See `docs/GOLD_STANDARD_IMPLEMENTATION.md` for complete feature documentation
- See `tests/README.md` for test documentation
- See `ACTIVE_MODE_TEST_SUMMARY.md` for quick test reference

---

## [1.0.0] - 2026-01-17

### Initial Release

- Core MDD workflow scripts
- Basic task management (create, check, archive)
- Bootstrap and Active Mode support
- Basic documentation
