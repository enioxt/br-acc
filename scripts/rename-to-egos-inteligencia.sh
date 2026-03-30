#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# rename-to-egos-inteligencia.sh
# Renames br-acc → egos-inteligencia across all files in this repo
#
# Safety: DRY-RUN by default. Pass --execute to apply changes.
#
# Usage:
#   bash scripts/rename-to-egos-inteligencia.sh           # dry-run
#   bash scripts/rename-to-egos-inteligencia.sh --execute # APPLY CHANGES
#
# Phases (safest first):
#   1. Docs     (.md, .txt, .rst, .html) — zero production risk
#   2. Python   (.py, pyproject.toml) — imports + package name
#   3. Docker   (.yml, .yaml, Dockerfile*) — container/network names
#   4. Shell    (.sh, Makefile)
#   5. Configs  (.json, .ts, .js, .toml)
#
# Substitution rules (specific → broad):
#   bracc_etl         → egos_inteligencia_etl    (Python module)
#   bracc-etl         → egos-inteligencia-etl    (package name)
#   BRACC_ETL         → EGOS_INTELIGENCIA_ETL    (env var prefix)
#   bracc-neo4j       → egos-inteligencia-neo4j  (Docker containers)
#   bracc-redis       → egos-inteligencia-redis
#   bracc-api         → egos-inteligencia-api
#   bracc-worker      → egos-inteligencia-worker
#   bracc-frontend    → egos-inteligencia-frontend
#   infra_bracc       → infra_egos_inteligencia  (Docker network)
#   BRACC_SOURCE      → EGOS_INTELIGENCIA_SOURCE
#   BRACC_            → EGOS_INTELIGENCIA_        (generic env vars)
#   br-acc            → egos-inteligencia         (generic refs)
#   br_acc            → egos_inteligencia
#   BRACC             → EGOS_INTELIGENCIA         (ALLCAPS)
#   bracc             → egos_inteligencia         (lowercase — last)
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DRY_RUN=true
LOG_FILE="/tmp/egos-rename-$(date +%Y%m%d-%H%M%S).log"
CHANGED_FILES=0

for arg in "$@"; do
  case "$arg" in
    --execute) DRY_RUN=false ;;
  esac
done

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; RESET='\033[0m'

log() { echo -e "$1" | tee -a "$LOG_FILE"; }

# ─── Files / dirs to skip ────────────────────────────────────────────────────
should_skip() {
  local file="$1"
  case "$file" in
    */.git/*|*/__pycache__/*|*/*.pyc|*/node_modules/*|*/.lock|*/data/*|*/neo4j/*)
      return 0 ;;
    */rename-to-egos-inteligencia.sh)
      return 0 ;;
  esac
  # Skip binary files
  if file "$file" 2>/dev/null | grep -qE "binary|ELF|image|PDF"; then
    return 0
  fi
  return 1
}

# ─── Apply substitutions to a single file ────────────────────────────────────
# Uses a sed script with all rules in order (specific → broad)
apply_substitutions() {
  local file="$1"

  # Quick check: does this file have any of our patterns?
  if ! grep -qE "bracc|br-acc|br_acc|BRACC" "$file" 2>/dev/null; then
    return
  fi

  local tmp="${file}.rename_tmp"
  cp "$file" "$tmp"

  sed -i \
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
    "$tmp"

  if diff -q "$file" "$tmp" > /dev/null 2>&1; then
    rm -f "$tmp"
    return
  fi

  local count
  count=$(diff "$file" "$tmp" | grep -c "^>" || true)

  if $DRY_RUN; then
    log "  ${YELLOW}~ WOULD   ${RESET}  ${file#$REPO_ROOT/}  (+${count} lines changed)"
    rm -f "$tmp"
  else
    mv "$tmp" "$file"
    log "  ${GREEN}✓ CHANGED ${RESET}  ${file#$REPO_ROOT/}  (+${count} lines changed)"
  fi
  CHANGED_FILES=$((CHANGED_FILES + 1))
}

# ─── Scan a phase ─────────────────────────────────────────────────────────────
scan_phase() {
  local phase_name="$1"; shift
  log ""
  log "${BLUE}── ${phase_name} ─────────────────────────────────────────────────${RESET}"
  local count=0
  while IFS= read -r -d '' file; do
    should_skip "$file" && continue
    apply_substitutions "$file"
    count=$((count + 1))
  done < <(find "$REPO_ROOT" \( "$@" \) -type f -print0 2>/dev/null)
  [ "$count" -eq 0 ] && log "  (no files matched)"
}

# ─── Header ──────────────────────────────────────────────────────────────────
log ""
log "${CYAN}═══════════════════════════════════════════════════════════════${RESET}"
log "${CYAN}  EGOS Rename: br-acc → egos-inteligencia${RESET}"
if $DRY_RUN; then
  log "${CYAN}  Mode: DRY RUN (safe — no files modified)${RESET}"
else
  log "${RED}  Mode: ⚠️  EXECUTE — APPLYING CHANGES${RESET}"
fi
log "${CYAN}  Repo: ${REPO_ROOT}${RESET}"
log "${CYAN}  Log:  ${LOG_FILE}${RESET}"
log "${CYAN}═══════════════════════════════════════════════════════════════${RESET}"
[ "$DRY_RUN" = true ] && log "${YELLOW}  To apply changes, run with --execute${RESET}"
log ""

# ─── Phases ──────────────────────────────────────────────────────────────────
scan_phase "Phase 1: Documentation" \
  -name "*.md" -o -name "*.txt" -o -name "*.rst" -o -name "*.html"

scan_phase "Phase 2: Python source + package config" \
  -name "*.py" -o -name "pyproject.toml" -o -name "setup.py" -o -name "setup.cfg"

scan_phase "Phase 3: Docker / YAML" \
  -name "*.yml" -o -name "*.yaml" -o -name "Dockerfile" -o -name "Dockerfile.*"

scan_phase "Phase 4: Shell / Makefile" \
  -name "*.sh" -o -name "Makefile"

scan_phase "Phase 5: JSON / TS / JS / TOML configs" \
  -name "*.json" -o -name "*.ts" -o -name "*.js" -o -name "*.toml"

# ─── Python package directory rename ─────────────────────────────────────────
log ""
log "${BLUE}── Python package directory rename ──────────────────────────────${RESET}"
BRACC_ETL_DIR="${REPO_ROOT}/etl/src/bracc_etl"
TARGET_DIR="${REPO_ROOT}/etl/src/egos_inteligencia_etl"
if [ -d "$BRACC_ETL_DIR" ]; then
  if $DRY_RUN; then
    log "  ${YELLOW}~ WOULD   ${RESET}  git mv etl/src/bracc_etl → etl/src/egos_inteligencia_etl"
  else
    git -C "$REPO_ROOT" mv "$BRACC_ETL_DIR" "$TARGET_DIR" 2>/dev/null || mv "$BRACC_ETL_DIR" "$TARGET_DIR"
    log "  ${GREEN}✓ RENAMED ${RESET}  etl/src/bracc_etl → etl/src/egos_inteligencia_etl"
  fi
else
  log "  (bracc_etl dir not found — may already be renamed)"
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
log ""
log "${CYAN}═══════════════════════════════════════════════════════════════${RESET}"
log "${CYAN}  SUMMARY — Files affected: ${CHANGED_FILES}${RESET}"
if $DRY_RUN; then
  log "${YELLOW}  DRY RUN complete — 0 files modified${RESET}"
  log "${YELLOW}  Run with --execute when ready${RESET}"
else
  log "${GREEN}  ✅ EXECUTED — ${CHANGED_FILES} files modified${RESET}"
  log ""
  log "${YELLOW}  ⚠️  MANUAL STEPS STILL REQUIRED:${RESET}"
  log "${YELLOW}  1. Rename GitHub repo: Settings → Rename → egos-inteligencia${RESET}"
  log "${YELLOW}  2. On Hetzner: docker network rename infra_bracc infra_egos_inteligencia${RESET}"
  log "${YELLOW}  3. Redeploy: cd /app/br-acc/infra && docker compose up -d${RESET}"
  log "${YELLOW}  4. Update any external DNS / webhook URLs${RESET}"
  log "${YELLOW}  5. git add -A && git commit -m 'feat: rename br-acc → egos-inteligencia'${RESET}"
  log "${YELLOW}  6. git push && update remote URL if repo renamed${RESET}"
fi
log "${CYAN}  Full log: ${LOG_FILE}${RESET}"
log "${CYAN}═══════════════════════════════════════════════════════════════${RESET}"
