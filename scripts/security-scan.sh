#!/bin/bash
# Security Scanner for Agent Intelligent Bodies
# Detects common security issues in Python, Java, JavaScript, TypeScript source code

set -e

TARGET_DIR="${1:-.}"
SEVERITY_THRESHOLD="${2:-MEDIUM}"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "========================================"
echo "  Agent Security Scanner"
echo "  Target: $TARGET_DIR"
echo "========================================"
echo ""

# Initialize counters
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
    local pattern=$5

    case $severity in
        CRITICAL) ((CRITICAL++)) ;;
        HIGH) ((HIGH++)) ;;
        MEDIUM) ((MEDIUM++)) ;;
        LOW) ((LOW++)) ;;
    esac

    ISSUES+=("|$severity|$file:$line|$description|$pattern|")
}

echo "[*] Detecting supported file types..."
PY_FILES=$(find "$TARGET_DIR" -type f -name "*.py" 2>/dev/null | wc -l)
JAVA_FILES=$(find "$TARGET_DIR" -type f -name "*.java" 2>/dev/null | wc -l)
JS_FILES=$(find "$TARGET_DIR" -type f \( -name "*.js" -o -name "*.ts" \) 2>/dev/null | wc -l)
echo "    Python files: $PY_FILES"
echo "    Java files: $JAVA_FILES"
echo "    JS/TS files: $JS_FILES"
echo ""

echo "[*] Scanning for credentials exposure..."
while IFS= read -r file; do
    # Skip test files and examples
    if [[ "$file" == *"test"* ]] || [[ "$file" == *"example"* ]] || [[ "$file" == *".git"* ]]; then
        continue
    fi

    # Check for hardcoded credentials
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        # Skip if it's a placeholder or example
        if echo "$content" | grep -iqE "(placeholder|todo|sample|example|your_|fill_in)"; then
            continue
        fi
        log_issue "CRITICAL" "$file" "$linenum" "Potential hardcoded credential detected" "$content"
    done < <(grep -rnE "(api_key|apikey|secret|password|token|auth).*[=:]" "$file" 2>/dev/null || true)
done < <(find "$TARGET_DIR" -type f \( -name "*.py" -o -name "*.java" -o -name "*.js" -o -name "*.ts" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.md" -o -name "*.properties" -o -name "*.xml" \) 2>/dev/null | head -100)

echo "[*] Scanning for dangerous functions (Python)..."
while IFS= read -r file; do
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        log_issue "HIGH" "$file" "$linenum" "Dangerous function usage (eval/exec)" "$content"
    done < <(grep -rnE "(eval|exec|system)\s*\(" "$file" 2>/dev/null | grep -v "subprocess\|spawn\|# safe" | head -20 || true)
done < <(find "$TARGET_DIR" -type f -name "*.py" 2>/dev/null | head -50)

echo "[*] Scanning for dangerous functions (Java)..."
while IFS= read -r file; do
    # Runtime.getRuntime().exec() - potential command injection
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        log_issue "HIGH" "$file" "$linenum" "Potential command injection (Runtime.exec)" "$content"
    done < <(grep -rnE "Runtime\s*\.\s*getRuntime\s*\(\)\s*\.\s*exec" "$file" 2>/dev/null | head -20 || true)

    # ProcessBuilder usage
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        # Check if input is validated
        next_lines=$(sed -n "${linenum},$((linenum+10))p" "$file" 2>/dev/null || true)
        if ! echo "$next_lines" | grep -iqE "(validate|sanitize|check|isValid|whitelist)"; then
            log_issue "MEDIUM" "$file" "$linenum" "ProcessBuilder without input validation" "$content"
        fi
    done < <(grep -rnE "new ProcessBuilder" "$file" 2>/dev/null | head -20 || true)

    # SQL injection - PreparedStatement usage check
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        # Check if using Statement instead of PreparedStatement
        if echo "$content" | grep -qE "createStatement\s*\("; then
            log_issue "HIGH" "$file" "$linenum" "Potential SQL injection - use PreparedStatement" "$content"
        fi
    done < <(grep -rnE "(Statement|Connection)\s*\." "$file" 2>/dev/null | head -30 || true)

    # JNDI injection
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        log_issue "HIGH" "$file" "$linenum" "JNDI injection risk" "$content"
    done < <(grep -rnE "InitialContext\s*\.\s*lookup" "$file" 2>/dev/null | head -20 || true)

    # ObjectInputStream - deserialization vulnerability
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        log_issue "HIGH" "$file" "$linenum" "Deserialization vulnerability risk (ObjectInputStream)" "$content"
    done < <(grep -rnE "ObjectInputStream" "$file" 2>/dev/null | head -20 || true)
done < <(find "$TARGET_DIR" -type f -name "*.java" 2>/dev/null | head -50)

echo "[*] Scanning for missing input validation (Python)..."
while IFS= read -r file; do
    # Look for input handling without validation
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        # Check if there's validation nearby
        next_lines=$(sed -n "${linenum},$((linenum+5))p" "$file" 2>/dev/null || true)
        if ! echo "$next_lines" | grep -iqE "(validate|sanitize|check|assert|is_valid)"; then
            log_issue "MEDIUM" "$file" "$linenum" "Potential unvalidated input" "$content"
        fi
    done < <(grep -rnE "(input\(|user_input|request\.|args\.get|params\.)" "$file" 2>/dev/null | head -10 || true)
done < <(find "$TARGET_DIR" -type f -name "*.py" 2>/dev/null | head -50)

echo "[*] Scanning for missing input validation (Java)..."
while IFS= read -r file; do
    # Look for request parameters without validation
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        # Check if there's validation nearby
        next_lines=$(sed -n "${linenum},$((linenum+5))p" "$file" 2>/dev/null || true)
        if ! echo "$next_lines" | grep -iqE "(validate|sanitize|check|assert|isValid|notNull|notEmpty)"; then
            log_issue "MEDIUM" "$file" "$linenum" "Potential unvalidated input" "$content"
        fi
    done < <(grep -rnE "(request\.|getParameter|@RequestParam|@PathVariable|HttpServletRequest)" "$file" 2>/dev/null | head -10 || true)
done < <(find "$TARGET_DIR" -type f -name "*.java" 2>/dev/null | head -50)

echo "[*] Scanning for missing .gitignore entries..."
if [ -f "$TARGET_DIR/.gitignore" ]; then
    if ! grep -qiE "(\.env|credentials|secrets|\.key)" "$TARGET_DIR/.gitignore" 2>/dev/null; then
        log_issue "MEDIUM" ".gitignore" "0" "No credential patterns in .gitignore" "Missing secrets protection"
    fi
fi

echo "[*] Scanning for file permission issues (shell scripts)..."
while IFS= read -r file; do
    perms=$(stat -f "%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null || echo "000")
    if [ "$perms" -gt 644 ] 2>/dev/null; then
        if [[ "$file" == *"credential"* ]] || [[ "$file" == *"secret"* ]] || [[ "$file" == *".env"* ]]; then
            log_issue "HIGH" "$file" "0" "Insecure file permissions (should be 600)" "Permissions: $perms"
        fi
    fi
done < <(find "$TARGET_DIR" -type f \( -name "*credential*" -o -name "*secret*" -o -name ".env*" \) 2>/dev/null | head -20)

echo "[*] Scanning for TODO/FIXME security notes..."
while IFS= read -r file; do
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        if echo "$content" | grep -iqE "(security|hack|vulnerability|exploit|injection)"; then
            log_issue "LOW" "$file" "$linenum" "Security-related TODO comment" "$content"
        fi
    done < <(grep -rnE "(TODO|FIXME|HACK|XXX).*(security|vuln|auth|credential|token)" "$file" 2>/dev/null | head -10 || true)
done < <(find "$TARGET_DIR" -type f \( -name "*.py" -o -name "*.java" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | head -50)

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
    echo "No issues found!"
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
        LOW) color=$GREEN ;;
    esac

    printf "${color}[%s]${NC} %s\n" "$severity" "$location"
    printf "         %s\n\n" "$description"
done

echo "========================================"
echo "  Recommendations"
echo "========================================"
echo ""

if [ $CRITICAL -gt 0 ]; then
    echo "- CRITICAL: Address credential exposure immediately"
fi
if [ $HIGH -gt 0 ]; then
    echo "- HIGH: Review dangerous function usage and file permissions"
fi
if [ $MEDIUM -gt 0 ]; then
    echo "- MEDIUM: Add input validation and secure .gitignore"
fi
if [ $LOW -gt 0 ]; then
    echo "- LOW: Clean up security-related TODO comments"
fi

echo ""
echo "For full security analysis, also run: ./scripts/prompt-injection-detector.sh"
echo ""

# Exit with error code if critical or high issues found
if [ $CRITICAL -gt 0 ] || [ $HIGH -gt 0 ]; then
    exit 1
fi
exit 0