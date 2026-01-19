# Parametric Task Management Scripts

These scripts allow you to manage task files with parametric commands instead of manually editing them.

## 📋 Scripts

1. **check-task.sh** - Checkbox checking
2. **update-progress.sh** - Adding entry to Progress Log
3. **set-priority.sh** - Changing priority
4. **add-tags.sh** - Adding/editing tags

---

## 1. check-task.sh - Checking Checkbox

### Usage

```bash
./scripts/check-task.sh <task-file> <task-text-or-number>
```

### Examples

```bash
# By task text (partial match supported)
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Create ThemeContext"
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "ThemeContext"

# By task number (Plan.Task format)
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "1.1"  # Plan 1, Task 1
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "1.2"  # Plan 1, Task 2
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "2.1"  # Plan 2, Task 1

# With auto-commit
./scripts/check-task.sh --auto-commit .claude/active/feature-add-dark-mode.md "1.1"
```

### What It Does?

- Changes specified task's checkbox from `[ ]` → `[x]`
- Works with task text or task number
- Supports partial match (for task text)
- Checks first matching task (for text matching)

### Task Number Format

- Format: `PlanNumber.TaskNumber` (e.g., `1.1`, `1.2`, `2.1`)
- `1.1` = Plan 1, first task
- `1.2` = Plan 1, second task
- `2.1` = Plan 2, first task
- Task numbers start from 1 within each plan

### Notes

- Task text doesn't need to match exactly (partial match OK)
- When task number is used, checks based on specified plan and task number
- Doesn't re-check already checked tasks
- Shows error message if task not found
- Text and number formats can be used together (backward compatible)

---

## 2. update-progress.sh - Adding Entry to Progress Log

### Usage

```bash
./scripts/update-progress.sh <task-file> <message> [task-number]
```

### Examples

```bash
# Normal entry (without task number)
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "Plan 1 completed"
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "Fixed bug in theme toggle"
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "All components styled for dark mode, tested on Chrome and Firefox"

# With task number (optional)
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "Task completed" "1.1"
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "Bug fixed" "2.3"
```

### What It Does?

- Adds new entry to Progress Log section
- Automatically adds date/time
- If task number is provided, entry format: `**YYYY-MM-DD HH:MM** - [Task 1.1] your message`
- If task number is not provided, entry format: `**YYYY-MM-DD HH:MM** - your message`
- Creates Progress Log section if it doesn't exist

### Format

**Without task number:**
```
**2026-01-18 14:30** - Plan 1 completed
```

**With task number:**
```
**2026-01-18 14:30** - [Task 1.1] Task completed
**2026-01-18 14:30** - [Task 2.3] Bug fixed
```

### Task Number Format

- Format: `PlanNumber.TaskNumber` (e.g., `1.1`, `1.2`, `2.1`)
- Optional parameter - normal entry if not provided
- If provided, entry is labeled with task number

---

## 3. set-priority.sh - Changing Priority

### Usage

```bash
./scripts/set-priority.sh <task-file> <priority>
```

### Examples

```bash
# Set high priority
./scripts/set-priority.sh .claude/active/feature-add-dark-mode.md high

# Set medium priority
./scripts/set-priority.sh .claude/active/feature-add-dark-mode.md medium

# Set low priority
./scripts/set-priority.sh .claude/active/feature-add-dark-mode.md low
```

### What It Does?

- Updates priority in frontmatter
- Validates (high/medium/low)
- Warns if already same priority

### Priority Values

- `high` - High priority
- `medium` - Medium priority (default)
- `low` - Low priority

---

## 4. add-tags.sh - Adding/Editing Tags

### Usage

```bash
./scripts/add-tags.sh <task-file> <tag1> [tag2] [tag3] ...
```

### Examples

```bash
# Add single tag
./scripts/add-tags.sh .claude/active/feature-add-dark-mode.md auth

# Add multiple tags
./scripts/add-tags.sh .claude/active/feature-add-dark-mode.md auth security frontend

# Add to existing tags (duplicate check is done)
./scripts/add-tags.sh .claude/active/feature-add-dark-mode.md ui theme
```

### What It Does?

- Adds new tags to existing tags
- Checks for duplicates (same tag won't be added twice)
- Sorts tags alphabetically
- Preserves existing tags

### Example

**Before:**
```yaml
tags: [auth]
```

**Command:**
```bash
./scripts/add-tags.sh file.md security frontend
```

**After:**
```yaml
tags: [auth, frontend, security]
```

---

## 🔄 Daily Usage Scenarios

### Scenario 1: Starting Task and Progress

```bash
# 1. Start task
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting Plan 1"

# 2. Complete a task
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Create ThemeContext"

# 3. Record progress
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "ThemeContext created and tested"

# 4. Increase priority (if needed)
./scripts/set-priority.sh .claude/active/feature-add-dark-mode.md high
```

### Scenario 2: Tag Management

```bash
# Create task
./scripts/new-task.sh feature "Add user authentication"

# Add tags
./scripts/add-tags.sh .claude/active/feature-add-user-authentication.md auth security backend

# Result: tags: [auth, backend, security]
```

### Scenario 3: Plan Completion

```bash
# Check all tasks in Plan 1
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Create ThemeContext"
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Add localStorage hook"
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Implement system preference"

# Record progress
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "Plan 1 completed - All setup tasks done"
```

---

## 💡 Tips

### 1. Checking Checkbox

**✅ Good:**
```bash
# Use partial match (more flexible)
./scripts/check-task.sh file.md "ThemeContext"
```

**❌ Bad:**
```bash
# Too specific (might not match)
./scripts/check-task.sh file.md "Create ThemeContext and Provider"
```

### 2. Progress Log

**✅ Good:**
```bash
# Specific and descriptive
./scripts/update-progress.sh file.md "Plan 1 completed - All components created"
```

**❌ Bad:**
```bash
# Too general
./scripts/update-progress.sh file.md "Done"
```

### 3. Tags

**✅ Good:**
```bash
# Meaningful and consistent tags
./scripts/add-tags.sh file.md auth security backend
```

**❌ Bad:**
```bash
# Too specific or meaningless
./scripts/add-tags.sh file.md "my-feature" "temp" "test123"
```

---

## 🔗 Combination with Other Scripts

### With Automated Scripts

```bash
# 1. Manually check checkbox
./scripts/check-task.sh file.md "Create component"

# 2. Automatic plan check
./scripts/auto-complete-phases.sh file.md

# 3. Automatic status update
./scripts/auto-update-status.sh file.md
```

### With Claude

```bash
# 1. Work with Claude
@file.md Help me implement Plan 1

# 2. Manually check checkbox (if Claude didn't)
./scripts/check-task.sh file.md "Create component"

# 3. Record progress
./scripts/update-progress.sh file.md "Plan 1 implementation done"
```

---

## ⚠️ Error Cases

### check-task.sh

**Task not found:**
```
⚠️  Task not found or already checked: Create ThemeContext
```

**Solution:** Check task text, use partial match

### set-priority.sh

**Invalid priority:**
```
Error: Invalid priority 'urgent'
Valid priorities: high, medium, low
```

**Solution:** Use high, medium, or low

### add-tags.sh

**Tags line not found:**
```
Error: No tags line found in file
```

**Solution:** File must have `tags: []` line in frontmatter

---

## 📊 Example Daily Flow

### Morning

```bash
# View daily summary
./scripts/daily-summary.sh

# Start task you'll work on today
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting work today"
```

### During the Day

```bash
# Complete task
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Create ThemeContext"

# Record progress
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "ThemeContext created"

# Increase priority (if needed)
./scripts/set-priority.sh .claude/active/feature-add-dark-mode.md high
```

### Evening

```bash
# Record final progress
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "End of day - Plan 1 60% complete"

# Check daily summary again
./scripts/daily-summary.sh
```

---

## 🎯 Summary

| Script | What It Does | Parameters |
|--------|--------------|------------|
| `check-task.sh` | Check checkbox | task-file, task-text-or-number |
| `update-progress.sh` | Add entry to Progress Log | task-file, message, [task-number] |
| `set-priority.sh` | Change priority | task-file, priority |
| `add-tags.sh` | Add/edit tags | task-file, tag1, tag2, ... |

**All scripts:**
- ✅ Parametric (user controlled)
- ✅ Platform compatible (macOS/Linux)
- ✅ Error checking
- ✅ Informative output

---

**Note:** These scripts facilitate manual operations. Automated scripts (auto-update-status.sh, auto-complete-phases.sh) are available.
