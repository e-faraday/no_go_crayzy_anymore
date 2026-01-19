# Automated Task Management Scripts

These scripts automatically analyze and update task files. They require no user intervention, just run them.

## 📋 Automated Scripts

1. **auto-update-status.sh** - Updates status based on checkbox state
2. **auto-complete-phases.sh** - Marks completed plans
3. **auto-complete-task.sh** - Marks task as completed when all plans are done
4. **auto-update-checkpoint.sh** - Updates Current Checkpoint based on most active plan
5. **auto-sync.sh** - Performs all automatic updates at once

---

## 1. auto-update-status.sh - Automatic Status Update

### Usage

```bash
./scripts/auto-update-status.sh <task-file>
```

### What It Does?

Automatically updates status based on checkbox state:

- **All checkboxes checked** → `status: completed`
- **Some checkboxes checked** → `status: in-progress`
- **No checkboxes checked** → `status: todo`

### Examples

```bash
# Update status
./scripts/auto-update-status.sh .claude/active/feature-add-dark-mode.md
```

**Output:**
```
✅ Status updated

Changed: todo → in-progress
Reason: 5 of 12 checkboxes checked
Checkbox status: 5/12 checked
```

### Logic

- Counts all checkboxes (Implementation Plans + Acceptance Criteria)
- Counts checked checkboxes
- Determines status based on ratio

---

## 2. auto-complete-phases.sh - Automatic Plan Completion

### Usage

```bash
./scripts/auto-complete-phases.sh <task-file> [message]
```

### What It Does?

If **all checkboxes in a plan are checked**:
- Adds "(✅ COMPLETED)" to plan header
- Adds entry to Progress Log (optional)

### Examples

```bash
# Check plans and mark completed ones
./scripts/auto-complete-phases.sh .claude/active/feature-add-dark-mode.md

# With custom message
./scripts/auto-complete-phases.sh .claude/active/feature-add-dark-mode.md "All setup tasks completed"
```

**Output:**
```
✅ Plan 1 completed: Setup & Infrastructure
✅ Plan 2 completed: Core Implementation

✅ Marked 2 plan(s) as completed

Next steps:
  - Update status: ./scripts/auto-update-status.sh file.md
  - Check if task complete: ./scripts/auto-complete-task.sh file.md
```

### Logic

- Checks each plan
- Counts all checkboxes in plan
- Marks plan as completed if all are checked

---

## 3. auto-complete-task.sh - Automatic Task Completion

### Usage

```bash
./scripts/auto-complete-task.sh <task-file> [message]
```

### What It Does?

If **all plans are "(✅ COMPLETED)"**:
- Sets status to `completed`
- Sets Current Checkpoint to "✅ All plans completed"
- Adds final entry to Progress Log

### Examples

```bash
# Complete task (if all plans are completed)
./scripts/auto-complete-task.sh .claude/active/feature-add-dark-mode.md

# With custom message
./scripts/auto-complete-task.sh .claude/active/feature-add-dark-mode.md "Ready for production"
```

**Output:**
```
✅ Task marked as completed!

All plans completed: 3/3
Message: Ready for production

Next step:
  ./scripts/archive-completed.sh
```

### Logic

- Checks all plans
- Marks task as completed if all are "(✅ COMPLETED)"
- Otherwise shows which plans are missing

---

## 4. auto-update-checkpoint.sh - Automatic Checkpoint Update

### Usage

```bash
./scripts/auto-update-checkpoint.sh <task-file>
```

### What It Does?

Detects plan with most checkboxes checked:
- "Working on" → Most active plan
- "Next" → Next plan

### Examples

```bash
# Update checkpoint
./scripts/auto-update-checkpoint.sh .claude/active/feature-add-dark-mode.md
```

**Output:**
```
✅ Current Checkpoint updated

Working on: Plan 2: Core Implementation
Next: Plan 3: Testing & Polish
```

### Logic

- Calculates checkbox count in each plan
- Finds plan with highest progress percentage
- Updates Current Checkpoint

---

## 5. auto-sync.sh - All Automatic Updates

### Usage

```bash
./scripts/auto-sync.sh <task-file>
```

### What It Does?

Performs all automatic updates in sequence:
1. Check plans and mark completed ones
2. Update status
3. Update checkpoint
4. Mark task as completed if done

### Examples

```bash
# Sync single task
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md

# Sync all active tasks
for file in .claude/active/*.md; do
    ./scripts/auto-sync.sh "$file"
done
```

**Output:**
```
🔄 Syncing: feature-add-dark-mode.md

1. Checking plans...
   ✓ Plans checked
2. Updating status...
   ✓ Status updated
3. Updating checkpoint...
   ✓ Checkpoint updated
4. Checking task completion...
   ℹ  Task not ready for completion

✅ Sync complete for: feature-add-dark-mode.md
```

---

## 🔄 Daily Usage Scenarios

### Scenario 1: Daily Synchronization

```bash
# Morning: Sync all tasks
for file in .claude/active/*.md; do
    ./scripts/auto-sync.sh "$file"
done

# View daily summary
./scripts/daily-summary.sh
```

### Scenario 2: After Checking Checkbox

```bash
# Manually check checkbox
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Create ThemeContext"

# Run automatic updates
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md
```

### Scenario 3: When Plan is Completed

```bash
# Mark all checkboxes in plan (manually or with Claude)
# Then run automatic updates
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md
```

---

## 💡 Tips

### 1. Daily Routine

**Morning:**
```bash
# Sync all tasks
for file in .claude/active/*.md; do ./scripts/auto-sync.sh "$file"; done
```

**Evening:**
```bash
# Sync again (for changes during the day)
for file in .claude/active/*.md; do ./scripts/auto-sync.sh "$file"; done

# Archive completed tasks
./scripts/archive-completed.sh
```

### 2. After Checking Checkbox

Run automatic updates after each checkbox is checked:

```bash
# Check checkbox
./scripts/check-task.sh file.md "Task name"

# Automatic update
./scripts/auto-sync.sh file.md
```

### 3. Automation with Git Hook

You can add to `.git/hooks/post-commit`:

```bash
#!/bin/bash
# Sync all active tasks
for file in .claude/active/*.md; do
    ./scripts/auto-sync.sh "$file" > /dev/null 2>&1
done
```

---

## 🔗 Combination with Parametric Scripts

### Complete Workflow

```bash
# 1. Start task
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting Plan 1"

# 2. Check checkbox (manually or with Claude)
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Create ThemeContext"

# 3. Run automatic updates
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md

# 4. Record progress (optional)
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "ThemeContext created"

# 5. Sync again
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md
```

---

## ⚠️ Important Notes

1. **Automated scripts only analyze and update**
   - Don't check boxes (must be done manually or with Claude)
   - Don't add detailed entries to Progress Log (only for plan completion)

2. **Status update logic:**
   - All checkboxes → completed
   - Some checkboxes → in-progress
   - No checkboxes → todo

3. **Plan completion:**
   - **All** checkboxes in a plan must be checked
   - Acceptance Criteria checkboxes are not counted (only those in plans)

4. **Task completion:**
   - **All** plans must be "(✅ COMPLETED)"
   - Acceptance Criteria are not checked

---

## 📊 Summary

| Script | What It Does | Automated? |
|--------|--------------|------------|
| `auto-update-status.sh` | Updates status based on checkbox state | ✅ Yes |
| `auto-complete-phases.sh` | Marks completed plans | ✅ Yes |
| `auto-complete-task.sh` | Marks task as completed when all plans are done | ✅ Yes |
| `auto-update-checkpoint.sh` | Updates checkpoint based on most active plan | ✅ Yes |
| `auto-sync.sh` | Performs all automatic updates | ✅ Yes |

**All scripts:**
- ✅ Automated (no user intervention required)
- ✅ Platform compatible (macOS/Linux)
- ✅ Safe (only analyzes and updates)
- ✅ Provides informative output

---

**Note:** These scripts don't check boxes, they only analyze current state and update. Use `check-task.sh` or Claude to check boxes.
