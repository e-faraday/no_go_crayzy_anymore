#!/bin/bash
# scripts/setup.sh
# Setup MDD structure for new project

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Check for git
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Git repository detected"
    
    # Add to git
    git add .claude/ scripts/
    
    echo -e "${GREEN}✅ Files staged for commit${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. git commit -m 'Add MD-Driven Development setup'"
    echo "  2. ./scripts/new-task.sh feature 'Your First Feature'"
else
    echo -e "${BLUE}ℹ️  Not a git repository${NC}"
    echo ""
    echo "Consider initializing git:"
    echo "  git init"
fi

echo ""
echo -e "${GREEN}✨ Setup complete!${NC}"
echo ""
echo "Quick start:"
echo "  ./scripts/new-task.sh feature 'Feature Name'"
echo "  ./scripts/daily-summary.sh"
echo ""
echo "Documentation: .claude/README.md"
