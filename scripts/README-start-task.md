# start-task.sh - Automatic Status Tracking

## Purpose

When starting a task, automatically:
- Sets status to `in-progress`
- Adds entry to Progress Log
- Adds date/time information

## Usage

### Basic Usage

```bash
./scripts/start-task.sh .claude/active/feature-add-user-authentication.md
```

**Default message:** "Started working on this task"

### With Custom Message

```bash
./scripts/start-task.sh .claude/active/feature-add-user-authentication.md "Starting Plan 1"
```

### Starting Plan

```bash
./scripts/start-task.sh .claude/active/feature-add-user-authentication.md "Starting Plan 2: Core Implementation"
```

## What It Does?

1. **Status Update:**
   - In frontmatter: `status: in-progress`
   - In body: `**Status:** In Progress`

2. **Progress Log Entry:**
   - Format: `**YYYY-MM-DD HH:MM** - [your message]`
   - Added to top of Progress Log section

3. **Safety Check:**
   - Warns if task is already `in-progress`
   - Asks for confirmation (y/N)

## Examples

### Scenario 1: Starting New Task

```bash
# Create task
./scripts/new-task.sh feature "Add dark mode"

# Start task
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting implementation"
```

**Result:**
- Status: `in-progress`
- Progress Log: `**2026-01-18 10:00** - Starting implementation`

### Scenario 2: Starting Plan

```bash
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting Plan 2: UI Components"
```

**Result:**
- Status: `in-progress` (warns if already in-progress)
- Progress Log: `**2026-01-18 14:30** - Starting Plan 2: UI Components`

### Scenario 3: Continuing During the Day

```bash
# Started in morning
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting work"

# Continuing in afternoon
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Continuing Plan 1"
```

**Result:**
- New Progress Log entry added on each run
- All work history is preserved

## Daily Workflow

### Morning Routine

```bash
# View daily summary
./scripts/daily-summary.sh

# Start task you'll work on today
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting work today"
```

### During the Day

```bash
# When moving to new plan
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting Plan 2"
```

### Evening

```bash
# Check progress
cat .claude/active/feature-add-dark-mode.md | grep "Progress Log" -A 10
```

## Tips

1. **Specific Messages:**
   ```bash
   # ✅ Good
   ./scripts/start-task.sh file.md "Starting Plan 1: Setup"
   
   # ❌ Bad
   ./scripts/start-task.sh file.md "Starting"
   ```

2. **With Claude:**
   ```bash
   # Start task
   ./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting Plan 1"
   
   # Show to Claude
   @.claude/active/feature-add-dark-mode.md Help me implement Plan 1
   ```

3. **Progress Tracking:**
   - Run script at each important step
   - Progress Log automatically grows
   - All work history is preserved

## Error Cases

### File Not Found

```bash
Error: Task file not found: .claude/active/feature-test.md
```

**Solution:** Check file path

### Already In-Progress

```bash
⚠️  Task is already in-progress
Continue anyway? (y/N)
```

**Solution:** 
- `y` → Continue, add new Progress Log entry
- `N` → Cancel

## Technical Details

- **Platform:** Compatible with macOS and Linux
- **Sed commands:** Automatically selected based on platform
- **Progress Log format:** Markdown compatible
- **Status update:** Frontmatter and body section

## Example Output

```bash
$ ./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting Plan 1"

✅ Task started!

Status updated: in-progress
Progress Log: **2026-01-18 10:00** - Starting Plan 1

Next steps:
  1. Start working: claude
  2. Reference it: @.claude/active/feature-add-dark-mode.md implement this
```

---

**Note:** This script allows you to automatically track task statuses. No need for manual status updates!
