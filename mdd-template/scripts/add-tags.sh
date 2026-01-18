#!/bin/bash
# scripts/add-tags.sh
# Add or update tags in task file

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -lt 2 ]; then
    echo -e "${RED}Usage: $0 <task-file> <tag1> [tag2] [tag3] ...${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 .claude/active/feature-add-dark-mode.md auth security"
    echo "  $0 .claude/active/feature-add-dark-mode.md ui theme frontend"
    echo "  $0 .claude/active/feature-add-dark-mode.md bug critical"
    exit 1
fi

TASK_FILE=$1
shift
NEW_TAGS=("$@")

# Check if file exists
if [ ! -f "$TASK_FILE" ]; then
    echo -e "${RED}Error: Task file not found: $TASK_FILE${NC}"
    exit 1
fi

# Get current tags
CURRENT_TAGS_LINE=$(grep "^tags:" "$TASK_FILE" | head -1)

if [ -z "$CURRENT_TAGS_LINE" ]; then
    echo -e "${RED}Error: No tags line found in file${NC}"
    exit 1
fi

# Extract current tags (remove brackets and commas)
CURRENT_TAGS_RAW=$(echo "$CURRENT_TAGS_LINE" | sed 's/tags: \[//' | sed 's/\]//')
CURRENT_TAGS=$(echo "$CURRENT_TAGS_RAW" | tr ',' '\n' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | grep -v '^$' || true)

# Combine current and new tags, remove duplicates
ALL_TAGS=()
if [ -n "$CURRENT_TAGS" ]; then
    while IFS= read -r tag || [ -n "$tag" ]; do
        if [ -n "$tag" ]; then
            ALL_TAGS+=("$tag")
        fi
    done <<< "$CURRENT_TAGS"
fi

# Add new tags (avoid duplicates)
for new_tag in "${NEW_TAGS[@]}"; do
    # Remove any quotes
    new_tag=$(echo "$new_tag" | sed 's/^"//' | sed 's/"$//' | sed "s/^'//" | sed "s/'$//")
    
    # Check if tag already exists
    FOUND=0
    for existing_tag in "${ALL_TAGS[@]}"; do
        if [ "$existing_tag" = "$new_tag" ]; then
            FOUND=1
            break
        fi
    done
    
    if [ $FOUND -eq 0 ]; then
        ALL_TAGS+=("$new_tag")
    fi
done

# Sort tags alphabetically
IFS=$'\n' SORTED_TAGS=($(sort <<<"${ALL_TAGS[*]}"))
unset IFS

# Build new tags line
TAGS_STRING=""
for tag in "${SORTED_TAGS[@]}"; do
    if [ -z "$TAGS_STRING" ]; then
        TAGS_STRING="$tag"
    else
        TAGS_STRING="$TAGS_STRING, $tag"
    fi
done

NEW_TAGS_LINE="tags: [$TAGS_STRING]"

# Update tags in file
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|^tags:.*|$NEW_TAGS_LINE|" "$TASK_FILE"
else
    # Linux
    sed -i "s|^tags:.*|$NEW_TAGS_LINE|" "$TASK_FILE"
fi

echo -e "${GREEN}✅ Tags updated${NC}"
echo ""
echo -e "${BLUE}Current tags:${NC} $TAGS_STRING"
echo ""
if [ ${#NEW_TAGS[@]} -gt 0 ]; then
    echo -e "${BLUE}Added:${NC} ${NEW_TAGS[*]}"
fi
