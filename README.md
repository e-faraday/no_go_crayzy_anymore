<div align="center">

# 🚀 Cursor No Go Crazy Anymore

**MDD - Markdown Driven Development**

*A lightweight, spec-driven workflow for building with AI — designed to prevent context rot by keeping implementation work in fresh contexts.*

[![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](LICENSE)

<br>

*"Stop context rot. Keep quality high. Build faster."*

<br>

</div>

---

## 🎯 Why MDD?

Long AI coding sessions degrade as the context window fills. MDD keeps quality stable by:

- 📝 **Keeping the "big picture" in markdown** (a feature file you can read/review)
- 🎯 **Executing in small plans** (2–3 tasks per plan)
- 🔄 **Using fresh contexts per plan** (Cursor: Fresh Chat Pattern)

---

## 👥 Who This Is For

- ✅ You want a simple workflow: **describe → plan → execute → checkpoint → repeat**
- ✅ You want **traceable progress** and **atomic commits**
- ✅ You use **Cursor** and still want to avoid context rot (without Task tool)

---

## 🚀 Getting Started

### Option A: Use the template inside your project (recommended)

Copy the template contents into your target repo:

```bash
cp -R mdd-template/. /path/to/your-project/
cd /path/to/your-project
./scripts/setup.sh
```

### Option B: Use this repo as-is (sandbox)

```bash
cd mdd-test
./scripts/setup.sh
```

---

## 📦 Create a Feature

```bash
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

Cursor doesn't have Task tool, so you "fake" subagents by using **a new chat per plan**:

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

## 📜 Scripts

### 🔨 Core Workflow

| Script | What it does |
|---|---|
| `scripts/setup.sh` | Create `.claude/` folders and make scripts executable |
| `scripts/new-task.sh` | Create a new `feature` / `bug` / `refactor` markdown file |
| `scripts/start-task.sh` | Mark a feature as started + append progress |
| `scripts/check-task.sh` | Check off a task (by name or by number like `1.1`) |
| `scripts/update-progress.sh` | Append a progress log entry (optional task number) |
| `scripts/archive-completed.sh` | Archive a completed feature |

### 🤖 Auto-commit (Optional)

| Script | When to use |
|---|---|
| `scripts/auto-commit-task.sh` | Commit after a task checkbox is completed |
| `scripts/auto-commit-plan.sh` | Commit when a plan completes |
| `scripts/auto-commit-feature.sh` | Commit when a feature completes |

### 🔐 Permissions

For frictionless automation, configure `.claude/settings.json` (included in this repo) to allow common Bash/Git commands without constant approvals.

---

## 📚 Docs

- `mdd-template/WORKFLOW.md` - Complete workflow guide

---

<div align="center">

**Stop context rot. Keep quality high. Build faster.**

Made with ❤️ for Cursor users

</div>
