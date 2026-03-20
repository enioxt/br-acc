# TASKS.md — EGOS Inteligência (SSOT)

> **Updated:** 2026-03-18 | **Patterns:** 10 | **Nodes:** 77.0M | **Rels:** 25.1M | **Tools:** 27 | **Tasks:** 103/141 ✅ | **GitHub Issues:** https://github.com/enioxt/EGOS-Inteligencia/issues

---

## Strategic Reset — Product Focus (2026-03-18)

- [ ] TASK-136: Reposition `EGOS-Inteligencia` as the strongest reference implementation for `EGOS Guard Brasil`, not as the entire business thesis
- [ ] TASK-137: Expose guardrail primitives from this repo as reusable proof surfaces — LGPD/public guard, masking, evidence-aware chat, public-safe investigation flows
- [ ] TASK-138: Prove one lighthouse use case with hard evidence and neutral language — a public-safe assistant for investigations/due diligence under Brazilian constraints
- [ ] TASK-140: Adopt the kernel `docs/SSOT_REGISTRY.md` in `br-acc` — map local SSOTs (`AGENTS`, `TASKS`, local maps, legal docs) to the cross-repo contract and document what remains public-safe local truth

> **Directive:** New work in `br-acc` should either strengthen the reference implementation, improve truthfulness of public claims, or help package the flagship guardrails product.

## P0 — Em Andamento (Blockers)

### TASK-001: CNPJ ETL — 53.6M empresas ⏳ 🚨 CRITICAL
- [x] Upload 6.8GB zip para Contabo
- [x] Extrair dados (26GB descomprimido)
- [x] Phase 2: Create Company nodes (8,860,601 loaded)
- [ ] Phase 1: Build estab_lookup (status unknown — check if still running)
- [ ] **Phase 3: Create Person/Partner nodes + SOCIO_DE relationships** 🚨
- [ ] Phase 4: Post-load hooks (entity linking)
- [x] Fix local do pós-load `run_id` → `linking_hooks.py`/`runner.py` + teste de regressão (06/03/2026)
> **Server:** 217.216.95.126 | **Service target:** `bracc-etl.service` (reality check 2026-03-06: inactive)
> **Reality check 2026-03-06:** Docker stack está saudável (5/5 containers), mas o ETL não está rodando pelo systemd. O último comando ativo ficou preso em `tmux` e o log final mostra erro em `linking_hooks.py`: `Neo.ClientError.Statement.ParameterMissing: Expected parameter(s): run_id`.
> **Estado real do grafo:** 59,573,749 `Company` + 17,454,980 `Partner` + 7,074 `Person` = **77,035,803 entidades** e **25,091,492 `SOCIO_DE`**.
> **Control-plane drift:** `etl-monitor.sh` segue registrando “ETL running” com `CPU 0.0%` e delta zero, enquanto `/api/v1/meta/etl-progress` retorna `running=false`, `percent=90` e `last_update=2026-03-06 00:06:36`.
> **Impact:** A Fase 3 carregou massa crítica de sócios/relacionamentos, mas o pós-load falhou, a telemetria pública está stale e a Fase 4 permanece bloqueada.
> **Local fix já aplicado (06/03/2026):** `etl/src/bracc_etl/linking_hooks.py`, `etl/src/bracc_etl/runner.py`, `etl/tests/test_linking_hooks.py` — faltam redeploy/reexecução controlada no VPS.

### TASK-002: Neo4j Performance Optimization ⏳
- [x] Criar script `neo4j-memory-upgrade.sh` (16G heap, 22G pagecache)
- [x] Criar script `post-etl-optimize.sh` (13 indexes: 9 B-tree + 2 fulltext + 2 composite)
- [x] Documentar arquitetura: `docs/analysis/PERFORMANCE_ARCHITECTURE_2026-03.md`
- [x] Scripts deployed to VPS (`/opt/bracc/scripts/`) — session 17
- [ ] Aplicar memory upgrade APÓS ETL completar
- [ ] Executar `post-etl-optimize.sh` APÓS ETL completar
- [ ] Verificar query < 5ms para CNPJ lookup
> **Depende de:** TASK-001
> **Arquivos:** `infra/scripts/neo4j-memory-upgrade.sh`, `infra/scripts/post-etl-optimize.sh`

### TASK-003: Search Fix + Hardcoded Data ✅ (02/03/2026)
- [x] Remover números falsos do i18n.ts (87M, 53M, 8 algoritmos)
- [x] Adicionar wildcard + fuzzy search na API (`_build_search_query()`)
- [x] Deploy API + frontend reconstruídos
- [x] Verificar busca funcionando ("silva" → 1073 resultados)
> **Arquivos:** `api/src/bracc/routers/search.py`, `frontend/src/i18n.ts`

---

## P1 — Sprint Atual

### TASK-004: Redis Cache-Aside (GitHub #19) ✅ (02/03/2026)
- [x] Redis rodando no docker-compose (bracc network)
- [x] `api/src/bracc/services/cache.py` — async cache with graceful degradation
- [x] Search endpoint cached (TTL 2min), entity (5min), stats (1min), connections (3min)
- [x] `/api/v1/meta/cache-stats` — hit rate, misses, errors, TTL config
- [x] `/api/v1/meta/cache` DELETE — flush all cache keys
- [x] Deployed and verified: 50% hit rate on repeated queries
> **Arquivos:** `api/src/bracc/services/cache.py`, `api/src/bracc/routers/search.py`, `api/src/bracc/routers/meta.py`

### TASK-005: GDS Algorithms (GitHub #20) ⬜
- [ ] Instalar plugin GDS no Neo4j
- [ ] Implementar PageRank para entidades
- [ ] Community Detection (Louvain) para clusters
- [ ] Shortest Path entre entidades
- [ ] Betweenness Centrality para bridge entities
> **Depende de:** TASK-001, TASK-002

### TASK-006: Bounded Traversals (GitHub #22) ⬜
- [ ] Limitar traversals a max 3 hops
- [ ] Query timeout 30s max
- [ ] Pre-computar anomaly scores para hot entities
- [ ] Paginação para large result sets
> **Inspiração:** Palantir Gotham

### TASK-007: Investigation Upload + Sharing ⬜
- [ ] API: endpoint para upload de investigações (HTML, PDF, JSON)
- [ ] API: listar investigações compartilhadas publicamente
- [ ] Frontend: UI de upload no menu do usuário
- [ ] Frontend: galeria de investigações compartilhadas
- [ ] Frontend: "continuar a partir de" outra investigação (fork)
> **Referência:** Intelink `components/shared/ShareJourneyDialog.tsx`

### TASK-008: Journey Tracker / Step Counter ✅ (02/03/2026)
- [x] Journey lib: localStorage, 500 entries, dedup, export JSON/MD, Web Share API
- [x] JourneyPanel: floating panel with stats, entries, export/share/clear
- [x] Integrado em: Chat, Search, EntityAnalysis, Dashboard, Landing, GraphExplorer, Investigations
- [x] Registra buscas, views de entidades, queries de chat automaticamente
> **Arquivos:** `frontend/src/lib/journey.ts`, `frontend/src/components/journey/JourneyPanel.tsx`

### TASK-009: Patense Report v2 ✅ (02/03/2026)
- [x] Reescrever relatório com linguagem neutra
- [x] Completar dados BNDES (R$217M, 4 empresas, 563 operações)
- [x] Publicar em inteligencia.egos.ia.br/reports/patense.html
- [x] Persistir em frontend/public/reports/
> **Arquivos:** `docs/showcase/patense-investigation.html`

### TASK-010: Public Mode + Landing Page ✅ (02/03/2026)
- [x] Ativar VITE_PUBLIC_MODE=true no Dockerfile
- [x] Adicionar LiveDatabaseStatus component
- [x] Adicionar PartnershipCTA component
- [x] Deploy no Contabo
> **Arquivos:** `frontend/Dockerfile`, `frontend/src/pages/Landing.tsx`

### TASK-075: Integrar Chatbot "Padrão 852" (Vercel AI SDK) ao EGOS ⬜ 🚨
- [ ] Analisar arquitetura do `/home/enio/852` (Next.js App Router, `ai` sdk, persistência Supabase)
- [ ] Mapear lacunas do atual `frontend/src/components/chat/ChatInterface.tsx` (que usa UI customizada Vite/React)
- [ ] Portar formatação refinada de Markdown, exibição de fontes e retenção de contexto para o EGOS
- [ ] Adequar o OpenRouter do EGOS aos padrões máximos encontrados no 852
> **Motivo:** O repositório 852 possui o chatbot mais avançado de todo o workspace. Torná-lo o benchmark oficial.

### TASK-072: Reality Check — VPS, ETL e Métricas do Sistema ⬜
- [ ] Verificar estado real do `bracc-etl.service` e processos relacionados no VPS
- [ ] Atualizar porcentagem real do ETL e gargalo atual (Phase 1/3/4) com evidência
- [ ] Atualizar métricas canônicas de nós, relacionamentos, fontes, tools e capacidade em `AGENTS.md`, `TASKS.md` e relatório técnico
- [ ] Validar se widgets/endpoints públicos de progresso refletem o estado real do sistema
- [ ] Consolidar relatório técnico 2026-03 com capacidade, limites e próximos bloqueios
> **Evidência já coletada (2026-03-06):** `bracc-etl.service` inactive; stack 5/5 healthy; `etl-monitor-state.json` = 17,454,980 Partner / 59,573,749 Company / 25,091,492 `SOCIO_DE`; `cnpj-etl.log` encerra com erro `Expected parameter(s): run_id`; endpoint `/api/v1/meta/etl-progress` stale em 90%.
> **Progresso local nesta sessão:** fix mínimo do `run_id` implementado e validado com `ruff` + `pytest` (`40 passed`).

### TASK-073: Relatório Técnico 2026-03 — EGOS Inteligência ⬜
- [ ] Revisar claims públicos vs código vs VPS real
- [ ] Consolidar arquitetura atual (API, frontend, Neo4j, Redis, bots, ETLs)
- [ ] Explicitar o que está estável, em beta e bloqueado
- [ ] Publicar versão atualizada do relatório em local SSOT apropriado

### TASK-074: Caso Vorcaro — Mapa Público de Entidades e Sinais (GitHub #57) 🔄 (06/03/2026)
- [x] Levantar entidades e CNPJs publicamente citáveis relacionados ao caso
- [ ] Cruzar web pública, grafo, DataJud, diários, contratos e sanções sem linguagem acusatória
- [x] Separar fatos confirmados, sinais, lacunas e próximos passos de verificação
- [x] Produzir relatório com fontes, timestamps e caveats legais explícitos
> **Arquivos:** `docs/cases/caso-vorcaro-mapa-publico.md`
> **Trilha segura inicial (2026-03-06):** começar por fontes oficiais/regulatórias, depois bases societárias públicas e só então cobertura jornalística como contexto.
> **Âncoras públicas já identificadas:**
> 1. **Banco Central / Dados Abertos:** dataset `SFN - BANCO MASTER - EM LIQUIDAÇÃO EXTRAJUDICIAL`.
> 2. **CVM / gov.br:** notícia de 2025 sobre rejeição de Termo de Compromisso envolvendo `Banco Master S.A.`, `Viking Participações Ltda.` e `Daniel Bueno Vorcaro`.
> 3. **CNPJ/QSA público:** páginas de vínculo societário por nome para `Daniel Bueno Vorcaro` e empresas associadas.
> **Regra de linguagem:** fatos = apenas o que estiver em documento oficial ou registro público nominativo; mídia entra como `sinal/contexto`, nunca como conclusão. Toda saída deve separar `fatos confirmados`, `sinais`, `lacunas` e `próximas verificações`.

### TASK-075: Benchmark Global de OSINT & Public Intelligence ⬜
- [ ] Usar Gem Hunter + pesquisa manual para mapear referências open-source relevantes no mundo
- [ ] Comparar navegação, evidence chain, UX investigativa, relatórios e assistentes contextuais
- [ ] Converter os melhores padrões em backlog executável para EGOS Inteligência

### TASK-135: Casos Públicos do Brasil — Matriz de Benchmark Investigativo (GitHub #58) ⬜
- [ ] Selecionar uma cesta inicial de casos públicos de alto impacto (financeiro, político, societário, regulatório)
- [ ] Mapear para cada caso as fontes oficiais/reprodutíveis: Judiciário, MPF/PF, CVM, BCB, TCU/CGU, juntas/CNPJ, diários, fatos relevantes
- [ ] Extrair primitivas reutilizáveis para o produto: entidade, evento, instrumento, fluxo financeiro, jurisdição, tempo, evidência, caveat legal
- [ ] Separar claramente `fatos confirmados`, `sinais/contexto`, `lacunas` e `próximas verificações` em formato replicável
- [ ] Conectar a matriz ao piloto já aberto em `TASK-074` (Vorcaro) sem linguagem acusatória nem implementação órfã
> **Objetivo:** transformar grandes casos públicos em backlog de fontes, heurísticas e padrões de cruzamento para o EGOS Inteligência.

---

## P2 — Backlog

### TASK-011: Rename BR/ACC → Novo Nome ⬜
- [ ] Definir nome final (EGOS Intelligence? Outro?)
- [ ] Atualizar i18n, README, ROADMAP, frontend
- [ ] Atualizar DNS se necessário
- [ ] Score de divergência do fork original > 80%

### TASK-012: Gem Hunter Agent (GitHub #23) ⬜
- [ ] Criar agente que escaneia GitHub por repos brasileiros de transparência
- [ ] Classificar repos por qualidade, features únicas, oportunidades
- [ ] Gerar relatório semanal em docs/gem-hunter/
- [ ] Notificar bots (Telegram/Discord) sobre descobertas
> **Referência:** `egos-lab/scripts/scan_ideas.ts`, `docs/plans/EGOS_LOST_GEMS.md`

### TASK-013: Fork Monitor (GitHub #9) ⬜
- [ ] Script 2x/dia checa forks de World-Open-Graph/br-acc
- [ ] Detectar novos PRs, issues, contribuições
- [ ] Alertar no Telegram/Discord
- [ ] Comparar features entre forks

### TASK-014: Website Redesign (GitHub #21) ⬜
- [ ] CMD+K global search (portar do Intelink)
- [ ] Search history (últimos acessos)
- [ ] Connection preview on hover
- [ ] Entity Detail Modal from search
- [ ] Mobile responsive improvements
- [ ] Accessibility (a11y)
> **Referência:** Intelink `components/shared/GlobalSearch.tsx`

### TASK-015: Bot Integration — Discord/Telegram (GitHub #8) ✅ (02/03/2026)
- [x] Discord: `EGOS Intelligence#2881` — 14 OSINT tools, slash commands, Supabase persistence
- [x] Telegram: `@EGOSin_bot` — 14 OSINT tools, long polling, conversation memory
- [x] Both bots stable via PM2 ecosystem.config.cjs with .env loading
- [x] Model fallback: paid Gemini 2.0 Flash first, free tier as backup
- [x] Auto-create GitHub issues from user feedback (||TASK|| markers)
- [ ] WhatsApp: estrutura pronta para qualquer número
> **Arquivos:** `/opt/egos-bot/packages/shared/src/social/` (discord-bot.ts, telegram-bot.ts, ai-engine.ts)

### TASK-016: Pipeline Extrateto — Supersalários (GitHub #5) ⬜
- [ ] ETL para dados de salários do judiciário
- [ ] Detecção de supersalários acima do teto

### TASK-017: Lei de Benford (GitHub #6) ✅ (03/03/2026)
- [x] Pattern detector `benford_contract_values` implementado em Cypher
- [x] API endpoint: `GET /api/v1/patterns/{entity_id}/benford_contract_values`
- [x] MAD threshold configurável via `PATTERN_BENFORD_MAD_THRESHOLD`
- [x] Mínimo de contratos configurável via `PATTERN_BENFORD_MIN_CONTRACTS`
> **Arquivos:** `queries/public_pattern_benford_contract_values.cypher`, `config.py`

### TASK-018: HHI — Concentração de Fornecedores (GitHub #7) ✅ (03/03/2026)
- [x] Pattern detector `hhi_contract_concentration` implementado em Cypher
- [x] API endpoint: `GET /api/v1/patterns/{entity_id}/hhi_contract_concentration`
- [x] Threshold configurável via `PATTERN_HHI_THRESHOLD` (default 0.25)
> **Arquivos:** `queries/public_pattern_hhi_contract_concentration.cypher`, `config.py`

### TASK-019: i18n Completo PT-BR (GitHub #1, #2) ✅ (03/03/2026)
- [x] Frontend: locale pt-BR completo (440+ keys traduzidas)
- [x] Frontend: locale EN — removed hardcoded numbers, fixed PT-BR leaks in nav
- [x] API: mensagens de erro em PT-BR (verificado session 17 — testes atualizados)
> **Arquivos:** `frontend/src/i18n.ts`

### TASK-020: Neutrality Audit CI ✅ (03/03/2026)
- [x] CI job `neutrality` em `.github/workflows/ci.yml` — 9 banned words
- [x] `test_no_banned_words_in_pattern_metadata` em unit tests
- [x] Exemption via `# neutrality-ok` comment
- [x] Fixed 1 violation: `journey.ts` "corrupt" → "malformed"
> **Arquivos:** `.github/workflows/ci.yml`, `api/tests/unit/test_patterns.py`

### TASK-021: Interoperabilidade Global (GitHub #18) ⬜
- [ ] FollowTheMoney format
- [ ] Aleph/OCCRP integration
- [ ] ICIJ compatibility

### TASK-022: Pipelines Restantes (GitHub #12-16) ⬜
- [ ] IBGE (Censo, PNAD, IPCA, PIB) — #12
- [ ] DENATRAN/RENAVAM — #13
- [ ] Agências Reguladoras — #14
- [ ] Meio Ambiente (INPE, CAR, INCRA) — #15
- [ ] SIAFI + Tesouro Transparente — #16

### TASK-023: Docs para Leigos (GitHub #3, #4) ✅ (03/03/2026)
- [x] Traduzir data-sources.md para PT-BR (session 18)
- [x] Criar FAQ para leigos em PT-BR (02/03/2026)
> **Arquivos:** `docs/FAQ_PT-BR.md`, `docs/fontes-de-dados.md`

### TASK-024: Rename BR/ACC → EGOS Inteligência ✅ (02/03/2026)
- [x] i18n.ts — todas as referências
- [x] index.html — title
- [x] AppShell.tsx — logo sidebar
- [x] README.md — reescrito completo
- [x] ROADMAP.md — headers e links
- [x] TASKS.md — header
> **DNS pendente:** Criar `inteligencia.egos.ia.br` e atualizar Caddy

### TASK-025: LGPD — Remover CPF do sistema inteiro ✅ (02/03/2026)
- [x] Frontend: remover CPF de search placeholders (i18n.ts)
- [x] Frontend: remover CPF de EntityDetail.tsx (só mostra CNPJ)
- [x] Backend: `public_guard.py` — CPF lookup SEMPRE bloqueado (não só public mode)
- [x] Backend: `sanitize_public_properties` — SEMPRE filtra CPF (não só public mode)
- [x] Backend: CPF masking middleware mantido como safety net
> **Arquivos:** `frontend/src/i18n.ts`, `frontend/src/components/entity/EntityDetail.tsx`, `api/src/bracc/services/public_guard.py`

### TASK-026: Mobile-First — Remover bloqueio de tela <1024px ✅ (02/03/2026)
- [x] Remover `isMobileBlocked` do AppShell.tsx
- [x] Adicionar bottom navigation para mobile (<768px)
- [x] Mobile layout funcional com Outlet + nav fixa
> **Arquivos:** `frontend/src/components/common/AppShell.tsx`

### TASK-027: Chatbot AI na Landing Page ✅ (02/03/2026)
- [x] Backend: `POST /api/v1/chat` — endpoint conversacional
- [x] Frontend: `ChatInterface.tsx` — componente mobile-first (dark theme)
- [x] Integrar na Landing como interface primária
- [x] Phase 1: busca estruturada Neo4j (sem LLM)
- [x] Phase 2: LLM via OpenRouter (Gemini 2.0 Flash) com function calling
- [x] Memória de conversa por sessão (IP-based, 30min TTL, 20 msgs)
- [x] 3 tools: search_entities, get_graph_stats, get_entity_connections
- [x] Sugestões contextuais dinâmicas
- [x] Phase 3: rich results — entity cards clicáveis + evidence chain + cost display ✅ (03/03/2026)
> **Arquivos:** `api/src/bracc/routers/chat.py`, `frontend/src/components/chat/ChatInterface.tsx`

### TASK-028: Investigações — Export Formats ✅ (03/03/2026)
- [x] Formatos de exportação: MD, JSON, HTML, PDF (4 formatos)
- [x] `export_service.py` — Markdown + HTML renderers com CPF masking
- [x] `_resolve_entities()` — helper compartilhado com PEP guard
- [ ] Formatos de importação: MD, JSON, HTML (P2 futuro)
- [ ] Fork/clone de investigações públicas (P2 futuro)
- [ ] Espiral de escuta — continuar investigação a partir de outra
- [ ] Interação e comentários em investigações compartilhadas

### TASK-029: Journey Tracker v2 ⬜
- [ ] Design novo (não port do Intelink)
- [ ] Rastreamento de passos de investigação
- [ ] FAB mobile-friendly
- [ ] Exportação de timeline

### TASK-030: Gem Hunter Agent ✅ (GitHub #23) (04/03/2026)
- [x] Construir modular no egos-lab framework (Feito como v2 agents/gem_hunter)
- [x] Scanner de repos GitHub brasileiros de transparência (gem_hunter_tags.json + API)
- [ ] Primeiro deploy no website EGOS Inteligência
- [x] Pesquisa inicial: 9 projetos encontrados (02/03/2026)
> **Projetos encontrados:**
> - `jpvss/CEAP-Playbook` — Benford + HHI para CEAP (OURO)
> - `Pr0teus/BROS` — OSINT sources brasileiras + Neo4j
> - `pedropberger/Julius` — Bot scraper de portais de transparência (ES)
> - `vfpimenta/corruption-profiler` — Anomalia em gastos parlamentares
> - `rodrigolink/benford` — Benford em dados eleitorais TSE
> - `pedronipalhares/CVM358` — Insider trading CVM
> - `GuiCosti/Public-Spending-Analysis` — CPGF anomalias
> - `RenatoDev4/spending-anomalies` — AutoEncoder para gastos
> - `Apify/brazil-government-transparency` — Scraper dados governo

### TASK-031: Integrar CEAP-Playbook (Benford + HHI) ⬜
- [ ] Adaptar `analise_benford()` para nosso backend (scipy chi-squared)
- [ ] Adaptar HHI por fornecedor para contratos no grafo
- [ ] Criar ETL pipeline para CEAP (Câmara API, CSV zips por ano)
- [ ] Adicionar dicionário de dados CEAP
- [ ] Visualização Benford no frontend (esperado vs observado)
> **Ref:** https://github.com/jpvss/CEAP-Playbook

### TASK-032: DNS inteligencia.egos.ia.br ✅ (02/03/2026)
- [x] DNS A record criado pelo usuário
- [x] Caddyfile atualizado (inteligencia.egos.ia.br + bracc 301 redirect)
- [x] SSL Let's Encrypt obtido automaticamente
- [x] Caddy reiniciado, serviço ativo
- [x] URLs atualizadas no codebase (TASKS, ROADMAP, plans)
- [x] CORS_ORIGINS/.env atualizados

### TASK-033: Linguagem Legal — Pesquisa Pessoal ✅ (02/03/2026)
- [x] Disclaimer atualizado: "Pesquisa pessoal com dados públicos. Padrões são sinais, não prova jurídica."
- [x] "Investigue em profundidade" → "Pesquise em profundidade"
- [x] "Investigações recentes" → "Pesquisas recentes"
- [x] Feature descriptions focam em "pesquisa pessoal" e "dados públicos"
> **Arquivos:** `frontend/src/i18n.ts`

### TASK-034: Gem Hunter — Keywords de Busca ⬜
- [ ] Implementar busca por semântica no GitHub API
- [ ] Keywords mapeadas: CEAP, cota parlamentar, transparencia brasil, CNPJ consulta, licitacao anomalia, benford brazil, Neo4j governo, OSINT brasil, serenata amor, TCU auditoria, CGU dados
- [ ] Engenharia reversa do EGOS Inteligência para extrair tags
- [ ] Monitoramento periódico de novos repos

### TASK-035: Changelog/Updates no Website ✅ (02/03/2026)
- [x] UpdatesTimeline component na landing page (expandable cards, tags, metricas)
- [x] JSON changelog entries em frontend/public/updates/YYYY-MM-DD.json
- [x] Primeira entrada: Redis cache, 108 fontes, bots, governanca
- [x] Relatorio Patense linkado no changelog
> **Arquivos:** `frontend/src/components/landing/UpdatesTimeline.tsx`, `frontend/public/updates/`

### TASK-036: Pipeline Social Integrado (/postar) ⏳
- [x] Workflow /postar criado (X.com, Telegram, Discord)
- [x] Telegram e Discord postando com sucesso
- [ ] X.com: precisa API keys (X_API_KEY, X_API_SECRET, X_ACCESS_TOKEN, X_ACCESS_TOKEN_SECRET)
- [ ] Conta @anoineim precisa verificacao por telefone
> **Arquivos:** `.windsurf/workflows/postar.md`, bot x-client.ts

### TASK-037: Bot Self-Healing ✅ (02/03/2026)
- [x] Cron healthcheck cada 5 min (/opt/egos-bot/healthcheck.sh)
- [x] Auto-restart de bots crashados via PM2
- [x] Logging em /var/log/egos-bot-health.log
- [x] Alertas via Telegram quando bot restartar (envia para @ethikin)
- [x] Healthcheck v2: pm2 describe + awk para status correto
- [ ] Dashboard de uptime no website (P3)
- [ ] HGR-style 3-level memory (P3, inspirado RokoOfficial/HGR)

### TASK-038: Kubernetes / Autoscaler / Self-Healing ⬜ (P2 — Planejamento)
- [ ] Avaliar migrar de Docker Compose para k3s (lightweight Kubernetes para VPS)
- [ ] Configurar HPA (Horizontal Pod Autoscaler) para API
- [ ] Liveness/readiness probes para todos os servicos
- [ ] Auto-rollback em deploys com falha
- [ ] Monitoramento com Prometheus + Grafana
> **Nota:** Contabo VPS tem recursos limitados. k3s é mais viavel que k8s completo.

### TASK-039: Codex CLI no Contabo VPS ⬜ (P2 — Pesquisa)
- [ ] Verificar se OpenAI Codex CLI funciona em VPS headless
- [ ] Configurar codex login via token (sem browser)
- [ ] Usar codex exec para tarefas async (code review, testes)
- [ ] Integrar com CI/CD para auto-fix de falhas
> **Requisitos:** Conta OpenAI ativa, CODEX_TOKEN no .env

### TASK-040: OpenClaw / Agentes CI/CD QA ⬜ (P2 — Pesquisa)
- [ ] Avaliar OpenClaw como framework de agentes autonomos
- [ ] Configurar agente QA para monitorar erros e sugerir fixes
- [ ] Integrar com GitHub Actions para PR auto-review
- [ ] Usar modelo Gemini 2.0 Flash (pago) via OpenRouter
- [ ] Pipeline: erro detectado -> agente analisa -> sugere fix -> cria PR
> **Inspiracao:** OpenClaw molt.sh self-healing pattern, RokoOfficial/OPENBOT

### TASK-041: SourceRegistry — Transparencia Total no Website ✅ (02/03/2026)
- [x] SourceRegistry component com 108 fontes, links diretos, categorias, tiers, filtros
- [x] sources.json gerado do CSV com 27 categorias
- [x] Injetado na landing page acima do UpdatesTimeline
- [x] Cada fonte com link para portal oficial do governo
- [x] Paginacao: 10 fontes por pagina com botoes prev/next
> **Arquivos:** `frontend/src/components/landing/SourceRegistry.tsx`, `frontend/public/updates/sources.json`

### TASK-044: Linha do Tempo Completa + ETL Progress Widget ✅ (02/03/2026)
- [x] UpdatesTimeline reescrito com timeline vertical (24 marcos desde fork do Bruno)
- [x] timeline.json com todos os milestones de Jan 15 a Mar 02 2026
- [x] Mostra 5 recentes por padrao, expansivel para todos os 24
- [x] ETLProgress widget: barra de progresso ao vivo, auto-refresh 30s
- [x] Endpoint /api/v1/meta/etl-progress: fase, arquivo, %, running status
- [x] ETL usa mtime do log (container-compatible) em vez de pgrep
> **Arquivos:** `frontend/src/components/landing/UpdatesTimeline.tsx`, `frontend/public/updates/timeline.json`, `frontend/src/components/landing/ETLProgress.tsx`, `api/src/bracc/routers/meta.py`

### TASK-045: Bot Error Handling — DM Only ✅ (02/03/2026)
- [x] Telegram: erros so enviados em chat privado (ctx.chat.type === 'private')
- [x] Discord: erros via message.author.send() (DM), nao message.reply() (channel)
- [x] Healthcheck v2: corrigido parsing de status (pm2 describe + awk)
- [x] Healthcheck alertas Telegram para @ethikin no restart/failure
> **Arquivos:** `telegram-bot.ts`, `discord-bot.ts`, `/opt/egos-bot/healthcheck.sh`

### TASK-047: Chat Links New Tab + Journey System ✅ (02/03/2026)
- [x] Chat: entity clicks abrem em nova aba (window.open _blank) em vez de navegar
- [x] Chat: URLs no markdown recebem target=_blank automaticamente
- [x] Chat: links markdown [text](url) renderizados corretamente
- [x] Journey: lib/journey.ts — localStorage com 500 entries max, dedup 60s, export JSON/MD
- [x] Journey: JourneyPanel.tsx — painel flutuante com stats, lista, export, share, clear
- [x] Journey: integrado no ChatInterface (tracks queries + entity views)
- [x] Journey: exportavel como JSON ou Markdown, compartilhavel via Web Share API
- [ ] Journey: persistencia no backend com login (futuro)
> **Arquivos:** `frontend/src/lib/journey.ts`, `frontend/src/components/journey/JourneyPanel.tsx`, `frontend/src/components/chat/ChatInterface.tsx`

### TASK-046: Diagnostico Completo do Sistema ✅ (02/03/2026)
- [x] 14 OSINT tools registrados nos bots
- [x] 30+ endpoints API em 10 routers
- [x] 5 containers Docker (frontend, api, caddy, neo4j, redis)
- [x] 2 bots PM2 (discord, telegram)
- [x] 23 issues GitHub abertas, 0 fechadas
- [x] ETL: CPU processing (32GB em disco), nao internet
- [x] Relatorio Patense em /reports/patense.html (nao linkado na landing)
- [x] Pre-commit hooks instalados (secrets, large files, Python syntax) ✅ (02/03/2026)
- [x] ReportsShowcase na landing (Patense report linkado) ✅ (02/03/2026)
- [x] Docker API rebuilt (DNS resolvido) ✅ (02/03/2026)

### TASK-042: /app — Plataforma de Pesquisa Colaborativa ⏳ (P1)
- [x] /app/search: Busca no grafo (JA EXISTE, public mode)
- [x] /app/analysis/:entityId: Analise de entidade (JA EXISTE)
- [x] /app/graph/:entityId: Explorador de grafo (JA EXISTE)
- [x] /app/patterns: Deteccao de padroes (JA EXISTE)
- [x] /app/baseline/:entityId: Baseline de entidade (JA EXISTE)
- [x] /app/investigations: Caderno de pesquisa (JA EXISTE, auth-gated)
- [x] /app/shared/:token: Compartilhamento publico de investigacoes (JA EXISTE)
- [x] Dashboard com pesquisas recentes + busca rapida (JA EXISTE)
- [ ] Auth: Login com Google/GitHub (precisa backend auth)
- [ ] /app/public: Feed comunitario de pesquisas publicadas
- [ ] Incentivo: Badge "Pesquisador Cidadao" para quem publica
- [ ] Cross-link: Quando pesquisas diferentes encontram mesmas entidades, destacar
- [ ] Feedback loop: Conexoes de usuarios -> melhorar ETL
- [x] Historico de pesquisas: Journey system (localStorage, export JSON/MD, share) ✅ (02/03/2026)
> **Status:** Frontend JA TEM 8 paginas funcionais + Journey. Falta auth backend + feed comunitario.
> **Arquivos:** `frontend/src/pages/Dashboard.tsx`, `Investigations.tsx`, `SharedInvestigation.tsx`, `Search.tsx`, `EntityAnalysis.tsx`, `GraphExplorer.tsx`, `Patterns.tsx`, `Baseline.tsx`

### TASK-048: Chatbot Investigativo — 18 Tools ✅ (02/03/2026)
- [x] 3 graph tools: search_entities, get_graph_stats, get_entity_connections
- [x] web_search (DuckDuckGo), search_emendas, search_transferencias (TransfereGov)
- [x] search_ceap, search_pep_city, search_votacoes (Câmara dos Deputados)
- [x] search_gazettes, cnpj_info (Querido Diário — 510+ cidades)
- [x] search_servidores, search_licitacoes, search_cpgf, search_viagens, search_contratos, search_sancoes (Portal da Transparência — chave API)
- [x] search_processos (DataJud/CNJ — todos os tribunais do Brasil)
- [x] System prompt: puxar o fio, cross-reference, caminho do dinheiro
- [x] Suggestions: recuperações judiciais, supersalários, fornecedores, investigações
- [x] 18 tools total (3 grafo + 8 livres + 6 Portal Transparência + 1 DataJud)
- [x] Brave Search API integrado como primário ($5/mês), DDG fallback ✅ (02/03/2026)
> **Arquivos:** `api/src/bracc/services/transparency_tools.py`, `api/src/bracc/routers/chat.py`
> **APIs:** Brave Search (primário) + DDG (fallback), TransfereGov, Câmara, Querido Diário + Portal Transparência, DataJud

### TASK-049: Avaliação Unikraft + ESAA ✅ (02/03/2026)
- [x] Unikraft avaliado: NÃO aplicável (unikernels para microserviços stateless, nosso stack é Docker + Neo4j + Python)
- [x] ESAA avaliado: EXCELENTE padrão para egos-lab (event sourcing para agentes AI, audit trail, contracts)
- [ ] Implementar event sourcing no egos-lab agent runtime (inspirado ESAA) — P2
> **Unikraft:** github.com/unikraft/unikraft — 4.1k★. Boot em ms, footprint mínimo. Não roda Neo4j/Redis.
> **ESAA:** github.com/elzobrito/ESAA — Event Sourcing for Autonomous Agents. Append-only .jsonl, SHA-256 verified projections, contracts YAML.

### TASK-050: Observabilidade — Analytics + Error Tracking ✅ (02/03/2026)
- [x] Self-hosted analytics: `/api/v1/analytics/pageview` + `/api/v1/analytics/summary`
- [x] Redis-backed: page views por dia, unique visitors (IP hash), hourly, 7-day history
- [x] Frontend tracking: App.tsx useLocation → POST pageview em cada navegação
- [x] Microsoft Clarity ativado (project ID: vpkwrlf847) — session recordings, heatmaps
- [x] Analytics dashboard page: `/app/analytics` (page views, UV, hourly, 7-day chart) ✅ (02/03/2026)
- [ ] Sentry para error tracking (ou self-hosted alternative)
> **Arquivos:** `api/src/bracc/routers/analytics.py`, `frontend/src/App.tsx`, `frontend/index.html`, `frontend/src/pages/Analytics.tsx`

### TASK-051: Avaliação De Olho em Você + Mission Control ✅ (02/03/2026)
- [x] De Olho em Você (deolhoemvoce.com.br): monitora emendas Pix, CEAP, votações
- [x] Aprendizado: adicionamos search_votacoes (como eles têm), Flock analytics (similar ao nosso self-hosted)
- [x] Vantagem deles: per-deputy profiles visuais, Emendas Pix específicas, AdSense
- [x] Vantagem nossa: Neo4j graph, CNPJ/sócios, gazette search, AI chatbot, open-source
- [x] Mission Control (builderz-labs): agent orchestration dashboard
- [x] Relevante para egos-lab (23 agents), NÃO para EGOS Inteligência
- [x] Ideias: cost tracking por agente, GitHub Issues sync, Kanban board
> **Similares avaliados:** comovotou.org, deolhonodeputado.app.br, Mika-IO/deolho

### TASK-052: Daily Update Policy ✅ (02/03/2026)
- [x] Documento criado: `docs/DAILY_UPDATE_POLICY.md`
- [x] Regra: 1 post/dia contendo tudo, exceto updates "importantes" (ver critérios)
- [x] Critérios de "importante": nova fonte de dados, feature UX, marco, incidente, contribuição externa
- [x] Template de post diário definido
- [x] Canais: Telegram, Discord, Website timeline

### TASK-053: Portal da Transparência + DataJud APIs ✅ (02/03/2026)
- [x] Portal da Transparência: chave `f6341a...` integrada (6 endpoints)
- [x] Servidores federais: nome, salário, cargo, órgão (requer CPF ou código SIAPE)
- [x] Contratos: fornecedor, valor, vigência, aditivos
- [x] Sanções: CEIS (inidôneas) + CNEP (punidas) — funciona sem filtros
- [x] CPGF, viagens, licitações (requerem filtros mínimos)
- [x] DataJud (CNJ): chave `cDZH...` integrada — todos os 27+ tribunais
- [x] Recuperação Judicial: 1.180 processos TJMG confirmados
- [x] Elasticsearch queries: match_phrase para classes processuais
> **Arquivos:** `api/src/bracc/services/transparency_tools.py`
> **Verificado:** CEIS, contratos, DataJud TJMG (Recuperação Judicial) — todos funcionando

### TASK-054: Avaliação OpenPlanter ✅ (02/03/2026)
- [x] OpenPlanter (ShinMegamiBoson): agente investigativo recursivo com TUI
- [x] 19 tools: file I/O, shell, web search (Exa), subtask delegation
- [x] Entity resolution cross-dataset, evidence-chain construction
- [x] Suporta GPT-5.2, Claude Opus 4.6, Qwen, Ollama local
- [x] Inspiração: sub-agent delegation, recursive investigations
- [x] Nosso diferencial: Neo4j 317K+ nós, 18 APIs, frontend web, open-source
> **Veredicto:** Ótima inspiração para multi-step investigations futuras. Não substitui.

### TASK-055: Auditoria de Features Intelink ✅ (02/03/2026)
- [x] Intelink tem 179 pages/routes em 17 seções
- [x] **Já adotamos:** Chat, Graph, Entity, Search, Investigation, Dashboard, Journey, Landing, Patterns, Baseline (10/17)
- [x] **Relevante adotar:** Analytics dashboard (visual), Reports generation, Alertas, Activity feed
- [x] **NÃO relevante (policial):** Delegacias, operações, membros, equipe, permissões, qualidade
- [x] **Conclusão:** Core investigativo está completo. Faltam features de UX/engagement.

### TASK-056: Mapa de Portais de Transparência ✅ (02/03/2026)
- [x] Pesquisa: PNTP (10.335 portais), Transparência Internacional (300+ cidades), Radar Transparente
- [x] 122 municípios SEM portal, 109 com 100%, média prefeituras 67%
- [x] Gaps: 95% sem API, 70% dados em PDF, 40% sem licitações
- [x] Padrão referência: Portal da Transparência federal (⭐⭐⭐⭐⭐)
- [x] Proposta: API REST mínima obrigatória, JSON, atualização diária
- [x] Próximas APIs: Dados Abertos SP, MG, ComprasNet, SIAFI, Senado
> **Documento:** `docs/reports/transparency-portal-map.md`

### TASK-057: Análise de Custos de APIs ✅ (02/03/2026)
- [x] ReceitaWS (R$99/mês): NÃO vale — nosso ETL 60GB tem mesmos dados, ilimitado, grátis
- [x] SerpAPI ($75/mês): CARO — substituído por Brave Search
- [x] Brave Search ($5/mês): MELHOR custo-benefício — #1 benchmark, 669ms, 2k grátis/mês
- [x] Exa ($49/mês): Já temos via MCP Cascade — usar para dev, não produção
- [x] Recomendação: Brave para chatbot produção, Exa para pesquisa interna
> **Economia:** R$1.188/ano evitando ReceitaWS, $840/ano evitando SerpAPI

### TASK-058: GitGuardian Fix — Chaves em Env Vars ✅ (02/03/2026)
- [x] Removidas chaves hardcoded de `transparency_tools.py` (alerta GitGuardian)
- [x] Chaves movidas para `docker-compose.yml` como env vars
- [x] PORTAL_TRANSPARENCIA_API_KEY, DATAJUD_API_KEY, BRAVE_API_KEY
- [x] Código usa `os.environ.get()` — chaves nunca mais no código fonte
> **Nota:** DataJud e Portal Transparência são chaves públicas (registro gratuito), mas best practice é env vars.

### TASK-059: Brave Search Integration ✅ (02/03/2026)
- [x] Brave Search API como busca primária (key de `/home/enio/egos-lab/.env`)
- [x] DuckDuckGo como fallback automático
- [x] #1 benchmark (14.89), 669ms latência, 2k queries grátis/mês
- [x] Issue #28 fechada com comentário

### TASK-060: Analytics Dashboard Frontend ✅ (02/03/2026)
- [x] Página `/app/analytics` com visualização em tempo real
- [x] Cards: views hoje, visitantes únicos, total all-time
- [x] Gráfico de barras: últimos 7 dias + distribuição por hora
- [x] Tabela: páginas mais visitadas
> **Arquivos:** `frontend/src/pages/Analytics.tsx`, `Analytics.module.css`

### TASK-061: Monitor Endpoints (Sanções + Auto-Report) ✅ (02/03/2026)
- [x] `GET /api/v1/monitor/sanctions/recent` — últimas sanções CEIS+CNEP
- [x] `GET /api/v1/monitor/report/{municipio}` — relatório automático por município
- [x] Testado: 20 sanções recentes retornadas, Patos de Minas report funcional
> **Arquivos:** `api/src/bracc/routers/monitor.py`

### TASK-062: Sincronização GitHub Issues ↔ Tasks ✅ (02/03/2026)
- [x] Issue #25 (Portal Transparência): CLOSED — integrado
- [x] Issue #26 (DataJud): CLOSED — integrado
- [x] Issue #27 (ReceitaWS): CLOSED wontfix — ETL melhor
- [x] Issue #28 (SerpAPI/Brave): CLOSED — Brave integrado
- [ ] Criar issues para novas tasks pendentes
- [ ] Automatizar sync (script ou GitHub Action)

### TASK-063: 3 Relatórios de Investigação Publicados ✅ (02/03/2026)
- [x] Report 01: SUPERAR LTDA (CNPJ 13.482.516/0001-61) — 7 sanções no grafo, QSA com PJ sócia
- [x] Report 02: Transparência Municipal Manaus — 15 emendas, 4.664 ACPs TJAM, diligences ambientais
- [x] Report 03: Recuperação Judicial SP — 3.704 processos TJSP, 10K+ exec fiscais
- [x] Cada relatório: passo a passo para leigos + stack técnica + custos + comparação Palantir
- [x] Publicados no site: `/reports/report-0X-*.md`
- [x] Update JSON v2 para timeline do site
> **Arquivos:** `docs/reports/report-01-superar-ltda.md`, `report-02-manaus-transparencia.md`, `report-03-recuperacao-judicial-sp.md`
> **Dados reais:** Neo4j 317K nós + Portal Transparência + DataJud + BrasilAPI

### TASK-064: Auditoria Profunda Intelink v2 ✅ (02/03/2026)
- [x] 44 páginas mapeadas (14 adotadas, 3 parciais, 15 gaps relevantes, 11 N/A policial)
- [x] 135 API routes analisadas (entities, reports, analysis, documents, OCR, legal, debate)
- [x] Top 10 features para adotar: Report Gen, Activity Feed, Evidence Chain, Chat Vision, Alerts, Analysis Suite
- [x] Features egos-lab para trazer: Rho Score, Eagle Eye, Cost Tracking
- [x] Comparação Palantir/NSA/i2: tabela completa
> **Documento:** `docs/reports/intelink-deep-audit.md`

### TASK-065: Fix CEIS API Filter ✅ (02/03/2026)
- [x] Bug: Portal Transparência CEIS ignora parâmetro `cnpjSancionado`
- [x] Fix: filtro client-side por CNPJ/nome após receber resultados
- [x] Testado: sanções agora filtradas corretamente por empresa
> **Arquivo:** `api/src/bracc/services/transparency_tools.py`

### TASK-066: Evidence Chain — Data Provenance per Query ✅ (02/03/2026)
- [x] Backend: EvidenceItem model (tool, source, query, result_count, timestamp, api_url)
- [x] 18 tools mapeados para nomes de fonte e URLs de API
- [x] Cada resposta do chatbot inclui `evidence_chain[]` com proveniência completa
- [x] Frontend: display colapsável "Fontes (N) | Custo: $X.XXXX" abaixo de cada resposta
- [x] Testado: SUPERAR LTDA → 2 evidence items (Neo4j + Brave Search)
> **Conceito Mycelium aplicado:** Cada dado tem trail auditável — de onde veio, quando, quantos resultados.
> **Arquivos:** `api/src/bracc/routers/chat.py`, `frontend/src/components/chat/ChatInterface.tsx`, `frontend/src/api/client.ts`

### TASK-067: Cost Tracking per Query ✅ (02/03/2026)
- [x] Gemini Flash pricing: $0.075/1M input, $0.30/1M output tokens
- [x] `cost_usd` calculado por query baseado em `usage.prompt_tokens` + `usage.completion_tokens`
- [x] Retornado na ChatResponse e exibido no frontend
- [x] Testado: query típica = $0.000552 (~R$ 0,003)
> **Insight:** Uma investigação completa com 6 tool calls custa ~$0.003 (~R$ 0,02). Para R$630/mês operamos ~210K queries.

### TASK-068: Correção de Custos nos Relatórios ✅ (02/03/2026)
- [x] Contabo VPS: $35/mês (não €15)
- [x] Supabase Pro: $20/mês
- [x] Windsurf IDE: $45/mês
- [x] OpenRouter LLM: ~$5/mês
- [x] Brave Search: $0-5/mês
- [x] TOTAL: ~$105/mês (~R$ 630) — antes constava R$ 120 (ERRADO)
- [x] Corrigido nos 3 relatórios publicados

### TASK-069: Análise Mycelium + Chat Vision + Prioridades ✅ (02/03/2026)
- [x] Chat Vision: NÃO AGORA — sistema usa APIs estruturadas, não imagens
- [x] Mycelium Event Bus: APLICÁVEL — evidence chain implementada como conceito
- [x] Mycelium ZKP/Shadow Nodes: NÃO AGORA — overengineering sem base de usuários
- [x] Cross-app events (Intelink ↔ Intel): PLANEJADO para próxima fase
- [x] Prioridades filtradas: só tasks com ROI real (Evidence Chain, Activity Feed, Eagle Eye)
> **Documento:** Análise entregue no chat + knowledge base

### TASK-070: Activity Feed — Mycelium Event Trail ✅ (02/03/2026)
- [x] Backend: `activity.py` router com `/api/v1/activity/feed` + `/api/v1/activity/stats`
- [x] In-memory event store (500 max, Redis upgrade futuro)
- [x] Chat endpoint loga cada query como evento de atividade
- [x] Cada evento: type, title, source, result_count, cost_usd, timestamp
- [x] Frontend: `/app/activity` com timeline real-time (refresh 15s)
- [x] Stats bar: total events, by type (chat/search/report), custo total
- [x] Filtro por tipo de evento (click no stat)
- [x] Sidebar: Clock icon + nav.activity i18n
- [x] Testado: chat query → evento logado → visível no feed
> **Conceito Mycelium:** Cada ação do sistema é um evento auditável — transparência total.
> **Arquivos:** `api/src/bracc/routers/activity.py`, `frontend/src/pages/Activity.tsx`

### TASK-071: Eagle Eye Gazette Monitor ✅ (02/03/2026)
- [x] Backend: `gazette_monitor.py` com `/api/v1/monitor/gazettes/scan` + `/patterns`
- [x] 8 padrões investigativos: dispensa, inexigibilidade, aditivo, emergência, sobrepreço, tomada de contas, sanção, licitação fracassada
- [x] 10 cidades SP com dados no Querido Diário (Botucatu, Santos, Campinas, etc.)
- [x] Alertas auto-logados no Activity Feed
- [x] Testado: 23 alertas em Botucatu em 7 dias
- [x] Bridge Eagle Eye (egos-lab) ↔ EGOS Intel (produção)
> **Próximo:** Cron automático + dashboard de alertas + mais cidades
> **Arquivo:** `api/src/bracc/routers/gazette_monitor.py`

### TASK-072: GitGuardian Fix + Security Hardening ✅ (02/03/2026)
- [x] Incidente: Brave API key vazou em `apps/openclaw/config.json.bak.1` (EGOSv5 repo)
- [x] Key rotacionada pelo usuário
- [x] `.gitignore`: adicionado `*.bak`, `*.bak.*`, `*.backup`, `*.old`, `config.json.bak*`
- [x] `security_scan.ts`: +5 padrões (Brave BSA..., JSON apiKey/token, Bearer, backup files)
- [x] Pre-commit agora bloqueia: backup files + 13 padrões de secrets + entropy check
- [x] Regras de deploy documentadas em memória (docker rebuild para novos módulos)
> **Root cause:** .bak file não estava no .gitignore

### TASK-073: Website Overhaul — SEO + Copy + Crawlers ✅ (02/03/2026)
- [x] SEO meta tags: OG, Twitter Card, Schema.org JSON-LD, AI crawler meta
- [x] `robots.txt`: permitir AI crawlers (GPTBot, ChatGPT-User, Anthropic, Google-Extended)
- [x] `sitemap.xml`: landing + 4 relatórios
- [x] Landing page: custo corrigido $36 → $105/mês
- [x] Header/navbar com links para Pesquisar, Relatórios, Estatísticas, GitHub ✅ (03/03/2026)
- [x] Copy melhorada: CTA "Abrir Plataforma" (era "Open Explorer"), GitHub URL atualizada ✅ (03/03/2026)
- [ ] OG image para compartilhamento em redes sociais
> **Arquivos:** `index.html`, `robots.txt`, `sitemap.xml`, `Landing.tsx`

### TASK-074: Chatbot Intelligence — Reports + Proactive ✅ (02/03/2026)
- [x] System prompt: awareness de 4 relatórios com URLs
- [x] 6 sugestões inteligentes no welcome (em vez de 4 genéricas)
- [x] Regras proativas: "NUNCA peça se pode buscar, INVESTIGUE primeiro"
- [x] Testado: agora lista relatórios corretamente quando perguntado
- [x] Usa tools antes de responder (evidence chain ativa)
- [ ] Chatbot ainda pede cidade para queries nacionais (emendas, supersalários)
- [ ] Memória entre mensagens (histórico de sessão)
- [ ] Mais testes de hallucination e edge cases
> **Arquivo:** `chat.py` (SYSTEM_PROMPT), `ChatInterface.tsx`

### TASK-075: Docker DNS Fix — Permanent ✅ (03/03/2026)
- [x] Root cause: systemd-resolved `nameserver 127.0.0.53` não funciona dentro de containers Docker
- [x] Fix: `/etc/docker/daemon.json` com DNS `8.8.8.8`, `8.8.4.4`, `1.1.1.1` + retry opts
- [x] `systemctl restart docker` — todos containers voltaram healthy
- [x] Verificado: `docker run --rm alpine cat /etc/resolv.conf` mostra DNS corretos
- [x] `docker compose build api --no-cache` agora funciona sem falhas intermitentes
> **Arquivo:** `/etc/docker/daemon.json` no Contabo 217.216.95.126

### TASK-076: GitHub Actions — Reduce Noise ✅ (03/03/2026)
- [x] CI workflow: mudou de `push: main` para `pull_request + weekly Monday + manual`
- [x] Security workflow: mudou de `push: main` para `pull_request + weekly Wednesday + manual`
- [x] Release Drafter: mudou de `push: main` para `manual only`
- [x] Resultado: sem mais notificações de falha em cada commit
> **Arquivos:** `.github/workflows/ci.yml`, `security.yml`, `release-drafter.yml`

### TASK-077: Website Header/Navbar ✅ (03/03/2026)
- [x] PublicShell: adicionado nav com links Pesquisar, Relatórios, Estatísticas, GitHub
- [x] CTA: "Abrir Plataforma" (era "Open Explorer")
- [x] GitHub URLs atualizadas de br-acc para EGOS-Inteligencia
- [x] Responsivo: nav escondido em mobile (<768px)
- [x] Frontend rebuilt e deployed no Contabo
> **Arquivos:** `PublicShell.tsx`, `PublicShell.module.css`, `Landing.tsx`

### TASK-043: Gem Hunter v2 — Melhorar Busca de Projetos ⏳ (P2)
- [x] Adicionar keywords semanticas: "accountability", "civic tech", "open government"
- [x] Busca automatizada via GitHub Search API (5 categorias, 02/03/2026)
- [x] LMCache avaliado: NAO aplicavel (usamos API OpenRouter)
- [x] Bruin avaliado: framework ETL declarativo — NAO aplicavel AGORA (sem Neo4j), util futuro para DuckDB analytics
- [x] OSINT-BIBLE (299★), WebRecon (250★), OSINTel-Dashboard (39★) encontrados
- [x] synapse-lite (Neo4j fraud detection) encontrado — pequeno mas relevante
- [x] **Transparencia-360** analisado (04/03): Super Reports, anomaly workers, deduplicação — complementar
- [x] **Brazil Visible** analisado (04/03): 92 APIs catalogadas, health check, receitas cruzamento, 550+ tags
- [ ] Monitorar repos novos com cron semanal
- [ ] Manter registro de projetos avaliados (evitar re-avaliar)
- [ ] Implementar health check de APIs (inspirado Brazil Visible)
> **Projetos avaliados:** 9 + LMCache + 3 RokoOfficial + Bruin + 4 OSINT + Transparencia-360 + Brazil Visible (total: 20)
> **Transparencia-360:** github.com/MatheusMarkies/Transparencia-360 — Spring Boot + Neo4j, 26-step pipeline, Super Reports
> **Brazil Visible:** github.com/nferdica/brazil-visible — 92+ APIs, health check automático, receitas cruzamento

### TASK-091: Chat Agent Upgrade — 24 Tools + GPT-4o-mini ✅ (03/03/2026)
- [x] LLM: Gemini Flash → GPT-4o-mini (melhor multi-tool calling, 4 tools paralelos vs 1)
- [x] 6 novos OSINT tools: BNMP mandados, procurados Interpol, lista suja, PNCP licitações, OAB advogados, OpenCNPJ
- [x] System prompt: enforce 2-4 tool calls paralelos por query
- [x] max_rounds: 6 → 8, timeout: 30s → 45s
- [x] search_servidores: corrigido com SIAPE org codes (Senado=11001, STF=10001)
- [x] Custo: ~$0.001/query (4 tools), era ~$0.0003 (1 tool)
> **Arquivos:** `chat.py`, `transparency_tools.py`, `config.py`

### TASK-092: Exposure Score Fix — 5-Factor Scoring ✅ (03/03/2026)
- [x] Bug: pattern_percentile e baseline_percentile hardcoded 0.0 (30% do peso desperdiçado)
- [x] entity_score.cypher: retorna sanction_count, embargo_count, contract_count, amendment_count
- [x] score_service.py: compute real pattern percentile (sancionada+contratos=80%, sancionada=45%)
- [x] intelligence_provider.py: community tier agora usa 5 fatores (era 1)
- [x] Resultado: empresa 64 sanções: 90.0 (inflado) → 39.1 (realista)
> **Feedback do colaborador:** Corrigido conforme sugestão. Ranking agora é significativo.
> **Arquivos:** `score_service.py`, `intelligence_provider.py`, `entity_score.cypher`

### TASK-093: Activity Feed Pagination ✅ (03/03/2026)
- [x] 10 eventos por página (era 100 sem paginação)
- [x] Botões Anterior/Próxima com info "Página X de Y (N eventos)"
- [x] Reset de página ao mudar filtro
> **Arquivos:** `Activity.tsx`, `Activity.module.css`

### TASK-094: Chat UX — Guided Search + Model Transparency ✅ (03/03/2026)
- [x] Welcome: "Você não precisa de CNPJ!" + 4 exemplos de input
- [x] 8 sugestões acionáveis (políticos por cidade, lista suja, mandados, licitações)
- [x] Mostra modelo e custo no welcome message
- [x] 24 tools contados corretamente
> **Arquivos:** `ChatInterface.tsx`

### TASK-095: Model Fallback + Rate Limit + BYOK ✅ (03/03/2026)
- [x] 10 msgs/dia premium (GPT-4o-mini), 20 msgs/dia free (Gemini Flash), depois aviso BYOK
- [x] BYOK via header `x-openrouter-key` (chave do usuário no OpenRouter)
- [x] Aviso automático ao atingir limites de cada tier
- [x] Tier logado no activity feed (model + tier em cada evento)
- [x] _call_openrouter aceita model + api_key params
> **Arquivos:** `chat.py`

### TASK-096: Bug Fixes — DDG Search + PNCP API ✅ (03/03/2026)
- [x] DDG fallback: 3 regex patterns for resilience + graceful empty fallback
- [x] PNCP: try 3 endpoint URLs (API changed), handle 400 gracefully, date normalization
> **Issues:** #32 (P1), #33 (P2)
> **Arquivos:** `api/src/bracc/services/transparency_tools.py`

### TASK-097: System Map — API/Routes/Pages Inventory ✅ (03/03/2026)
- [x] Documentar 55+ endpoints em 13 routers
- [x] Frontend: 14 páginas inventory
- [x] Docker: 5 containers topology
- [x] 26 AI chat tools documented
- [x] 10 pattern detectors documented
- [x] Middleware & services documented
- [x] External bots (Discord + Telegram) documented
> **Arquivos:** `docs/SYSTEM_MAP.md`

### TASK-118: Transparency Report + Pattern Engine ✅ (03/03/2026)
- [x] Comprehensive transparency/methodology HTML report (10 sections)
- [x] All 38 active data sources documented with volumes
- [x] 41+ planned sources documented with status
- [x] 26 AI tools, 10 pattern detectors, roadmap, limitations, call to participate
- [x] Pattern detection engine enabled (config: patterns_enabled=True)
- [x] Report added to Reports page as first item
> **Arquivos:** `frontend/public/reports/transparencia-metodologia.html`, `frontend/src/pages/Reports.tsx`, `api/src/bracc/config.py`
- [ ] OSINT: 24 tools com rate limits
- [ ] Observability: structured logging, request tracing
> **Issue:** #34 (P2)

### TASK-119: SSOT Governance Scaffolding ✅ (03/03/2026)
- [x] AGENTS.md — project config, stack, commands, frozen zones, key metrics
- [x] .windsurfrules v1.0.0 — 12 mandamentos, orchestration protocol, doc SSOT table
- [x] .guarani/IDENTITY.md — agent identity, mission, ethical language rules
- [x] .guarani/PREFERENCES.md — Python/FastAPI/React coding standards
- [x] .guarani/orchestration/DOMAIN_RULES.md — domain checklists
- [x] .windsurf/workflows/start.md + end.md — session lifecycle
- [x] Doc dedup: symlinks for fontes-de-dados.md + system-capabilities
- [x] Cross-repo rules referencing egos-lab as canonical orchestration source
> **Arquivos:** `AGENTS.md`, `.windsurfrules`, `.guarani/`, `.windsurf/workflows/`

### TASK-098: BYOK Settings Page ✅ (03/03/2026)
- [x] Frontend: ByokSettings modal — Key icon in chat header, dark theme, PT-BR
- [x] Instruções: criar conta OpenRouter, inserir créditos, colar chave (3-step guide)
- [x] Security: chave só em localStorage, nunca logada no backend
- [x] API client: sendChatMessage sends x-openrouter-key header when BYOK key present
- [x] Backend already supports BYOK via x-openrouter-key header (chat.py)
> **Arquivos:** `frontend/src/components/chat/ByokSettings.tsx`, `frontend/src/components/chat/ChatInterface.tsx`, `frontend/src/api/client.ts`
> **Issue:** #35 (P2)

---

## Métricas

| Métrica | Valor | Data |
|---|---|---|
| **Nós no grafo** | 317.583 | 02/03/2026 |
| **Relacionamentos** | 34.507 | 02/03/2026 |
| **Issues GitHub abertas** | 27 | 02/03/2026 |
| **Tasks concluídas** | 60/85 | 03/03/2026 |
| **Chatbot Tools** | 24 (3 grafo + 8 livres + 6 Portal + 1 DataJud + 6 novos OSINT) | 03/03/2026 |
| **LLM Model** | GPT-4o-mini (premium) + Gemini Flash (free tier) | 03/03/2026 |
| **Rate Limit** | 10 premium + 20 free/dia por IP, BYOK suportado | 03/03/2026 |
| **ETL Status** | Phase 1 file 6/10 (15%) — Contabo CPU | 02/03/2026 |
| **Website** | inteligencia.egos.ia.br (SSL ✅) | 02/03/2026 |
| **Analytics** | Self-hosted + Clarity + Dashboard frontend ✅ | 02/03/2026 |
| **Web Search** | Brave Search (primário) + DDG (fallback) | 02/03/2026 |
| **Issues GitHub** | 35 abertas (4 fechadas: #25-#28) | 03/03/2026 |
| **APIs com chave** | Portal Transparência + DataJud + Brave | 02/03/2026 |
| **Segurança** | GitGuardian fix — chaves em env vars | 02/03/2026 |
| **Relatórios** | 4 publicados (Patense, SUPERAR, Manaus, RJ-SP) | 02/03/2026 |
| **Exposure Index** | 5-factor scoring (connections, sources, financial, patterns, baseline) | 03/03/2026 |
| **Evidence Chain** | Proveniência de dados em cada query ✅ | 02/03/2026 |
| **Cost/Query** | ~$0.001/query premium, ~$0.0003 free (~R$ 0,006) | 03/03/2026 |
| **Custo Mensal Real** | ~$105/mês (~R$ 630) | 02/03/2026 |

### TASK-090: UI Polish — Scrollbar, Reports HTML, Privacy, Sidebar ✅ (03/03/2026)
- [x] Dark scrollbar matching site palette (scrollbar-color: bg-surface/bg-secondary)
- [x] Reports page: cards now open HTML in new tab (removed raw MD viewer)
- [x] 3 new HTML report pages (SUPERAR, Manaus, Recuperação Judicial) — standardized template
- [x] Activity feed: hide search terms/entity names for user privacy
- [x] Sidebar: fix "EGOS Inteligência" text cutoff (font-size-sm + ellipsis)
- [x] ReportsShowcase landing: all 4 reports shown (was showing only Patense)
- [x] PR #24 mobile responsive CSS merged + deployed
- [x] PR #29 spam bot closed
- [x] GitHub issues #6 + #7 closed (resolved by PR #30)
- [x] FAQ PT-BR created (docs/pt-BR/FAQ.md, closes issue #4)
- [x] Analytics verified: 21 unique visitors, 5270 views — REAL (Redis in-memory)
- [ ] X.com post: API returning 503 (Twitter outage), retry later
> **Arquivos:** `global.css`, `AppShell.module.css`, `Reports.tsx`, `Activity.tsx`, `ReportsShowcase.tsx`, 3 HTML reports

### TASK-087: Branding — EGOS Logo as Favicon + OG Image ✅ (03/03/2026)
- [x] Generate favicon.ico (16/32/48px), favicon-16x16.png, favicon-32x32.png
- [x] Generate apple-touch-icon.png (180x180), android-chrome (192/512)
- [x] Generate og-image.png (1200x630) for social sharing previews
- [x] Create site.webmanifest (theme: #00e5a0, standalone)
- [x] Update index.html with all icon refs + OG image + Twitter image
- [x] Deploy to Contabo — all assets returning HTTP 200
> **Source:** `/home/enio/Downloads/egos_discord_icon_1771941656007.png`
> **Arquivos:** `index.html`, `favicon.ico`, `site.webmanifest`, `og-image.png`

### TASK-089: Mobile Responsive CSS ✅ (03/03/2026)
- [x] PR #24 by @Kai-Rowan-the-AI: pure CSS mobile responsive improvements (+235/-0)
- [x] GraphExplorer: stacks vertically on mobile, hides resize handle
- [x] Dashboard: mobile breakpoints for search, results, investigation cards
- [x] CommandPalette: mobile sizing, hides keyboard shortcuts
- [x] global.css: font size reduction on mobile (768px/480px breakpoints)
- [x] Code review: approved + merged
> **Arquivos:** 7 CSS modules (GraphExplorer, Dashboard, Search, EntityAnalysis, CommandPalette, ControlsSidebar, global.css)

### TASK-088: First Community PR — Benford's Law + HHI Patterns ✅ (03/03/2026)
- [x] PR #30 by @mrncstt: 2 new intelligence patterns (+134/-2 lines)
- [x] Benford's Law: flags contract values deviating from expected leading-digit distribution (MAD threshold)
- [x] HHI Concentration: flags companies with high Herfindahl-Hirschman Index across contracting agencies
- [x] Code review: approved with minor observations (precision, performance, scaling docs)
- [x] Merged to main, API rebuild deployed
- [x] Test count: 8→10 patterns, 48 unit tests passing
> **Milestone:** First external contributor! ~70 GitHub stars 🎉
> **Arquivos:** `config.py`, `pattern.py`, `intelligence_provider.py`, 2 new `.cypher` files

### TASK-086: UI Fix — Scrolling + Analytics Improvement ✅ (03/03/2026)
- [x] Root cause: AppShell.module.css `.main` had `overflow: hidden` — killed scrolling on ALL app pages
- [x] Fix: changed to `overflow: auto` — Reports, Activity, Analytics all scroll now
- [x] Analytics: aggregate entity analysis URLs into single group (was polluting 200+ entries)
- [x] Analytics: added note about in-memory data persistence (resets on API restart)
- [x] Analytics data verified REAL: 4607 views, 20 unique visitors, 80 activity events
- [x] Contract tests: 9/9 endpoints passing (health, search, chat, cache, analytics, activity, 422, 404)
> **Arquivos:** `AppShell.module.css`, `Analytics.tsx`

### TASK-078: Crash Prevention — Defensive Frontend ✅ (03/03/2026)
- [x] Root cause: SourceRegistry crashed on placeholder sources.json (no sources array)
- [x] 14 files fixed: ?? [] guards on entity_ids, sources, entities, categories
- [x] Neo4j retry on startup: 30 attempts with 2-30s backoff (dependencies.py)
- [x] API healthcheck in docker-compose (Python urllib, 60s start_period)
- [x] Caddy depends on API+Frontend healthy before routing traffic
- [x] Pre-commit hook v2: warns on unsafe .length/.map without ?? guard
- [x] Memory saved: defensive coding rules for EGOS Inteligência
> **Impact:** 94% of requests were 502 errors before fix. Now 100% healthy.
> **Arquivos:** dependencies.py, docker-compose.yml, SourceRegistry.tsx, 13 more components

### TASK-079: Novas Fontes — ComexStat (MDIC) ⬜ (P2)
- [ ] ETL: API REST api-comexstat.mdic.gov.br — importação/exportação por CNPJ/NCM/município
- [ ] Grafo: Empresa ↔ Município ↔ Produto (NCM) ↔ Fluxo comercial
- [ ] Detecção: dumping, triangulação, crescimento anômalo de importações
> **Fonte:** https://api-comexstat.mdic.gov.br/docs
> **LGPD:** Dados agregados por empresa (CNPJ), 100% público

### TASK-080: Novas Fontes — ANM (Mineração + CFEM) ⬜ (P2)
- [ ] ETL: API/CSV da Agência Nacional de Mineração
- [ ] Grafo: Empresa ↔ Título Minerário ↔ Município ↔ Royalties CFEM
- [ ] Cruzar com sanções, contratos, DOU
> **Fonte:** https://www.gov.br/anm/pt-br/acesso-a-informacao/dados-abertos
> **LGPD:** Registro público (Lei 227/1967)

### TASK-081: Novas Fontes — SALIC / Lei Rouanet ⬜ (P2)
- [ ] ETL: API api.salic.cultura.gov.br — projetos culturais + captação + patrocinadores
- [ ] Grafo: CNPJ/Proponente ↔ Projeto ↔ Captação ↔ Patrocinador
- [ ] LGPD: masking extra para proponentes pessoa física
> **Fonte:** https://api.salic.cultura.gov.br/docs

### TASK-082: Novas Fontes — CADE (Concorrência) ⬜ (P2)
- [ ] ETL: dados abertos CADE — processos + multas + TCCs
- [ ] Grafo: Empresa ↔ Processo CADE ↔ Multa ↔ TCC
- [ ] Cruzar com contratos públicos e sanções
> **Fonte:** https://www.gov.br/cade/pt-br/centrais-de-conteudo/cade-em-numeros

### TASK-083: Novas Fontes — INPI (Propriedade Industrial) ⬜ (P2)
- [ ] ETL: dados abertos INPI — patentes, marcas, desenhos industriais
- [ ] Grafo: Empresa ↔ Patente/Marca ↔ Setor
> **Fonte:** https://www.gov.br/inpi/pt-br (dados abertos)
> **LGPD:** Registro público (Lei 9.279/1996)

### TASK-084: Novas Fontes — GLEIF (Identificador Global) ⬜ (P3)
- [ ] ETL: API GLEIF — LEI (Legal Entity Identifier) + ownership chains
- [ ] Entity resolution cross-border: conectar CNPJs a LEIs globais
- [ ] Enriquecer offshores ICIJ com dados GLEIF
> **Fonte:** https://www.gleif.org/en/lei-data/gleif-api

### TASK-085: Novas Fontes — TCEs/TCMs (Tribunais de Contas) ⬜ (P3)
- [ ] Mapear portais de dados abertos dos 33 TCEs + TCMs
- [ ] ETL: licitações, contratos, folhas de pagamento estaduais/municipais
- [ ] Grafo: Empresa ↔ Contrato Estadual/Municipal ↔ Servidor
> **Impacto:** Expande cobertura além do federal para estados e municípios

### TASK-099: Review PR #38 — Em-dash to Hyphen Normalization ✅ (03/03/2026)
- [x] **Autor:** @mrncstt (comunidade)
- [x] **Escopo:** 6 arquivos, 6 linhas — substitui `—` por `-` em 6 componentes frontend
- [x] **Decisão:** Merged (admin) — mudança cosmética, gesto de acolhimento ao contribuidor
- [x] Também corrigiu typo "Societaria" → "Societária" no ReportsShowcase
> **PR:** https://github.com/enioxt/EGOS-Inteligencia/pull/38

### TASK-100: Review PR #39 — Índice Central de Documentação ⏳ (P1 — Split)
- [x] **Autor:** @enioxt (Codex-generated)
- [x] **Análise:** 354 adições — docs + código ETL misturados
- [ ] **AÇÃO:** Merge apenas docs (README.md, STACK_SCALING_DECISION, MYCELIUM_AUDIT_TRAIL)
- [ ] **AÇÃO:** Separar código ETL (base.py, provenance.py, test_provenance.py) → TASK-104
- [x] **Stack Decision:** Documento CRÍTICO — manter Python, não migrar para Go (ver análise abaixo)
> **PR:** https://github.com/enioxt/EGOS-Inteligencia/pull/39

### TASK-104: Review ETL Provenance Code (split de PR #39) ⬜ (P2 — Análise Técnica)
- [ ] `etl/src/bracc_etl/provenance.py` — SHA-256 hash de linhas brutas, source fingerprint
- [ ] `etl/src/bracc_etl/base.py` — método `build_audit_fields()` no Pipeline base
- [ ] `etl/tests/test_provenance.py` — testes de estabilidade de hash
- [ ] **Valor:** Não-repúdio dos dados (de onde veio, quando, hash da linha original)
- [ ] **Risco:** Precisa validar que não quebra ETL em produção (10.5G memória, 9M+ nós)
- [ ] **Decisão:** Testar em ambiente isolado antes de merge
> **Origem:** PR #39 (código separado dos docs)

### TASK-101: Review PR #40 — Mycelium Migration Plan + GitNexus Eval ⬜ (P2 — Adiado)
- [ ] **Autor:** @enioxt (Codex-generated)
- [ ] **Docs:** MYCELIUM_LEGACY_MIGRATION_PLAN.md (migração incremental de dados legados)
- [ ] **Docs:** GITNEXUS_EGOS_AVALIACAO_PRELIMINAR.md (avaliação de projeto externo)
- [ ] **Script PERIGOSO:** legacy_tagging_backfill.cypher — marca TODOS nós sem audit_hash como "legacy"
- [ ] **AÇÃO:** Merge docs quando conveniente. Script Cypher NÃO rodar sem dry-run em staging
- [ ] **Decisão adiada:** Avaliar após TASK-104 (provenance code)
> **PR:** https://github.com/enioxt/EGOS-Inteligencia/pull/40

### TASK-102: Review PR #31 — BR-ACC Upstream Monitor ⏳ (P1 — Split Pedido)
- [x] **Autor:** @Douglas-Strey (comunidade)
- [x] **Análise:** 1.624 adições — script útil mas escopo grande demais
- [x] **Comentário postado:** Pedido split em (A) script+workflow, (B) docs SSOT
- [ ] **Aguardando:** Resposta do Douglas com PRs separadas
- [ ] **Valor:** Monitor de upstream é útil para acompanhar forks e contribuições
- [ ] **Risco:** Modifica TASKS.md/ROADMAP/README (nossos SSOT docs)
> **PR:** https://github.com/enioxt/EGOS-Inteligencia/pull/31

### TASK-103: Intelink Copy — Linguagem Neutra (só no que migrarmos) ⏳ (P1)
- [x] "investigação/investigações" → "pesquisa/pesquisas" (i18n PT-BR já estava neutro, EN corrigido)
- [x] Reports.tsx, Dashboard.tsx, PartnershipCTA.tsx — texto hardcoded corrigido
- [x] i18n EN: "Investigate in depth" → "Research in depth"
- [ ] "operação/operações" → "caso/casos" ou "análise/análises" (não encontrado em uso)
- [ ] "acusado/acusados" → "envolvido/envolvidos" (não encontrado em UI)
- [ ] "suspeito/suspeitos" → "pessoa de interesse" (não encontrado em UI)
- [ ] "Inteligência Policial" → "Inteligência em Dados Públicos" (não encontrado em UI)
- [x] NÃO renomear variáveis código (Investigation, investigations) — mantido para API compat
- [x] Manter ambos sites funcionando (intelink.ia.br + inteligencia.egos.ia.br)
> **Contexto Discord:** @ericklucioh perguntou "oq seria investigacoes e relatorios?" — @enioxt respondeu "Resquícios do Intelink, vou mudar o nome"
> **Arquivos:** `Reports.tsx`, `Dashboard.tsx`, `PartnershipCTA.tsx`, `i18n.ts`

---

## Audit Tasks (Dossiê Técnico 2026-03-03)

> Geradas pela auditoria completa do código-fonte. Ref: `docs/TECHNICAL_DOSSIE_2026-03.md`

### TASK-105: Rotacionar API Keys Expostas ✅ (03/03/2026)
- [x] Rotacionar key Portal da Transparência (nova key aplicada na VPS)
- [x] DataJud — API pública, sem necessidade de rotação (https://datajud-wiki.cnj.jus.br/api-publica/acesso)
- [x] Brave Search — rotacionada pelo usuário (aguardando nova key para atualizar VPS)
- [x] Atualizar `.env` na VPS (`/opt/bracc/infra/.env`)
- [ ] Considerar BFG Repo Cleaner para limpar git history (P2)
> **Arquivos:** `/opt/bracc/infra/.env`

### TASK-106: Whitelist Cypher Injection em `_tool_cypher` ✅ (03/03/2026)
- [x] Substituir blacklist (`CREATE, DELETE, MERGE...`) por whitelist
- [x] Permitir APENAS: `MATCH`, `RETURN`, `WITH`, `UNWIND`, `ORDER`, `LIMIT`, `WHERE`, `OPTIONAL`, `AS`, `DISTINCT`, `COUNT`, `SUM`, `AVG`, `COLLECT`
- [x] Bloquear: `CALL`, `LOAD CSV`, `FOREACH`, `CREATE`, `DELETE`, `MERGE`, `SET`, `REMOVE`, `DROP`, `DETACH`
- [ ] Adicionar teste de regressão (P2)
> **Evidência:** `api/src/bracc/routers/chat.py:264-281`
> **Esforço:** 1h | **Impacto:** Fecha maior vetor de ataque

### TASK-107: Migrar Conversas para Redis ✅ (03/03/2026)
- [x] Conversas já tinham Redis persistence via `conversations.py` (30-day TTL, CRUD, ownership)
- [x] Migrar `_usage_counts` e `_usage_day` para Redis INCR com TTL 24h
- [x] Graceful degradation (Redis down = in-memory fallback)
- [x] Key pattern: `egos:usage:{date}:{client_id}`
> **Evidência:** `api/src/bracc/routers/chat.py:66-73`
> **Esforço:** 2h | **Impacto:** Conversas sobrevivem restart/deploy

### TASK-108: Split `chat.py` em Módulos ✅ (03/03/2026)
- [x] Extrair `chat_tools.py` — 26 tool definitions (TOOLS array, 393 lines)
- [x] Extrair `chat_models.py` — Pydantic models (ChatMessage, EntityCard, etc.)
- [x] Extrair `chat_prompt.py` — SYSTEM_PROMPT (67 lines)
- [ ] Extrair `chat_openrouter.py` — `_call_openrouter()` + tool execution loop (P2)
- [x] `chat.py` reduzido de 1330 → 845 linhas (36% redução)
> **Arquivos:** `chat_models.py`, `chat_tools.py`, `chat_prompt.py`

### TASK-109: Testes Backend — Integration Tests ⏳
- [x] Setup pytest + httpx AsyncClient fixtures (conftest.py with mock Neo4j)
- [x] 219 unit tests passing (session 17: fixed 3 stale assertions)
- [x] Test patterns endpoint (list, 503 disabled, 404 invalid, include_probable)
- [x] Test CPF masking middleware (mask, PEP exception)
- [x] Test public_guard (CPF blocked, Person hidden, props stripped)
- [x] Test search endpoint against live VPS (fulltext, CNPJ, empty query, pagination)
- [x] Test chat endpoint (simple query, empty rejection)
- [x] Test entity lookup (CNPJ, invalid format, graph traversal)
- [x] Test patterns against live VPS (list 10, invalid 404)
- [x] Test health/meta/activity/cache endpoints
- [x] 955 ETL unit tests passing (0 warnings after Pandas fix)
- [ ] Integration tests with testcontainers Neo4j
- [ ] Test chat tool calling + tier fallback + rate limit
> **Status (session 17-18):** 219 API unit + 18 live integration + 955 ETL = **1,192 tests**
> **Arquivos:** `api/tests/integration/test_live_api.py`, `api/tests/unit/`, `etl/tests/`
> **Esforço restante:** 2h | **Impacto:** Qualidade e confiança

### TASK-110: Neo4j Backup Script (Cron) ✅ (03/03/2026)
- [x] Hot tar backup do volume Docker (sem parar Neo4j) + count snapshot
- [x] Cron job diário às 3AM (`/opt/bracc/scripts/neo4j-backup.sh`)
- [x] Reter últimos 5 backups (rotação automática)
- [x] APOC export habilitado (`apoc.export.file.enabled=true` em apoc.conf)
- [x] Alertar se dump falhar via Telegram (v2 deployed 04/03/2026)
> **Arquivos:** `/opt/bracc/scripts/neo4j-backup.sh`, `/opt/bracc/backups/`
> **Nota:** neo4j-admin dump falha em Community Edition. Backup via tar do volume (~1.5GB comprimido de 6.7GB)

### TASK-111: Circuit Breaker para APIs Externas ✅ (03/03/2026)
- [x] `circuit_breaker.py` — per-host circuit breaker (CLOSED→OPEN→HALF_OPEN)
- [x] Config: 5 failures in 2min window → 60s cooldown
- [x] `safe_get()` helper in `transparency_tools.py` wraps httpx + circuit breaker
- [x] `get_status()` method for monitoring all circuits
- [ ] Migrar todas as 21 tools para usar `safe_get()` (progressivo, P2)
> **Arquivos:** `services/circuit_breaker.py`, `services/transparency_tools.py`

### TASK-112: Input Sanitization (Prompt Injection) ✅ (03/03/2026)
- [x] 10 regex patterns: ignore instructions, system prompt reveal, jailbreak, DAN mode, special tokens
- [x] Soft detection: log suspicious inputs via activity feed (não bloqueia)
- [x] 13 unit tests cobrindo todos os patterns + queries normais PT/EN
- [ ] Rate limit agressivo para IPs com inputs suspeitos (P2 futuro)
> **Arquivos:** `middleware/input_sanitizer.py`, `tests/unit/test_input_sanitizer.py`, `routers/chat.py`

### TASK-113: BFG Repo Cleaner — Git History ⬜ (P2)
- [ ] Executar BFG para remover API keys do history completo
- [ ] Force push (coordenar com contribuidores)
- [ ] Verificar que keys não aparecem mais em `git log -p`
> **Depende de:** TASK-105 (rotacionar primeiro)
> **Esforço:** 1h

### TASK-114: DSAR Workflow Automatizado ⏳ (P2)
- [x] GitHub issue template `dsar_request.yml` — 6 request types, identity, evidence, attestation (session 18)
- [ ] Endpoint `/api/v1/dsar` para submissão programática
- [ ] Workflow: register → verify scope → produce decision log
- [ ] Prazo LGPD: 15 dias úteis para resposta
> **Arquivos:** `.github/ISSUE_TEMPLATE/dsar_request.yml`
> **Evidência:** LGPD Art. 18 — template criado, API pendente

### TASK-115: CORS Explícito + JWT Startup Validation ✅ (03/03/2026)
- [x] CORS: `allow_headers` explícito (Authorization, Content-Type, Accept, Origin, X-Requested-With)
- [x] CORS: `allow_methods` explícito (GET, POST, PUT, DELETE, OPTIONS)
- [x] JWT: `raise RuntimeError` em production se secret fraco/default (dev apenas loga)
> **Arquivos:** `main.py`

### TASK-116: Componentizar Landing.tsx ✅ (03/03/2026)
- [x] Extrair HeroSearch → `components/landing/HeroSearch.tsx`
- [x] Extrair LiveDatabaseStatus → `components/landing/LiveDatabaseStatus.tsx`
- [x] Extrair PartnershipCTA → `components/landing/PartnershipCTA.tsx`
- [x] Landing.tsx: 533 → 287 linhas (-46%)
> **Arquivos:** `pages/Landing.tsx`, `components/landing/HeroSearch.tsx`, `components/landing/LiveDatabaseStatus.tsx`, `components/landing/PartnershipCTA.tsx`

### TASK-117: Registro de Tratamento LGPD (Art. 37) ✅ (03/03/2026)
- [x] 6 categorias documentadas: CNPJ, TSE, Contratos, Sanções, PEP, Interação
- [x] Base legal, finalidade, retenção, medidas de segurança por categoria
- [x] Tabela de medidas técnicas e organizacionais
- [x] Workflow de direitos do titular (Art. 18)
> **Arquivos:** `docs/legal/REGISTRO_TRATAMENTO.md`

### TASK-118: Observabilidade — Request Tracing + JSON Logs + Security Posture ✅ (03/03/2026)
- [x] `RequestIDMiddleware` — X-Request-ID header em toda resposta (gera ou ecoa do cliente)
- [x] `GET /api/v1/meta/security` — endpoint de postura de segurança (sem segredos)
- [x] `logging_config.py` — JSON structured logs em produção, human-readable em dev
- [x] 3 novos testes para middleware (gerar, ecoar, unicidade)
- [x] 235 API unit tests passando (219 + 13 sanitizer + 3 request-id)
> **Arquivos:** `middleware/request_id.py`, `logging_config.py`, `routers/meta.py`, `main.py`

### TASK-120: Pre-commit v2 + Workflows v2 ✅ (03/03/2026)
- [x] 8-section pre-commit hook: security, python, frontend, data accuracy, fork sync, PR/issue, TASKS sync, convention
- [x] Detects stale data (141M/MIT), upstream fork delta, open PRs
- [x] /start v2: API live check, upstream sync, PR/issue/fork count
- [x] /end v2: GitHub issue close sync, deployment verify
- [x] Upstream remote added (World-Open-Graph/br-acc)
- [x] gh default set to enioxt/EGOS-Inteligencia
> **Arquivos:** `scripts/pre-commit-v2.sh`, `.windsurf/workflows/start.md`, `.windsurf/workflows/end.md`

### TASK-121: Methodology Page ✅ (03/03/2026) — GitHub #51
- [x] New /app/methodology route with iframe to existing HTML
- [x] BookOpen icon in sidebar, i18n keys (PT-BR + EN)
- [x] Removed from PUBLISHED_REPORTS in Reports.tsx
> **Arquivos:** `frontend/src/pages/Methodology.tsx`, `App.tsx`, `AppShell.tsx`, `i18n.ts`

### TASK-122: Data Accuracy SSOT ✅ (03/03/2026) — GitHub #52
- [x] Created platform-stats.json with ALL verified numbers
- [x] Fixed 14 data errors across 9 files (141M→9.2M, MIT→AGPL, 38→36, etc)
- [x] Verified 11 metrics against live API (100% match)
- [x] Pre-commit detects stale numbers
> **Arquivos:** `frontend/public/updates/platform-stats.json`, 9 files corrected

### TASK-123: Multi-hop Connection Finder (Tool #27) ✅ (03/03/2026)
- [x] find_connection_path — shortestPath with configurable depth (1-6 hops)
- [x] Fuzzy entity matching via fulltext index
- [x] Evidence chain integration
- [x] Deployed to VPS (docker cp + restart)
- [ ] **BLOCKED:** Only 4 SOCIO_DE relationships in Neo4j — tool works but graph too sparse
> **Arquivos:** `api/src/bracc/routers/chat.py`, `api/src/bracc/routers/chat_tools.py`
> **Depende de:** TASK-001 (CNPJ ETL Phase 3 must re-run to load 24.6M SOCIO_DE)

### TASK-124: GitHub Issues Sync ✅ (03/03/2026)
- [x] Closed issues #34 (System Map), #35 (BYOK)
- [x] Created issues #49-55 (security, devops, methodology, SSOT, investigation, BFG, Intelink)
- [x] 30 open issues covering all project areas
> **Total:** 55 issues (25 closed, 30 open)

### TASK-125: Codex CLI Integration ✅ (04/03/2026)
- [x] Define 6 roles: Code Review, Test Writer, Doc Updater, Bug Fixer, Async Refactor, Security Audit
- [x] Add delegation rules to `.windsurfrules` (v2.0.0)
- [x] Update `/start` workflow with Codex status check (Section 6)
- [x] Update `/end` workflow with Codex cleanup step (Section 8)
- [x] Add Section 9 to pre-commit (Codex CLI reminder, 10 sections total)
- [ ] Login and register GitHub (`codex login`)
- [ ] Run first delegated task (code review)
> **Arquivos:** `.windsurfrules`, `start.md`, `end.md`, `pre-commit-v2.sh`

### TASK-126: Análise Transparencia-360 ✅ (04/03/2026)
- [x] Repo analisado: Spring Boot + Neo4j + Python workers, 26-step pipeline
- [x] Comparação: 8 fontes vs nossas 108, sem AI chat, com Super Reports automatizados
- [x] Features valiosas: GhostEmployee/RachadinhaWorker, deduplicação, SpatialAnomaly
- [x] Nosso diferencial: 4.5x mais fontes, AI chatbot 27 tools, evidence chain
- [ ] Agradecer no repositório deles (GitHub star/issue)
> **Ref:** https://github.com/MatheusMarkies/Transparencia-360

### TASK-127: Análise Brazil Visible ✅ (04/03/2026)
- [x] Repo + site analisados: 92 APIs em 22 categorias, 5 receitas cruzamento
- [x] Features valiosas: health check automático (6h), 550+ tags, Jupyter notebooks
- [x] Inspirado pela comunidade br/acc (mesma que nosso fork original)
- [x] Nosso diferencial: executamos cruzamentos interativamente, eles documentam
- [ ] Agradecer no repositório deles (GitHub star/issue)
> **Ref:** https://github.com/nferdica/brazil-visible

### TASK-128: Activity Feed v2 — Redis Persistence ✅ (04/03/2026)
- [x] Cumulative counters in Redis (survive restarts)
- [x] Daily breakdown, unique users, model/source tracking
- [x] Daily activity chart, model usage, top sources in frontend
> **Arquivos:** `activity.py`, `Activity.tsx`

### TASK-129: AI Model Fallback + Landing Cleanup ✅ (04/03/2026)
- [x] MODEL_FALLBACK = google/gemini-2.0-flash-exp:free (auto-switch on 402/429)
- [x] Removed LiveDatabaseStatus + DATA_SOURCES grid (duplicates)
- [x] Methodology iframe CSP fix (frame-ancestors + X-Frame-Options)
- [x] Backend-frontend sync check in pre-commit (Section 8)
> **Arquivos:** `chat.py`, `Caddyfile`, `Landing.tsx`, `pre-commit-v2.sh`

### TASK-130: Docker Auto-Heal System ✅ (04/03/2026)
- [x] `scripts/auto-heal.sh` — 4-layer monitoring (container state, healthcheck, URL check, disk space)
- [x] Deployed to VPS `/opt/bracc/scripts/auto-heal.sh`
- [x] Cron every 2 minutes (`*/2 * * * *`)
- [x] Logs to `/opt/bracc/logs/auto-heal.log` (auto-trimmed to 500 lines)
- [x] Verifies site HTTP 200 after healing
> **Root cause (session 26):** Containers were in "Created" state after `docker compose up` dependency chain failure.
> **Prevention:** Script detects Created/Exited/Dead containers and force-starts them.

### TASK-131: Landing Page Redesign — Civic Intelligence Hub ⬜ (P1)
- [ ] Use Google Stitch (stitch.withgoogle.com) to prototype dark-theme landing page
- [ ] Align with www.egos.ia.br aesthetic (dark, modern, Palantir/Linear style)
- [ ] Position as "Hub de Inteligência Cívica Compartilhada"
- [ ] Inspiração: OCCRP Aleph, Hack23/CIA, Open Politics HQ, Decidim, CitiLink
- [ ] Hero: AI chatbot + live stats + search bar (keep existing)
- [ ] Add: "How it compares" section (vs Palantir, vs OCCRP)
- [ ] Add: Community/contributors section
- [ ] Mobile-first responsive design
> **Stitch:** stitch.withgoogle.com — text→UI design + React/Tailwind code
> **Ref:** OCCRP Aleph (data platform), Decidim (citizen participation), Open Politics HQ (politics intelligence)

### TASK-132: GSD Context Engineering — Adopt for EGOS ⬜ (P2)
- [ ] Evaluate GSD's spec-driven development (SPEC.md → PLAN.md → execute) for egos-lab agents
- [ ] Adopt "files as long-term memory" pattern (STATE.md, CONTEXT.md) to reduce LLM context rot
- [ ] Implement Plan→Check→Revise loop for Cypher query validation
- [ ] Add Nyquist validation (GSD's spec quality checker) concept to orchestration pipeline
- [ ] Measure token savings vs current approach
> **Ref:** gsd-build/get-shit-done (24K★, MIT) — meta-prompting + context engineering for Claude Code
> **Relevância:** Reduz custo LLM e melhora qualidade de outputs longos

---

## Novos Produtos (Cross-Repo)

### TASK-133: NexusBridge — Camada de Interoperabilidade Cross-Repo ⬜ (P1)
- [ ] TASK-NB-001: Criar SERVICE_KEY no .env da VPS + middleware de validação
- [ ] TASK-NB-002: Criar router `/api/v1/interop/` no br-acc (FastAPI)
- [ ] TASK-NB-003: Endpoint `GET /interop/entity/{cnpj}` — busca empresa + sócios
- [ ] TASK-NB-004: Endpoint `GET /interop/network/{cnpj}` — grafo de rede (1 hop)
- [ ] TASK-NB-005: Endpoint `GET /interop/pep/{cpf_or_name}` — check PEP
- [ ] TASK-NB-006: Endpoint `GET /interop/sanctions/{cnpj}` — sanções CEIS/CNEP
- [ ] TASK-NB-007: Endpoint `GET /interop/health` — status do Neo4j + contagens
- [ ] TASK-NB-008: Criar `bracc-client.ts` no egos-lab (`packages/shared/src/`)
- [ ] TASK-NB-009: Criar tool `bracc.query-entity` no MCP do egos-lab
- [ ] TASK-NB-010: Integrar no Telegram bot — consultar VPS quando user perguntar sobre empresa
- [ ] TASK-NB-011: Client no carteira-livre para KYC enrichment
- [ ] TASK-NB-012: Audit log de queries interop
- [ ] TASK-NB-013: Rate limit por SERVICE_KEY
> **Spec:** `colaboracao-multi-repos/NEXUSBRIDGE_SPEC.md`
> **Princípio:** Neo4j na VPS é SSOT. Sem duplicação. Endpoints semânticos, nunca Cypher cru.
> **Depende de:** TASK-001 (ETL) para dados completos

### TASK-134: [MOVED] Forja — Moved to private repo (github.com/enioxt/FORJA) ✅ (05/03/2026)

---

## P1 — Novas Tasks (Sprint 06/03/2026)

### TASK-135: Padrão de Relatórios — Disclaimers, Fontes, Colaboração ⬜ (P1)
- [x] Criar template padrão de relatórios (`docs/standards/REPORT_STANDARDS.md`)
- [ ] Aplicar padrão ao relatório Vorcaro v2 (disclaimer legal, rodapé, fontes por afirmação)
- [ ] Aplicar padrão a todos os relatórios futuros gerados pelo bot/sistema
- [ ] Criar validador automático (agent) que verifica conformidade de relatórios
> **Princípio:** Nenhuma acusação, fontes rastreáveis, convite à correção.
> **Arquivo:** `docs/standards/REPORT_STANDARDS.md`

### TASK-136: Provenance/Não-Repúdio — Integrar em Pipelines ⬜ (P0)
- [x] Módulo `bracc_etl/provenance.py` criado com SHA-256 determinístico
- [x] Testes unitários (`tests/test_provenance.py`)
- [ ] Integrar `build_audit_fields()` no pipeline CNPJ/QSA
- [ ] Integrar no pipeline Sanctions (CEIS/CNEP)
- [ ] Integrar no pipeline DataJud
- [ ] Marcar dados legados como `audit_status = "legacy"` via script Cypher
- [ ] Criar nó `:DataSource` + rel `[:PROVENANCE]` no grafo para fontes críticas
- [ ] Validar que hash é estável (mesmo input → mesmo hash) em produção
> **Arquivo:** `etl/src/bracc_etl/provenance.py`
> **Plano:** `docs/analysis/MYCELIUM_AUDIT_TRAIL_2026-03.md`

### TASK-137: Mapa de Bases Governamentais + Posicionamento ⬜ (P1)
- [x] Criar mapa de bases públicas vs restritas (`docs/standards/GOVERNMENT_DATABASES_MAP.md`)
- [ ] Adicionar seção "Para Autoridades" na landing page do br-acc
- [ ] Criar página `/authorities` no frontend com proposta de valor
- [ ] Incluir mapa de bases na documentação do README
- [ ] Preparar one-pager PDF para envio a órgãos (MP, CGU, TCU, PF)
> **Proposta:** Código aberto + dados públicos + infraestrutura gratuita para autoridades.
> **Arquivo:** `docs/standards/GOVERNMENT_DATABASES_MAP.md`

### TASK-138: DataJud — Ingestão de Dados Judiciais ⬜ (P1)
- [ ] Obter credencial de acesso à API DataJud (CNJ)
- [ ] Executar `download_datajud.py` com filtros por entidades do caso Vorcaro
- [ ] Rodar pipeline DataJud para carregar processos no Neo4j
- [ ] Cruzar processos judiciais com entidades já mapeadas (Master, Viking, Entre)
> **Pipeline:** `etl/src/bracc_etl/pipelines/datajud.py` (existe, 0 dados carregados)
> **Depende de:** Acesso à API DataJud

### TASK-139: Caso Vorcaro v3 — Expansão com Dados Cruzados ⬜ (P1)
- [x] v1: Fatos oficiais + entidades manuais (06/03/2026)
- [x] v2: Neo4j cross-reference — 8 CNPJs, 15 empresas Vorcaro, 8 sócios, 0 sanções CEIS/CNEP
- [ ] v3: Aplicar REPORT_STANDARDS (disclaimer, rodapé, provenance)
- [ ] v3: Expandir rede 2º grau (sócios dos sócios)
- [ ] v3: Cruzar com DataJud (quando disponível)
- [ ] v3: Cruzar com Diários Oficiais (Querido Diário)
- [ ] v3: Identificar os 14 acusados CVM restantes (requer corpo do PAS)
> **Arquivo:** `docs/cases/caso-vorcaro-mapa-publico.md`

---

*"Siga o dinheiro público. Dados abertos, código aberto."*
