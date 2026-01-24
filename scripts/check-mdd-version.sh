#!/bin/bash
# scripts/check-mdd-version.sh
# Checks MDD version compatibility between project and scripts
# Returns 0 if compatible, 1 if incompatible, 2 if version file missing

set -e

YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current script version (from MDD repository)
# Try to detect from git branch or use default
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_SCRIPTS_DIR="$HOME/.mdd/scripts"

# Determine script version
# Priority 1: Check if we're in a git repo and get branch/tag
if [ -d "$SCRIPT_DIR/../.git" ]; then
    # Try to get version from git branch or tag
    GIT_BRANCH=$(cd "$SCRIPT_DIR/.." && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    GIT_TAG=$(cd "$SCRIPT_DIR/.." && git describe --tags --exact-match HEAD 2>/dev/null || echo "")
    
    if [ -n "$GIT_TAG" ]; then
        SCRIPT_VERSION="$GIT_TAG"
    elif [[ "$GIT_BRANCH" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        SCRIPT_VERSION="$GIT_BRANCH"
    elif [[ "$GIT_BRANCH" =~ v([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        SCRIPT_VERSION="v${BASH_REMATCH[1]}"
    else
        # Default to v3.0.0 if can't detect
        SCRIPT_VERSION="v3.0.0"
    fi
else
    # Not in git repo, try to read from VERSION file if exists
    if [ -f "$SCRIPT_DIR/../VERSION" ]; then
        SCRIPT_VERSION=$(cat "$SCRIPT_DIR/../VERSION" | tr -d ' \n')
    else
        # Default version
        SCRIPT_VERSION="v3.0.0"
    fi
fi

# Normalize version (remove 'v' prefix for comparison)
normalize_version() {
    echo "$1" | sed 's/^v//'
}

SCRIPT_VERSION_NORM=$(normalize_version "$SCRIPT_VERSION")

# Check project version
PROJECT_ROOT="$(pwd)"
PROJECT_VERSION_FILE="$PROJECT_ROOT/.claude/.mdd-version"

if [ ! -f "$PROJECT_VERSION_FILE" ]; then
    # No version file - this is a new project or old project without version tracking
    exit 2
fi

PROJECT_VERSION=$(cat "$PROJECT_VERSION_FILE" | tr -d ' \n')
PROJECT_VERSION_NORM=$(normalize_version "$PROJECT_VERSION")

# Compare versions
compare_versions() {
    local v1=$1
    local v2=$2
    
    # Extract major, minor, patch
    local v1_major=$(echo "$v1" | cut -d. -f1)
    local v1_minor=$(echo "$v1" | cut -d. -f2)
    local v1_patch=$(echo "$v1" | cut -d. -f3)
    
    local v2_major=$(echo "$v2" | cut -d. -f1)
    local v2_minor=$(echo "$v2" | cut -d. -f2)
    local v2_patch=$(echo "$v2" | cut -d. -f3)
    
    # Compare major versions
    if [ "$v1_major" -lt "$v2_major" ]; then
        echo "older"
    elif [ "$v1_major" -gt "$v2_major" ]; then
        echo "newer"
    else
        # Same major, compare minor
        if [ "$v1_minor" -lt "$v2_minor" ]; then
            echo "older"
        elif [ "$v1_minor" -gt "$v2_minor" ]; then
            echo "newer"
        else
            # Same minor, compare patch
            if [ "$v1_patch" -lt "$v2_patch" ]; then
                echo "older"
            elif [ "$v1_patch" -gt "$v2_patch" ]; then
                echo "newer"
            else
                echo "same"
            fi
        fi
    fi
}

COMPARISON=$(compare_versions "$PROJECT_VERSION_NORM" "$SCRIPT_VERSION_NORM")

# Extract major versions for compatibility check
PROJECT_MAJOR=$(echo "$PROJECT_VERSION_NORM" | cut -d. -f1)
SCRIPT_MAJOR=$(echo "$SCRIPT_VERSION_NORM" | cut -d. -f1)

# Check compatibility
if [ "$PROJECT_MAJOR" != "$SCRIPT_MAJOR" ]; then
    # Major version mismatch - incompatible
    echo -e "${RED}⚠️  MDD Version Incompatibility Detected!${NC}" >&2
    echo "" >&2
    echo -e "${YELLOW}Project MDD Version:${NC} $PROJECT_VERSION" >&2
    echo -e "${YELLOW}Script MDD Version:${NC} $SCRIPT_VERSION" >&2
    echo "" >&2
    
    # Determine if project is newer or older than scripts
    if [ "$PROJECT_MAJOR" -gt "$SCRIPT_MAJOR" ]; then
        # Project is newer (e.g., v3.0.0 project with v2.0.0 scripts)
        echo -e "${RED}This project was created with $PROJECT_VERSION, but $SCRIPT_VERSION scripts are being used.${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}⚠️  Backward Incompatibility:${NC}" >&2
        echo "  v$PROJECT_MAJOR projects are NOT fully compatible with v$SCRIPT_MAJOR scripts." >&2
        echo "  Features added in v$PROJECT_MAJOR may not be available in v$SCRIPT_MAJOR scripts." >&2
        echo "  Some commands may fail or show unexpected behavior." >&2
        echo "" >&2
        echo -e "${BLUE}Recommended Solutions:${NC}" >&2
        echo "  1. Use $PROJECT_VERSION scripts (RECOMMENDED):" >&2
        echo "     git clone -b $PROJECT_VERSION https://github.com/e-faraday/no_go_crayzy_anymore.git ~/.mdd" >&2
        echo "  2. Or migrate the project to be compatible with $SCRIPT_VERSION" >&2
    else
        # Project is older (e.g., v2.0.0 project with v3.0.0 scripts)
        # New script version is not compatible with old project version - block
        echo -e "${RED}⚠️  New Script Version Not Compatible with Old Project Version!${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}Project MDD Version:${NC} $PROJECT_VERSION (old)" >&2
        echo -e "${YELLOW}Script MDD Version:${NC} $SCRIPT_VERSION (new)" >&2
        echo "" >&2
        echo -e "${RED}This project was created with $PROJECT_VERSION, but $SCRIPT_VERSION scripts are installed.${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}⚠️  Forward Incompatibility:${NC}" >&2
        echo "  New script version ($SCRIPT_VERSION) is not compatible with old project version ($PROJECT_VERSION)." >&2
        echo "  Data corruption or unexpected behavior may occur." >&2
        echo "" >&2
        echo -e "${BLUE}Solution: Remove New Version and Install Old Version${NC}" >&2
        echo "" >&2
        echo "  1. Remove the new version:" >&2
        echo "     rm -rf ~/.mdd" >&2
        echo "" >&2
        echo "  2. Install the old version:" >&2
        echo "     git clone -b $PROJECT_VERSION https://github.com/e-faraday/no_go_crayzy_anymore.git ~/.mdd" >&2
        echo "" >&2
        echo -e "${YELLOW}Alternative:${NC} Migrate the project to be compatible with $SCRIPT_VERSION" >&2
    fi
    echo "" >&2
    echo -e "${YELLOW}Note:${NC} Incompatibility may exist between different major versions." >&2
    exit 1
elif [ "$COMPARISON" = "older" ]; then
    # Project is older but same major version - warning but compatible
    echo -e "${YELLOW}ℹ️  MDD Version Information:${NC}" >&2
    echo -e "  Project: $PROJECT_VERSION, Script: $SCRIPT_VERSION" >&2
    echo -e "${BLUE}  Same major version - compatible, but new features may be available.${NC}" >&2
    exit 0
else
    # Same or newer - compatible
    exit 0
fi
