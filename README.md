<div align="center">

# 🚀 Cursor No Go Crazy Anymore (MDD)

**The AI Workflow Engine for Cursor**

*Standardize your process. Persist your state. Automate your progress.*

[![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](LICENSE)

<br>

**"Fresh Chat is the solution for performance, MDD is the solution for continuity."**
<br>
*A script-driven framework to manage high-level AI tasks across multiple chat sessions.*

</div>

---

## 🎯 Why MDD?

**Fresh Chat solves performance. MDD solves continuity.**

Cursor's **Fresh Chat (Shift+Cmd+L)** feature solves performance issues, but creates **State Loss**:

* 🧠 **Forgetfulness:** AI forgets what stage the project is at.
* 📉 **Tracking Difficulty:** Information about which tasks are done and which remain is buried in chat history.
* 🛠️ **Loading Cost:** Reloading context into each new chat wastes time.

**MDD (Markdown Driven Development)** fills this gap by managing the process like a "State Machine":

- 📝 **Workflow Management:** Standardized process (define → execute → checkpoint)
- 🔄 **State Persistence:** Progress is persistent in markdown file (not affected by chat resets)
- 📊 **Traceability:** Every step has a record and a corresponding commit

---

## 👥 Who This Is For

- ✅ You want a simple workflow: **describe → plan → execute → checkpoint → repeat**
- ✅ You want **traceable progress** and **atomic commits**
- ✅ You use **Cursor** and want **workflow continuity** and **traceability** across multiple chat sessions
- ✅ You want **state persistence** - your progress survives chat resets

---

## 🚀 Getting Started

### Option A: Use the template inside your project (recommended)

Copy the template contents into your target repo:

```bash
cp -R mdd-template/. /path/to/your-project/
cd /path/to/your-project
./scripts/setup.sh
```

**After setup, you can use MDD commands in two ways:**

#### Method 1: Using `mdd` wrapper (shorter commands)

```bash
# Short commands
mdd newtask feature "Add dark mode"
mdd checktask .claude/active/feature-x.md "Task 1"
mdd autosync
mdd archive
```

**Note:** `setup.sh` automatically creates a symlink in `~/bin/mdd` for global access. If `~/bin` is in your PATH, you can use `mdd` from anywhere. Otherwise, use `./mdd` from the project root.

#### Method 2: Using full script paths (always works)

```bash
# Full script paths
./scripts/new-task.sh feature "Add dark mode"
./scripts/check-task.sh .claude/active/feature-x.md "Task 1"
./scripts/auto-sync.sh
./scripts/archive-completed.sh
```

**Both methods work identically - choose what's convenient for you!**

### Option B: Use this repo as-is (sandbox)

```bash
cd mdd-test
./scripts/setup.sh
# Now you can use: mdd newtask feature "Add dark mode"
# Or: ./scripts/new-task.sh feature "Add dark mode"
```

### 🔗 Optional: Global `mdd` Command Setup

If you want to use `mdd` command from any directory (not just the project root):

1. **Automatic (during setup):** `setup.sh` will offer to create a symlink in `~/bin/` and add it to your PATH.

2. **Manual setup:**
   ```bash
   # Create ~/bin directory
   mkdir -p ~/bin
   
   # Create symlink
   ln -s /path/to/mdd-test/mdd ~/bin/mdd
   
   # Add to PATH (~/.zshrc or ~/.bashrc)
   echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **Verify:**
   ```bash
   which mdd
   # Should show: ~/bin/mdd
   
   # Test from any directory
   cd /any/project
   mdd newtask feature "Test"
   ```

**Note:** If you prefer not to set up the symlink, you can always use `./mdd` from the project root or use full script paths like `./scripts/new-task.sh`.

---

## 🛠️ The Solution: "Cockpit Mode" Workflow

MDD transforms Cursor usage from a "chat" into a disciplined **Workflow**.

### The Layout Strategy
* **Left Panel (Pinned):** `feature.md` — Your process management file (Single Source of Truth).
* **Right Panel:** Your code editor.
* **Terminal:** Your MDD scripts (Process triggers).

### The Continuous Workflow Loop

1.  **📝 Define (`mdd newtask`):**
    Break the work into atomic parts. Your plan file becomes AI's "External Memory".

2.  **✨ Execute (Fresh Context):**
    Start **Fresh Chat (Shift+Cmd+L)** for each plan step.
    * **Action:** Tell the chat `@feature.md Implement Plan 1.2`.
    * **Result:** AI focuses only on that moment, doesn't carry noise from previous chats, but knows where it is in the plan.

3.  **✅ Checkpoint (`mdd checktask`):**
    Seal it from the terminal when the step is done.
    * Your markdown file is updated (`[x]`).
    * Your git commit is automatically created.
    * **State becomes persistent.** Now the next Fresh Chat knows exactly where it left off.

### 💡 Why This Changes Your Workflow

* **Atomic Progress:** Cursor only writes code; MDD manages which goal that code serves.
* **Traceability:** Every step has a record (feature.md) and a corresponding commit.
* **Context Persistence:** Even if you reset the chat 100 times, when you say `@feature.md`, AI has 100% awareness of the current workflow.

---

## 📦 Create a Feature

```bash
# Method 1: Using mdd wrapper (shorter)
mdd newtask feature "Add dark mode"

# Method 2: Using full script path (always works)
./scripts/new-task.sh feature "Add dark mode"
```

This creates a feature file under:

- `.claude/active/feature-add-dark-mode.md`

Fill in:

- 🎯 Goal
- 🚫 Scope Guard (in/out of scope)
- 📊 Implementation Plans (2–3 tasks per plan)
- ✅ Acceptance Criteria

---

## ⚡ Execute a Plan

**Note:** Claude Code users can use the Task tool/subagent pattern; see `.claude/agents/mdd-executor.md` for details.

### 🖥️ Cursor IDE (Fresh Chat Pattern)

Use **Fresh Chat (Shift+Cmd+L)** for each plan to get fresh context while maintaining workflow continuity:

```text
# Chat 1: Plan 1
@.claude/active/feature-add-dark-mode.md
Help me implement Plan 1: Setup

# Chat 2: Plan 2 (NEW CHAT)
@.claude/active/feature-add-dark-mode.md
Help me implement Plan 2: Implementation
```

**Checkpoint rule in Cursor:** if you hit a checkpoint, **stay in the same chat** until the checkpoint is resolved; only then start a new chat for the next plan.

---

## 🤔 Cursor Chat vs Claude Code

### 🖥️ Cursor Chat (Designed for This Project) ✅

**Usage:**
```
Shift+Cmd+L → @file → prompt → Enter
For new plan: Shift+Cmd+L again (fresh chat)
```

**Advantages:**
- ✅ Visual editor
- ✅ Tab completion
- ✅ @Codebase support
- ✅ Fresh Chat for performance
- ✅ MDD for workflow continuity

**Note:**
- Fresh Chat handles performance (clears context)
- MDD handles continuity (preserves state in markdown)

### 💻 Claude Code Terminal

**Usage:**
```bash
claude
> @file prompt
```

**Advantages:**
- ✅ Automatic subagent
- ✅ Terminal automation

**Disadvantage:**
- ⚠️ No visual editor

---

## 🔧 How It Works

### 📁 Core Files (What Persists)

| File/Folder | Purpose |
|---|---|
| `.claude/active/` | Active feature markdown files |
| `.claude/completed/` | Archived/completed features |
| `.claude/templates/` | Feature templates |
| `.claude/agents/` | Agent definitions (e.g. `mdd-executor`) |
| `scripts/` | Automation scripts (create, update, commit, archive) |

### 🎯 Checkpoints

MDD supports these checkpoint types:

- `human-verify`: you review/approve or report issues
- `decision`: you choose an option
- `human-action`: you perform a manual step (login, copy token, etc.)

**Important:** for `decision` and `human-action`, the **result is explicitly carried forward** in the continuation prompt so it won't get lost if execution resumes in a fresh context.

---

## 🔄 Bootstrap vs Active Mode

MDD automatically detects your project state and adjusts behavior accordingly.

### Mode Detection

MDD checks for active features to determine the current mode:

```bash
ls -1 .claude/active/*.md 2>/dev/null | grep -v .gitkeep | wc -l
# Output: 0 = Bootstrap, >0 = Active
```

### Bootstrap Mode (New Project)

**When:** No active features exist (`.claude/active/` is empty or only contains `.gitkeep`)

**Behavior:**
- ✅ State tracking **NOT required** (no state exists yet)
- ✅ OK to make code changes without state updates
- ✅ OK to commit without validation
- ✅ OK to create first feature

**To start:**
```bash
./scripts/new-task.sh feature "Your First Feature"
```

**After first feature created:** Project automatically switches to Active Mode.

### Active Mode (Existing Project)

**When:** Active features exist in `.claude/active/`

**Behavior:**
- ✅ State tracking **MANDATORY**
- ✅ Every code change must update state file
- ✅ Fresh Chat auto-loads current state
- ✅ Pre-commit hook validates state updates

**State update required:**
```bash
# After code changes, update state
./scripts/auto-sync.sh .claude/active/your-feature.md
```

**Validation:**
```bash
# Check if state is up to date
./scripts/validate-state.sh
```

### Mode Transition

**Bootstrap → Active:**
- Happens automatically when first feature is created
- State tracking becomes mandatory
- Validation scripts start enforcing rules

**Active → Bootstrap:**
- Rare, only when all features are archived
- Happens automatically when `.claude/active/` becomes empty

### Why This Matters

**Bootstrap Mode:**
- Prevents unnecessary warnings in new projects
- Allows you to set up project structure first
- No state discipline until you're ready

**Active Mode:**
- Ensures continuity across Fresh Chat sessions
- Prevents context rot
- Maintains workflow integrity

**Check current mode:**
```bash
# Quick check
ls -1 .claude/active/*.md 2>/dev/null | grep -v .gitkeep | wc -l

# Detailed view
./scripts/daily-summary.sh
```

---

## 📦 Automation Tools (The Engine)

These scripts automate your workflow discipline with Cursor:

| Script | Workflow Role |
|---|---|
| `scripts/new-task.sh` | **Task Initiation:** Standardizes project scope and plan. |
| `scripts/check-task.sh` | **Status Update:** Seals completed work, updates feature.md. |
| `scripts/update-progress.sh` | **Context Addition:** Adds notes and intermediate logs to the plan. |
| `scripts/archive-completed.sh` | **Cleanup:** Archives completed processes, maintains your focus. |

You can use scripts in two ways:

### Method 1: `mdd` Wrapper (Shorter Commands)

```bash
# Core workflow
mdd newtask feature "Add dark mode"
mdd checktask <file> "Task name"
mdd updateprogress <file> "Progress message"
mdd starttask <file> "Started message"
mdd archive

# Automation
mdd autosync
mdd autocompletetask <file>
mdd autocompletephases <file>
mdd autoupdatestatus <file>

# Utilities
mdd setpriority <file> high
mdd addtags <file> frontend ui
mdd dailysummary
mdd syncall
```

**Note:** Requires `./mdd` in project root, or `mdd` in PATH (if symlink is set up).

### Method 2: Full Script Paths (Always Works)

```bash
# Core workflow
./scripts/new-task.sh feature "Add dark mode"
./scripts/check-task.sh <file> "Task name"
./scripts/update-progress.sh <file> "Progress message"
./scripts/start-task.sh <file> "Started message"
./scripts/archive-completed.sh

# Automation
./scripts/auto-sync.sh
./scripts/auto-complete-task.sh <file>
./scripts/auto-complete-phases.sh <file>
./scripts/auto-update-status.sh <file>

# Utilities
./scripts/set-priority.sh <file> high
./scripts/add-tags.sh <file> frontend ui
./scripts/daily-summary.sh
./scripts/sync-all-tasks.sh
```

**Both methods are equivalent - use whichever you prefer!**

### Available Commands

| Task | `mdd` Command | Full Script Path |
|---|---|---|
| Create task | `mdd newtask feature "Name"` | `./scripts/new-task.sh feature "Name"` |
| Check task | `mdd checktask <file> "Task"` | `./scripts/check-task.sh <file> "Task"` |
| Update progress | `mdd updateprogress <file> "Msg"` | `./scripts/update-progress.sh <file> "Msg"` |
| Start task | `mdd starttask <file> "Msg"` | `./scripts/start-task.sh <file> "Msg"` |
| Archive | `mdd archive` | `./scripts/archive-completed.sh` |
| Auto sync | `mdd autosync` | `./scripts/auto-sync.sh` |
| Daily summary | `mdd dailysummary` | `./scripts/daily-summary.sh` |
| Set priority | `mdd setpriority <file> high` | `./scripts/set-priority.sh <file> high` |
| Add tags | `mdd addtags <file> tag1 tag2` | `./scripts/add-tags.sh <file> tag1 tag2` |

Run `mdd` without arguments to see all available commands.

### 🤖 Auto-commit (Optional)

| Task | `mdd` Command | Full Script Path |
|---|---|---|
| Commit after task | `mdd autocommittask <file>` | `./scripts/auto-commit-task.sh <file>` |
| Commit after plan | `mdd autocommitplan <file>` | `./scripts/auto-commit-plan.sh <file>` |
| Commit after feature | `mdd autocommitfeature <file>` | `./scripts/auto-commit-feature.sh <file>` |

### 🔐 Permissions

For frictionless automation, configure `.claude/settings.json` (included in this repo) to allow common Bash/Git commands without constant approvals.

---

## 🧪 Testing

### Active Mode Test Suite

Comprehensive test suite for Active Mode functionality with **41 test cases** across **10 categories**:

```bash
# Run all tests
./scripts/test-active-mode.sh --all

# Run specific category
./scripts/test-active-mode.sh --category detection
./scripts/test-active-mode.sh --category enforcement
./scripts/test-active-mode.sh --category validation
```

**Test Categories:**
1. Active Mode Detection
2. State Update Enforcement
3. validate-state.sh Script Tests
4. Pre-Commit Hook Tests
5. Fresh Chat Auto-Load Tests
6. auto-sync.sh Script Tests
7. Edge Cases
8. Integration Tests
9. Performance Tests
10. Error Handling

**CI/CD Integration:**
- Tests run automatically on push/PR
- Daily scheduled tests at 2 AM UTC
- GitHub Actions workflows in `.github/workflows/`

See `tests/README.md` for complete test documentation.

---

## 📚 Docs

- `mdd-template/WORKFLOW.md` - Complete workflow guide
- `tests/README.md` - Test suite documentation
- `tests/TEST_PLAN_IMPLEMENTATION.md` - Test plan implementation summary

---

---

<div align="center">

**Stop managing chats. Start managing workflows.**

</div>

---

**Made with ❤️ for developers who want to build better with AI**
