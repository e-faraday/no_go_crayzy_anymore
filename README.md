# No Go Crayzy Anymore

> **Markdown Driven Development Framework for Vibe Coding**  
> A lightweight, spec-driven workflow for building with AI — designed to prevent context rot by keeping implementation work in tact contexts.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 📋 Branch Structure

```
main          # Main branch (stable) v2.0.0
├
└── v3.0.0    # New version branch
```

### Version Information

- **main (v2.0.0)**: Stable production version
- **v3.0.0**: Development branch for next major release

---

## 🎯 Overview

**Stop managing chats. Start managing workflows.**

MDD (Markdown Driven Development) is a framework that helps you maintain context and continuity when working with AI coding assistants like Cursor. It prevents context rot by keeping all implementation work in structured markdown files that persist across sessions.

### Key Features

- ✅ **State Tracking**: Automatic state management across chat sessions
- ✅ **Bootstrap & Active Modes**: Automatic mode detection based on project state
- ✅ **Checkpoint System**: Human verification, decisions, and action points
- ✅ **Automation Scripts**: Complete workflow automation
- ✅ **CI/CD Integration**: Gold standard testing and validation
- ✅ **Pre-commit Hooks**: Automatic state validation

---

## 🚀 Quick Start

### For New Projects (First Time Setup)

**Important:** If you're setting up MDD in a **new project**, follow these steps:

```bash
# 1. Create your new project directory
mkdir ~/Projects/my-new-project
cd ~/Projects/my-new-project

# 2. Run setup script from MDD repository
# Option A: If you have MDD repository cloned locally
path/to/mdd-repo/scripts/setup.sh

# Option B: Clone MDD repository first, then run setup
git clone https://github.com/e-faraday/no_go_crayzy_anymore.git /tmp/mdd
/tmp/mdd/scripts/setup.sh
```

The `setup.sh` script will:
- ✅ Create directory structure (`.claude/`, `scripts/`)
- ✅ Copy all necessary scripts from MDD repository
- ✅ Copy templates
- ✅ Create `mdd` wrapper script
- ✅ Set up global `mdd` command (optional)

**Note:** If you already have a global `mdd` command configured, you still need to copy the `scripts/` directory to your project. The setup script handles this automatically.

### Installation (For Existing MDD Projects)

If you already have MDD set up in your project:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/e-faraday/no_go_crayzy_anymore.git
   cd no_go_crayzy_anymore
   ```

2. **Create your first task:**
   ```bash
   ./scripts/new-task.sh feature "Your First Feature"
   ```

### Basic Workflow

```bash
# Create a new feature
./scripts/new-task.sh feature "Add dark mode"

# Start working on it
./scripts/start-task.sh .claude/active/add-dark-mode.md "Started implementation"

# Update progress
./scripts/update-progress.sh .claude/active/add-dark-mode.md "Added theme toggle component"

# Mark as complete
./scripts/check-task.sh .claude/active/add-dark-mode.md "Dark mode feature"

# Archive completed tasks
./scripts/archive-completed.sh
```

---

## 📁 Project Structure

```
no_go_crayzy_anymore/
├── .claude/
│   ├── active/          # Active feature markdown files
│   ├── completed/       # Archived/completed features
│   ├── templates/       # Feature templates
│   ├── agents/          # Agent definitions (e.g. mdd-executor)
│   └── settings.json    # Cursor settings
├── scripts/             # Automation scripts
├── tests/               # Test suite
├── plans/               # Project plans
└── mdd-template/        # MDD template structure
```

---

## 🔄 Bootstrap vs Active Mode

MDD automatically detects your project state and adjusts behavior accordingly.

### Mode Detection

```bash
ls -1 .claude/active/*.md 2>/dev/null | grep -v .gitkeep | wc -l
# Output: 0 = Bootstrap, >0 = Active
```

### Bootstrap Mode (New Project)

**When:** No active features exist

**Behavior:**
- ✅ State tracking **NOT required** (no state exists yet)
- ✅ OK to make code changes without state updates
- ✅ OK to commit without validation
- ✅ OK to create first feature

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

---

## 🛠️ Automation Tools

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

### Available Commands

| Task            | mdd Command                     | Full Script Path                          |
| --------------- | ------------------------------- | ----------------------------------------- |
| Create task     | `mdd newtask feature "Name"`    | `./scripts/new-task.sh feature "Name"`    |
| Check task      | `mdd checktask <file> "Task"`   | `./scripts/check-task.sh <file> "Task"`   |
| Update progress | `mdd updateprogress <file>`     | `./scripts/update-progress.sh <file>`      |
| Start task      | `mdd starttask <file>`          | `./scripts/start-task.sh <file>`           |
| Archive         | `mdd archive`                   | `./scripts/archive-completed.sh`          |
| Auto sync       | `mdd autosync`                  | `./scripts/auto-sync.sh`                  |
| Daily summary   | `mdd dailysummary`              | `./scripts/daily-summary.sh`              |
| Set priority    | `mdd setpriority <file> high`   | `./scripts/set-priority.sh <file> high`   |
| Add tags        | `mdd addtags <file> tag1 tag2`  | `./scripts/add-tags.sh <file> tag1 tag2`  |

Run `mdd` without arguments to see all available commands.

### 🤖 Auto-commit (Optional)

| Task                 | mdd Command                  | Full Script Path                        |
| -------------------- | ---------------------------- | --------------------------------------- |
| Commit after task    | `mdd autocommittask <file>`  | `./scripts/auto-commit-task.sh <file>`  |
| Commit after plan    | `mdd autocommitplan <file>`  | `./scripts/auto-commit-plan.sh <file>`  |
| Commit after feature | `mdd autocommitfeature`      | `./scripts/auto-commit-feature.sh`      |

---

## 🎯 Checkpoints

MDD supports these checkpoint types:

- **`human-verify`**: You review/approve or report issues
- **`decision`**: You choose an option
- **`human-action`**: You perform a manual step (login, copy token, etc.)

**Important:** For `decision` and `human-action`, the **result is explicitly carried forward** in the continuation prompt so it won't get lost if execution resumes in a fresh context.

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

## 📚 Documentation

- `mdd-template/WORKFLOW.md` - Complete workflow guide
- `tests/README.md` - Test suite documentation
- `tests/TEST_PLAN_IMPLEMENTATION.md` - Test plan implementation summary

---

## 🔐 Permissions

For frictionless automation, configure `.claude/settings.json` (included in this repo) to allow common Bash/Git commands without constant approvals.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

**Made with ❤️ for developers who want to build better with AI**

---

## 📞 Support

For issues, questions, or contributions, please open an issue on [GitHub](https://github.com/e-faraday/no_go_crayzy_anymore/issues).

---

**Stop managing chats. Start managing workflows.**
