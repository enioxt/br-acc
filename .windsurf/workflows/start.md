---
description: Session initialization for EGOS Inteligência
---

# /start — Session Initialization (v1.0)

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

- Recent commits: `git log --oneline -5`
- VPS health: `ssh root@217.216.95.126 "cd /opt/bracc/infra && docker compose ps --format 'table {{.Name}}\t{{.Status}}' 2>/dev/null | head -10"`
- Neo4j: `curl -s http://217.216.95.126:8000/api/v1/meta/health`

## 5. Output Briefing

Present to user:

- **Rules:** Version + mandamento count
- **Tasks:** P0 blockers → P1 sprint → P2 backlog (counts)
- **Recent commits:** Last 5
- **VPS:** Container status
- **Orchestration:** "Pipeline active. Gate threshold: 75."
