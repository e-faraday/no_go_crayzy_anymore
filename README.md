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

### 🔄 Version Compatibility

MDD automatically tracks version compatibility between your project and the installed scripts. When you set up a project with `setup.sh`, it creates a `.claude/.mdd-version` file that records the MDD version used.

**Important:** If you move a project created with v3.0.0 to a new machine and install v4.0.0 scripts, MDD will detect the version mismatch and **block execution** to prevent data corruption:

```
⚠️  MDD Version Incompatibility Detected!

Project MDD Version: v3.0.0
Script MDD Version: v4.0.0

This project was created with v3.0.0, but v4.0.0 scripts are being used.

⚠️  Backward Incompatibility:
  v3 projects are NOT fully compatible with v2 scripts.
  v3 features may not be available in v2 scripts.
  Some commands may fail or show unexpected behavior.

Recommended Solutions:
  1. Use v3.0.0 scripts (RECOMMENDED):
     git clone -b v3.0.0 https://github.com/e-faraday/no_go_crayzy_anymore.git ~/.mdd
  2. Or migrate the project to be compatible with v4.0.0

❌ Command stopped: Major version incompatibility detected.
Override: MDD_SKIP_VERSION_CHECK=1 mdd <command>
```

**Version Compatibility Rules:**
- ✅ **Same major version** (e.g., v3.0.0 ↔ v3.1.0): Compatible, minor warnings may appear
- ⚠️ **Different major versions** (e.g., v3.0.0 ↔ v4.0.0): **BLOCKING** - Command execution stops to prevent data corruption
- ❌ **Backward incompatibility** (e.g., v3.0.0 project with v2.0.0 scripts): **NOT compatible** - v3.0.0 features won't work with v2.0.0 scripts
- ⚠️ **Forward incompatibility** (e.g., v2.0.0 project with v3.0.0 scripts): May work but some v3.0.0 features won't be available
- ℹ️ **No version file**: New projects or projects created before version tracking was added (non-blocking warning)

**Important Notes:**
- **v3.0.0 projects MUST NOT be used with v2.0.0 scripts**: v3.0.0 features don't exist in v2.0.0
- **v2.0.0 projects can work with v3.0.0 scripts**: But migration is recommended
- **Override option**: Use `MDD_SKIP_VERSION_CHECK=1` to bypass version check in emergency situations

#### 📄 Version File Mechanism

The `.claude/.mdd-version` file is the core of MDD's version tracking system:

**1. Creation:**
- Automatically created when you run `mdd setup` or `setup.sh`
- Version is detected from:
  1. Git tag (if MDD repo is on a tagged commit)
  2. Git branch name (if branch matches version pattern like `v3.0.0`)
  3. `VERSION` file in MDD repo (if git is not available)
  4. Default: `v3.0.0` (if none of the above)

**2. Location:**
```
your-project/
└── .claude/
    └── .mdd-version  ← Contains: "v3.0.0"
```

**3. Usage:**
- Every `mdd` command automatically checks version compatibility
- Compares project version (from `.claude/.mdd-version`) with script version (from `~/.mdd/scripts/` git repo)
- **Major version mismatch** → **BLOCKING** (command stops)
- **Minor/patch mismatch** → Warning (command continues)
- **No version file** → Warning (command continues, assumes new project)

**4. Example Flow:**
```bash
# 1. Setup new project
cd my-project
mdd setup
# → Creates .claude/.mdd-version with "v3.0.0"

# 2. Move project to another machine
# (copy .claude/ directory)

# 3. New machine has v4.0.0 scripts installed
mdd newtask feature "Test"
# → ⚠️  Version incompatibility detected!
# → ❌ Command stopped: Major version incompatibility
# → Solution: Install v3.0.0 scripts or migrate project
```

**5. Why It Matters:**
- **Data Integrity**: Prevents data corruption from version mismatches
- **Feature Compatibility**: Ensures features exist in the script version
- **Portability**: Projects can be safely moved between machines
- **Migration Guidance**: Helps users identify when migration is needed

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
path/to/mdd/scripts/setup.sh

# Option B: Clone MDD repository first, then run setup
git clone https://github.com/e-faraday/no_go_crayzy_anymore.git /tmp/mdd
cd ~/Projects/my-new-project
/tmp/mdd/scripts/setup.sh
```

The `setup.sh` script will:
- ✅ Create directory structure (`.claude/` only - scripts are global)
- ✅ Install global scripts to `~/.mdd/scripts/` (one-time setup)
- ✅ Copy templates to `.claude/templates/`
- ✅ Create `mdd` wrapper script in project root
- ✅ Set up global `mdd` command (optional)

**Important:** Scripts are now **global** (`~/.mdd/scripts/`). Only state files (`.claude/`) are stored in your project. This makes projects more portable - you only need to copy `.claude/` when moving projects.

### Installation (For Existing MDD Projects)

If you already have MDD set up in your project, you can use the global scripts directly:

```bash
# Make sure global scripts are installed
# (setup.sh does this automatically, or install manually:)
# git clone https://github.com/e-faraday/no_go_crayzy_anymore.git ~/.mdd

# Create your first task
mdd newtask feature "Your First Feature"
```

### Basic Workflow

```bash
# Create a new feature (uses global scripts)
mdd newtask feature "Add dark mode"

# Start working on it
mdd starttask .claude/active/add-dark-mode.md "Started implementation"

# Update progress
mdd updateprogress .claude/active/add-dark-mode.md "Added theme toggle component"

# Mark as complete
mdd checktask .claude/active/add-dark-mode.md "Dark mode feature"

# Archive completed tasks
mdd archive
```

**Note:** You can also use full script paths if needed: `~/.mdd/scripts/new-task.sh feature "Name"`

---

## 📁 Project Structure

### In Your Project (Portable State)
```
your-project/
└── .claude/
    ├── active/          # Active feature markdown files (state)
    ├── completed/       # Archived/completed features (state)
    ├── templates/       # Feature templates
    ├── decisions/       # Decision records (state)
    └── agents/          # Agent definitions (e.g. mdd-executor)
```

### Global (Shared Across All Projects)
```
~/.mdd/
├── scripts/             # Automation scripts (global)
└── mdd                  # Wrapper script (optional, can be in ~/bin/)
```

**Key Point:** Only `.claude/` is in your project. Scripts are global, making projects portable - just copy `.claude/` when moving projects!

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
