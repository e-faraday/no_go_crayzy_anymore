# Active Mode Test Suite

This directory contains the test suite for Active Mode functionality.

## Structure

```
tests/
├── fixtures/          # Test data fixtures
│   ├── feature-template.md
│   ├── feature-with-progress.md
│   ├── feature-completed.md
│   └── ...
└── README.md          # This file
```

## Running Tests

### Run All Tests

```bash
./scripts/test-active-mode.sh --all
```

### Run Specific Category

```bash
# Category 1: Detection
./scripts/test-active-mode.sh --category detection

# Category 2: Enforcement
./scripts/test-active-mode.sh --category enforcement

# Category 3: Validation
./scripts/test-active-mode.sh --category validation

# Category 4: Pre-commit Hook
./scripts/test-active-mode.sh --category precommit

# Category 5: Fresh Chat
./scripts/test-active-mode.sh --category freshchat

# Category 6: Auto-sync
./scripts/test-active-mode.sh --category autosync

# Category 7: Edge Cases
./scripts/test-active-mode.sh --category edgecases

# Category 8: Integration
./scripts/test-active-mode.sh --category integration

# Category 9: Performance
./scripts/test-active-mode.sh --category performance

# Category 10: Error Handling
./scripts/test-active-mode.sh --category errorhandling
```

### Using Numeric IDs

You can also use numeric IDs:

```bash
./scripts/test-active-mode.sh --category 1
./scripts/test-active-mode.sh --category 2
# ... etc
```

## Test Categories

### Category 1: Active Mode Detection
Tests for detecting Active Mode vs Bootstrap Mode:
- Single feature detection
- Multiple features detection
- .gitkeep exclusion

### Category 2: State Update Enforcement
Tests for enforcing state updates:
- Blocking commits without state updates
- Allowing commits with state updates
- Multiple features handling

### Category 3: validate-state.sh Script Tests
Tests for the validation script:
- Bootstrap mode skip
- No code changes handling
- State update validation
- Progress Log checks
- Checkpoint validation

### Category 4: Pre-Commit Hook Tests
Tests for git pre-commit hook:
- Hook installation
- Blocking invalid commits
- Allowing valid commits
- Bootstrap mode skip

### Category 5: Fresh Chat Auto-Load Tests
Tests for Fresh Chat protocol:
- Bootstrap mode message
- Single feature loading
- Multiple features loading
- Priority sorting
- Progress Log extraction

### Category 6: auto-sync.sh Script Tests
Tests for auto-sync script:
- Bootstrap mode detection
- Valid feature file handling
- Invalid file error handling

### Category 7: Edge Cases
Tests for edge cases:
- Missing frontmatter
- Missing checkpoint section
- Missing Progress Log
- Multiple commits without state
- State-only updates
- Mode transitions

### Category 8: Integration Tests
End-to-end workflow tests:
- Full feature lifecycle
- Multiple features workflow
- Cursor rule enforcement

### Category 9: Performance Tests
Performance benchmarks:
- Validation speed with many features
- Fresh Chat load time

### Category 10: Error Handling
Error handling tests:
- Git not initialized
- No commits yet
- Corrupted files

## CI/CD Integration

Tests run automatically on:
- Push to main/develop branches
- Pull requests
- Daily schedule (2 AM UTC)
- Manual trigger via workflow_dispatch

See `.github/workflows/test-active-mode.yml` for details.

## Test Fixtures

Test fixtures are located in `tests/fixtures/`:
- Standard feature templates
- Features with various statuses
- Features with missing sections
- Malformed features

See `tests/fixtures/README.md` for details.

## Success Criteria

All tests must pass for Active Mode to be considered working:
- **Detection:** 100% accuracy
- **Enforcement:** 100% commit blocking when needed
- **Validation:** All checks work correctly
- **Fresh Chat:** All features load correctly
- **Edge Cases:** All handled gracefully
- **Performance:** All operations <2 seconds

## Troubleshooting

### Tests Fail in CI but Pass Locally

1. Check script permissions: `chmod +x scripts/*.sh`
2. Verify scripts exist: `ls -la scripts/`
3. Check bash version: `bash --version`
4. Review CI logs for specific errors

### Some Tests Are Skipped

Some tests may be skipped if:
- Required scripts are not available
- Pre-commit hooks are not installed
- Git is not initialized

This is expected behavior - skipped tests are not failures.

### Performance Tests Fail

Performance tests may fail if:
- CI environment is slow
- System load is high
- Many features exist

Consider adjusting thresholds or running performance tests separately.

## Contributing

When adding new tests:
1. Add to appropriate category function in `scripts/test-active-mode.sh`
2. Update this README if adding new category
3. Add test fixtures if needed
4. Ensure tests work in isolated environment
5. Update CI workflow if needed
