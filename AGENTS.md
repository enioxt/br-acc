# EGOS-KERNEL-PROPAGATED: 2026-06-05
<!-- AUTO-INJECTED by disseminate-propagator.ts — DO NOT EDIT THIS BLOCK MANUALLY -->
<!-- Kernel commit: b94e86d4 | 1 rule section(s) changed -->
<!-- Source of rules: egos/AGENTS.md (canonical). Kernel-only authoritative copy: ~/.claude/CLAUDE.md -->
<!-- Re-run: bun ~/egos/scripts/disseminate-propagator.ts --all to update -->
<!-- + CLAUDE.md (1 lines) -->

> ⚠️ **PROPAGATED FROM KERNEL** — Edits to this block are overwritten by next `bun governance:sync:exec`.
> Edit kernel `egos/AGENTS.md` section between `<!-- PROPAGATE-RULES-BEGIN -->` and `<!-- PROPAGATE-RULES-END -->` instead.

<!-- === BEGIN KERNEL RULES BODY (auto-injected from egos/AGENTS.md) === -->

## 📋 Canonical Rules (authoritative across ALL IDEs)

This section is the single source of truth for agent rules. Claude Code reads this. Windsurf reads this. Cursor reads this. Codex reads this. GitHub Copilot reads this. When `~/.claude/CLAUDE.md`, `.windsurfrules`, or repo-level `CLAUDE.md` diverge from this file, **AGENTS.md wins**.

> 🃏 **4 pilares (TL;DR — resume R0-R8; conflito→texto completo. Corte Enio 2026-06-03):** **1)** §R0 safe-push, sem segredo, sem publish-sem-HITL, sem `git add -A`, commit TASKS.md já · **2)** §R1/R7 memory-mcp p/ código, externo=REAL/CONCEPT/PHANTOM, subagente=síntese, capacidade=≥3 golden cases · **3)** §R3/R4/R8/RLS frozen via Prime/`EGOS_FROZEN_OVERRIDE`, Guarani propõe/Prime commita, DB schema-first+RLS anon · **4)** §R2/Karpathy mínimo código, falhe visível, SSOT>duplicação.
### Highest-Leverage Rule
EGOS maximizes value when it turns proven operational capability into governed reusable infrastructure.
Default path: prove in a real leaf/runtime → extract what is reusable → register canonical ownership → enforce evidence and eval → reduce replication cost for the next repo/agent/client. When in doubt, prefer extraction over duplication, canon over parallel docs, deploy traceability over informal runtime assumptions.

### R0 — Critical non-negotiables (irreversible damage prevention)
1. **NEVER `git push --force` to main/master/production** — use `bash scripts/safe-push.sh` (INC-001)
2. **NEVER log/echo/commit secrets** — no `.env`, no hardcoded keys
3. **NEVER publish externally without human approval** — articles, X posts, outreach
4. **NEVER `git add -A` in background agents** — always `git add <specific-file>` (INC-002)
5. **COMMIT TASKS.md immediately** after edit (parallel agents lose uncommitted state)

### R1 — Verification before assertion
1. **Code claims** (function exists, caller count, import usage, dead code, route mapping) → `codebase-memory-mcp` is PRIMARY. Read/Grep is fallback for docs/config/markdown only. If `cbm-code-discovery-gate` hook fires, load MCP tools via ToolSearch; never bypass.
2. **External LLM paste** (ChatGPT/Gemini/Grok/Kimi/Perplexity output) → every named feature, commit, file, version = UNVERIFIED CLAIM. Classify REAL/CONCEPT/PHANTOM via `git log --grep` + `Glob`. High-density buzzword lists (8+ capitalized "systems") = phantom signal (INC-005).
3. **Subagent audits** (Agent/Explore/Plan outputs) = SYNTHESIS, not evidence. Before citing in commit/SSOT edit: re-verify top 3 structural claims via `codebase-memory-mcp`. Absolute audit claims ("X doesn't exist", "Y is skeleton") without file:line anchor = PHANTOM until verified (INC-006).
4. **When spawning Agent/Explore/Plan** → prompt MUST include: "return evidence tuples `{claim, evidence_path, evidence_line}`; prefix unanchored with `UNVERIFIED:`".
5. **Proveniência-por-ação [T1 — Enio 2026-06-04, vale p/ TODO agente: Prime/Guarani/Codex/EVA/Hermes]:** antes de afirmar QUALQUER coisa sobre o sistema, cite a fonte consultada (`file:line`/comando). "Não existe X" exige busca **machine-wide**, não 1 diretório. **Marcar task `[x]` (done) exige EVIDÊNCIA verificável** (SHA do commit, arquivo gerado, `Closes/Fixes`, ou prova reproduzível) — `[x]` sem evidência = **phantom-done** (caso real: LANDING-EVOLVE-001 marcado done por Guarani sem `egos-web` ter mudado, 2026-06-04). Enforcement: gate `phantom-done` no `.husky/pre-commit` + espelha `provenance.py`/`.ts` (rigor de dados → afirmações). SSOT: `~/.claude/CLAUDE.md` §1.

### R2 — SSOT integrity
1. **Scored SSOT tables** (columns: `Compliance`/`Score`/`%`/`Coverage`/`Maturity`/`Readiness`/`Grade`) MUST be wrapped in `<!-- AUTO-GEN-BEGIN:<agent> -->` / `<!-- AUTO-GEN-END -->` populated by a compliance agent, OR every row MUST carry `VERIFIED_AT` + `method` + `evidence` (file:line or cmd output SHA). Handwritten scored tables are PHANTOM VECTORS. Pre-commit blocks after MSSOT-002 ships (INC-006).
2. **Use-case scoped scoring** — before applying a uniform rubric across products, declare each product's primary use case. Mark rubric rows REQUIRED/OPTIONAL/N/A per use case. `N/A (use case: X)` is valid, not a fail. Cannot use single score column across heterogeneous use cases (INC-006).
3. **ONE SSOT per domain** — see "SSOT Map" section below. New content goes to existing SSOT, never new file. Prohibited: `docs/business/`, `docs/sales/`, `docs/notes/`, `docs/tmp/`, timestamped docs, `AUDIT*.md`, `REPORT*.md`, `DIAGNOSTIC*.md` (except in `_archived/`).
4. **Evidence-first** — every claim in durable docs (README, SSOT, article) needs: automated test exercising it, metric confirming the number, entry in manifest (`.egos-manifest.yaml` or `CAPABILITY_REGISTRY.md`), or dashboard tile. Unproven claims marked `unverified:`.
5. **Reuse-first em leaf-repos (INC-009).** Antes de criar `<leaf>/docs/governance/X.md`, `<leaf>/docs/specs/X.md`, ou qualquer doc descrevendo agente/sistema prompt/registry/capability:
   1. Glob `<leaf>/lib/prompts/*.ts`, `<leaf>/lib/config/*.ts`, `<leaf>/lib/agents/*.ts` — existe sistema prompt / tool registry / agent canonical?
   2. Read `<leaf>/AGENTS.md` (full — não só PROPAGATE block) e `<leaf>/CLAUDE.md`
   3. Read `<leaf>/lib/prompts/PROMPT_REGISTRY.md` se existir
   4. Read `<leaf>/docs/UPSTREAM_KERNEL.md` se existir
   5. Grep similar em `egos/docs/CAPABILITY_REGISTRY.md` (kernel)
   Se 1+ existe → **ESTENDER (mesmo arquivo, nova section)**, não duplicar. Sprint cross-repo (kernel + leaf na mesma sessão) → criar entry `COORD-YYYY-MM-DD-X` em `egos/docs/COORDINATION.md` antes de qualquer commit. Postmortem: `docs/INCIDENTS/INC-009-leaf-silo-work.md`.

### R3 — Edit safety
1. Read before Edit (at least the relevant section). Confirm exact string. Re-read after edit.
2. Max 3 edits per file before verification read.
3. Rename/signature change → grep all callers first.
4. Large files (>300 LOC): remove dead code first (separate commit), break into phases (max 5 files).
5. **Simplicity First (Karpathy):** minimum code that solves. No speculative abstractions. Wait for 3rd repetition before extracting. Test: "Would a senior engineer call this overcomplicated?"
6. **Fail Visibly (Karpathy/Mnilax):** never `|| true` on non-trivial operations. Errors must surface. Prefer `|| { echo "[ERROR] <context>"; exit 1; }`. Silent failures hide real bugs.
7. **State Assumptions First (Karpathy):** before implementing anything ambiguous, write out assumptions as a message or comment BEFORE writing code. If unclear, ask — don't guess silently.

### R4 — Git safety
1. Force-push forbidden on main/master/production/prod/release/hotfix. Exception: `EGOS_ALLOW_FORCE_PUSH=1` in shell only.
2. Always `bash scripts/safe-push.sh <branch>` (fetch+rebase+retry).
3. `.husky/pre-push` blocks non-FF. Answer = `git fetch && git rebase`, never `--no-verify`.

### R5 — Context & swarm
1. Use Agent tool when: 5+ files to read, >3 Glob/Grep rounds expected, research+implement needed. Don't spawn for single-file edits, git ops, known answers.
2. Independent tasks → all agents in ONE message. Dependent → sequential.
3. After 10+ turns or compaction: re-read TASKS.md + current file.
4. Cost control: 3 retries fail on same error → STOP, flag `[BLOCKER]`.
5. **Session checkpoint:** when pre-commit emits `[CHECKPOINT-NEEDED]` (turns≥10/commits≥15/elapsed≥90min), invoke `/checkpoint` (Hard Reset). Use `bun scripts/session-init.ts --status` to check. Never ignore [CHECKPOINT-NEEDED].

### R6 — Incident-driven (always load when relevant)
| Incident | Rule |
|---|---|
| INC-001 | Force-push protocol — `bash scripts/safe-push.sh` |
| INC-002 | Git swarm — `git add <specific>`, commit TASKS.md first |
| INC-003 | TASKS.md — verify artifact before adding, mark `[x]` same commit |
| INC-004 | Supabase Realtime quota — rate limiter + retention |
| INC-005 | External LLM narrative — classify REAL/CONCEPT/PHANTOM |
| INC-006 | RLS policy role validation (28 tables `{public}`) — see R-RLS-001; subagent phantoms + scored SSOT tables — see R1.3, R2.1-2 |
| INC-007 | API key exposure via `|| fallback` pattern — never commit secrets |
| INC-008 | Phantom compliance stubs — see R7 below |
| INC-009 | Leaf-repo silo-work (agente cria SSOT paralelo ignorando canonical existente) — see R2.5 above. `/start` LAYER 4.6 força leitura de SSOTs do leaf antes de qualquer write |

Full postmortems: `docs/INCIDENTS/INC-XXX-*.md`. Index: `docs/INCIDENTS/INDEX.md`.

### R-RLS-001 — Row-Level Security (INC-006, 2026-05-05)
Every RLS policy MUST have explicit `TO <role>`. No `{public}` on sensitive tables (`users`, `*_keys`, `*_secrets`, `admin_*`). Validator: `scripts/security/rls-validator.ts`. Continuous auditor: `scripts/security/rls-auditor-comprehensive.ts` (VPS cron daily 2 AM UTC). Setup: `docs/jobs/SUPABASE_RLS_AUDIT_SETUP.md`. Override: `RLS-POLICY-OVERRIDE: <reason>`.

### R7 — Behavioral eval required for claimed capabilities (INC-008, 2026-04-22)

**Rule:** Any capability a system claims (in manifest, README, docs, CAPABILITY_REGISTRY, or `/api/*/discover` response) MUST have a **behavioral eval** proving it at runtime.

- **"Behavioral"** = simulates real usage (full input→output pipeline), not shape assertions on pure functions.
- Unit test of `detectPII()` returning correct findings is **NOT** enough — it doesn't prove `detectPII()` is being called in the code path that claims PII masking.
- Golden case that POSTs a chat message containing a CPF and asserts the response has no unmasked CPF **IS** behavioral.

**Why (INC-008, 2026-04-22):** Intelink's `lib/shared.ts` exported stub implementations of `scanForPII`/`sanitizeText`/`createAtrianValidator` that returned `[]`/unchanged/always-passed. Route imported these expecting real work. Manifest claimed `pii-masking` + `atrian-validation`. Type checker, linter, 151 unit tests all green. For weeks/months, PII leaked in every production response. Golden eval's first live run caught it in 1 day.

**How to apply:**
1. **New capability in manifest/README → ≥3 golden cases before merge.** If the capability is `X`, at least one case must be designed so that if the underlying code were a stub, the case would fail.
2. **Stubs in compliance/safety code paths are FORBIDDEN in main.** Use `throw new Error('NOT IMPLEMENTED — see TODO-XXX')` during refactors so CI fails loudly, not a silent no-op returning `[]`/`true`/unchanged input.
3. **`try { compliance() } catch { /* non-fatal */ }` patterns MUST log + alert.** Silent swallow is how stubs hide.
4. **Weekly eval against production.** Pass-rate drop = something regressed silently. See `@egos/eval-runner` + `intelink/tests/eval/` for reference.
5. **Canonical eval harness:** `packages/eval-runner/` (extracted from 852's battle-tested runner + trajectory + judge-LLM). Adopt it, don't reinvent. promptfoo layers on top for YAML cases + redteam (Phase B of EVAL track).

**Pattern to detect in code review:**
- File named `*.shared.ts`, `*.stubs.ts`, `*-placeholder.ts` exporting functions with non-trivial signatures returning trivial defaults
- Capability listed in manifest with no corresponding `tests/eval/golden/*.ts` case
- Green CI + green typecheck + green unit tests but no end-to-end eval

Full postmortem: `docs/INCIDENTS/INC-008-phantom-compliance-stubs.md`.
Canonical eval strategy: `docs/knowledge/AI_EVAL_STRATEGY.md` (being written — see EVAL-X2).

### R8 — DB Discipline (INC-DB-001 — 2026-05-22)

> SSOT completo: `docs/governance/DB_DISCIPLINE.md`. Pre-commit enforcement: `scripts/pre-commit-db-discipline.sh`.

1. **R-DB-001 Schema-First** — scripts Supabase usam tipos gerados / zod. Nunca literal solto `{ is_active: true }` (PostgREST ignora colunas erradas em silêncio → bug invisível).
2. **R-DB-002 Smoke ANON pós-write** — todo seed/migration termina com SELECT count usando ANON, assertando ≥ expected.
3. **R-DB-003 RLS anon explícito** — migration de tabela usada por storefront DEVE incluir `CREATE POLICY ... TO anon, authenticated USING (...)` no mesmo arquivo. Nunca `current_setting('app.*')`.
4. **R-DB-004 SSOT-only** — fixes em `central-egos/template/` (ou equivalente leaf). Nunca em `clients/<slug>/src/`. **Incidente origem:** FVP seed v2 usou `is_active`, 32 rows defaultaram `active=false`, storefront 0 produtos 12h (RLS exigindo session var não-setada).

**R9 — Agentic Governance & Scopes (2026-05-30):** agentes seguem escopos/permissões/notificação de [agent_scopes_and_governance.md](docs/governance/agent_scopes_and_governance.md). Out-of-scope → lock `.egos-lock` + escalar Council/HITL (Telegram/WhatsApp). Anti-repetição: checar `TASKS.md` + `git log` antes de planejar.

**R10 — Cooperação e Banda Cognitiva (Guarani ↔ Prime - 2026-06-04):** O Guarani (runtime Antigravity/Gemini) propõe código e correções técnicas, mas NUNCA realiza commits diretamente. Toda alteração de produção proposta pelo Guarani DEVE passar pela revisão final do Prime (Claude Code/Opus). Decisões de segurança crítica, modificações no schema de Banco de Dados, regras de RLS ou arquivos em Frozen Zones exigem obrigatoriamente a invocação da Banda Cognitiva (`/banda`) com Força Total (`--council` acionando Opus/Gemini Pro/GPT-5 via OpenRouter), assegurando verificação estrutural e AST anti-phantom.

**R-SEC-002 [T0] — Dado soberano nunca sai da máquina (INC-PII-001 2026-06-04):** dado real de investigação / PII de terceiros / dado PCMG NUNCA versionado em git (nem privado), NUNCA servido em domínio público, NUNCA em VPS/nuvem. Git = apenas dados sintéticos; dado real = local cifrado. App com dado real → nunca domínio público aberto. Scanner pré-commit: `bun scripts/security/scan-hardcoded-sensitive.ts --staged`.
**R-SEC-003 [T1] — Segurança = enforcement:** toda regra de segurança DEVE ter gate executável. Scanner sem wiring = doc morto. Sugestão mock/fixture: `// scan-ok: mock` ou `<!-- scan-ok -->`. SSOT: `docs/INCIDENTS/INC-PII-001_investigation-data-leak.md`.

<!-- === END KERNEL RULES BODY === -->

---

# AGENTS.md — EGOS Inteligência (BR/ACC)

> **VERSION:** 1.1.0 | **UPDATED:** 2026-03-06
> **TYPE:** Intelligence Platform

---

<!-- llmrefs:start -->

## LLM Reference Signature

- **Role:** workspace map + governance entrypoint
- **Summary:** Brazilian public accountability intelligence platform. Python ETL pipelines consuming 21 government APIs (Transparência, TCU, CNPJ, CEP). Neo4j graph database with 47 Cypher queries. Proof-of-research SHA-256 non-repudiation. Source of BRACC-001..003 (provenance, cache, pipeline-base modules extracted to EGOS shared).
- **Read next:**
  - `TASKS.md` — current priorities and blockers
  - `docs/` — architecture and module documentation

<!-- llmrefs:end -->

## Project Overview

| Item | Value |
|------|-------|
| **Projeto** | EGOS Inteligência (BR/ACC) |
| **Descrição** | Plataforma open-source de inteligência sobre dados públicos brasileiros |
| **Path** | /home/enio/egos-inteligencia |
| **VPS** | 204.168.217.125 (Hetzner, /opt/egos_inteligencia) |
| **Repo** | github.com/enioxt/EGOS-Inteligencia |
| **Kernel SSOT Registry** | `/home/enio/egos/docs/SSOT_REGISTRY.md` |
| **Deploy** | Docker Compose no VPS (API + Frontend + Neo4j + Redis) |
| **URL** | inteligencia.egos.ia.br |
| **Framework** | EGOS (egos-lab) — regras compartilhadas |

## Architecture

```
egos-inteligencia/
├── api/             # FastAPI backend (Python 3.12, uvicorn)
│   └── src/egos_inteligencia/   # Core: routers, services, config
├── etl/             # 46 ETL pipelines (Python, Neo4j ingestion)
├── frontend/        # React 18 + Vite + TypeScript
├── infra/           # Docker Compose, nginx, scripts VPS
├── scripts/         # Automation, security, audit
├── docs/            # Technical docs, analysis, legal
├── .guarani/        # LOCAL coding rules (from EGOS framework)
└── .windsurf/       # Workflows + skills
```

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Backend** | Python 3.12, FastAPI, uvicorn |
| **Frontend** | React 18, Vite, TypeScript, CSS Modules |
| **Database** | Neo4j 5.x (graph), Redis (cache) |
| **AI** | OpenRouter (Gemini Flash / GPT-4o-mini) |
| **Deploy** | Docker Compose on Hetzner VPS |
| **ETL** | Python ETL + tmux/manual orchestration + monitor script |

## Commands

```bash
# Development
cd api && uv run uvicorn src.egos_inteligencia.main:app --reload --port 8000
cd frontend && npm run dev

# Testing
cd api && uv run pytest -x --tb=short     # 235+ tests
cd frontend && npm test                     # Frontend tests

# VPS Operations
ssh root@204.168.217.125
cd /opt/egos_inteligencia/infra && docker compose restart api
cd /opt/egos_inteligencia/infra && docker compose build frontend && docker compose up -d frontend
docker compose logs -f api --tail 50

# Quick checks
cd api && uv run ruff check src/           # Python lint (~5s)
cd frontend && npx tsc --noEmit --pretty false 2>&1 | grep "error TS" | head -20

# Deploy
git push origin main                        # Then VPS: git pull + docker compose restart
```

## SSOT Files (5 govern everything)

| File | Purpose |
|------|---------|
| `AGENTS.md` | Project config (this file) |
| `TASKS.md` | All tasks (SSOT) |
| `.windsurfrules` | Agent rules |
| `.guarani/PREFERENCES.md` | Coding standards |
| `.guarani/IDENTITY.md` | Agent identity |

## Frozen Zones

> **DO NOT EDIT** without explicit user request:
> - **Auth/JWT:** `api/src/egos_inteligencia/auth.py`, JWT secret config
> - **Docker Compose:** `infra/docker-compose.yml` (production topology)
> - **ETL in progress:** Any ETL pipeline currently running (TASK-001)
> - **Neo4j schema:** Node labels and relationship types in production

## Key Metrics

| Metric | Value |
|--------|-------|
| Neo4j Entities | 77,035,803 |
| Neo4j Relationships | 25,091,492 `SOCIO_DE` |
| Data Sources Loaded | 36 |
| Data Sources Mapped | 108 |
| AI Chat Tools | 26 |
| Pattern Detectors | 10 |
| ETL Pipelines | 46 |
| Production Containers | 5/5 healthy |
| ETL Reality Check | Phase 3 interrompida em 17,454,980 / 24.6M Partner (~70%) |
| ETL Control Plane | `egos-inteligencia-etl.service` inactive; `/api/v1/meta/etl-progress` stale em 90% |
| Monthly Cost | ~$36 |

## Sibling Projects

| Project | Path | Relationship |
|---------|------|-------------|
| egos-lab | /home/enio/egos-lab | Framework (shared rules canonical here) |
| carteira-livre | /home/enio/carteira-livre | Separate product (DO NOT MIX) |

## Legal & Ethics Docs (root level)

| File | Purpose |
|------|---------|
| `ETHICS.md` | Prohibited uses, non-accusatory language |
| `LGPD.md` | Data protection baseline |
| `PRIVACY.md` | Privacy policy |
| `TERMS.md` | Terms of service |
| `DISCLAIMER.md` | Legal disclaimer |
| `SECURITY.md` | Security policy |
| `ABUSE_RESPONSE.md` | Abuse handling |

---

*"Dados públicos, código aberto, transparência real."*
