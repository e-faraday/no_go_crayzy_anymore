# MDD Workflow - Manual and Automated Steps

## Overview

This documentation covers all steps from creating a feature to archiving it. Manual tasks (by user or Claude) and automated tasks (by scripts) are clearly separated.

**Hierarchy:**
- **Feature** - Top-level unit (large feature/module)
- **Plan** - Execution unit (2-3 tasks)
- **Task** - Atomic work unit

## Workflow Flow

### Phase 1: Task Creation and Planning

#### 1.1 Task Creation (Automated)

```bash
./scripts/new-task.sh feature "Add dark mode"
```

**What it does:**
- Creates task file from template
- Fills frontmatter (type, priority, status, created date)
- File: `.claude/active/feature-add-dark-mode.md`

#### 1.2 Filling Task Details (Manual - Claude or Manual)

**Sections that need manual editing:**
- **Goal:** What are we doing and why?
- **Scope Guard:** IN SCOPE and OUT OF SCOPE lists
- **Implementation Plans:** Plans and tasks in each plan (checkboxes)
- **Acceptance Criteria:** Criteria (checkboxes)

**Filling with Claude:**
```
@.claude/active/feature-add-dark-mode.md 
Help me fill in the Goal, Scope Guard, Implementation Plans, and Acceptance Criteria for this feature.
```

**Manual filling:**
- Open file in editor and fill sections

#### 1.3 Setting Priority and Tags (Parametric - Manual)

```bash
# Set priority
./scripts/set-priority.sh .claude/active/feature-add-dark-mode.md high

# Add tags
./scripts/add-tags.sh .claude/active/feature-add-dark-mode.md ui theme frontend
```

### Phase 2: Starting Task

#### 2.1 Starting Task (Parametric - Manual)

```bash
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting Plan 1: Setup"
```

**What it does:**
- Sets status to `in-progress`
- Adds entry to Progress Log
- Adds date/time

### Phase 3: Implementation

#### 3.1 Working with Claude (Manual)

```
@.claude/active/feature-add-dark-mode.md Help me implement Plan 1
```

#### 3.2 Checking Tasks (Parametric - Manual)

If Claude didn't check the boxes:

**By task text:**
```bash
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Create ThemeContext"
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Add localStorage hook"
```

**By task number (Plan.Task format):**
```bash
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "1.1"  # Plan 1, Task 1
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "1.2"  # Plan 1, Task 2
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "2.1"  # Plan 2, Task 1
```

**Note:** Task number format is `PlanNumber.TaskNumber` (e.g., `1.1`, `1.2`, `2.1`). Task numbers start from 1 within each plan.

#### 3.3 Recording Progress (Parametric - Manual)

**Normal entry:**
```bash
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "ThemeContext created and tested"
```

**With task number (optional):**
```bash
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "Task completed" "1.1"
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "Bug fixed" "2.3"
```

**Note:** If task number is provided, progress log entry is labeled as `[Task 1.1]` format.

#### 3.4 Automatic Updates (Automated)

After each checkbox is checked or progress is recorded:

```bash
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md
```

**What it does:**
1. Checks plans, marks completed ones
2. Updates status (based on checkbox state)
3. Updates checkpoint (based on most active plan)
4. Marks feature as completed if all plans are done

#### 3.5 Context Management - Fresh Context Pattern (Recommended)

Working in fresh AI context for each plan prevents context rot and ensures optimal performance. Two approaches are available:

##### 3.5.1 Claude Code - Task Tool with Subagent Orchestration

**Requirements:** Claude Code + Task tool access

```markdown
@feature-dark-mode.md Help me implement Plan 1

[You work as orchestrator]
1. Parse Plan 1
2. Spawn subagent with Task tool:
   Task(
     prompt=plan-execution-prompt.md (filled),
     subagent_type="mdd-executor",
     description="Execute Plan 1: Setup"
   )
3. Check results when subagent returns
4. Verify commits
```

**Advantages:**
- Each plan runs in fresh 200k token context
- Main context stays light (30-40% usage)
- Context rot prevented
- Each plan runs at optimal performance
- Automatic orchestration

**Checkpoint Handling:**

When subagent hits a checkpoint:
1. Read checkpoint message
2. Take required action (verify, decision, action)
3. **Prepare decision/action result:**
   - Decision checkpoint: Prepare selected option and details
   - Human-action checkpoint: Prepare action result and verification
4. Spawn fresh agent with continuation template (add decision/action result to prompt)

##### 3.5.2 Cursor - Manual Context Management (Fresh Chat Pattern)

**Requirements:** Cursor IDE (no Task tool)

Since Cursor doesn't have Task tool, you can provide fresh context by starting a new chat for each plan:

**For Plan 1:**
```
[Start new chat]
@.claude/active/feature-dark-mode.md Help me implement Plan 1: Setup
```

**For Plan 2:**
```
[START NEW chat - don't close previous chat, open new chat]
@.claude/active/feature-dark-mode.md Help me implement Plan 2: Implementation
```

**For Plan 3:**
```
[START NEW chat]
@.claude/active/feature-dark-mode.md Help me implement Plan 3: Testing
```

**Advantages:**
- Each plan starts in fresh chat (context rot prevented)
- Works in Cursor (no Task tool required)
- Manual control

**Disadvantages:**
- Need to manually start new chat for each plan
- No orchestration (each chat is independent)
- Checkpoint handling is more difficult

**Best Practices:**
1. Start new chat for each plan
2. Reference feature file with `@` in each chat
3. Continue in same chat at checkpoints (don't start new chat)
4. Keep feature file updated in each chat

**Note:** 
- If using Claude Code, prefer 3.5.1 (Task tool)
- If using Cursor, use 3.5.2 (Fresh Chat Pattern)
- Both approaches prevent context rot, but Task tool is more automatic and powerful

### Phase 4: Plan Completion

#### 4.1 Marking All Tasks in Plan (Manual)

```bash
# Mark all tasks in Plan 1
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Task 1"
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Task 2"
# ... other tasks
```

#### 4.2 Automatic Plan Completion (Automated)

```bash
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md
```

**Result:** Plan header gets "(✅ COMPLETED)" added

#### 4.3 Moving to New Plan (Parametric - Manual)

```bash
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting Plan 2: UI Components"
```

### Phase 5: Feature Completion

#### 5.1 Completing All Plans (Manual)

Mark all checkboxes in all plans

#### 5.2 Automatic Feature Completion (Automated)

```bash
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md
```

**Result:**
- Status becomes `completed`
- Current Checkpoint becomes "✅ All plans completed"
- Final entry added to Progress Log

### Phase 6: Git Operations

#### 6.1 Automatic Commit (Recommended)

MDD offers automatic commit support. Automatic commits can be made when each task, plan, and feature is completed.

**Setup:**

1. Create `.claude/settings.json` file (available in template):
```json
{
  "permissions": {
    "allow": [
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git status:*)",
      ...
    ]
  }
}
```

2. Run Claude Code with `--dangerously-skip-permissions` flag:
```bash
claude --dangerously-skip-permissions
```

**Automatic Commit Scenarios:**

**When Task (Checkbox) is completed:**
```bash
# Check checkbox with automatic commit
./scripts/check-task.sh --auto-commit .claude/active/feature-add-dark-mode.md "Create ThemeContext"

# Or with environment variable
AUTO_COMMIT=true ./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Create ThemeContext"
```

**When Plan is completed:**
```bash
# Complete plan with automatic commit (default)
./scripts/auto-complete-phases.sh .claude/active/feature-add-dark-mode.md

# Skip commit
./scripts/auto-complete-phases.sh --no-commit .claude/active/feature-add-dark-mode.md
```

**When Feature is completed:**
```bash
# Complete feature with automatic commit (default)
./scripts/auto-complete-task.sh .claude/active/feature-add-dark-mode.md

# Skip commit
./scripts/auto-complete-task.sh --no-commit .claude/active/feature-add-dark-mode.md
```

**Bulk sync with commits:**
```bash
# All automatic updates + commits
./scripts/auto-sync.sh --with-commits .claude/active/feature-add-dark-mode.md
```

#### 6.2 Manual Git Commit (Alternative)

If you don't want to use automatic commits:

```bash
git add .claude/active/feature-add-dark-mode.md
git commit -m "feat: Add dark mode feature"
```

**Commit Formats:**

- **Task commit:** `feat({feature-slug}): {task-name}`
- **Plan commit:** `docs({feature-slug}): complete Plan {N}: {plan-name}`
- **Feature commit:** `docs({feature-slug}): complete feature`

### Phase 7: Archiving

#### 7.1 Archiving Completed Tasks (Automated)

```bash
./scripts/archive-completed.sh
```

**What it does:**
- Finds all tasks with `status: completed`
- Moves them to `.claude/completed/YYYY-MM/` directory
- Uses `git mv` if tracked in git

## Daily Routine Scenarios

### Morning Routine

```bash
# 1. View daily summary
./scripts/daily-summary.sh

# 2. Start task you'll work on today
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting work today"
```

### During the Day

```bash
# Check checkbox (with automatic commit)
# By task text:
./scripts/check-task.sh --auto-commit .claude/active/feature-add-dark-mode.md "Task name"
# By task number:
./scripts/check-task.sh --auto-commit .claude/active/feature-add-dark-mode.md "1.1"

# Record progress
# Normal entry:
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "Progress message"
# With task number:
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "Task completed" "1.1"

# Run automatic updates (commits included)
./scripts/auto-sync.sh --with-commits .claude/active/feature-add-dark-mode.md
```

### Evening Routine

```bash
# 1. Synchronize all tasks
./scripts/sync-all-tasks.sh

# 2. Archive completed tasks
./scripts/archive-completed.sh

# 3. Check daily summary again
./scripts/daily-summary.sh
```

## Manual vs Automated Summary

### Manual Tasks (by User or Claude)

1. ✅ Filling feature details (Goal, Scope Guard, Plans, Acceptance Criteria)
2. ✅ Setting priority and tags (with parametric scripts)
3. ✅ Starting feature (with start-task.sh)
4. ✅ Implementation (working with Claude)
5. ✅ Checking boxes (with check-task.sh or Claude)
6. ✅ Recording progress (with update-progress.sh)
7. ✅ Git commit (automatic or manual - optional)

### Automated Tasks (by Scripts)

1. ✅ Feature creation (new-task.sh)
2. ✅ Status update (auto-update-status.sh)
3. ✅ Plan completion marking (auto-complete-phases.sh)
4. ✅ Feature completion (auto-complete-task.sh)
5. ✅ Checkpoint update (auto-update-checkpoint.sh)
6. ✅ All automatic updates (auto-sync.sh)
7. ✅ Bulk synchronization (sync-all-tasks.sh)
8. ✅ Archiving (archive-completed.sh)
9. ✅ **Automatic Git commits (auto-commit-task.sh, auto-commit-plan.sh, auto-commit-feature.sh)**

## Complete Workflow Example

```bash
# 1. Create task (Automated)
./scripts/new-task.sh feature "Add dark mode"

# 2. Fill task details (Manual - with Claude)
# @.claude/active/feature-add-dark-mode.md Help me fill in the details

# 3. Set priority and tags (Parametric)
./scripts/set-priority.sh .claude/active/feature-add-dark-mode.md high
./scripts/add-tags.sh .claude/active/feature-add-dark-mode.md ui theme

# 4. Start feature (Parametric)
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting Plan 1"

# 5. Implementation (Manual - with Claude)
# @.claude/active/feature-add-dark-mode.md Help me implement Plan 1

# 6. Check checkbox (With automatic commit)
# By task text:
./scripts/check-task.sh --auto-commit .claude/active/feature-add-dark-mode.md "Create ThemeContext"
# By task number:
./scripts/check-task.sh --auto-commit .claude/active/feature-add-dark-mode.md "1.1"

# 7. Record progress (Parametric)
# Normal entry:
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "ThemeContext created"
# With task number:
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "ThemeContext created" "1.1"

# 8. Run automatic updates (Automated - commits included)
./scripts/auto-sync.sh --with-commits .claude/active/feature-add-dark-mode.md

# 9. Sync again when plan is completed (Automated - plan commit included)
./scripts/auto-sync.sh --with-commits .claude/active/feature-add-dark-mode.md

# 10. Automatic feature completion + commit when all plans are done (Automated)
./scripts/auto-sync.sh --with-commits .claude/active/feature-add-dark-mode.md

# 11. Archive (Automated)
./scripts/archive-completed.sh

# Note: Git commits were made automatically:
# - For each task: feat({slug}): {task-name}
# - For each plan: docs({slug}): complete Plan {N}
# - For feature: docs({slug}): complete feature
```

## Important Notes

1. **auto-sync.sh** should be run after each checkbox is checked or progress is recorded
2. **sync-all-tasks.sh** is used to bulk synchronize all tasks at end of day
3. **archive-completed.sh** only archives tasks with `status: completed`
4. Checkbox checking can be done manually or with Claude
5. Feature details (Goal, Scope Guard, Plans) must be filled manually

## Script References

### Parametric Scripts (Manual Control)
- `check-task.sh` - Checkbox checking
- `update-progress.sh` - Adding entry to Progress Log
- `set-priority.sh` - Changing priority
- `add-tags.sh` - Adding/editing tags
- `start-task.sh` - Starting task
- `help-parametrik.sh` - Usage guide for all parametric scripts

### Automated Scripts
- `auto-sync.sh` - Performs all automatic updates
- `auto-update-status.sh` - Updates status based on checkbox state
- `auto-complete-phases.sh` - Marks completed plans
- `auto-complete-task.sh` - Marks feature as completed
- `auto-update-checkpoint.sh` - Updates checkpoint
- `sync-all-tasks.sh` - Synchronizes all active features
- `archive-completed.sh` - Archives completed features

### Helper Scripts
- `new-task.sh` - Creating new feature
- `daily-summary.sh` - Viewing daily summary

## Detailed Documentation

- Parametric scripts: `scripts/README-parametrik-scripts.md`
- Automated scripts: `scripts/README-auto-scripts.md`
- Start task: `scripts/README-start-task.md`

## Quick Help

To see usage for all parametric scripts:

```bash
./scripts/help-parametrik.sh
```

This command shows parameters, examples, and usage information for all parametric scripts.
