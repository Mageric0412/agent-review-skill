#!/bin/bash
# MCP Configuration Security Scanner
# Detects security issues in MCP server configurations

set -e

TARGET_DIR="${1:-.}"

echo "========================================"
echo "  MCP Configuration Scanner"
echo "  Target: $TARGET_DIR"
echo "========================================"
echo ""

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

CRITICAL=0
HIGH=0
MEDIUM=0
LOW=0

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

    printf "${RED}[%s]${NC} %s:%s\n" "$severity" "$file" "$line"
    printf "         %s\n\n" "$description"
}

echo "[*] Scanning for MCP configuration files..."

# Find MCP config files
MCP_CONFIG_FILES=()
while IFS= read -r file; do
    MCP_CONFIG_FILES+=("$file")
done < <(find "$TARGET_DIR" -type f \( -name ".mcp*" -o -name "mcp.json" -o -name "mcp.yaml" -o -name "mcp.yml" -o -name "*mcp*.json" -o -name "*mcp*.yaml" -o -name "CLAUDE.md" -o -name "AGENTS.md" -o -name "SOUL.md" \) 2>/dev/null)

if [ ${#MCP_CONFIG_FILES[@]} -eq 0 ]; then
    echo "No MCP configuration files found."
    echo ""
    echo "[*] Looking for potential config locations..."
    find "$TARGET_DIR" -type f \( -name ".mcp*" -o -name "*mcp*" \) 2>/dev/null | head -10
    exit 0
fi

echo "Found ${#MCP_CONFIG_FILES[@]} MCP-related files"
echo ""

for file in "${MCP_CONFIG_FILES[@]}"; do
    echo "[*] Scanning: $file"

    # Check for hardcoded credentials in MCP configs
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        if echo "$content" | grep -iqE "(api_key|token|secret|password).*[=:]"; then
            if ! echo "$content" | grep -iqE "(env\.|process\.env|os\.environ|\${)"; then
                log_issue "CRITICAL" "$file" "$linenum" "Hardcoded credential in MCP config"
            fi
        fi
    done < <(grep -rnE "(api_key|token|secret|password).*[=:].{10,}" "$file" 2>/dev/null || true)

    # Check for dangerous URL patterns
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        # Check for HTTP (not HTTPS) in production-like contexts
        if echo "$content" | grep -qE "http://(?!localhost|127\.)"; then
            log_issue "HIGH" "$file" "$linenum" "Non-HTTPS URL in MCP config - potential MITM"
        fi
    done < <(grep -rnE "https?://" "$file" 2>/dev/null | head -20 || true)

    # Check for command injection in command URLs
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        if echo "$content" | grep -qE "\$(.*\)|`.*`"; then
            log_issue "CRITICAL" "$file" "$linenum" "Command substitution in MCP config - potential injection"
        fi
    done < <(grep -rnE "\$\(|`" "$file" 2>/dev/null || true)

    # Check for overly permissive settings
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        if echo "$content" | grep -iqE "(dangerously|allow.*all|unrestricted|skip.*auth)"; then
            log_issue "HIGH" "$file" "$linenum" "Overly permissive MCP setting detected"
        fi
    done < <(grep -rnE "(dangerously|allow.*all|unrestricted)" "$file" 2>/dev/null || true)

done

# Scan for hook injection in CLAUDE.md/AGENTS.md
echo ""
echo "[*] Scanning for hook injection patterns..."

HOOK_FILES=()
while IFS= read -r file; do
    HOOK_FILES+=("$file")
done < <(find "$TARGET_DIR" -type f \( -name "CLAUDE.md" -o -name "AGENTS.md" -o -name "SOUL.md" -o -name ".claude*" \) 2>/dev/null)

for file in "${HOOK_FILES[@]}"; do
    # Check for external content references without sanitization
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        # Check for fetch/web references
        if echo "$content" | grep -iqE "(fetch|url|curl|wget|http).*\$"; then
            log_issue "HIGH" "$file" "$linenum" "Dynamic content injection in hook file"
        fi
    done < <(grep -rnE "(fetch|url|curl|wget|http).*\$" "$file" 2>/dev/null | head -10 || true)

    # Check for base64 encoded commands
    while IFS= read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        if echo "$content" | grep -iqE "base64.*decode|decode.*base64|from.*base64"; then
            log_issue "MEDIUM" "$file" "$linenum" "Base64 decoding pattern - possible obfuscation"
        fi
    done < <(grep -rnE "base64" "$file" 2>/dev/null | head -10 || true)

done

# Print summary
echo ""
echo "========================================"
echo "  MCP Scan Results"
echo "========================================"
echo ""
printf "${RED}CRITICAL: %d${NC}\n" "$CRITICAL"
printf "${RED}HIGH: %d${NC}\n" "$HIGH"
printf "${YELLOW}MEDIUM: %d${NC}\n" "$MEDIUM"
printf "${GREEN}LOW: %d${NC}\n" "$LOW"
echo ""

if [ $CRITICAL -eq 0 ] && [ $HIGH -eq 0 ]; then
    echo "No critical MCP security issues found."
    exit 0
else
    echo "Recommendations:"
    echo "- Use environment variables for credentials in MCP configs"
    echo "- Always use HTTPS URLs"
    echo "- Validate and sanitize any dynamic content in hooks"
    echo "- Review CLAUDE.md/AGENTS.md for potential injection vectors"
    exit 1
fi