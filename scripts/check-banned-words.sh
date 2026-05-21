#!/usr/bin/env bash
# Banned Words Gate — A53 enforcement (INC-2026-05-08)
# Bloqueia palavras absolutas em copy pública staged: 100%, perfeito, garantido, infalível, único no Brasil, primeiro do Brasil
# SSOT: ~/.claude/CLAUDE.md §1 "Banned absolutes"
#
# Dispara quando: staged diff toca arquivos de copy pública (*.md *.html *.jsx *.tsx *.txt)
# Modo: warn-only padrão | EGOS_BANNED_STRICT=1 → bloqueia
# Skip: EGOS_BANNED_SKIP="motivo"

set -eu

# Só checar arquivos de copy pública (não código)
COPY_PATTERNS='\.md$|\.html$|\.jsx$|\.tsx$|\.txt$|\.json$'

CHANGED=$(git diff --cached --name-only 2>/dev/null | grep -E "$COPY_PATTERNS" || true)
if [ -z "$CHANGED" ]; then exit 0; fi

# Skip explícito
if [ -n "${EGOS_BANNED_SKIP:-}" ]; then
  echo "⚠️  BANNED WORDS: SKIP autorizado: $EGOS_BANNED_SKIP"
  exit 0
fi

# Palavras banidas (insensível a maiúsculas)
BANNED_REGEX='100%|perfeito|garantido|infalível|infalivel|único no Brasil|unico no Brasil|primeiro do Brasil|sem erros|100 por cento'

FOUND=""
while IFS= read -r file; do
  [ -f "$file" ] || continue
  MATCHES=$(git diff --cached "$file" | grep '^+' | grep -iv "$BANNED_REGEX" >/dev/null && echo "" || \
            git diff --cached "$file" | grep '^+' | grep -iE "$BANNED_REGEX" 2>/dev/null || true)
  if [ -n "$MATCHES" ]; then
    FOUND="${FOUND}\n${file}:\n${MATCHES}"
  fi
done <<< "$CHANGED"

if [ -z "$FOUND" ]; then exit 0; fi

echo ""
echo "🚨 BANNED WORDS GATE — palavras absolutas detectadas em copy pública:"
echo -e "$FOUND"
echo ""
echo "   Substituir por: 'alta acurácia validada', 'múltiplas camadas de validação',"
echo "   'resistente e auditável', 'bem testado em produção'"
echo "   Fundamento: A53 (Karpathy Doctrine) — não existe 100% no universo."
echo ""
echo "   Skip: EGOS_BANNED_SKIP='justificativa' git commit ..."

if [ "${EGOS_BANNED_STRICT:-0}" = "1" ]; then
  echo "🔒 STRICT MODE — commit bloqueado."
  exit 1
fi

echo "⚠️  WARN-ONLY — commit prossegue. Set EGOS_BANNED_STRICT=1 para bloquear."
exit 0
