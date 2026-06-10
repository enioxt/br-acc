# UPSTREAM_KERNEL.md — br-acc

> **SSOT:** `egos/agents/registry/leaf-repos.json` | **Kernel:** `/home/enio/egos` | **Gerado em:** 2026-06-10 (MYCELIUM-006)

## O que este repositório herda do kernel EGOS

Este repo (`br-acc`) é um **leaf** (anel R2) do ecossistema EGOS. Recebe propagação de governança via `disseminate-propagator.ts`.

### Artefatos propagados automaticamente

| Arquivo | O que contém | Como é atualizado |
|---------|-------------|-------------------|
| `CLAUDE.md` | Bloco `# EGOS-KERNEL-PROPAGATED:` com regras R0-R8 | `bun ~/egos/scripts/disseminate-propagator.ts --all` |
| `.windsurfrules` | Mesmas regras em formato Windsurf | idem |
| `AGENTS.md` | Regras de agentes do kernel (se presente) | idem |

### O que NÃO é propagado (per-repo, adaptar localmente)

- `README.md` — conteúdo específico de br-acc
- Migrations, seeds, lógica de negócio
- Secrets, `.env`

## Como receber uma atualização do kernel

```bash
# No kernel (~/egos):
bun scripts/disseminate-scanner.ts
bun scripts/disseminate-propagator.ts --repo /home/enio/br-acc
```

## Contexto do repositório

**br-acc** — EGOS Inteligência: Plataforma Aberta de Cruzamento de Dados Públicos. Leaf do ecossistema EGOS.

---
*Mantido automaticamente pelo EGOS kernel. Edite via `~/egos/agents/registry/leaf-repos.json`.*
