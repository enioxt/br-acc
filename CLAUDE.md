# EGOS-KERNEL-PROPAGATED: 2026-06-18
<!-- AUTO-INJECTED by disseminate-propagator.ts — DO NOT EDIT THIS BLOCK MANUALLY -->
<!-- Kernel commit: 65e955cd | 2 rule section(s) changed -->
<!-- Source of rules: egos/AGENTS.md (canonical). Kernel-only authoritative copy: ~/.claude/CLAUDE.md -->
<!-- Re-run: bun ~/egos/scripts/disseminate-propagator.ts --all to update -->
<!-- - CLAUDE.md (1 lines) -->
<!-- + CLAUDE.md → ## R-DIAG-001 — Diagnóstico Antes de Demo [T1 — Enio 2026-06-09, reforçado 2026-06-18] (7 lines) -->

> ⚠️ **PROPAGATED FROM KERNEL** — Edits to this block are overwritten by next `bun governance:sync:exec`.
> Edit kernel `egos/AGENTS.md` section between `<!-- PROPAGATE-RULES-BEGIN -->` and `<!-- PROPAGATE-RULES-END -->` instead.

<!-- === BEGIN KERNEL RULES BODY (auto-injected from egos/AGENTS.md) === -->

## 📋 Canonical Rules (authoritative across ALL IDEs)

This section is the single source of truth for agent rules. Claude Code reads this. Windsurf reads this. Cursor reads this. Codex reads this. GitHub Copilot reads this. When `~/.claude/CLAUDE.md`, `.windsurfrules`, or repo-level `CLAUDE.md` diverge from this file, **AGENTS.md wins**. **Cláusula-árbitro (C1/C2 — Fable 2026-06-09):** Regras de agente (comportamento/código/SSOT): AGENTS.md vence. `.guarani` = índice de descoberta + enforcement de frozen-zones/pipeline; em conflito de REGRA, AGENTS.md vence; em conflito de PROCESSO/orquestração (`.guarani/orchestration/`), `.guarani` vence.

> 🃏 **4 pilares (TL;DR — resume R0-R8; conflito→texto completo. Corte Enio 2026-06-03):** **1)** §R0 safe-push, sem segredo, sem publish-sem-HITL, sem `git add -A`, commit TASKS.md já · **2)** §R1/R7 memory-mcp p/ código, externo=REAL/CONCEPT/PHANTOM, subagente=síntese, capacidade=≥3 golden cases, avaliador (Banda/Codex/Council) exige metaprompt MP-R1..R6 senão recusa (`docs/governance/METAPROMPT_STANDARD.md`) · **3)** §R3/R4/R8/RLS frozen via Prime/`EGOS_FROZEN_OVERRIDE`, Guarani propõe/Prime commita, DB schema-first+RLS anon · **4)** §R2/Karpathy mínimo código, falhe visível, SSOT>duplicação.
### Highest-Leverage Rule
EGOS maximizes value when it turns proven operational capability into governed reusable infrastructure.
Default path: prove in a real leaf/runtime → extract what is reusable → register canonical ownership → enforce evidence and eval → reduce replication cost for the next repo/agent/client. When in doubt, prefer extraction over duplication, canon over parallel docs, deploy traceability over informal runtime assumptions.

### R-DEV-001 — 100% AI-Driven Developer (No-Code Master) [T0 — 2026-06-10]
**Enio não escreve nem lê código cru** — dev 100% por IAs, que assumem total responsabilidade técnica (NUNCA pedir copy/paste ou edição manual; editar direto com tools). Comunicação no nível de comportamento de sistema/fluxos/interfaces renderizadas (HTML/dashboards) — nunca snippets ou prosa técnica de baixo nível na conversa.

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
5. **Proveniência-por-ação [T1 — Enio 2026-06-04, vale p/ TODO agente: Prime/Guarani/Codex/EVA/Hermes]:** antes de afirmar QUALQUER coisa sobre o sistema, cite a fonte consultada (`file:line`/comando). "Não existe X" exige busca **machine-wide**, não 1 diretório. **Marcar task `[x]` (done) exige EVIDÊNCIA verificável** (SHA do commit, arquivo gerado, `Closes/Fixes`, ou prova reproduzível) — `[x]` sem evidência = **phantom-done** (caso real: LANDING-EVOLVE-001 marcado done por Guarani sem `egos-web` ter mudado, 2026-06-04). Enforcement: gate `phantom-done` no `.husky/pre-commit` + espelha `provenance.py`/`.ts` (rigor de dados → afirmações). SSOT: `~/.claude/CLAUDE.md` §1. **§5b PHANTOM-CLOSE [T1 — Enio 2026-06-11, incidentes 83ce33bc/81386682]:** task ABERTA (`- [ ]`/`- [/]` com **ID**) NUNCA é deletada do TASKS.md nem arquivada sem prova — fechar = marcar `[x]` com evidência dura DEPOIS do ✅ (`✅ YYYY-MM-DD <SHA|URL|PR #>`); o auto-archive move. Evidência no corpo da task NÃO conta (corpo carrega URLs/SHAs de anotação). Enforcement executável (7/7 golden 2026-06-11): gate `0pre-b` no `.husky/pre-commit` + guard `PHANTOM-CLOSE` no `.husky/pre-push` (pega `--no-verify` e commits de fora). Override consciente: `EGOS_TASK_DELETE_OK=1` (logado). Outra janela marcou done? NÃO confie — verifique a prova; sem prova, reabra citando o SHA do fechamento phantom.

### R2 — SSOT integrity
1. **Scored SSOT tables** (columns: `Compliance`/`Score`/`%`/`Coverage`/`Maturity`/`Readiness`/`Grade`) MUST be wrapped in `<!-- AUTO-GEN-BEGIN:<agent> -->` / `<!-- AUTO-GEN-END -->` populated by a compliance agent, OR every row MUST carry `VERIFIED_AT` + `method` + `evidence` (file:line or cmd output SHA). Handwritten scored tables are PHANTOM VECTORS. Pre-commit blocks after MSSOT-002 ships (INC-006).
2. **Use-case scoped scoring** — before applying a uniform rubric across products, declare each product's primary use case. Mark rubric rows REQUIRED/OPTIONAL/N/A per use case. `N/A (use case: X)` is valid, not a fail. Cannot use single score column across heterogeneous use cases (INC-006).
3. **ONE SSOT per domain** — see "SSOT Map" section below. New content goes to existing SSOT, never new file. Prohibited: `docs/business/`, `docs/sales/`, `docs/notes/`, `docs/tmp/`, timestamped docs, `AUDIT*.md`, `REPORT*.md`, `DIAGNOSTIC*.md` (except in `_archived/`).
4. **Evidence-first** — every claim in durable docs (README, SSOT, article) needs: automated test exercising it, metric confirming the number, entry in manifest (`.egos-manifest.yaml` or `CAPABILITY_REGISTRY.md`), or dashboard tile. Unproven claims marked `unverified:`.
5. **Reuse-first em leaf-repos (INC-009).** Antes de criar `<leaf>/docs/governance|specs/X.md` ou doc de agente/prompt/registry/capability: glob `<leaf>/lib/{prompts,config,agents}/*.ts` + read `<leaf>/AGENTS.md`(full)/`CLAUDE.md`/`UPSTREAM_KERNEL.md`/`PROMPT_REGISTRY.md` + grep kernel `CAPABILITY_REGISTRY.md`. 1+ existe → **ESTENDER, não duplicar**. Sprint cross-repo → entry `COORD-YYYY-MM-DD-X` em `COORDINATION.md` antes do commit. Postmortem: `docs/INCIDENTS/INC-009-leaf-silo-work.md`.
6. **Arquivos essenciais = roteadores enxutos, não enciclopédias (2026-06-09).** CLAUDE.md/AGENTS.md/MEMORY.md/memory-files são índice→temático→profundo→evidência. Orçamento de instrução: arquivo carregado toda sessão <200L (warn 300); comandos/skills warn-only (nunca bloqueiam). **Loop de captura:** toda decisão/aprendizado validado → memória → regra-quando-estável (não morre no transcript). Raiz do sprawl de memória = dedup/supersessão (não contagem de linha). Freshness mínima: `last_update`+`status`. SSOT: `docs/governance/ESSENTIAL_FILES_ARCHITECTURE.md`.

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
| INC-GATEWAY-001 | HTTP header values devem ser ASCII puro — em dash `—` e outros não-ASCII causam Hono 500 (2026-06-09). Strings estáticas em `c.header()` → verificar. |

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
**R-ARCH-001 [T1] — EGOS mostra o FLUXO, não decide pelo cliente (Enio 2026-06-10):** vendor/preço/prazo/stack/canal de CLIENTE sem confirmação = PARE → placeholder (`{PAYMENT_PROVIDER}`/`{PRICE}`/`{TIMELINE}`) + trade-off; cliente escolhe no diagnóstico. Consolida R-DIAG-002..006+VENDOR. Full: `egos/CLAUDE.md §R-ARCH-001`.
**R-SEC-003 [T1] — Segurança = enforcement:** toda regra de segurança DEVE ter gate executável. Scanner sem wiring = doc morto. Sugestão mock/fixture: `// scan-ok: mock` ou `<!-- scan-ok -->`. SSOT: `docs/INCIDENTS/INC-PII-001_investigation-data-leak.md`.
**R-ENV-001..005 [T1] — ENV Discipline (ENV-MASTER-001 2026-06-16):** SSOT `docs/governance/ENV_DISCIPLINE.md`; inventário `docs/governance/ENV_MASTER_MAP.md` (commitável, zero valores); gerador `scripts/env-master.ts`; master local `egos/.env.master` (chmod 600, gitignored). **(1) [T0]** `.env`/`.env.local`/`.env.master`/`.env.*.local` NUNCA no git — gate pre-commit `[1.55/5]` bloqueia por nome (pega `git add -f`); permitidos `.example`/`.template`/cifrados; override logado `EGOS_ENV_OVERRIDE=1`. **(2)** master é gerado, não editado à mão (mudar valor = editar `.env` do repo + regenerar). **(3)** trava local chmod 600 + transferência só cifrada (`gpg --symmetric`). **(4)** só o mapa vai pro git. **(5)** MCP/config sem secret hardcoded (`$VAR`, herda `ENVIRONMENT_REGISTRY.md §2`). Master SECCIONADO por repo: 79 chaves divergem entre projetos, merge achatado corromperia.
**R-DISCOVER-001 [T2] — Discover-before-create (2026-06-08):** antes de criar capability nova (package/command/skill/CBC/registry), rodar `bun scripts/discover-capability.ts <termo>` e incluir `CONSULTED-SSOT: <resultado>` no commit body. Gate 14 bloqueia sem prova. Escape: `DISCOVER-GATE-SKIP: <razão>`. Evita INC-009-leaf-silo.
**R11 [T2] — Observabilidade warn-not-block (2026-06-05):** falha em telemetria/agent-observatory = warn-only, nunca bloqueia execução de agente. SSOT: `docs/governance/MULTI_AGENT_OBSERVABILITY.md`.
**R12 [T2] — Núcleo multi-LLM replicável (FABLE-OR-001 — 2026-06-14):** Banda Cognitiva (`/banda`), Council (`/council`) e chamadas avulsas a LLM rodam sobre o módulo compartilhado `packages/shared/src/llm-providers/` (zero hardcode de path/slug). Qualquer repo/agente da frota usa copiando o módulo + os scripts desejados, definindo `OPENROUTER_API_KEY` e (se não for `egos`) `EGOS_HOME=<raiz>`. Slugs/modelos sobrescrevíveis por env (`BANDA_MAESTRO_MODEL`, `COUNCIL_SYNTHESIZER_MODEL`, etc.). **Maestro da Banda = Opus pela assinatura (`cli:claude:opus`), permanente; Fable nunca é maestro.** Guia de replicação: `packages/shared/src/llm-providers/README.md`. Não pagar Opus via OpenRouter — temos a assinatura.

<!-- === END KERNEL RULES BODY === -->

---

# CLAUDE.md — EGOS Inteligência (egos-inteligencia)

> Lido automaticamente pelo Claude Code CLI ao executar `claude` neste diretório.

## Projeto

**EGOS Inteligência** — Plataforma open-source de inteligência sobre dados públicos brasileiros. Grafo com 77M entidades (59.5M empresas + 17.5M sócios + 7K pessoas) e 25.1M relacionamentos. Deploy em produção: `https://inteligencia.egos.ia.br`.

Repositório público: `github.com/enioxt/EGOS-Inteligencia`

## Bloqueio Crítico Atual

**ETL CNPJ preso a 90%** — O serviço `egos-inteligencia-etl.service` está inativo. A Fase 3 carregou massa crítica, mas o pós-load falhou com `Neo.ClientError.Statement.ParameterMissing: Expected parameter(s): run_id`. Fix local já aplicado em `etl/src/egos_inteligencia_etl/linking_hooks.py` e `runner.py` — **falta redeploy/reexecução no VPS**.

## Arquitetura

```text
egos-inteligencia/
├── api/             # FastAPI backend (Python 3.12, uvicorn)
│   └── src/egos_inteligencia/   # routers (search, meta, entity), services (cache.py), config
├── etl/             # 46 pipelines ETL (Python, ingestão Neo4j)
│   └── src/egos_inteligencia_etl/
│       ├── linking_hooks.py   # FIX APLICADO (run_id bug)
│       └── runner.py          # FIX APLICADO (run_id bug)
├── frontend/        # React 18 + Vite + TypeScript
├── infra/           # Docker Compose, nginx, scripts VPS
│   └── scripts/     # neo4j-memory-upgrade.sh, post-etl-optimize.sh
├── scripts/         # Automação, segurança, auditoria
├── docs/            # Técnicos, análise, legal
│   └── showcase/    # patense-investigation.html
├── .guarani/        # Regras de código locais (framework EGOS)
└── .windsurf/       # Workflows + skills
```

## Stack

| Camada | Tecnologia |
|--------|-----------|
| **Backend** | Python 3.12, FastAPI, uvicorn |
| **Frontend** | React 18, Vite, TypeScript, CSS Modules |
| **Banco Principal** | Neo4j 5.x (grafo) |
| **Cache** | Redis (cache-aside, TTL configurável) |
| **AI** | OpenRouter (Gemini Flash / GPT-4o-mini) |
| **Deploy** | Docker Compose no Contabo VPS |
| **ETL** | Python ETL + tmux/systemd + monitor script |

## Comandos Principais

```bash
# Local
pip install -e etl/           # Instalar ETL em modo dev
pytest etl/tests/             # Rodar testes do ETL

# VPS (217.216.95.126, /opt/egos_inteligencia)
ssh root@217.216.95.126
cd /opt/egos_inteligencia
docker compose ps             # Estado dos 5 containers
docker compose logs api -f    # Logs da API
systemctl status egos-inteligencia-etl    # Status do ETL service (deve estar ativo)

# ETL (executar no VPS após fix de run_id)
# Ver README do ETL para comando exato de retomada da Fase 3

# API
curl https://inteligencia.egos.ia.br/api/v1/meta/etl-progress
curl https://inteligencia.egos.ia.br/api/v1/meta/cache-stats
```

## Regras

- Leia `.guarani/PREFERENCES.md` para padrões de código locais
- Commits convencionais: `feat:`, `fix:`, `chore:`, `docs:`
- Todo claim de capacidade deve ter evidência de runtime (sem "running" sem prova)
- LGPD/segurança: masking obrigatório em outputs públicos
- Novas features devem fortalecer o caso de referência para EGOS Guard Brasil
- Kernel SSOT: `/home/enio/egos/docs/SSOT_REGISTRY.md`

## Infraestrutura VPS

| Item | Valor |
|------|-------|
| **VPS Atual** | Contabo — 217.216.95.126 (`/opt/egos_inteligencia`) |
| **Migração planejada** | Hetzner |
| **Docker stack** | 5/5 containers saudáveis |
| **ETL service** | `egos-inteligencia-etl.service` — INATIVO (bloqueado) |
| **Grafo atual** | 77,035,803 entidades, 25,091,492 `SOCIO_DE` |

## Estado do ETL (2026-03-18)

- Fase 1 (estab_lookup): status desconhecido
- Fase 2 (Company nodes): 8,860,601 carregados
- Fase 3 (Person/Partner + SOCIO_DE): massa crítica carregada, pós-load falhou
- Fase 4 (post-load hooks): bloqueada aguardando Fase 3 completar
- Fix local (`run_id`): aplicado em `linking_hooks.py` e `runner.py` — aguarda redeploy

---

## Regra: Próxima Task

Quando iniciado neste repositório e perguntado "qual a próxima task?" ou "what's next?":
1. Leia este CLAUDE.md para contexto
2. Leia TASKS.md e identifique a task P0/P1 de maior prioridade incompleta
3. Leia PRs abertos: `gh pr list`
4. Responda com: task ID, descrição, arquivos envolvidos, e próximo passo concreto
Sem fricção. Direto ao ponto.

# INC-003 ANTI-HALLUCINATION (2026-04-08): Before adding task→verify artifact exists. After implement→mark [x] same commit. Checklist→spot-check top 5 P0/P1 tasks.
