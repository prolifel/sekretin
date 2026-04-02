#!/bin/sh
#
# secret-scan.sh - Scan git history for secrets using regex patterns
# Standalone version for remote hosting
#
# Usage: ./secret-scan.sh [--all] [--exit-code N] [--verbose] [--staged]
#

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Parse arguments
SCAN_ALL=""
EXIT_CODE=0
VERBOSE=""
STAGED_ONLY=""

while [ $# -gt 0 ]; do
    case $1 in
        --all)
            SCAN_ALL="--all"
            shift
            ;;
        --exit-code)
            EXIT_CODE="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE="true"
            shift
            ;;
        --staged)
            STAGED_ONLY="true"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Secret patterns (id:regex)
PATTERN_COUNT=10

get_pattern_id() {
    case $1 in
        0) echo "aws-access-key" ;;
        1) echo "aws-secret-key" ;;
        2) echo "github-token" ;;
        3) echo "github-oauth" ;;
        4) echo "github-app-token" ;;
        5) echo "github-refresh-token" ;;
        6) echo "gitlab-token" ;;
        7) echo "generic-api-key" ;;
        8) echo "private-key" ;;
        9) echo "jwt" ;;
    esac
}

get_pattern() {
    case $1 in
        0) echo '(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}' ;;
        1) echo 'aws(.{0,20})[0-9a-zA-Z/+]{40}' ;;
        2) echo 'ghp_[0-9a-zA-Z]{36}' ;;
        3) echo 'gho_[0-9a-zA-Z]{36}' ;;
        4) echo '(ghu|ghs)_[0-9a-zA-Z]{36}' ;;
        5) echo 'ghr_[0-9a-zA-Z]{36}' ;;
        6) echo 'glpat-[0-9a-zA-Z-]{20}' ;;
        7) echo '(api[_-]?key|apikey|api[_-]?secret)[^a-zA-Z0-9].{0,20}[0-9a-zA-Z]{16,}' ;;
        8) echo '-----BEGIN [A-Z ]*PRIVATE KEY-----' ;;
        9) echo 'eyJ[a-zA-Z0-9_-]*\.eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*' ;;
    esac
}

# Allowed paths (for excluding files)
is_allowed_path() {
    case "$1" in
        *.md) return 0 ;;
    esac
    return 1
}

# Mask secret - show first 4 and last 4 chars, mask the rest
mask_secret() {
    local secret="$1"
    local len=${#secret}
    if [ "$len" -le 8 ]; then
        echo "****"
    else
        local prefix="${secret:0:4}"
        local suffix="${secret:$((len-4)):4}"
        local mask_len=$((len - 8))
        local mask=""
        i=0
        while [ $i -lt $mask_len ]; do
            mask="${mask}*"
            i=$((i + 1))
        done
        echo "${prefix}${mask}${suffix}"
    fi
}

# Temp files
TEMP_LEAKS=$(mktemp)
TEMP_SEEN=$(mktemp)
trap "rm -f $TEMP_LEAKS $TEMP_SEEN" EXIT

printf "%b○%b\n" "$GREEN" "$NC"
printf "%b    │╲%b\n" "$GREEN" "$NC"
printf "%b    │ ○%b\n" "$GREEN" "$NC"
printf "%b    ○ ░%b\n" "$GREEN" "$NC"
printf "%b    ░    %bsecret-scan%b\n" "$GREEN" "$NC" "$NC"
echo ""

# Handle staged-only mode (for pre-commit)
if [ -n "$STAGED_ONLY" ]; then
    files=$(git diff --cached --name-only 2>/dev/null)
    if [ -z "$files" ]; then
        printf "%bNo staged files to scan%b\n" "$YELLOW" "$NC"
        exit 0
    fi

    for file in $files; do
        # Skip allowed paths
        if is_allowed_path "$file"; then
            continue
        fi

        # Get staged content
        content=$(git show ":$file" 2>/dev/null) || continue

        if [ -z "$content" ]; then
            continue
        fi

        # Check each pattern
        i=0
        while [ $i -lt $PATTERN_COUNT ]; do
            rule_id=$(get_pattern_id $i)
            pattern=$(get_pattern $i)

            match=$(echo "$content" | grep -E "$pattern" 2>/dev/null) || true
            if [ -n "$match" ]; then
                line_num=$(echo "$content" | grep -En "$pattern" | head -1 | cut -d: -f1)
                fingerprint="${file}:${rule_id}:${line_num}"

                # Skip if already seen (deduplicate)
                if grep -qF "$fingerprint" "$TEMP_SEEN" 2>/dev/null; then
                    i=$((i + 1))
                    continue
                fi
                echo "$fingerprint" >> "$TEMP_SEEN"

                echo "LEAK" >> "$TEMP_LEAKS"
                masked_match=$(mask_secret "$match")
                echo ""
                printf "%bFinding:%b     %s\n" "$RED" "$NC" "$masked_match"
                printf "%bRuleID:%b      %s\n" "$YELLOW" "$NC" "$rule_id"
                printf "%bFile:%b        %s\n" "$YELLOW" "$NC" "$file"
                printf "%bLine:%b        %s\n" "$YELLOW" "$NC" "$line_num"
            fi
            i=$((i + 1))
        done
    done

    leaks_found=$(wc -l < "$TEMP_LEAKS" | tr -d ' ')

    if [ "$leaks_found" -gt 0 ]; then
        printf "%b$(date '+%I:%M%p') WRN%b leaks found: %s\n" "$YELLOW" "$NC" "$leaks_found"
        if [ "$EXIT_CODE" -ne 0 ]; then
            exit "$EXIT_CODE"
        fi
    else
        printf "%b$(date '+%I:%M%p') INF%b no leaks found\n" "$GREEN" "$NC"
    fi

    exit 0
fi

# Git history scan mode
commits=$(git log $SCAN_ALL --pretty=format:'%H' --reverse 2>/dev/null)

if [ -z "$commits" ]; then
    printf "%bNo commits found to scan%b\n" "$YELLOW" "$NC"
    exit 0
fi

total_commits=$(echo "$commits" | wc -l | tr -d ' ')

# Scan each commit
for commit in $commits; do
    # Get files changed in this commit
    if git rev-parse --verify "${commit}^" >/dev/null 2>&1; then
        files=$(git diff-tree --no-commit-id --name-only -r "$commit" 2>/dev/null)
    else
        files=$(git ls-tree --name-only -r "$commit" 2>/dev/null)
    fi

    for file in $files; do
        # Skip allowed paths
        if is_allowed_path "$file"; then
            continue
        fi

        # Get file content at this commit
        content=$(git show "${commit}:${file}" 2>/dev/null) || continue

        if [ -z "$content" ]; then
            continue
        fi

        # Check each pattern
        i=0
        while [ $i -lt $PATTERN_COUNT ]; do
            rule_id=$(get_pattern_id $i)
            pattern=$(get_pattern $i)

            match=$(echo "$content" | grep -E "$pattern" 2>/dev/null) || true
            if [ -n "$match" ]; then
                line_num=$(echo "$content" | grep -En "$pattern" | head -1 | cut -d: -f1)
                fingerprint="${file}:${rule_id}:${line_num}"

                # Skip if already seen (deduplicate)
                if grep -qF "$fingerprint" "$TEMP_SEEN" 2>/dev/null; then
                    i=$((i + 1))
                    continue
                fi
                echo "$fingerprint" >> "$TEMP_SEEN"

                echo "LEAK" >> "$TEMP_LEAKS"
                author=$(git log -1 --pretty=format:'%an' "$commit")
                email=$(git log -1 --pretty=format:'%ae' "$commit")
                date=$(git log -1 --pretty=format:'%ai' "$commit")
                masked_match=$(mask_secret "$match")
                echo ""
                printf "%bFinding:%b     %s\n" "$RED" "$NC" "$masked_match"
                printf "%bRuleID:%b      %s\n" "$YELLOW" "$NC" "$rule_id"
                printf "%bFile:%b        %s\n" "$YELLOW" "$NC" "$file"
                printf "%bLine:%b        %s\n" "$YELLOW" "$NC" "$line_num"
                printf "%bCommit:%b    %s\n" "$YELLOW" "$NC" "$commit"
                printf "%bAuthor:%b    %s\n" "$YELLOW" "$NC" "$author"
                printf "%bEmail:%b     %s\n" "$YELLOW" "$NC" "$email"
                printf "%bDate:%b      %s\n" "$YELLOW" "$NC" "$date"
                if [ "$VERBOSE" = "true" ]; then
                    printf "%bFingerprint:%b %s:%s:%s:%s\n" "$YELLOW" "$NC" "$commit" "$file" "$rule_id" "$line_num"
                fi
            fi
            i=$((i + 1))
        done
    done
done

echo ""
printf "%b$(date '+%I:%M%p') INF%b %s commits scanned.\n" "$GREEN" "$NC" "$total_commits"

leaks_found=$(wc -l < "$TEMP_LEAKS" | tr -d ' ')

if [ "$leaks_found" -gt 0 ]; then
    printf "%b$(date '+%I:%M%p') WRN%b leaks found: %s\n" "$YELLOW" "$NC" "$leaks_found"
    if [ "$EXIT_CODE" -ne 0 ]; then
        exit "$EXIT_CODE"
    fi
else
    printf "%b$(date '+%I:%M%p') INF%b no leaks found\n" "$GREEN" "$NC"
fi

exit 0
