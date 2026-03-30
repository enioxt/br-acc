#!/usr/bin/env bash
# Phase 1 only: docs (.md, .txt, .html) — zero production risk
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHANGED=0

while IFS= read -r -d '' file; do
  # Skip
  case "$file" in
    */.git/*|*/__pycache__/*|*/data/*|*/rename-to-egos-inteligencia.sh|*/rename-phase1-docs.sh) continue ;;
  esac

  # Only process files that have matches
  if ! grep -qE "bracc|br-acc|br_acc|BRACC" "$file" 2>/dev/null; then
    continue
  fi

  tmp="${file}.tmp"
  sed \
    -e 's/bracc_etl/egos_inteligencia_etl/g' \
    -e 's/bracc-etl/egos-inteligencia-etl/g' \
    -e 's/BRACC_ETL/EGOS_INTELIGENCIA_ETL/g' \
    -e 's/bracc-neo4j/egos-inteligencia-neo4j/g' \
    -e 's/bracc-redis/egos-inteligencia-redis/g' \
    -e 's/bracc-api/egos-inteligencia-api/g' \
    -e 's/bracc-worker/egos-inteligencia-worker/g' \
    -e 's/bracc-frontend/egos-inteligencia-frontend/g' \
    -e 's/infra_bracc/infra_egos_inteligencia/g' \
    -e 's/BRACC_SOURCE/EGOS_INTELIGENCIA_SOURCE/g' \
    -e 's/BRACC_/EGOS_INTELIGENCIA_/g' \
    -e 's/br-acc/egos-inteligencia/g' \
    -e 's/br_acc/egos_inteligencia/g' \
    -e 's/BRACC/EGOS_INTELIGENCIA/g' \
    -e 's/bracc/egos_inteligencia/g' \
    "$file" > "$tmp"

  if ! diff -q "$file" "$tmp" > /dev/null 2>&1; then
    mv "$tmp" "$file"
    echo "CHANGED: ${file#$REPO_ROOT/}"
    CHANGED=$((CHANGED + 1))
  else
    rm -f "$tmp"
  fi
done < <(find "$REPO_ROOT" \( -name "*.md" -o -name "*.txt" -o -name "*.html" \) -type f -print0)

echo "---"
echo "Phase 1 complete: $CHANGED doc files renamed"
