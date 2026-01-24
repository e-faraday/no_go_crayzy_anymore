#!/bin/bash
# scripts/setup.sh
# Setup MDD structure for new project

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# PROJECT_ROOT should be the current working directory, not script's parent
PROJECT_ROOT="$(pwd)"

echo -e "${BLUE}🚀 Setting up MD-Driven Development...${NC}"
echo ""

# Create directory structure (only .claude/, scripts are global now)
echo "Creating directory structure..."
mkdir -p .claude/active
mkdir -p .claude/completed
mkdir -p .claude/templates
mkdir -p .claude/decisions

# Create .gitkeep files
touch .claude/active/.gitkeep
touch .claude/completed/.gitkeep
touch .claude/decisions/.gitkeep

# Create version file to track MDD version compatibility
echo "Creating MDD version file..."
MDD_VERSION_FILE=".claude/.mdd-version"

# Try to detect MDD version from git branch/tag or use default
if [ -d "$SCRIPT_DIR/../.git" ]; then
    # Try to get version from git branch or tag
    GIT_BRANCH=$(cd "$SCRIPT_DIR/.." && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    GIT_TAG=$(cd "$SCRIPT_DIR/.." && git describe --tags --exact-match HEAD 2>/dev/null || echo "")
    
    if [ -n "$GIT_TAG" ]; then
        MDD_VERSION="$GIT_TAG"
    elif [[ "$GIT_BRANCH" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        MDD_VERSION="$GIT_BRANCH"
    elif [[ "$GIT_BRANCH" =~ v([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        MDD_VERSION="v${BASH_REMATCH[1]}"
    else
        # Default to v3.0.0 if can't detect
        MDD_VERSION="v3.0.0"
    fi
else
    # Not in git repo, try to read from VERSION file if exists
    if [ -f "$SCRIPT_DIR/../VERSION" ]; then
        MDD_VERSION=$(cat "$SCRIPT_DIR/../VERSION" | tr -d ' \n')
    else
        # Default version
        MDD_VERSION="v3.0.0"
    fi
fi

# Write version to file
echo "$MDD_VERSION" > "$MDD_VERSION_FILE"
echo -e "${GREEN}✅ MDD version file created: $MDD_VERSION${NC}"

echo -e "${GREEN}✅ Directory structure created${NC}"
echo ""

# Setup global scripts if not already installed
GLOBAL_MDD_DIR="$HOME/.mdd"
GLOBAL_SCRIPTS_DIR="$GLOBAL_MDD_DIR/scripts"

if [ ! -d "$GLOBAL_SCRIPTS_DIR" ]; then
    echo "Setting up global MDD scripts..."
    echo "This is a one-time setup. Scripts will be installed to: $GLOBAL_SCRIPTS_DIR"
    echo ""
    
    # Create global MDD directory
    mkdir -p "$GLOBAL_SCRIPTS_DIR"
    
    # Copy scripts to global location
    if [ -d "$SCRIPT_DIR" ]; then
        cp "$SCRIPT_DIR"/*.sh "$GLOBAL_SCRIPTS_DIR/" 2>/dev/null || true
        chmod +x "$GLOBAL_SCRIPTS_DIR"/*.sh 2>/dev/null || true
        echo -e "${GREEN}✅ Global scripts installed to $GLOBAL_SCRIPTS_DIR${NC}"
    else
        echo -e "${YELLOW}⚠️  Warning: MDD scripts directory not found at $SCRIPT_DIR${NC}"
        echo "Please clone MDD repository to ~/.mdd or install scripts manually"
    fi
    echo ""
else
    echo -e "${BLUE}ℹ️  Global scripts already installed at $GLOBAL_SCRIPTS_DIR${NC}"
    echo ""
fi

# Copy .claude templates if they exist
echo "Copying templates..."
if [ -d "$SCRIPT_DIR/../.claude/templates" ]; then
    mkdir -p "$PROJECT_ROOT/.claude/templates"
    cp -r "$SCRIPT_DIR/../.claude/templates"/* "$PROJECT_ROOT/.claude/templates/" 2>/dev/null || true
    echo -e "${GREEN}✅ Templates copied${NC}"
elif [ -d "$SCRIPT_DIR/../mdd-template/.claude/templates" ]; then
    # Fallback to mdd-template directory
    mkdir -p "$PROJECT_ROOT/.claude/templates"
    cp -r "$SCRIPT_DIR/../mdd-template/.claude/templates"/* "$PROJECT_ROOT/.claude/templates/" 2>/dev/null || true
    echo -e "${GREEN}✅ Templates copied from template${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: Templates directory not found${NC}"
fi
echo ""

# Create mdd wrapper script (uses global scripts)
echo "Creating mdd wrapper script..."
if [ -f "$SCRIPT_DIR/../mdd" ]; then
    # Copy from MDD repository root if exists
    cp "$SCRIPT_DIR/../mdd" "$PROJECT_ROOT/mdd" 2>/dev/null || true
    chmod +x "$PROJECT_ROOT/mdd" 2>/dev/null || true
    echo -e "${GREEN}✅ mdd wrapper script created${NC}"
elif [ -f "$PROJECT_ROOT/mdd" ]; then
    # File already exists, just make it executable
    chmod +x "$PROJECT_ROOT/mdd" 2>/dev/null || true
    echo -e "${GREEN}✅ mdd wrapper script found and made executable${NC}"
else
    # Create mdd wrapper that uses global scripts
    cat > "$PROJECT_ROOT/mdd" << 'MDD_EOF'
#!/bin/bash
# mdd - MDD Script Wrapper (Bash + Zsh compatible)
# Usage: mdd <command> [args...]

# Get script directory (bash + zsh compatible, handles symlinks)
if [[ -n "$ZSH_VERSION" ]]; then
    # Zsh - resolve symlink if needed
    SCRIPT_FILE="${(%):-%x}"
    # Resolve symlink to get actual file path
    if command -v readlink >/dev/null 2>&1; then
        # Try readlink -f first (GNU), fallback to readlink (BSD)
        RESOLVED=$(readlink -f "$SCRIPT_FILE" 2>/dev/null || readlink "$SCRIPT_FILE" 2>/dev/null || echo "$SCRIPT_FILE")
        if [ -n "$RESOLVED" ] && [ "$RESOLVED" != "$SCRIPT_FILE" ]; then
            SCRIPT_FILE="$RESOLVED"
        fi
    fi
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_FILE")" && pwd)"
elif [[ -n "$BASH_VERSION" ]]; then
    # Bash - resolve symlink if needed
    SCRIPT_FILE="${BASH_SOURCE[0]}"
    if command -v readlink >/dev/null 2>&1; then
        RESOLVED=$(readlink -f "$SCRIPT_FILE" 2>/dev/null || readlink "$SCRIPT_FILE" 2>/dev/null || echo "$SCRIPT_FILE")
        if [ -n "$RESOLVED" ] && [ "$RESOLVED" != "$SCRIPT_FILE" ]; then
            SCRIPT_FILE="$RESOLVED"
        fi
    fi
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_FILE")" && pwd)"
else
    # Fallback
    SCRIPT_FILE="$0"
    if command -v readlink >/dev/null 2>&1; then
        RESOLVED=$(readlink -f "$SCRIPT_FILE" 2>/dev/null || readlink "$SCRIPT_FILE" 2>/dev/null || echo "$SCRIPT_FILE")
        if [ -n "$RESOLVED" ] && [ "$RESOLVED" != "$SCRIPT_FILE" ]; then
            SCRIPT_FILE="$RESOLVED"
        fi
    fi
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_FILE")" && pwd)"
fi

# Try to find scripts directory
# Priority 1: Global MDD scripts (~/.mdd/scripts/)
# Priority 2: Project-local scripts (for backward compatibility)
GLOBAL_SCRIPTS_DIR="$HOME/.mdd/scripts"
PROJECT_SCRIPTS_DIR="$SCRIPT_DIR/scripts"

if [ -d "$GLOBAL_SCRIPTS_DIR" ]; then
    SCRIPTS_DIR="$GLOBAL_SCRIPTS_DIR"
elif [ -d "$PROJECT_SCRIPTS_DIR" ]; then
    # Fallback to project-local scripts (backward compatibility)
    SCRIPTS_DIR="$PROJECT_SCRIPTS_DIR"
else
    echo "❌ Error: MDD scripts directory not found"
    echo ""
    echo "Please install MDD scripts globally:"
    echo "  1. Clone MDD repository: git clone https://github.com/e-faraday/no_go_crayzy_anymore.git ~/.mdd"
    echo "  2. Or run setup.sh in your project to create .claude/ structure"
    echo ""
    echo "Global scripts location: $GLOBAL_SCRIPTS_DIR"
    echo "Project scripts location: $PROJECT_SCRIPTS_DIR"
    exit 1
fi

# Check version compatibility (skip for setup command and if override is set)
if [ "$1" != "setup" ] && [ -d ".claude" ] && [ "$MDD_SKIP_VERSION_CHECK" != "1" ]; then
    if [ -f "$SCRIPTS_DIR/check-mdd-version.sh" ]; then
        # Run version check script
        VERSION_CHECK_OUTPUT=$("$SCRIPTS_DIR/check-mdd-version.sh" 2>&1)
        VERSION_CHECK_EXIT=$?
        
        # Always show output
        echo "$VERSION_CHECK_OUTPUT" >&2
        
        # Exit 1 = Major version mismatch - BLOCKING (stop execution)
        if [ $VERSION_CHECK_EXIT -eq 1 ]; then
            echo "" >&2
            echo -e "${RED}❌ Komut durduruldu: Major version uyumsuzluğu tespit edildi.${NC}" >&2
            echo -e "${YELLOW}Override için: MDD_SKIP_VERSION_CHECK=1 mdd <komut>${NC}" >&2
            exit 1
        fi
        # Exit 2 = Version file missing - Non-blocking (continue)
        # Exit 0 = Compatible - Continue normally
    fi
fi

get_script() {
    case "$1" in
        newtask|new-task) echo "new-task.sh" ;;
        checktask|check-task) echo "check-task.sh" ;;
        updateprogress|update-progress) echo "update-progress.sh" ;;
        starttask|start-task) echo "start-task.sh" ;;
        archivetask|archive|archive-completed) echo "archive-completed.sh" ;;
        autosync|auto-sync) echo "auto-sync.sh" ;;
        autocompletetask|autocomplete-task) echo "auto-complete-task.sh" ;;
        autocompletephases|autocomplete-phases) echo "auto-complete-phases.sh" ;;
        autoupdatestatus|autoupdate-status) echo "auto-update-status.sh" ;;
        autoupdatecheckpoint|autoupdate-checkpoint) echo "auto-update-checkpoint.sh" ;;
        autocommittask|autocommit-task) echo "auto-commit-task.sh" ;;
        autocommitplan|autocommit-plan) echo "auto-commit-plan.sh" ;;
        autocommitfeature|autocommit-feature) echo "auto-commit-feature.sh" ;;
        setpriority|set-priority) echo "set-priority.sh" ;;
        addtags|add-tags) echo "add-tags.sh" ;;
        dailysummary|daily-summary) echo "daily-summary.sh" ;;
        syncall|sync-all) echo "sync-all-tasks.sh" ;;
        setup) echo "setup.sh" ;;
        *) echo "" ;;
    esac
}

if [ $# -eq 0 ]; then
    echo "MDD - Markdown Driven Development"
    echo "Usage: mdd <command> [args...]"
    echo "Run 'mdd' without arguments to see all commands"
    exit 0
fi

CMD="$1"
shift
SCRIPT=$(get_script "$CMD")

if [ -z "$SCRIPT" ]; then
    echo "❌ Error: Unknown command '$CMD'"
    echo "Run 'mdd' without arguments to see available commands"
    exit 1
fi

SCRIPT_PATH="$SCRIPTS_DIR/$SCRIPT"
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ Error: Script not found: $SCRIPT_PATH"
    exit 1
fi

[ ! -x "$SCRIPT_PATH" ] && chmod +x "$SCRIPT_PATH"
exec "$SCRIPT_PATH" "$@"
MDD_EOF
    chmod +x "$PROJECT_ROOT/mdd" 2>/dev/null || true
    echo -e "${GREEN}✅ mdd wrapper script created${NC}"
fi
echo ""

chmod +x "$PROJECT_ROOT/mdd" 2>/dev/null || true
echo ""

# Check for git
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Git repository detected"
    
    # Add to git (only .claude/, scripts are global now)
    git add .claude/
    
    echo -e "${GREEN}✅ Files staged for commit${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. git commit -m 'Add MD-Driven Development setup'"
    echo "  2. mdd newtask feature 'Your First Feature'"
    echo ""
    echo "Note: Scripts are now global (~/.mdd/scripts/), only .claude/ is in your project"
else
    echo -e "${BLUE}ℹ️  Not a git repository${NC}"
    echo ""
    echo "Consider initializing git:"
    echo "  git init"
fi

# Create user-local symlink for global mdd command
echo "Setting up global 'mdd' command..."
USER_BIN_DIR="$HOME/bin"
SKIP_SYMLINK=false

# Check if mdd command already exists
EXISTING_MDD=$(which mdd 2>/dev/null)
if [ -n "$EXISTING_MDD" ] && [ "$EXISTING_MDD" != "$USER_BIN_DIR/mdd" ]; then
    echo -e "${YELLOW}⚠️  Warning: Another 'mdd' command found: $EXISTING_MDD${NC}"
    echo ""
    echo "Options:"
    echo "  1. Use existing: $EXISTING_MDD"
    echo "  2. Create symlink in ~/bin (will take precedence if ~/bin is first in PATH)"
    echo ""
    read -p "Create symlink anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}ℹ️  Skipping symlink creation${NC}"
        SKIP_SYMLINK=true
    fi
fi

if [ "$SKIP_SYMLINK" != "true" ]; then
    # Create ~/bin directory if it doesn't exist
    if [ ! -d "$USER_BIN_DIR" ]; then
        mkdir -p "$USER_BIN_DIR"
        echo -e "${GREEN}✅ Created $USER_BIN_DIR${NC}"
    fi

    # Create or update symlink
    MDD_SYMLINK="$USER_BIN_DIR/mdd"
    if [ -L "$MDD_SYMLINK" ] || [ -f "$MDD_SYMLINK" ]; then
        # Remove existing symlink/file
        rm "$MDD_SYMLINK"
        echo -e "${BLUE}ℹ️  Removed existing $MDD_SYMLINK${NC}"
    fi

    # Create new symlink
    ln -s "$PROJECT_ROOT/mdd" "$MDD_SYMLINK"
    echo -e "${GREEN}✅ Created symlink: $MDD_SYMLINK${NC}"

    # Check PATH priority
    if [[ ":$PATH:" == *":$USER_BIN_DIR:"* ]]; then
        # Check if ~/bin is first in PATH
        FIRST_IN_PATH=$(echo "$PATH" | cut -d: -f1)
        if [ "$FIRST_IN_PATH" = "$USER_BIN_DIR" ]; then
            echo -e "${GREEN}✅ $USER_BIN_DIR is first in PATH (highest priority)${NC}"
            echo -e "${BLUE}ℹ️  You can now use 'mdd' command from anywhere!${NC}"
        else
            echo -e "${YELLOW}⚠️  $USER_BIN_DIR is in PATH but not first${NC}"
            echo -e "${BLUE}ℹ️  To ensure our 'mdd' takes precedence, move it to the front:${NC}"
            echo "  export PATH=\"\$HOME/bin:\$PATH\""
        fi
    else
        # Add to PATH
        echo ""
        echo -e "${YELLOW}⚠️  $USER_BIN_DIR is not in your PATH${NC}"
        echo ""
        echo "To use 'mdd' command globally, add this to your shell config:"
        echo ""
        # Detect shell
        if [ -n "$ZSH_VERSION" ]; then
            SHELL_RC="$HOME/.zshrc"
            echo "  export PATH=\"\$HOME/bin:\$PATH\""
        elif [ -n "$BASH_VERSION" ]; then
            SHELL_RC="$HOME/.bashrc"
            echo "  export PATH=\"\$HOME/bin:\$PATH\""
        else
            SHELL_RC="$HOME/.zshrc"  # Default to zsh
            echo "  export PATH=\"\$HOME/bin:\$PATH\""
        fi
        echo ""
        read -p "Would you like to add it now? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Add to PATH if not already there
            if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$SHELL_RC" 2>/dev/null; then
                echo '' >> "$SHELL_RC"
                echo '# MDD - Add ~/bin to PATH for global mdd command' >> "$SHELL_RC"
                echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_RC"
                echo -e "${GREEN}✅ Added to $SHELL_RC${NC}"
                echo -e "${BLUE}ℹ️  Run 'source $SHELL_RC' or restart terminal${NC}"
            else
                echo -e "${BLUE}ℹ️  Already in $SHELL_RC${NC}"
            fi
        else
            echo -e "${BLUE}ℹ️  You can add it manually later${NC}"
        fi
    fi
    echo ""
fi

echo ""
echo -e "${GREEN}✨ Setup complete!${NC}"
echo ""
echo "Quick start:"
echo "  mdd newtask feature 'Feature Name'"
echo "  mdd dailysummary"
echo ""
echo "Or use full script paths:"
echo "  ./scripts/new-task.sh feature 'Feature Name'"
echo "  ./scripts/daily-summary.sh"
echo ""
echo "Documentation: .claude/README.md"
