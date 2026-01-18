# Automated Task Management Scripts

These scripts automatically analyze and update task files. They require no user intervention, just run them.

## 📋 Automated Scripts

1. **auto-update-status.sh** - Updates status based on checkbox state
2. **auto-complete-phases.sh** - Marks completed plans (automatic commit support)
3. **auto-complete-task.sh** - Marks feature as completed when all plans are done (automatic commit support)
4. **auto-update-checkpoint.sh** - Updates Current Checkpoint based on most active plan
5. **auto-sync.sh** - Performs all automatic updates at once (--with-commits flag)
6. **auto-commit-task.sh** - Automatically commits when a single task is completed
7. **auto-commit-plan.sh** - Automatically commits when a plan is completed
8. **auto-commit-feature.sh** - Automatically commits when a feature is completed

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
./scripts/auto-complete-phases.sh [--no-commit] <task-file> [message]
```

### What It Does?

If **all checkboxes in a plan are checked**:
- Adds "(✅ COMPLETED)" to plan header
- Automatically calls `auto-commit-plan.sh` (can be skipped with --no-commit)

### Examples

```bash
# Check plans and mark completed ones
./scripts/auto-complete-phases.sh .claude/active/feature-add-dark-mode.md

# With custom message
./scripts/auto-complete-phases.sh .claude/active/feature-add-dark-mode.md "All setup tasks completed"

# Skip commit
./scripts/auto-complete-phases.sh --no-commit .claude/active/feature-add-dark-mode.md
```

**Output:**
```
✅ Plan 1 completed: Setup & Infrastructure
✅ Committed: docs(add-dark-mode): complete Plan 1
   Commit: abc123f
✅ Plan 2 completed: Core Implementation
✅ Committed: docs(add-dark-mode): complete Plan 2
   Commit: def456g

✅ Marked 2 plan(s) as completed

Next steps:
  - Update status: ./scripts/auto-update-status.sh file.md
  - Check if feature complete: ./scripts/auto-complete-task.sh file.md
```

### Logic

- Checks each plan
- Counts all checkboxes in plan
- Marks plan as completed if all are checked
- Automatically commits (can be skipped with --no-commit)

---

## 3. auto-complete-task.sh - Automatic Feature Completion

### Usage

```bash
./scripts/auto-complete-task.sh [--no-commit] <task-file> [message]
```

### What It Does?

If **all plans are "(✅ COMPLETED)"**:
- Sets status to `completed`
- Sets Current Checkpoint to "✅ All plans completed"
- Adds final entry to Progress Log
- Automatically calls `auto-commit-feature.sh` (can be skipped with --no-commit)

### Examples

```bash
# Complete feature (if all plans are completed)
./scripts/auto-complete-task.sh .claude/active/feature-add-dark-mode.md

# With custom message
./scripts/auto-complete-task.sh .claude/active/feature-add-dark-mode.md "Ready for production"

# Skip commit
./scripts/auto-complete-task.sh --no-commit .claude/active/feature-add-dark-mode.md
```

**Output:**
```
✅ Feature marked as completed!

All plans completed: 3/3
Message: Ready for production

✅ Committed: docs(add-dark-mode): complete feature
   Commit: xyz789a

Next step:
  ./scripts/archive-completed.sh
```

### Logic

- Checks all plans
- Marks feature as completed if all are "(✅ COMPLETED)"
- Automatically commits (can be skipped with --no-commit)
- Otherwise shows which plans are missing

---

## 4. auto-update-checkpoint.sh - Automatic Checkpoint Update

### Usage

```bash
./scripts/auto-update-checkpoint.sh <task-file>
```

### What It Does?

Finds most active plan and updates Current Checkpoint:
- Finds plan with most checkboxes
- Updates checkpoint to "Working on: Plan {N}"

### Examples

```bash
# Update checkpoint
./scripts/auto-update-checkpoint.sh .claude/active/feature-add-dark-mode.md
```

---

## 5. auto-sync.sh - All Automatic Updates

### Usage

```bash
./scripts/auto-sync.sh [--with-commits] <task-file>
```

### Options

- `--with-commits` - Also run automatic commits (on plan/feature completion)

### What It Does?

Performs all automatic updates in sequence:
1. Check plans and mark completed ones
2. Update status
3. Update checkpoint
4. Mark feature as completed if done

### Examples

```bash
# Sync single feature
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md

# With commits
./scripts/auto-sync.sh --with-commits .claude/active/feature-add-dark-mode.md

# Sync all active features
for file in .claude/active/*.md; do
    ./scripts/auto-sync.sh "$file"
done
```

**Output:**
```
🔄 Syncing: feature-add-dark-mode.md

1. Checking phases...
   ✓ Phases checked and committed
2. Updating status...
   ✓ Status updated
3. Updating checkpoint...
   ✓ Checkpoint updated
4. Checking task completion...
   ✓ Task marked as completed and committed!

✅ Sync complete for: feature-add-dark-mode.md
```

---

## 6. Automatic Commit Scripts

MDD offers automatic commit support. Automatic commits can be made when each task, plan, and feature is completed.

### 6.1 auto-commit-task.sh

Commits when a single task (checkbox) is completed.

**Usage:**
```bash
./scripts/auto-commit-task.sh <task-file> <task-name>
```

**Commit format:**
```
feat({feature-slug}): {task-name}
```

**Example:**
```bash
./scripts/auto-commit-task.sh .claude/active/feature-add-dark-mode.md "Create ThemeContext"
```

**Output:**
```
✅ Committed: feat(add-dark-mode): Create ThemeContext
   Commit: abc123f
```

### 6.2 auto-commit-plan.sh

Makes a metadata commit when a plan is completed (all checkboxes checked).

**Usage:**
```bash
./scripts/auto-commit-plan.sh <task-file> <plan-name>
```

**Commit format:**
```
docs({feature-slug}): complete Plan {N}: {plan-name}

Tasks completed: {N}/{N}
- {Task 1}
- {Task 2}
```

**Example:**
```bash
./scripts/auto-commit-plan.sh .claude/active/feature-add-dark-mode.md "Plan 1: Setup"
```

**Output:**
```
✅ Committed: docs(add-dark-mode): complete Plan 1
   Commit: def456g
```

### 6.3 auto-commit-feature.sh

Makes final commit when feature is completed (all plans completed).

**Usage:**
```bash
./scripts/auto-commit-feature.sh <task-file>
```

**Commit format:**
```
docs({feature-slug}): complete feature

Plans completed: {N}/{N}
- Plan 1: {name}
- Plan 2: {name}
```

**Example:**
```bash
./scripts/auto-commit-feature.sh .claude/active/feature-add-dark-mode.md
```

**Output:**
```
✅ Committed: docs(add-dark-mode): complete feature
   Commit: xyz789a
```

---

## 7. Automation Flow

### Fully Automated Workflow

```bash
# 1. Check checkbox (with automatic commit)
./scripts/check-task.sh --auto-commit .claude/active/feature-add-dark-mode.md "Create ThemeContext"

# 2. Automatic updates + commits
./scripts/auto-sync.sh --with-commits .claude/active/feature-add-dark-mode.md
```

**Result:**
- When each task is completed → `feat(...): {task}` commit
- When each plan is completed → `docs(...): complete Plan {N}` commit
- When feature is completed → `docs(...): complete feature` commit

### Manual Commit (Traditional)

```bash
# Run scripts with --no-commit
./scripts/auto-complete-phases.sh --no-commit .claude/active/feature-add-dark-mode.md
./scripts/auto-complete-task.sh --no-commit .claude/active/feature-add-dark-mode.md

# Manual commit
git add .claude/active/feature-add-dark-mode.md
git commit -m "feat: Add dark mode feature"
```

---

## 8. Setup

### .claude/settings.json

Automatic commits require Claude Code to have bash command permissions:

```json
{
  "permissions": {
    "allow": [
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git status:*)",
      "Bash(git mv:*)",
      "Bash(date:*)",
      "Bash(echo:*)",
      "Bash(cat:*)",
      "Bash(grep:*)",
      "Bash(sed:*)",
      "Bash(awk:*)",
      "Bash(tr:*)",
      "Bash(cut:*)",
      "Bash(basename:*)",
      "Bash(dirname:*)",
      "Bash(find:*)",
      "Bash(git ls-files:*)",
      "Bash(git rev-parse:*)",
      "Bash(git rm:*)"
    ]
  }
}
```

Or run Claude Code with `--dangerously-skip-permissions` flag:
```bash
claude --dangerously-skip-permissions
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
# Check checkbox with automatic commit
./scripts/check-task.sh --auto-commit .claude/active/feature-add-dark-mode.md "Create ThemeContext"

# Run automatic updates (commits included)
./scripts/auto-sync.sh --with-commits .claude/active/feature-add-dark-mode.md
```

### Scenario 3: When Plan is Completed

```bash
# Mark all checkboxes in plan (manually or with Claude)
# Then run automatic updates (plan commit included)
./scripts/auto-sync.sh --with-commits .claude/active/feature-add-dark-mode.md
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
for file in .claude/active/*.md; do ./scripts/auto-sync.sh --with-commits "$file"; done

# Archive completed tasks
./scripts/archive-completed.sh
```

### 2. After Checking Checkbox

Run automatic updates after each checkbox is checked:

```bash
# Check checkbox (with automatic commit)
./scripts/check-task.sh --auto-commit file.md "Task name"

# Automatic update
./scripts/auto-sync.sh --with-commits file.md
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

# 2. Check checkbox (with automatic commit)
./scripts/check-task.sh --auto-commit .claude/active/feature-add-dark-mode.md "Create ThemeContext"

# 3. Run automatic updates (commits included)
./scripts/auto-sync.sh --with-commits .claude/active/feature-add-dark-mode.md

# 4. Record progress (optional)
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "ThemeContext created"

# 5. Sync again
./scripts/auto-sync.sh --with-commits .claude/active/feature-add-dark-mode.md
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
   - Automatic commit is made (can be skipped with --no-commit)

4. **Feature completion:**
   - **All** plans must be "(✅ COMPLETED)"
   - Acceptance Criteria are not checked
   - Automatic commit is made (can be skipped with --no-commit)

---

## 📊 Summary

| Script | What It Does | Automated? | Commit? |
|--------|--------------|------------|---------|
| `auto-update-status.sh` | Updates status based on checkbox state | ✅ Yes | ❌ |
| `auto-complete-phases.sh` | Marks completed plans | ✅ Yes | ✅ (optional) |
| `auto-complete-task.sh` | Marks feature as completed when all plans are done | ✅ Yes | ✅ (optional) |
| `auto-update-checkpoint.sh` | Updates checkpoint based on most active plan | ✅ Yes | ❌ |
| `auto-sync.sh` | Performs all automatic updates | ✅ Yes | ✅ (--with-commits) |
| `auto-commit-task.sh` | Commits when single task is completed | ✅ Yes | ✅ |
| `auto-commit-plan.sh` | Commits when plan is completed | ✅ Yes | ✅ |
| `auto-commit-feature.sh` | Commits when feature is completed | ✅ Yes | ✅ |

**All scripts:**
- ✅ Automated (no user intervention required)
- ✅ Platform compatible (macOS/Linux)
- ✅ Safe (only analyzes and updates)
- ✅ Provides informative output
- ✅ Automatic commit support

---

**Note:** These scripts don't check boxes, they only analyze current state and update. Use `check-task.sh` or Claude to check boxes.
