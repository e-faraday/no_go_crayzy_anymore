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
    echo -e "${RED}⚠️  MDD Version Uyumsuzluğu Tespit Edildi!${NC}" >&2
    echo "" >&2
    echo -e "${YELLOW}Proje MDD Versiyonu:${NC} $PROJECT_VERSION" >&2
    echo -e "${YELLOW}Script MDD Versiyonu:${NC} $SCRIPT_VERSION" >&2
    echo "" >&2
    
    # Determine if project is newer or older than scripts
    if [ "$PROJECT_MAJOR" -gt "$SCRIPT_MAJOR" ]; then
        # Project is newer (e.g., v3.0.0 project with v2.0.0 scripts)
        echo -e "${RED}Bu proje $PROJECT_VERSION ile oluşturulmuş, ancak $SCRIPT_VERSION script'leri kullanılıyor.${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}⚠️  Geriye Dönük Uyumsuzluk (Backward Incompatibility):${NC}" >&2
        echo "  v$PROJECT_MAJOR projeleri v$SCRIPT_MAJOR script'leri ile tam uyumlu DEĞİLDİR." >&2
        echo "  v$PROJECT_MAJOR'da eklenen özellikler v$SCRIPT_MAJOR script'lerinde bulunmayabilir." >&2
        echo "  Bazı komutlar çalışmayabilir veya beklenmeyen davranışlar gösterebilir." >&2
        echo "" >&2
        echo -e "${BLUE}Önerilen Çözümler:${NC}" >&2
        echo "  1. $PROJECT_VERSION script'lerini kullanın (ÖNERİLEN):" >&2
        echo "     git clone -b $PROJECT_VERSION https://github.com/e-faraday/no_go_crayzy_anymore.git ~/.mdd" >&2
        echo "  2. Veya projeyi $SCRIPT_VERSION ile uyumlu hale getirmek için migration yapın" >&2
    else
        # Project is older (e.g., v2.0.0 project with v3.0.0 scripts)
        # Yeni script eski versiyon dosyalar ile uyumlu değil - block yap
        echo -e "${RED}⚠️  Yeni Script Versiyonu Eski Proje Versiyonu ile Uyumlu Değil!${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}Proje MDD Versiyonu:${NC} $PROJECT_VERSION (eski)" >&2
        echo -e "${YELLOW}Script MDD Versiyonu:${NC} $SCRIPT_VERSION (yeni)" >&2
        echo "" >&2
        echo -e "${RED}Bu proje $PROJECT_VERSION ile oluşturulmuş, ancak $SCRIPT_VERSION script'leri yüklü.${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}⚠️  İleriye Dönük Uyumsuzluk (Forward Incompatibility):${NC}" >&2
        echo "  Yeni script versiyonu ($SCRIPT_VERSION) eski proje versiyonu ($PROJECT_VERSION) ile uyumlu değil." >&2
        echo "  Veri bozulması veya beklenmeyen davranışlar olabilir." >&2
        echo "" >&2
        echo -e "${BLUE}Çözüm: Yeni Versiyonu Silip Eski Versiyonu Yükleyin${NC}" >&2
        echo "" >&2
        echo "  1. Yeni versiyonu silin:" >&2
        echo "     rm -rf ~/.mdd" >&2
        echo "" >&2
        echo "  2. Eski versiyonu yükleyin:" >&2
        echo "     git clone -b $PROJECT_VERSION https://github.com/e-faraday/no_go_crayzy_anymore.git ~/.mdd" >&2
        echo "" >&2
        echo -e "${YELLOW}Alternatif:${NC} Projeyi $SCRIPT_VERSION ile uyumlu hale getirmek için migration yapın" >&2
    fi
    echo "" >&2
    echo -e "${YELLOW}Not:${NC} Farklı major versiyonlar arasında uyumsuzluk olabilir." >&2
    exit 1
elif [ "$COMPARISON" = "older" ]; then
    # Project is older but same major version - warning but compatible
    echo -e "${YELLOW}ℹ️  MDD Versiyon Bilgisi:${NC}" >&2
    echo -e "  Proje: $PROJECT_VERSION, Script: $SCRIPT_VERSION" >&2
    echo -e "${BLUE}  Aynı major versiyon - uyumlu, ancak yeni özellikler kullanılabilir.${NC}" >&2
    exit 0
else
    # Same or newer - compatible
    exit 0
fi
