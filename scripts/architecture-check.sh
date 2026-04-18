#!/bin/bash
# Architecture Checker for Agent Intelligent Bodies
# Analyzes code architecture for anti-patterns and structural issues

set -e

TARGET_DIR="${1:-.}"

echo "========================================"
echo "  Architecture Analysis"
echo "  Target: $TARGET_DIR"
echo "========================================"
echo ""

# Detect language
LANG_EXT=$(find "$TARGET_DIR" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | head -1 | sed 's/.*\.//')
echo "[*] Detected language: $LANG_EXT"
echo ""

# Count files and lines
TOTAL_FILES=$(find "$TARGET_DIR" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | wc -l)
TOTAL_LINES=$(find "$TARGET_DIR" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" \) -exec cat {} \; 2>/dev/null | wc -l)
echo "[*] Total files: $TOTAL_FILES"
echo "[*] Total lines: $TOTAL_LINES"
echo ""

# Analyze module size (God module detection)
echo "[*] Analyzing module sizes..."
echo "----------------------------------------"
echo " Files with >500 lines (potential God modules):"
while IFS= read -r file; do
    lines=$(wc -l < "$file")
    if [ "$lines" -gt 500 ]; then
        echo "  WARNING: $file ($lines lines)"
    fi
done < <(find "$TARGET_DIR" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null)

echo ""
echo "----------------------------------------"
echo " Files with >300 lines (review candidates):"
while IFS= read -r file; do
    lines=$(wc -l < "$file")
    if [ "$lines" -gt 300 ] && [ "$lines" -le 500 ]; then
        echo "  INFO: $file ($lines lines)"
    fi
done < <(find "$TARGET_DIR" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null)

# Analyze imports for coupling
echo ""
echo "[*] Analyzing module coupling..."
echo "----------------------------------------"
echo " Files with >15 imports (high coupling):"
HIGH_COUPLING=0
while IFS= read -r file; do
    if [ "$LANG_EXT" = "py" ]; then
        import_count=$(grep -cE "^import |^from " "$file" 2>/dev/null || echo 0)
    else
        import_count=$(grep -cE "^import |^require|require\(" "$file" 2>/dev/null || echo 0)
    fi

    if [ "$import_count" -gt 15 ]; then
        echo "  WARNING: $file ($import_count imports)"
        ((HIGH_COUPLING++))
    fi
done < <(find "$TARGET_DIR" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null)

if [ $HIGH_COUPLING -eq 0 ]; then
    echo "  OK: No high-coupling modules detected"
fi

# Circular dependency detection
echo ""
echo "[*] Detecting circular dependencies..."
echo "----------------------------------------"

if [ "$LANG_EXT" = "py" ]; then
    # Build import map
    declare -A IMPORTS
    while IFS= read -r file; do
        module_name=$(echo "$file" | sed 's|^\./||' | sed 's|\.py$||' | sed 's|/|.|g' | sed 's|^\.||')
        while IFS= read -r line; do
            imported=$(echo "$line" | sed -E 's/^from ([^ ]+).*/\1/; s/^import ([^ ]+).*/\1/' | tr -d ' ')
            if [ -n "$imported" ]; then
                IMPORTS["$module_name"]+="$imported "
            fi
        done < <(grep -E "^import |^from " "$file" 2>/dev/null || true)
    done < <(find "$TARGET_DIR" -type f -name "*.py" 2>/dev/null)

    # Check for cycles (simplified)
    CYCLES=0
    for module in "${!IMPORTS[@]}"; do
        deps="${IMPORTS[$module]}"
        for dep in $deps; do
            if [[ "${IMPORTS[$dep]}" == *"$module"* ]]; then
                echo "  WARNING: Circular dependency: $module <-> $dep"
                ((CYCLES++))
            fi
        done
    done

    if [ $CYCLES -eq 0 ]; then
        echo "  OK: No circular dependencies detected"
    fi
else
    echo "  (Circular dependency detection not yet implemented for $LANG_EXT)"
fi

# Separation of concerns check
echo ""
echo "[*] Checking separation of concerns..."
echo "----------------------------------------"

# Look for proper directory structure
HAS_TOOLS=0
HAS_MEMORY=0
HAS_AGENT=0
HAS_CONFIG=0

if find "$TARGET_DIR" -type d -name "*tool*" >/dev/null 2>&1; then HAS_TOOLS=1; fi
if find "$TARGET_DIR" -type d -name "*memory*" >/dev/null 2>&1; then HAS_MEMORY=1; fi
if find "$TARGET_DIR" -type d -name "*agent*" >/dev/null 2>&1; then HAS_AGENT=1; fi
if find "$TARGET_DIR" -type d -name "*config*" >/dev/null 2>&1; then HAS_CONFIG=1; fi

echo "  Directory structure analysis:"
[ $HAS_TOOLS -eq 1 ] && echo "    + tools/ directory found" || echo "    - No tools/ directory (consider separating tool adapters)"
[ $HAS_MEMORY -eq 1 ] && echo "    + memory/ directory found" || echo "    - No memory/ directory (consider separating state management)"
[ $HAS_AGENT -eq 1 ] && echo "    + agent/ directory found" || echo "    - No agent/ directory (consider separating core logic)"
[ $HAS_CONFIG -eq 1 ] && echo "    + config/ directory found" || echo "    - No config/ directory (consider separating configuration)"

# File naming consistency
echo ""
echo "[*] Checking naming consistency..."
echo "----------------------------------------"
NAME_STYLE=$(find "$TARGET_DIR" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | head -10 | \
    awk -F/ '{print $NF}' | sed 's/[0-9]*//g' | sed 's/_.*//g' | sort | uniq -c | sort -rn | head -1)
echo "  Most common naming pattern: $NAME_STYLE"

# Generate summary
echo ""
echo "========================================"
echo "  Architecture Summary"
echo "========================================"
echo ""
echo "  Files: $TOTAL_FILES"
echo "  Lines: $TOTAL_LINES"
echo "  High-coupling modules: $HIGH_COUPLING"
echo ""

# Recommendations
echo "  Recommendations:"
if [ $HIGH_COUPLING -gt 0 ]; then
    echo "    - Consider breaking up high-coupling modules"
fi
if [ $HAS_TOOLS -eq 0 ] && [ $HAS_MEMORY -eq 0 ]; then
    echo "    - Consider layered architecture (core/agents/tools/memory)"
fi
echo "    - Review files >500 lines for single-responsibility violations"
echo ""

exit 0