#!/bin/bash
# scripts/install-pre-commit-hook.sh
# Installs git hooks for Gold Standard workflow
# Installs: pre-commit (state validation) + commit-msg (Conventional Commits)

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 Git Hooks Installation (Gold Standard)${NC}"
echo ""

# Check if we're in a git repo
if [ ! -d .git ]; then
    echo -e "${RED}❌ Error: Not a git repository${NC}"
    echo "Run this script from the root of your git repository."
    exit 1
fi

mkdir -p .git/hooks

# ============================================
# 1. Pre-commit Hook (State Validation)
# ============================================

PRE_COMMIT_EXAMPLE=".git/hooks/pre-commit.example"
echo -e "${YELLOW}⚠️  Updating pre-commit.example...${NC}"

cat > "$PRE_COMMIT_EXAMPLE" << 'EOF'
#!/bin/bash
# .git/hooks/pre-commit
# Pre-commit hook that validates state updates
# Gold Standard: Ensures state discipline

# State validation (if validate-state.sh exists)
if [ -f "scripts/validate-state.sh" ]; then
    ./scripts/validate-state.sh --strict
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 2 ]; then
        echo ""
        echo "❌ COMMIT BLOCKED: State not updated"
        echo ""
        echo "Fix:"
        echo "  1. ./scripts/auto-sync.sh .claude/active/your-feature.md"
        echo "  2. git add .claude/active/your-feature.md"
        echo "  3. git commit (try again)"
        exit 1
    fi
fi

exit 0
EOF
chmod +x "$PRE_COMMIT_EXAMPLE"

# Install pre-commit hook
PRE_COMMIT_HOOK=".git/hooks/pre-commit"
if [ -f "$PRE_COMMIT_HOOK" ]; then
    echo -e "${YELLOW}⚠️  Pre-commit hook already exists${NC}"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping pre-commit hook installation."
    else
        cp "$PRE_COMMIT_EXAMPLE" "$PRE_COMMIT_HOOK"
        chmod +x "$PRE_COMMIT_HOOK"
        echo -e "${GREEN}✅ Pre-commit hook installed${NC}"
    fi
else
    cp "$PRE_COMMIT_EXAMPLE" "$PRE_COMMIT_HOOK"
    chmod +x "$PRE_COMMIT_HOOK"
    echo -e "${GREEN}✅ Pre-commit hook installed${NC}"
fi

# ============================================
# 2. Commit-msg Hook (Conventional Commits)
# ============================================

COMMIT_MSG_EXAMPLE=".git/hooks/commit-msg.example"
echo -e "${YELLOW}⚠️  Updating commit-msg.example...${NC}"

cat > "$COMMIT_MSG_EXAMPLE" << 'EOF'
#!/bin/bash
# .git/hooks/commit-msg
# Commit message hook that validates Conventional Commits format
# Gold Standard: Ensures commit message standardization

# Conventional Commits validation (if script exists)
if [ -f "scripts/validate-commit-message.sh" ]; then
    ./scripts/validate-commit-message.sh "$1"
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        echo ""
        echo "❌ COMMIT BLOCKED: Invalid commit message format"
        echo ""
        echo "Commit message must follow Conventional Commits format:"
        echo "  type(scope): description"
        echo ""
        echo "Valid types:"
        echo "  feat     - New feature"
        echo "  fix      - Bug fix"
        echo "  docs     - Documentation"
        echo "  style    - Formatting"
        echo "  refactor - Code refactoring"
        echo "  test     - Test changes"
        echo "  chore    - Build/CI changes"
        echo "  perf     - Performance improvement"
        echo "  ci       - CI/CD changes"
        echo "  build    - Build system changes"
        echo ""
        echo "Examples:"
        echo "  feat(active-mode): add environment parity check"
        echo "  fix(validation): correct state update logic"
        echo "  docs(readme): update workflow diagram"
        exit 1
    fi
fi

exit 0
EOF
chmod +x "$COMMIT_MSG_EXAMPLE"

# Install commit-msg hook
COMMIT_MSG_HOOK=".git/hooks/commit-msg"
if [ -f "$COMMIT_MSG_HOOK" ]; then
    echo -e "${YELLOW}⚠️  Commit-msg hook already exists${NC}"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping commit-msg hook installation."
    else
        cp "$COMMIT_MSG_EXAMPLE" "$COMMIT_MSG_HOOK"
        chmod +x "$COMMIT_MSG_HOOK"
        echo -e "${GREEN}✅ Commit-msg hook installed${NC}"
    fi
else
    cp "$COMMIT_MSG_EXAMPLE" "$COMMIT_MSG_HOOK"
    chmod +x "$COMMIT_MSG_HOOK"
    echo -e "${GREEN}✅ Commit-msg hook installed${NC}"
fi

# ============================================
# Summary
# ============================================

echo ""
echo -e "${GREEN}✅ Git hooks installation complete!${NC}"
echo ""
echo "Installed hooks:"
echo "  1. pre-commit  → State validation (Active Mode)"
echo "  2. commit-msg → Conventional Commits format validation"
echo ""
echo "Test it:"
echo "  git commit -m 'feat(test): test hooks'"
echo ""
