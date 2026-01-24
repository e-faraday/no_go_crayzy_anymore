#!/bin/bash
# scripts/setup.sh
# Setup MDD structure for new project

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# PROJECT_ROOT should be the current working directory, not script's parent
PROJECT_ROOT="$(pwd)"

echo -e "${BLUE}🚀 Setting up MD-Driven Development...${NC}"
echo ""

# Create directory structure
echo "Creating directories..."
mkdir -p .claude/active
mkdir -p .claude/completed
mkdir -p .claude/templates
mkdir -p .claude/decisions
mkdir -p scripts

# Create .gitkeep files
touch .claude/active/.gitkeep
touch .claude/completed/.gitkeep
touch .claude/decisions/.gitkeep

echo -e "${GREEN}✅ Directory structure created${NC}"
echo ""

# Make scripts executable
echo "Making scripts executable..."
chmod +x scripts/*.sh 2>/dev/null || true

echo -e "${GREEN}✅ Scripts are executable${NC}"
echo ""

# Copy scripts from MDD repository to current project
echo "Copying scripts from MDD repository..."
if [ -d "$SCRIPT_DIR" ]; then
    # Ensure scripts directory exists
    mkdir -p "$PROJECT_ROOT/scripts"
    # Copy all .sh files from MDD repository
    cp "$SCRIPT_DIR"/*.sh "$PROJECT_ROOT/scripts/" 2>/dev/null || true
    # Make copied scripts executable
    chmod +x "$PROJECT_ROOT/scripts"/*.sh 2>/dev/null || true
    echo -e "${GREEN}✅ Scripts copied${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: MDD scripts directory not found at $SCRIPT_DIR${NC}"
fi
echo ""

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

# Create mdd wrapper script
echo "Creating mdd wrapper script..."
if [ -f "$SCRIPT_DIR/../mdd-template/mdd" ]; then
    # Copy from template if exists
    cp "$SCRIPT_DIR/../mdd-template/mdd" "$PROJECT_ROOT/mdd" 2>/dev/null || true
    chmod +x "$PROJECT_ROOT/mdd" 2>/dev/null || true
    echo -e "${GREEN}✅ mdd wrapper script created from template${NC}"
elif [ -f "$PROJECT_ROOT/mdd" ]; then
    # File already exists, just make it executable
    chmod +x "$PROJECT_ROOT/mdd" 2>/dev/null || true
    echo -e "${GREEN}✅ mdd wrapper script found and made executable${NC}"
else
    # Create basic mdd wrapper
    cat > "$PROJECT_ROOT/mdd" << 'MDD_EOF'
#!/bin/bash
# mdd - MDD Script Wrapper (Bash + Zsh compatible)
# Usage: mdd <command> [args...]

# Get script directory (bash + zsh compatible)
if [[ -n "$ZSH_VERSION" ]]; then
    # Zsh
    SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
elif [[ -n "$BASH_VERSION" ]]; then
    # Bash
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    # Fallback
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

SCRIPTS_DIR="$SCRIPT_DIR/scripts"

if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "❌ Error: scripts/ directory not found"
    exit 1
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
    
    # Add to git
    git add .claude/ scripts/
    
    echo -e "${GREEN}✅ Files staged for commit${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. git commit -m 'Add MD-Driven Development setup'"
    echo "  2. mdd newtask feature 'Your First Feature'"
    echo "     (or: ./scripts/new-task.sh feature 'Your First Feature')"
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
