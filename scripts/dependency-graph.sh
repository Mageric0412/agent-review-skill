#!/bin/bash
# Dependency Graph Analyzer for Agent Intelligent Bodies
# Generates module dependency graph and detects issues

set -e

TARGET_DIR="${1:-.}"

echo "========================================"
echo "  Dependency Analysis"
echo "  Target: $TARGET_DIR"
echo "========================================"
echo ""

# Detect language
if find "$TARGET_DIR" -type f -name "*.py" >/dev/null 2>&1; then
    LANG="python"
    EXT="py"
elif find "$TARGET_DIR" -type f -name "*.ts" >/dev/null 2>&1; then
    LANG="typescript"
    EXT="ts"
elif find "$TARGET_DIR" -type f -name "*.js" >/dev/null 2>&1; then
    LANG="javascript"
    EXT="js"
else
    echo "Unsupported language detected"
    exit 1
fi

echo "[*] Detected language: $LANG"
echo ""

# Build dependency map
declare -A DEPS
declare -A DEP_COUNT

echo "[*] Building dependency map..."

while IFS= read -r file; do
    module_name=$(echo "$file" | sed 's|^\./||' | sed "s|\.$EXT$||" | sed 's|/|.|g')

    if [ "$LANG" = "python" ]; then
        imports=$(grep -E "^import |^from " "$file" 2>/dev/null | \
            sed -E 's/^from ([^ ]+).*/\1/; s/^import ([^ ]+).*/\1/' | \
            tr -d ' ' | sort | uniq || true)
    else
        imports=$(grep -E "^import |^require" "$file" 2>/dev/null | \
            sed -E "s/.*require\(['\"](\.[^'\"]+)['\"].*/\1/; s/.*from ['\"](\.[^'\"]+)['\"].*/\1/" | \
            tr -d ' ' | sort | uniq || true)
    fi

    for imp in $imports; do
        DEPS["$module_name"]+="$imp "
    done
    DEP_COUNT["$module_name"]=$(echo "$imports" | wc -w)
done < <(find "$TARGET_DIR" -type f -name "*.$EXT" 2>/dev/null)

# Display dependency summary
echo ""
echo "[*] Module Dependency Summary:"
echo "----------------------------------------"

for module in "${!DEP_COUNT[@]}"; do
    count=${DEP_COUNT[$module]}
    if [ "$count" -gt 10 ]; then
        echo "  HIGH: $module ($count deps)"
    elif [ "$count" -gt 5 ]; then
        echo "  MED: $module ($count deps)"
    fi
done

# Detect circular dependencies
echo ""
echo "[*] Circular Dependency Detection:"
echo "----------------------------------------"

CIRCULAR=0
for module in "${!DEPS[@]}"; do
    deps="${DEPS[$module]}"
    for dep in $deps; do
        # Normalize for comparison
        dep_normalized=$(echo "$dep" | sed 's|\./||g' | sed 's|\..*||g')
        module_normalized=$(echo "$module" | sed 's|\./||g' | sed 's|\..*||g')

        if [ "$dep_normalized" = "$module_normalized" ]; then
            continue
        fi

        # Check if dep also imports module
        if [[ "${DEPS[$dep]}" == *"$module"* ]]; then
            echo "  CYCLE: $module <-> $dep"
            ((CIRCULAR++))
        fi
    done
done

if [ $CIRCULAR -eq 0 ]; then
    echo "  No circular dependencies detected"
fi

# Find central modules (high fan-out)
echo ""
echo "[*] Central Modules (High Fan-out):"
echo "----------------------------------------"

MAX_DEPS=0
CENTRAL_MODULE=""
for module in "${!DEP_COUNT[@]}"; do
    if [ ${DEP_COUNT[$module]} -gt $MAX_DEPS ]; then
        MAX_DEPS=${DEP_COUNT[$module]}
        CENTRAL_MODULE=$module
    fi
done

if [ $MAX_DEPS -gt 15 ]; then
    echo "  WARNING: $CENTRAL_MODULE has $MAX_DEPS dependencies (potential God module)"
    echo "  Recommendation: Consider splitting this module"
else
    echo "  Module with most dependencies: $CENTRAL_MODULE ($MAX_DEPS deps)"
fi

# Find isolated modules (no connections)
echo ""
echo "[*] Isolated Modules (No Dependencies):"
echo "----------------------------------------"

ISOLATED=0
for module in "${!DEP_COUNT[@]}"; do
    count=${DEP_COUNT[$module]}
    # Check if anyone depends on this module
    IS_DEPENDED_ON=0
    for other in "${!DEPS[@]}"; do
        if [[ "${DEPS[$other]}" == *"$module"* ]]; then
            IS_DEPENDED_ON=1
            break
        fi
    done

    if [ $count -eq 0 ] && [ $IS_DEPENDED_ON -eq 0 ]; then
        echo "  ISOLATED: $module"
        ((ISOLATED++))
    fi
done

if [ $ISOLATED -eq 0 ]; then
    echo "  No completely isolated modules"
fi

# Generate JSON output for tooling
echo ""
echo "[*] Generating JSON output..."
cat << 'EOF'
{
  "format": "dependency-graph",
  "version": "1.0"
}
EOF

# Simple graph output
echo ""
echo "[*] Dependency Graph (simplified):"
echo "----------------------------------------"
for module in $(echo "${!DEPS[@]}" | tr ' ' '\n' | sort); do
    deps="${DEPS[$module]}"
    if [ -n "$deps" ]; then
        echo "$module <- ${deps// /, }"
    fi
done

echo ""
echo "========================================"
echo "  Analysis Complete"
echo "========================================"
echo ""

exit 0