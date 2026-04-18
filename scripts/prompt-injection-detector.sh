#!/bin/bash
# Prompt Injection Detector for Agent Intelligent Bodies
# Detects patterns associated with prompt injection attacks

set -e

TARGET_DIR="${1:-.}"

echo "========================================"
echo "  Prompt Injection Detection"
echo "  Target: $TARGET_DIR"
echo "========================================"
echo ""

# Color codes
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

CRITICAL=0
HIGH=0
MEDIUM=0
LOW=0
ISSUES=()

log_issue() {
    local severity=$1
    local file=$2
    local line=$3
    local description=$4

    case $severity in
        CRITICAL) ((CRITICAL++)) ;;
        HIGH) ((HIGH++)) ;;
        MEDIUM) ((MEDIUM++)) ;;
        LOW) ((LOW++)) ;;
    esac

    ISSUES+=("|$severity|$file:$line|$description|")
}

# Layer 1: Direct injection patterns
echo "[*] Layer 1: Scanning for direct injection patterns..."

DIRECT_PATTERNS=(
    "ignore.*previous.*instructions"
    "disregard.*your.*programming"
    "disregard.*all.*previous"
    "you.*are.*now.*a.*different"
    "you.*are.*now.*an.*assistant"
    "new.*system.*prompt"
    "admin.*override"
    "override.*system"
    "set.*system.*prompt"
    "forget.*all.*instructions"
    "ignore.*system"
)

for pattern in "${DIRECT_PATTERNS[@]}"; do
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        file=$(echo "$line" | cut -d: -f2)
        content=$(echo "$line" | cut -d: -f3-)
        log_issue "CRITICAL" "$file" "$linenum" "Direct injection pattern: $pattern"
    done < <(grep -rnE -i "$pattern" "$TARGET_DIR" --include="*.py" --include="*.js" --include="*.ts" --include="*.md" 2>/dev/null | head -10 || true)
done

# Layer 2: Indirect injection patterns
echo "[*] Layer 2: Scanning for indirect injection patterns..."

INDIRECT_PATTERNS=(
    "dear.*ai.*assistant"
    "note.*to.*ai"
    "ai:.*ignore"
    "<!--.*ai.*-->"
    "\\[INST\\].*\\[/INST\\]"
    "<INST>"
    "note.*to.*the.*ai"
    "instruction.*for.*ai"
    "ai.*instruction"
    "system.*prompt.*injection"
)

for pattern in "${INDIRECT_PATTERNS[@]}"; do
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        file=$(echo "$line" | cut -d: -f2)
        content=$(echo "$line" | cut -d: -f3-)
        log_issue "HIGH" "$file" "$linenum" "Indirect injection pattern: $pattern"
    done < <(grep -rnE -i "$pattern" "$TARGET_DIR" --include="*.py" --include="*.js" --include="*.ts" --include="*.md" --include="*.html" --include="*.txt" 2>/dev/null | head -10 || true)
done

# Layer 3: Obfuscation detection
echo "[*] Layer 3: Scanning for obfuscation techniques..."

OBFUSCATION_PATTERNS=(
    "base64.*decode"
    "base64.*encode"
    "decode.*base64"
    "from.*base64"
    "import.*base64"
    "unicode.*lookalike"
    "\\x[0-9a-f]{2}"
    "\\u[0-9a-f]{4}"
    "hidden.*text"
    "invisible.*character"
    "zero.*width"
    "steganography"
)

for pattern in "${OBFUSCATION_PATTERNS[@]}"; do
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        file=$(echo "$line" | cut -d: -f2)
        content=$(echo "$line" | cut -d: -f3-)
        # Skip if in test or example context
        if echo "$file" | grep -iqE "(test|example|mock)"; then
            continue
        fi
        log_issue "HIGH" "$file" "$linenum" "Obfuscation technique: $pattern"
    done < <(grep -rnE -i "$pattern" "$TARGET_DIR" --include="*.py" --include="*.js" --include="*.ts" 2>/dev/null | head -10 || true)
done

# Layer 4: External content handling
echo "[*] Layer 4: Checking external content handling..."

# Look for fetch/web calls without sanitization
while IFS= read -r file; do
    content=$(cat "$file" 2>/dev/null || true)
    if echo "$content" | grep -iqE "(fetch|requests\.|urllib|http\.get|http\.post|curl|wget|aiohttp)"; then
        # Check if there's sanitization nearby
        if ! echo "$content" | grep -iqE "(sanitize|validate|strip.*html|escape|html\.unescape)"; then
            log_issue "MEDIUM" "$file" "0" "External content fetched without apparent sanitization"
        fi
    fi
done < <(find "$TARGET_DIR" -type f -name "*.py" 2>/dev/null | head -20)

# Layer 5: Output rendering
echo "[*] Layer 5: Checking output rendering safety..."

while IFS= read -r file; do
    content=$(cat "$file" 2>/dev/null || true)
    # Check for dangerous output methods
    if echo "$content" | grep -iqE "(execute.*output|render.*html|safe.*html|allow.*html)"; then
        if ! echo "$content" | grep -iqE "(markdown|strip.*tags|bleach|safe.*render)"; then
            log_issue "MEDIUM" "$file" "0" "Potential unsafe HTML rendering"
        fi
    fi
done < <(find "$TARGET_DIR" -type f -name "*.py" 2>/dev/null | head -20)

# Layer 6: Defense patterns check
echo "[*] Layer 6: Checking for defense mechanisms..."

DEFENSE_PATTERNS=(
    "content.*classif"
    "instruction.*isolation"
    "behavior.*monitor"
    "action.*gate"
    "human.*approval"
    "require.*confirm"
)

DEFENSE_COUNT=0
for pattern in "${DEFENSE_PATTERNS[@]}"; do
    if grep -rqE -i "$pattern" "$TARGET_DIR" --include="*.py" --include="*.md" 2>/dev/null; then
        ((DEFENSE_COUNT++))
    fi
done

echo ""
echo "  Defense mechanisms found: $DEFENSE_COUNT/${#DEFENSE_PATTERNS[@]}"
if [ $DEFENSE_COUNT -lt 3 ]; then
    echo -e "  ${YELLOW}WARNING: Limited defense mechanisms detected${NC}"
fi

# Print summary
echo ""
echo "========================================"
echo "  Scan Results"
echo "========================================"
echo ""
printf "${RED}CRITICAL: %d${NC}\n" "$CRITICAL"
printf "${RED}HIGH: %d${NC}\n" "$HIGH"
printf "${YELLOW}MEDIUM: %d${NC}\n" "$MEDIUM"
printf "${GREEN}LOW: %d${NC}\n" "$LOW"
echo ""

if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "No prompt injection patterns detected!"
    exit 0
fi

echo "========================================"
echo "  Detailed Findings"
echo "========================================"
echo ""

for issue in "${ISSUES[@]}"; do
    IFS='|' read -ra parts <<< "$issue"
    severity="${parts[1]}"
    location="${parts[2]}"
    description="${parts[3]}"

    case $severity in
        CRITICAL) color=$RED ;;
        HIGH) color=$RED ;;
        MEDIUM) color=$YELLOW ;;
        *) color=$NC ;;
    esac

    printf "${color}[%s]${NC} %s\n" "$severity" "$location"
    printf "         %s\n\n" "$description"
done

echo "========================================"
echo "  Recommendations"
echo "========================================"
echo ""
echo "  1. Implement content classification layer for external content"
echo "  2. Use instruction isolation - only trust direct user input"
echo "  3. Add behavioral monitoring for unexpected actions"
echo "  4. Implement action gating for sensitive operations"
echo "  5. Sanitize all displayed content from untrusted sources"
echo ""

# Exit with error if critical issues found
if [ $CRITICAL -gt 0 ] || [ $HIGH -gt 0 ]; then
    exit 1
fi
exit 0