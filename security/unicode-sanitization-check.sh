#!/bin/bash
# unicode-sanitization-check.sh
#
# Scans PR content and code files for zero-width characters, Unicode
# homoglyphs, and other characters that can be used for prompt injection
# or code obfuscation.
#
# Usage:
#   ./unicode-sanitization-check.sh [directory]
#   ./unicode-sanitization-check.sh --pr <PR_NUMBER>
#
# Exit codes:
#   0 - Clean (no suspicious characters found)
#   1 - Suspicious characters detected
#   2 - Usage error

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

FOUND_ISSUES=0

# Zero-width and invisible characters (hex patterns for grep)
# U+200B Zero Width Space
# U+200C Zero Width Non-Joiner
# U+200D Zero Width Joiner
# U+200E Left-to-Right Mark
# U+200F Right-to-Left Mark
# U+202A Left-to-Right Embedding
# U+202B Right-to-Left Embedding
# U+202C Pop Directional Formatting
# U+202D Left-to-Right Override
# U+202E Right-to-Left Override
# U+2060 Word Joiner
# U+2061 Function Application
# U+2062 Invisible Times
# U+2063 Invisible Separator
# U+2064 Invisible Plus
# U+FEFF Zero Width No-Break Space (BOM)
# U+E0001-U+E007F Unicode Tag Characters

check_zero_width() {
    local target="$1"
    local label="$2"

    echo -e "${YELLOW}Checking for zero-width characters in ${label}...${NC}"

    # Use grep with perl regex for Unicode detection
    if grep -rPn '[\x{200B}\x{200C}\x{200D}\x{200E}\x{200F}\x{202A}-\x{202E}\x{2060}-\x{2064}\x{FEFF}]' \
        --include="*.py" --include="*.js" --include="*.ts" --include="*.go" \
        --include="*.rs" --include="*.java" --include="*.rb" --include="*.php" \
        --include="*.yaml" --include="*.yml" --include="*.json" --include="*.md" \
        "$target" 2>/dev/null; then
        echo -e "${RED}FOUND: Zero-width characters detected!${NC}"
        FOUND_ISSUES=1
    else
        echo -e "${GREEN}Clean: No zero-width characters found.${NC}"
    fi
}

check_homoglyphs() {
    local target="$1"
    local label="$2"

    echo -e "${YELLOW}Checking for Unicode homoglyphs in ${label}...${NC}"

    # Common Cyrillic/Greek homoglyphs that look like Latin letters
    # а(U+0430) looks like a, е(U+0435) looks like e, о(U+043E) looks like o
    # р(U+0440) looks like p, с(U+0441) looks like c, х(U+0445) looks like x
    if grep -rPn '[\x{0400}-\x{04FF}\x{0370}-\x{03FF}]' \
        --include="*.py" --include="*.js" --include="*.ts" --include="*.go" \
        --include="*.rs" --include="*.java" --include="*.rb" --include="*.php" \
        "$target" 2>/dev/null; then
        echo -e "${RED}FOUND: Cyrillic or Greek characters in code files!${NC}"
        echo -e "${RED}These may be homoglyphs (visually identical to Latin characters).${NC}"
        FOUND_ISSUES=1
    else
        echo -e "${GREEN}Clean: No homoglyphs found in code files.${NC}"
    fi
}

check_bidi_override() {
    local target="$1"
    local label="$2"

    echo -e "${YELLOW}Checking for bidirectional override characters in ${label}...${NC}"

    # Bidi override characters can make code appear different from what it does
    # This is the "Trojan Source" attack
    if grep -rPn '[\x{202A}-\x{202E}\x{2066}-\x{2069}]' \
        --include="*.py" --include="*.js" --include="*.ts" --include="*.go" \
        --include="*.rs" --include="*.java" --include="*.rb" --include="*.php" \
        "$target" 2>/dev/null; then
        echo -e "${RED}FOUND: Bidirectional override characters detected!${NC}"
        echo -e "${RED}This may be a Trojan Source attack.${NC}"
        FOUND_ISSUES=1
    else
        echo -e "${GREEN}Clean: No bidi override characters found.${NC}"
    fi
}

check_tag_characters() {
    local target="$1"
    local label="$2"

    echo -e "${YELLOW}Checking for Unicode tag characters in ${label}...${NC}"

    # Tag characters (U+E0001-U+E007F) can embed hidden text
    if grep -rPn '[\x{E0001}-\x{E007F}]' \
        --include="*.py" --include="*.js" --include="*.ts" --include="*.go" \
        --include="*.rs" --include="*.java" --include="*.rb" --include="*.php" \
        --include="*.yaml" --include="*.yml" --include="*.json" --include="*.md" \
        "$target" 2>/dev/null; then
        echo -e "${RED}FOUND: Unicode tag characters detected!${NC}"
        echo -e "${RED}These can embed hidden instructions in text.${NC}"
        FOUND_ISSUES=1
    else
        echo -e "${GREEN}Clean: No tag characters found.${NC}"
    fi
}

check_pr_content() {
    local pr_number="$1"

    echo -e "${YELLOW}Checking PR #${pr_number} content...${NC}"

    # Get PR title and body
    local pr_content
    pr_content=$(gh pr view "$pr_number" --json title,body --jq '.title + "\n" + .body' 2>/dev/null)

    if [ -z "$pr_content" ]; then
        echo -e "${RED}Error: Could not fetch PR #${pr_number}${NC}"
        exit 2
    fi

    # Write to temp file for scanning
    local tmpfile
    tmpfile=$(mktemp)
    echo "$pr_content" > "$tmpfile"

    # Check for zero-width characters
    if grep -Pn '[\x{200B}\x{200C}\x{200D}\x{200E}\x{200F}\x{202A}-\x{202E}\x{2060}-\x{2064}\x{FEFF}]' "$tmpfile" 2>/dev/null; then
        echo -e "${RED}FOUND: Zero-width characters in PR title/body!${NC}"
        FOUND_ISSUES=1
    fi

    # Check for tag characters
    if grep -Pn '[\x{E0001}-\x{E007F}]' "$tmpfile" 2>/dev/null; then
        echo -e "${RED}FOUND: Unicode tag characters in PR title/body!${NC}"
        FOUND_ISSUES=1
    fi

    rm -f "$tmpfile"

    if [ "$FOUND_ISSUES" -eq 0 ]; then
        echo -e "${GREEN}Clean: PR content has no suspicious characters.${NC}"
    fi
}

# Main
echo "========================================"
echo "  Unicode Sanitization Check"
echo "========================================"
echo ""

if [ "${1:-}" = "--pr" ]; then
    if [ -z "${2:-}" ]; then
        echo "Usage: $0 --pr <PR_NUMBER>"
        exit 2
    fi
    check_pr_content "$2"
elif [ -n "${1:-}" ]; then
    TARGET="$1"
    check_zero_width "$TARGET" "$TARGET"
    echo ""
    check_homoglyphs "$TARGET" "$TARGET"
    echo ""
    check_bidi_override "$TARGET" "$TARGET"
    echo ""
    check_tag_characters "$TARGET" "$TARGET"
else
    TARGET="."
    check_zero_width "$TARGET" "current directory"
    echo ""
    check_homoglyphs "$TARGET" "current directory"
    echo ""
    check_bidi_override "$TARGET" "current directory"
    echo ""
    check_tag_characters "$TARGET" "current directory"
fi

echo ""
echo "========================================"
if [ "$FOUND_ISSUES" -eq 1 ]; then
    echo -e "${RED}RESULT: Suspicious characters found. Review required.${NC}"
    exit 1
else
    echo -e "${GREEN}RESULT: All checks passed. No suspicious characters.${NC}"
    exit 0
fi
