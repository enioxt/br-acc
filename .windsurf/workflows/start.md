---
description: Session initialization for EGOS Inteligência
---

# /start — Session Initialization (v2.0)

## 1. Load Core Context

Read these files in order:

- `AGENTS.md` — Project config, stack, commands
- `TASKS.md` — Current priorities (P0 → P1 → P2)
- `.guarani/PREFERENCES.md` — Coding standards
- `.guarani/IDENTITY.md` — Agent identity and mission

## 2. Load Orchestration (from egos-lab)

Read on demand for MODERATE+ tasks:

- `egos-lab/.guarani/orchestration/PIPELINE.md` — 7-phase protocol
- `egos-lab/.guarani/orchestration/GATES.md` — Quality scoring
- `egos-lab/.guarani/orchestration/QUESTION_BANK.md` — Maieutic questions
- `.guarani/orchestration/DOMAIN_RULES.md` — Local domain checklists

## 3. Rule Validation

Read `.windsurfrules` and confirm:
- Print: "Rules v[X.X.X] loaded. Mandamentos: [count]. Frozen zones: [count]."

## 4. System Status

// turbo
- Recent commits: `git log --oneline -5`
// turbo
- VPS health: `ssh root@217.216.95.126 "cd /opt/bracc/infra && docker compose ps --format 'table {{.Name}}\t{{.Status}}' 2>/dev/null | head -10"`
// turbo
- API live check: `curl -sL --max-time 10 https://inteligencia.egos.ia.br/api/v1/meta/stats | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'Nodes: {d[\"total_nodes\"]:,} | Rels: {d[\"total_relationships\"]:,} | Sources: {d[\"loaded_sources\"]}/{d[\"data_sources\"]}')" 2>/dev/null || echo 'API UNREACHABLE — INVESTIGATE BEFORE PROCEEDING'`

## 5. Fork & Community Status (NEW in v2.0)

// turbo
- Upstream sync: `git fetch upstream --quiet 2>/dev/null && echo "Behind upstream by $(git rev-list HEAD..upstream/main --count) commits" || echo "No upstream remote"`
// turbo
- Open PRs: `gh pr list --state open --limit 5 2>/dev/null || echo "gh not configured"`
// turbo
- Recent issues: `gh issue list --state open --limit 5 --sort created 2>/dev/null || echo "gh not configured"`
// turbo
- Forks: `gh api repos/enioxt/EGOS-Inteligencia --jq '.forks_count' 2>/dev/null || echo "?"`

## 6. Output Briefing

Present to user:

- **Rules:** Version + mandamento count
- **Tasks:** P0 blockers → P1 sprint → P2 backlog (counts)
- **Recent commits:** Last 5
- **VPS:** Container status + API live stats
- **Fork:** Upstream delta, open PRs, recent issues, fork count
- **Orchestration:** "Pipeline active. Gate threshold: 75."
