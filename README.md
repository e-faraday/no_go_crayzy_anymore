# No Go Crayzy Anymore

> **Markdown Driven Development Framework for Vibe Coding**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)](https://github.com/e-faraday/no_go_crayzy_anymore)

---

## What is MDD?

**Stop managing chats. Start managing workflows.**

MDD (Markdown Driven Development) is a framework that helps you maintain context and continuity when working with AI coding assistants like Cursor. It solves the **context rot problem** - where AI assistants lose track of what you're building across chat sessions.

### The Problem

When working with AI coding assistants:
- Context gets lost between chat sessions
- You repeat the same explanations over and over
- Progress tracking is manual and error-prone
- No single source of truth for project state

### The Solution

MDD keeps all implementation work in **structured markdown files** that persist across sessions:

- **State Tracking**: Automatic state management across chat sessions
- **Mode Detection**: Bootstrap (new project) vs Active (existing features) modes
- **Checkpoint System**: Human verification, decisions, and action points
- **Automation Scripts**: Complete workflow automation via `mdd` commands
- **Version Compatibility**: Prevents data corruption when moving projects between machines

### Core Workflow

```
1. Create a feature task     →  mdd newtask feature "Add dark mode"
2. Work on implementation    →  AI assistant reads state from .claude/active/
3. Update progress           →  mdd updateprogress <file> "Added toggle"
4. Complete and archive      →  mdd checktask <file> && mdd archive
```

All state is stored in `.claude/` directory, making projects portable.

---

## Quick Start

### Installation

```bash
# Clone MDD to your home directory (one-time setup)
git clone https://github.com/e-faraday/no_go_crayzy_anymore.git ~/.mdd
```

### Setup New Project

```bash
# Navigate to your project
cd ~/Projects/my-project

# Run setup
~/.mdd/scripts/setup.sh
```

This creates:
- `.claude/` directory structure (state files)
- `.claude/.mdd-version` (version tracking)
- `mdd` wrapper script in project root

### Basic Usage

```bash
# Create a new feature
mdd newtask feature "Add user authentication"

# Start working on it
mdd starttask .claude/active/add-user-authentication.md "Started"

# Update progress as you work
mdd updateprogress .claude/active/add-user-authentication.md "Added login form"

# Mark as complete
mdd checktask .claude/active/add-user-authentication.md "Auth complete"

# Archive completed tasks
mdd archive
```

Run `mdd` without arguments to see all available commands.

---

## Project Structure

### In Your Project (Portable State)
```
your-project/
├── mdd                      # Wrapper script
└── .claude/
    ├── .mdd-version         # Version tracking (v3.0.0)
    ├── active/              # Active feature files
    ├── completed/           # Archived features
    ├── templates/           # Feature templates
    ├── decisions/           # Decision records
    └── agents/              # Agent definitions
```

### Global Scripts (Shared)
```
~/.mdd/
├── scripts/                 # All automation scripts
└── mdd                      # Global wrapper (optional)
```

**Key Point:** Only `.claude/` is in your project. Scripts are global, making projects portable.

---

## Bootstrap vs Active Mode

MDD automatically detects your project state:

| Mode | Condition | Behavior |
|------|-----------|----------|
| **Bootstrap** | No files in `.claude/active/` | State tracking NOT required |
| **Active** | Files exist in `.claude/active/` | State tracking MANDATORY |

In **Active Mode**, every code change should update the corresponding state file.

---

## Available Commands

| Command | Description |
|---------|-------------|
| `mdd newtask <type> "name"` | Create new task (feature, bug, refactor) |
| `mdd starttask <file>` | Start working on a task |
| `mdd updateprogress <file> "msg"` | Update progress |
| `mdd checktask <file>` | Mark task complete |
| `mdd archive` | Archive completed tasks |
| `mdd autosync` | Auto-sync all state |
| `mdd dailysummary` | Show daily summary |
| `mdd validatestate` | Validate state integrity |
| `mdd e2etest` | Run E2E tests |

---

## Version Compatibility (v3.0.0)

MDD tracks version compatibility to prevent data corruption:

```bash
# Version is stored in each project
cat .claude/.mdd-version
# → v3.0.0
```

**Rules:**
- Same major version: Compatible
- Different major version: **BLOCKING** (prevents execution)
- Override: `MDD_SKIP_VERSION_CHECK=1 mdd <command>`

---

## Testing

```bash
# Run E2E tests (50 tests)
./scripts/e2e-test.sh

# Run Active Mode tests (41 tests)
./scripts/test-active-mode.sh --all
```

---

## Documentation

- [Workflow Guide](mdd-template/WORKFLOW.md)
- [Test Documentation](tests/README.md)
- [Auto Scripts Guide](scripts/README-auto-scripts.md)

---

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/Amazing`)
3. Commit changes (`git commit -m 'Add Amazing'`)
4. Push to branch (`git push origin feature/Amazing`)
5. Open Pull Request

---

## License

MIT License - see LICENSE file for details.

---

## Changelog

### [3.0.0] - 2026-01-24

#### Version Compatibility & Global Scripts Architecture

**Added:**
- Automatic version tracking via `.claude/.mdd-version`
- `check-mdd-version.sh` for compatibility validation
- **BLOCKING** behavior for major version mismatches
- Override: `MDD_SKIP_VERSION_CHECK=1`
- Global scripts architecture (`~/.mdd/scripts/`)
- Projects now fully portable (only `.claude/` needed)

**Changed:**
- Scripts moved to global location
- `setup.sh` creates version file automatically
- `mdd` wrapper includes version checking

**Migration from v2.0.0:**
```bash
# Install global scripts
git clone https://github.com/e-faraday/no_go_crayzy_anymore.git ~/.mdd

# Update existing project
cd your-project
~/.mdd/scripts/setup.sh
```

---

### [2.0.0] - 2026-01-22

#### Gold Standard Implementation

**Added:**
- Git Hooks Integration (pre-commit, commit-msg)
- E2E Test Suite (50 tests)
- Active Mode Test Suite (41 tests)
- CI/CD with GitHub Actions
- Conventional Commits enforcement
- Environment Parity verification

**Statistics:**
- Total Tests: 91 (100% pass rate)
- New Scripts: 6
- CI/CD Workflows: 4

**Migration from v1.0.0:**
```bash
./mdd installhooks
./mdd verifyenvparity
./mdd e2etest
```

---

### [1.0.0] - 2026-01-17

#### Initial Release

- Core MDD workflow scripts
- Task management (create, check, archive)
- Bootstrap and Active Mode support
- Feature templates
- Progress tracking and checkpoint system
- Cursor rules for memory management

---

## Support

For issues or questions: [GitHub Issues](https://github.com/e-faraday/no_go_crayzy_anymore/issues)

---

**Stop managing chats. Start managing workflows.**
