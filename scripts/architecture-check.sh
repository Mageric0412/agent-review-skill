#!/bin/bash
# Architecture Checker for Agent Intelligent Bodies
# Analyzes code architecture for anti-patterns and structural issues
# Supports: Python, Java, JavaScript, TypeScript

set -e

TARGET_DIR="${1:-.}"

echo "========================================"
echo "  Architecture Analysis"
echo "  Target: $TARGET_DIR"
echo "========================================"
echo ""

# Detect languages
PY_FILES=$(find "$TARGET_DIR" -type f -name "*.py" 2>/dev/null | wc -l)
JAVA_FILES=$(find "$TARGET_DIR" -type f -name "*.java" 2>/dev/null | wc -l)
JS_FILES=$(find "$TARGET_DIR" -type f -name "*.js" 2>/dev/null | wc -l)
TS_FILES=$(find "$TARGET_DIR" -type f -name "*.ts" 2>/dev/null | wc -l)

echo "[*] Detected languages:"
[ $PY_FILES -gt 0 ] && echo "    - Python: $PY_FILES files"
[ $JAVA_FILES -gt 0 ] && echo "    - Java: $JAVA_FILES files"
[ $JS_FILES -gt 0 ] && echo "    - JavaScript: $JS_FILES files"
[ $TS_FILES -gt 0 ] && echo "    - TypeScript: $TS_FILES files"
echo ""

# Count files and lines
TOTAL_FILES=$(find "$TARGET_DIR" -type f \( -name "*.py" -o -name "*.java" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | wc -l)
TOTAL_LINES=$(find "$TARGET_DIR" -type f \( -name "*.py" -o -name "*.java" -o -name "*.js" -o -name "*.ts" \) -exec cat {} \; 2>/dev/null | wc -l)
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
done < <(find "$TARGET_DIR" -type f \( -name "*.py" -o -name "*.java" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null)

echo ""
echo "----------------------------------------"
echo " Files with >300 lines (review candidates):"
while IFS= read -r file; do
    lines=$(wc -l < "$file")
    if [ "$lines" -gt 300 ] && [ "$lines" -le 500 ]; then
        echo "  INFO: $file ($lines lines)"
    fi
done < <(find "$TARGET_DIR" -type f \( -name "*.py" -o -name "*.java" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null)

# Analyze imports for coupling
echo ""
echo "[*] Analyzing module coupling..."
echo "----------------------------------------"
echo " Files with >15 imports (high coupling):"
HIGH_COUPLING=0

# Python coupling
while IFS= read -r file; do
    import_count=$(grep -cE "^import |^from " "$file" 2>/dev/null || echo 0)
    if [ "$import_count" -gt 15 ]; then
        echo "  WARNING: $file ($import_count imports)"
        ((HIGH_COUPLING++))
    fi
done < <(find "$TARGET_DIR" -type f -name "*.py" 2>/dev/null)

# Java coupling (import statements)
while IFS= read -r file; do
    import_count=$(grep -cE "^import " "$file" 2>/dev/null || echo 0)
    # Count class references in same file as well
    class_refs=$(grep -cE "new [A-Z][a-zA-Z]+|extends [A-Z][a-zA-Z]+|implements [A-Z][a-zA-Z]+" "$file" 2>/dev/null || echo 0)
    total=$((import_count + class_refs))
    if [ "$total" -gt 15 ]; then
        echo "  WARNING: $file ($total dependencies)"
        ((HIGH_COUPLING++))
    fi
done < <(find "$TARGET_DIR" -type f -name "*.java" 2>/dev/null)

# JS/TS coupling
while IFS= read -r file; do
    import_count=$(grep -cE "^import |^require|require\(" "$file" 2>/dev/null || echo 0)
    if [ "$import_count" -gt 15 ]; then
        echo "  WARNING: $file ($import_count imports)"
        ((HIGH_COUPLING++))
    fi
done < <(find "$TARGET_DIR" -type f \( -name "*.js" -o -name "*.ts" \) 2>/dev/null)

if [ $HIGH_COUPLING -eq 0 ]; then
    echo "  OK: No high-coupling modules detected"
fi

# Circular dependency detection
echo ""
echo "[*] Detecting circular dependencies..."
echo "----------------------------------------"

CYCLES=0

# Python circular dependency detection
if [ $PY_FILES -gt 0 ]; then
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

    for module in "${!IMPORTS[@]}"; do
        deps="${IMPORTS[$module]}"
        for dep in $deps; do
            if [[ "${IMPORTS[$dep]}" == *"$module"* ]]; then
                echo "  WARNING: Circular dependency: $module <-> $dep"
                ((CYCLES++))
            fi
        done
    done
fi

# Java circular dependency detection (via package dependencies)
if [ $JAVA_FILES -gt 0 ]; then
    declare -A PACKAGE_DEPS
    while IFS= read -r file; do
        # Get package name
        pkg=$(grep -m1 "^package " "$file" 2>/dev/null | sed 's/package //; s/;//' | tr -d ' ')
        [ -z "$pkg" ] && continue

        # Get imports
        while IFS= read -r line; do
            imported=$(echo "$line" | sed 's/import //; s/;//' | tr -d ' ')
            # Skip java.* and javax.* imports
            if [[ "$imported" == java.* ]] || [[ "$imported" == javax.* ]]; then
                continue
            fi
            PACKAGE_DEPS["$pkg"]+="$imported "
        done < <(grep "^import " "$file" 2>/dev/null || true)
    done < <(find "$TARGET_DIR" -type f -name "*.java" 2>/dev/null)

    for pkg in "${!PACKAGE_DEPS[@]}"; do
        deps="${PACKAGE_DEPS[$pkg]}"
        for dep in $deps; do
            # Simple check: if dep also imports pkg
            if [[ "${PACKAGE_DEPS[$dep]}" == *"$pkg"* ]]; then
                echo "  WARNING: Circular package dependency: $pkg <-> $dep"
                ((CYCLES++))
            fi
        done
    done
fi

if [ $CYCLES -eq 0 ]; then
    echo "  OK: No circular dependencies detected"
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
HAS_SERVICES=0
HAS_CONTROLLERS=0
HAS_MODELS=0
HAS_UTIL=0

if find "$TARGET_DIR" -type d \( -name "*tool*" -o -name "*adapter*" \) >/dev/null 2>&1; then HAS_TOOLS=1; fi
if find "$TARGET_DIR" -type d -name "*memory*" >/dev/null 2>&1; then HAS_MEMORY=1; fi
if find "$TARGET_DIR" -type d \( -name "*agent*" -o -name "*core*" \) >/dev/null 2>&1; then HAS_AGENT=1; fi
if find "$TARGET_DIR" -type d -name "*config*" >/dev/null 2>&1; then HAS_CONFIG=1; fi
if find "$TARGET_DIR" -type d -name "*service*" >/dev/null 2>&1; then HAS_SERVICES=1; fi
if find "$TARGET_DIR" -type d \( -name "*controller*" -o -name "*handler*" \) >/dev/null 2>&1; then HAS_CONTROLLERS=1; fi
if find "$TARGET_DIR" -type d \( -name "*model*" -o -name "*entity*" \) >/dev/null 2>&1; then HAS_MODELS=1; fi
if find "$TARGET_DIR" -type d \( -name "*util*" -o -name "*helper*" \) >/dev/null 2>&1; then HAS_UTIL=1; fi

echo "  Directory structure analysis:"
[ $HAS_TOOLS -eq 1 ] && echo "    + tools/ or adapter/ directory found" || echo "    - No tools/ directory (consider separating tool adapters)"
[ $HAS_MEMORY -eq 1 ] && echo "    + memory/ directory found" || echo "    - No memory/ directory (consider separating state management)"
[ $HAS_AGENT -eq 1 ] && echo "    + agent/ or core/ directory found" || echo "    - No agent/ directory (consider separating core logic)"
[ $HAS_CONFIG -eq 1 ] && echo "    + config/ directory found" || echo "    - No config/ directory (consider separating configuration)"
[ $HAS_SERVICES -eq 1 ] && echo "    + services/ directory found" || echo "    - No services/ directory"
[ $HAS_CONTROLLERS -eq 1 ] && echo "    + controllers/ or handlers/ directory found" || echo "    - No controllers/ directory"
[ $HAS_MODELS -eq 1 ] && echo "    + models/ or entities/ directory found" || echo "    - No models/ directory"
[ $HAS_UTIL -eq 1 ] && echo "    + utils/ or helpers/ directory found" || echo "    - No utils/ directory"

# File naming consistency
echo ""
echo "[*] Checking naming consistency..."
echo "----------------------------------------"

# Python naming
PY_NAMES=$(find "$TARGET_DIR" -type f -name "*.py" 2>/dev/null | head -10 | awk -F/ '{print $NF}' | \
    sed 's/[0-9]*//g' | sed 's/_.*//g' | sort | uniq -c | sort -rn | head -1)
[ -n "$PY_NAMES" ] && echo "  Python naming pattern: $PY_NAMES"

# Java naming
JAVA_NAMES=$(find "$TARGET_DIR" -type f -name "*.java" 2>/dev/null | head -10 | awk -F/ '{print $NF}' | \
    sed 's/[0-9]*//g' | sed 's/\.java.*//g' | sort | uniq -c | sort -rn | head -1)
[ -n "$JAVA_NAMES" ] && echo "  Java naming pattern: $JAVA_NAMES"

# JavaScript naming
JS_NAMES=$(find "$TARGET_DIR" -type f \( -name "*.js" -o -name "*.ts" \) 2>/dev/null | head -10 | awk -F/ '{print $NF}' | \
    sed 's/[0-9]*//g' | sed 's/\.(js|ts).*//g' | sort | uniq -c | sort -rn | head -1)
[ -n "$JS_NAMES" ] && echo "  JS/TS naming pattern: $JS_NAMES"

# Class/interface detection (for Java)
echo ""
echo "[*] Checking for design patterns..."
echo "----------------------------------------"
INTERFACES=$(find "$TARGET_DIR" -type f -name "*.java" -exec grep -l "^interface " {} \; 2>/dev/null | wc -l)
ABSTRACT=$(find "$TARGET_DIR" -type f -name "*.java" -exec grep -l "^abstract class " {} \; 2>/dev/null | wc -l)
SINGLETONS=$(find "$TARGET_DIR" -type f -name "*.java" -exec grep -l "private static.*instance" {} \; 2>/dev/null | wc -l)

[ $INTERFACES -gt 0 ] && echo "    + Interfaces found: $INTERFACES (good for abstraction)"
[ $ABSTRACT -gt 0 ] && echo "    + Abstract classes found: $ABSTRACT"
[ $SINGLETONS -gt 0 ] && echo "    + Potential singletons: $SINGLETONS"

# Generate summary
echo ""
echo "========================================"
echo "  Architecture Summary"
echo "========================================"
echo ""
echo "  Files: $TOTAL_FILES"
echo "  Lines: $TOTAL_LINES"
echo "  High-coupling modules: $HIGH_COUPLING"
echo "  Circular dependencies: $CYCLES"
echo ""

# Recommendations
echo "  Recommendations:"
if [ $HIGH_COUPLING -gt 0 ]; then
    echo "    - Consider breaking up high-coupling modules"
fi
if [ $CYCLES -gt 0 ]; then
    echo "    - Break circular dependencies by introducing interfaces"
fi
if [ $HAS_TOOLS -eq 0 ] && [ $HAS_MEMORY -eq 0 ] && [ $HAS_AGENT -eq 0 ]; then
    echo "    - Consider layered architecture (core/agents/tools/memory)"
fi
if [ $JAVA_FILES -gt 0 ] && [ $INTERFACES -eq 0 ]; then
    echo "    - Consider using interfaces for abstraction"
fi
echo "    - Review files >500 lines for single-responsibility violations"
echo ""

exit 0