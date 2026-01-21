# Test Fixtures

This directory contains test fixtures for Active Mode testing.

## Feature Files

- `feature-template.md` - Standard feature template with all sections
- `feature-with-progress.md` - Feature with multiple progress log entries
- `feature-completed.md` - Completed feature (status: completed)
- `feature-blocked.md` - Blocked feature (status: blocked)
- `feature-todo.md` - Todo feature (status: todo)
- `feature-no-checkpoint.md` - Feature missing checkpoint section
- `feature-no-progress.md` - Feature missing Progress Log section
- `feature-no-frontmatter.md` - Feature missing frontmatter

## Usage

These fixtures can be used in test scripts to ensure consistent test data:

```bash
# Copy fixture to test directory
cp tests/fixtures/feature-template.md .claude/active/feature-test.md

# Use in test scripts
create_feature_from_fixture() {
    local fixture="$1"
    local target="$2"
    cp "tests/fixtures/$fixture" "$target"
}
```

## Test Scenarios

### Standard Feature
Use `feature-template.md` for basic Active Mode tests.

### Multiple Progress Entries
Use `feature-with-progress.md` to test Progress Log extraction and display.

### Status Variations
Use `feature-completed.md`, `feature-blocked.md`, `feature-todo.md` to test status-based filtering and priority sorting.

### Missing Sections
Use `feature-no-checkpoint.md` and `feature-no-progress.md` to test validation and error handling.

### Malformed Files
Use `feature-no-frontmatter.md` to test graceful handling of invalid files.
