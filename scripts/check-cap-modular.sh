#!/usr/bin/env bash
# CAP-MODULAR Gate — K5 (GATES.md v2)
# Verifica se novo arquivo em packages/integrations/ tem entry em docs/CAPABILITY_REGISTRY.md
# SSOT: .guarani/orchestration/GATES.md K5 + docs/CAPABILITY_REGISTRY.md
#
# Dispara quando: staged diff adiciona arquivo em packages/integrations/
# Modo: warn-only padrão | EGOS_CAP_STRICT=1 → bloqueia

set -eu

# Só verifica se há mudanças em packages/integrations/
NEW_INTEGRATIONS=$(git diff --cached --name-only 2>/dev/null | grep '^packages/integrations/' || true)
if [ -z "$NEW_INTEGRATIONS" ]; then exit 0; fi

# Skip explícito
if [ -n "${EGOS_CAP_SKIP:-}" ]; then
  echo "⚠️  CAP-MODULAR: SKIP autorizado: $EGOS_CAP_SKIP"
  exit 0
fi

# Verificar se CAPABILITY_REGISTRY.md existe
REGISTRY="docs/CAPABILITY_REGISTRY.md"
if [ ! -f "$REGISTRY" ]; then
  echo "⚠️  CAP-MODULAR: docs/CAPABILITY_REGISTRY.md não encontrado"
  exit 0
fi

MISSING=""
while IFS= read -r file; do
  # Extrair nome da integração (packages/integrations/<nome>/...)
  INTEGRATION_NAME=$(echo "$file" | sed 's|packages/integrations/||' | cut -d'/' -f1)
  [ -z "$INTEGRATION_NAME" ] && continue

  # Verificar se há entry no registry
  if ! grep -qi "$INTEGRATION_NAME" "$REGISTRY" 2>/dev/null; then
    MISSING="${MISSING}\n  - ${INTEGRATION_NAME} (em ${file})"
  fi
done <<< "$NEW_INTEGRATIONS"

if [ -z "$MISSING" ]; then
  echo "✅ CAP-MODULAR: todas integrações registradas em CAPABILITY_REGISTRY.md"
  exit 0
fi

echo ""
echo "🚨 CAP-MODULAR GATE — integração nova sem entry em docs/CAPABILITY_REGISTRY.md:"
echo -e "$MISSING"
echo ""
echo "   Adicionar entrada com:"
echo "   ### CAP-INT-NNN: <nome>"
echo "   - Status: ✅ EM PRODUÇÃO (ou 🟡 PARCIAL)"
echo "   - SHA: <hash>"
echo "   - Cliente origem: <slug>"
echo "   - Reuso esperado: <vertical/cenário>"
echo ""
echo "   SSOT: .guarani/orchestration/GATES.md K5"
echo "   Skip: EGOS_CAP_SKIP='justificativa' git commit ..."

if [ "${EGOS_CAP_STRICT:-0}" = "1" ]; then
  echo "🔒 STRICT MODE — commit bloqueado."
  exit 1
fi

echo "⚠️  WARN-ONLY — commit prossegue. Set EGOS_CAP_STRICT=1 para bloquear."
exit 0
