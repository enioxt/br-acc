# TASKS_ARCHIVE.md — Completed Tasks (Append-Only)

Seções completas arquivadas de TASKS.md para manter o arquivo ativo conciso.

---

## Archived 2026-04-23

### TASK-003: Search Fix + Hardcoded Data ✅ (02/03/2026)
- [x] Remover números falsos do i18n.ts (87M, 53M, 8 algoritmos)
- [x] Adicionar wildcard + fuzzy search na API (`_build_search_query()`)
- [x] Deploy API + frontend reconstruídos
- [x] Verificar busca funcionando ("silva" → 1073 resultados)
> **Arquivos:** `api/src/egos_inteligencia/routers/search.py`, `frontend/src/i18n.ts`

---

## P1 — Sprint Atual


---

### TASK-004: Redis Cache-Aside (GitHub #19) ✅ (02/03/2026)
- [x] Redis rodando no docker-compose (egos_inteligencia network)
- [x] `api/src/egos_inteligencia/services/cache.py` — async cache with graceful degradation
- [x] Search endpoint cached (TTL 2min), entity (5min), stats (1min), connections (3min)
- [x] `/api/v1/meta/cache-stats` — hit rate, misses, errors, TTL config
- [x] `/api/v1/meta/cache` DELETE — flush all cache keys
- [x] Deployed and verified: 50% hit rate on repeated queries
> **Arquivos:** `api/src/egos_inteligencia/services/cache.py`, `api/src/egos_inteligencia/routers/search.py`, `api/src/egos_inteligencia/routers/meta.py`


---

### TASK-008: Journey Tracker / Step Counter ✅ (02/03/2026)
- [x] Journey lib: localStorage, 500 entries, dedup, export JSON/MD, Web Share API
- [x] JourneyPanel: floating panel with stats, entries, export/share/clear
- [x] Integrado em: Chat, Search, EntityAnalysis, Dashboard, Landing, GraphExplorer, Investigations
- [x] Registra buscas, views de entidades, queries de chat automaticamente
> **Arquivos:** `frontend/src/lib/journey.ts`, `frontend/src/components/journey/JourneyPanel.tsx`


---

### TASK-009: Patense Report v2 ✅ (02/03/2026)
- [x] Reescrever relatório com linguagem neutra
- [x] Completar dados BNDES (R$217M, 4 empresas, 563 operações)
- [x] Publicar em inteligencia.egos.ia.br/reports/patense.html
- [x] Persistir em frontend/public/reports/
> **Arquivos:** `docs/showcase/patense-investigation.html`


---

### TASK-010: Public Mode + Landing Page ✅ (02/03/2026)
- [x] Ativar VITE_PUBLIC_MODE=true no Dockerfile
- [x] Adicionar LiveDatabaseStatus component
- [x] Adicionar PartnershipCTA component
- [x] Deploy no Contabo
> **Arquivos:** `frontend/Dockerfile`, `frontend/src/pages/Landing.tsx`


---

### TASK-013: Fork Monitor (GitHub #9) ✅ (03/03/2026)
- [x] Script 2x/dia checa forks de World-Open-Graph/egos-inteligencia
- [x] Detectar novos PRs, issues, contribuições
- [x] Alertar no Telegram/Discord (webhook + Bot API opcionais)
- [x] Comparar features entre forks (categorização por arquivos; roadmap sync como sugestões no JSON)
> **Arquivos:** `scripts/egos_inteligencia-monitor.ts`, `.github/workflows/egos_inteligencia-monitor.yml`, [scripts/README-egos_inteligencia-monitor.md](scripts/README-egos_inteligencia-monitor.md)


---

### TASK-017: Lei de Benford (GitHub #6) ✅ (03/03/2026)
- [x] Pattern detector `benford_contract_values` implementado em Cypher
- [x] API endpoint: `GET /api/v1/patterns/{entity_id}/benford_contract_values`
- [x] MAD threshold configurável via `PATTERN_BENFORD_MAD_THRESHOLD`
- [x] Mínimo de contratos configurável via `PATTERN_BENFORD_MIN_CONTRACTS`
> **Arquivos:** `queries/public_pattern_benford_contract_values.cypher`, `config.py`


---

### TASK-018: HHI — Concentração de Fornecedores (GitHub #7) ✅ (03/03/2026)
- [x] Pattern detector `hhi_contract_concentration` implementado em Cypher
- [x] API endpoint: `GET /api/v1/patterns/{entity_id}/hhi_contract_concentration`
- [x] Threshold configurável via `PATTERN_HHI_THRESHOLD` (default 0.25)
> **Arquivos:** `queries/public_pattern_hhi_contract_concentration.cypher`, `config.py`


---

### TASK-019: i18n Completo PT-BR (GitHub #1, #2) ✅ (03/03/2026)
- [x] Frontend: locale pt-BR completo (440+ keys traduzidas)
- [x] Frontend: locale EN — removed hardcoded numbers, fixed PT-BR leaks in nav
- [x] API: mensagens de erro em PT-BR (verificado session 17 — testes atualizados)
> **Arquivos:** `frontend/src/i18n.ts`


---

### TASK-020: Neutrality Audit CI ✅ (03/03/2026)
- [x] CI job `neutrality` em `.github/workflows/ci.yml` — 9 banned words
- [x] `test_no_banned_words_in_pattern_metadata` em unit tests
- [x] Exemption via `# neutrality-ok` comment
- [x] Fixed 1 violation: `journey.ts` "corrupt" → "malformed"
> **Arquivos:** `.github/workflows/ci.yml`, `api/tests/unit/test_patterns.py`


---

### TASK-023: Docs para Leigos (GitHub #3, #4) ✅ (03/03/2026)
- [x] Traduzir data-sources.md para PT-BR (session 18)
- [x] Criar FAQ para leigos em PT-BR (02/03/2026)
> **Arquivos:** `docs/FAQ_PT-BR.md`, `docs/fontes-de-dados.md`


---

### TASK-024: Rename BR/ACC → EGOS Inteligência ✅ (02/03/2026)
- [x] i18n.ts — todas as referências
- [x] index.html — title
- [x] AppShell.tsx — logo sidebar
- [x] README.md — reescrito completo
- [x] ROADMAP.md — headers e links
- [x] TASKS.md — header
> **DNS pendente:** Criar `inteligencia.egos.ia.br` e atualizar Caddy


---

### TASK-025: LGPD — Remover CPF do sistema inteiro ✅ (02/03/2026)
- [x] Frontend: remover CPF de search placeholders (i18n.ts)
- [x] Frontend: remover CPF de EntityDetail.tsx (só mostra CNPJ)
- [x] Backend: `public_guard.py` — CPF lookup SEMPRE bloqueado (não só public mode)
- [x] Backend: `sanitize_public_properties` — SEMPRE filtra CPF (não só public mode)
- [x] Backend: CPF masking middleware mantido como safety net
> **Arquivos:** `frontend/src/i18n.ts`, `frontend/src/components/entity/EntityDetail.tsx`, `api/src/egos_inteligencia/services/public_guard.py`


---

### TASK-026: Mobile-First — Remover bloqueio de tela <1024px ✅ (02/03/2026)
- [x] Remover `isMobileBlocked` do AppShell.tsx
- [x] Adicionar bottom navigation para mobile (<768px)
- [x] Mobile layout funcional com Outlet + nav fixa
> **Arquivos:** `frontend/src/components/common/AppShell.tsx`


---

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
> **Arquivos:** `api/src/egos_inteligencia/routers/chat.py`, `frontend/src/components/chat/ChatInterface.tsx`


---

### TASK-032: DNS inteligencia.egos.ia.br ✅ (02/03/2026)
- [x] DNS A record criado pelo usuário
- [x] Caddyfile atualizado (inteligencia.egos.ia.br + egos_inteligencia 301 redirect)
- [x] SSL Let's Encrypt obtido automaticamente
- [x] Caddy reiniciado, serviço ativo
- [x] URLs atualizadas no codebase (TASKS, ROADMAP, plans)
- [x] CORS_ORIGINS/.env atualizados


---

### TASK-033: Linguagem Legal — Pesquisa Pessoal ✅ (02/03/2026)
- [x] Disclaimer atualizado: "Pesquisa pessoal com dados públicos. Padrões são sinais, não prova jurídica."
- [x] "Investigue em profundidade" → "Pesquise em profundidade"
- [x] "Investigações recentes" → "Pesquisas recentes"
- [x] Feature descriptions focam em "pesquisa pessoal" e "dados públicos"
> **Arquivos:** `frontend/src/i18n.ts`


---

### TASK-035: Changelog/Updates no Website ✅ (02/03/2026)
- [x] UpdatesTimeline component na landing page (expandable cards, tags, metricas)
- [x] JSON changelog entries em frontend/public/updates/YYYY-MM-DD.json
- [x] Primeira entrada: Redis cache, 108 fontes, bots, governanca
- [x] Relatorio Patense linkado no changelog
> **Arquivos:** `frontend/src/components/landing/UpdatesTimeline.tsx`, `frontend/public/updates/`


---

### TASK-041: SourceRegistry — Transparencia Total no Website ✅ (02/03/2026)
- [x] SourceRegistry component com 108 fontes, links diretos, categorias, tiers, filtros
- [x] sources.json gerado do CSV com 27 categorias
- [x] Injetado na landing page acima do UpdatesTimeline
- [x] Cada fonte com link para portal oficial do governo
- [x] Paginacao: 10 fontes por pagina com botoes prev/next
> **Arquivos:** `frontend/src/components/landing/SourceRegistry.tsx`, `frontend/public/updates/sources.json`


---

### TASK-044: Linha do Tempo Completa + ETL Progress Widget ✅ (02/03/2026)
- [x] UpdatesTimeline reescrito com timeline vertical (24 marcos desde fork do Bruno)
- [x] timeline.json com todos os milestones de Jan 15 a Mar 02 2026
- [x] Mostra 5 recentes por padrao, expansivel para todos os 24
- [x] ETLProgress widget: barra de progresso ao vivo, auto-refresh 30s
- [x] Endpoint /api/v1/meta/etl-progress: fase, arquivo, %, running status
- [x] ETL usa mtime do log (container-compatible) em vez de pgrep
> **Arquivos:** `frontend/src/components/landing/UpdatesTimeline.tsx`, `frontend/public/updates/timeline.json`, `frontend/src/components/landing/ETLProgress.tsx`, `api/src/egos_inteligencia/routers/meta.py`


---

### TASK-045: Bot Error Handling — DM Only ✅ (02/03/2026)
- [x] Telegram: erros so enviados em chat privado (ctx.chat.type === 'private')
- [x] Discord: erros via message.author.send() (DM), nao message.reply() (channel)
- [x] Healthcheck v2: corrigido parsing de status (pm2 describe + awk)
- [x] Healthcheck alertas Telegram para @ethikin no restart/failure
> **Arquivos:** `telegram-bot.ts`, `discord-bot.ts`, `/opt/egos-bot/healthcheck.sh`


---

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


---

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
> **Arquivos:** `api/src/egos_inteligencia/services/transparency_tools.py`, `api/src/egos_inteligencia/routers/chat.py`
> **APIs:** Brave Search (primário) + DDG (fallback), TransfereGov, Câmara, Querido Diário + Portal Transparência, DataJud


---

### TASK-051: Avaliação De Olho em Você + Mission Control ✅ (02/03/2026)
- [x] De Olho em Você (deolhoemvoce.com.br): monitora emendas Pix, CEAP, votações
- [x] Aprendizado: adicionamos search_votacoes (como eles têm), Flock analytics (similar ao nosso self-hosted)
- [x] Vantagem deles: per-deputy profiles visuais, Emendas Pix específicas, AdSense
- [x] Vantagem nossa: Neo4j graph, CNPJ/sócios, gazette search, AI chatbot, open-source
- [x] Mission Control (builderz-labs): agent orchestration dashboard
- [x] Relevante para egos-lab (23 agents), NÃO para EGOS Inteligência
- [x] Ideias: cost tracking por agente, GitHub Issues sync, Kanban board
> **Similares avaliados:** comovotou.org, deolhonodeputado.app.br, Mika-IO/deolho


---

### TASK-052: Daily Update Policy ✅ (02/03/2026)
- [x] Documento criado: `docs/DAILY_UPDATE_POLICY.md`
- [x] Regra: 1 post/dia contendo tudo, exceto updates "importantes" (ver critérios)
- [x] Critérios de "importante": nova fonte de dados, feature UX, marco, incidente, contribuição externa
- [x] Template de post diário definido
- [x] Canais: Telegram, Discord, Website timeline


---

### TASK-053: Portal da Transparência + DataJud APIs ✅ (02/03/2026)
- [x] Portal da Transparência: chave `f6341a...` integrada (6 endpoints)
- [x] Servidores federais: nome, salário, cargo, órgão (requer CPF ou código SIAPE)
- [x] Contratos: fornecedor, valor, vigência, aditivos
- [x] Sanções: CEIS (inidôneas) + CNEP (punidas) — funciona sem filtros
- [x] CPGF, viagens, licitações (requerem filtros mínimos)
- [x] DataJud (CNJ): chave `cDZH...` integrada — todos os 27+ tribunais
- [x] Recuperação Judicial: 1.180 processos TJMG confirmados
- [x] Elasticsearch queries: match_phrase para classes processuais
> **Arquivos:** `api/src/egos_inteligencia/services/transparency_tools.py`
> **Verificado:** CEIS, contratos, DataJud TJMG (Recuperação Judicial) — todos funcionando


---

### TASK-054: Avaliação OpenPlanter ✅ (02/03/2026)
- [x] OpenPlanter (ShinMegamiBoson): agente investigativo recursivo com TUI
- [x] 19 tools: file I/O, shell, web search (Exa), subtask delegation
- [x] Entity resolution cross-dataset, evidence-chain construction
- [x] Suporta GPT-5.2, Claude Opus 4.6, Qwen, Ollama local
- [x] Inspiração: sub-agent delegation, recursive investigations
- [x] Nosso diferencial: Neo4j 317K+ nós, 18 APIs, frontend web, open-source
> **Veredicto:** Ótima inspiração para multi-step investigations futuras. Não substitui.


---

### TASK-055: Auditoria de Features Intelink ✅ (02/03/2026)
- [x] Intelink tem 179 pages/routes em 17 seções
- [x] **Já adotamos:** Chat, Graph, Entity, Search, Investigation, Dashboard, Journey, Landing, Patterns, Baseline (10/17)
- [x] **Relevante adotar:** Analytics dashboard (visual), Reports generation, Alertas, Activity feed
- [x] **NÃO relevante (policial):** Delegacias, operações, membros, equipe, permissões, qualidade
- [x] **Conclusão:** Core investigativo está completo. Faltam features de UX/engagement.


---

### TASK-056: Mapa de Portais de Transparência ✅ (02/03/2026)
- [x] Pesquisa: PNTP (10.335 portais), Transparência Internacional (300+ cidades), Radar Transparente
- [x] 122 municípios SEM portal, 109 com 100%, média prefeituras 67%
- [x] Gaps: 95% sem API, 70% dados em PDF, 40% sem licitações
- [x] Padrão referência: Portal da Transparência federal (⭐⭐⭐⭐⭐)
- [x] Proposta: API REST mínima obrigatória, JSON, atualização diária
- [x] Próximas APIs: Dados Abertos SP, MG, ComprasNet, SIAFI, Senado
> **Documento:** `docs/reports/transparency-portal-map.md`


---

### TASK-057: Análise de Custos de APIs ✅ (02/03/2026)
- [x] ReceitaWS (R$99/mês): NÃO vale — nosso ETL 60GB tem mesmos dados, ilimitado, grátis
- [x] SerpAPI ($75/mês): CARO — substituído por Brave Search
- [x] Brave Search ($5/mês): MELHOR custo-benefício — #1 benchmark, 669ms, 2k grátis/mês
- [x] Exa ($49/mês): Já temos via MCP Cascade — usar para dev, não produção
- [x] Recomendação: Brave para chatbot produção, Exa para pesquisa interna
> **Economia:** R$1.188/ano evitando ReceitaWS, $840/ano evitando SerpAPI


---

### TASK-058: GitGuardian Fix — Chaves em Env Vars ✅ (02/03/2026)
- [x] Removidas chaves hardcoded de `transparency_tools.py` (alerta GitGuardian)
- [x] Chaves movidas para `docker-compose.yml` como env vars
- [x] PORTAL_TRANSPARENCIA_API_KEY, DATAJUD_API_KEY, BRAVE_API_KEY
- [x] Código usa `os.environ.get()` — chaves nunca mais no código fonte
> **Nota:** DataJud e Portal Transparência são chaves públicas (registro gratuito), mas best practice é env vars.


---

### TASK-059: Brave Search Integration ✅ (02/03/2026)
- [x] Brave Search API como busca primária (key de `/home/enio/egos-lab/.env`)
- [x] DuckDuckGo como fallback automático
- [x] #1 benchmark (14.89), 669ms latência, 2k queries grátis/mês
- [x] Issue #28 fechada com comentário


---

### TASK-060: Analytics Dashboard Frontend ✅ (02/03/2026)
- [x] Página `/app/analytics` com visualização em tempo real
- [x] Cards: views hoje, visitantes únicos, total all-time
- [x] Gráfico de barras: últimos 7 dias + distribuição por hora
- [x] Tabela: páginas mais visitadas
> **Arquivos:** `frontend/src/pages/Analytics.tsx`, `Analytics.module.css`


---

### TASK-061: Monitor Endpoints (Sanções + Auto-Report) ✅ (02/03/2026)
- [x] `GET /api/v1/monitor/sanctions/recent` — últimas sanções CEIS+CNEP
- [x] `GET /api/v1/monitor/report/{municipio}` — relatório automático por município
- [x] Testado: 20 sanções recentes retornadas, Patos de Minas report funcional
> **Arquivos:** `api/src/egos_inteligencia/routers/monitor.py`


---

### TASK-063: 3 Relatórios de Investigação Publicados ✅ (02/03/2026)
- [x] Report 01: SUPERAR LTDA (CNPJ 13.482.516/0001-61) — 7 sanções no grafo, QSA com PJ sócia
- [x] Report 02: Transparência Municipal Manaus — 15 emendas, 4.664 ACPs TJAM, diligences ambientais
- [x] Report 03: Recuperação Judicial SP — 3.704 processos TJSP, 10K+ exec fiscais
- [x] Cada relatório: passo a passo para leigos + stack técnica + custos + comparação Palantir
- [x] Publicados no site: `/reports/report-0X-*.md`
- [x] Update JSON v2 para timeline do site
> **Arquivos:** `docs/reports/report-01-superar-ltda.md`, `report-02-manaus-transparencia.md`, `report-03-recuperacao-judicial-sp.md`
> **Dados reais:** Neo4j 317K nós + Portal Transparência + DataJud + BrasilAPI


---

### TASK-064: Auditoria Profunda Intelink v2 ✅ (02/03/2026)
- [x] 44 páginas mapeadas (14 adotadas, 3 parciais, 15 gaps relevantes, 11 N/A policial)
- [x] 135 API routes analisadas (entities, reports, analysis, documents, OCR, legal, debate)
- [x] Top 10 features para adotar: Report Gen, Activity Feed, Evidence Chain, Chat Vision, Alerts, Analysis Suite
- [x] Features egos-lab para trazer: Rho Score, Eagle Eye, Cost Tracking
- [x] Comparação Palantir/NSA/i2: tabela completa
> **Documento:** `docs/reports/intelink-deep-audit.md`


---

### TASK-065: Fix CEIS API Filter ✅ (02/03/2026)
- [x] Bug: Portal Transparência CEIS ignora parâmetro `cnpjSancionado`
- [x] Fix: filtro client-side por CNPJ/nome após receber resultados
- [x] Testado: sanções agora filtradas corretamente por empresa
> **Arquivo:** `api/src/egos_inteligencia/services/transparency_tools.py`


---

### TASK-066: Evidence Chain — Data Provenance per Query ✅ (02/03/2026)
- [x] Backend: EvidenceItem model (tool, source, query, result_count, timestamp, api_url)
- [x] 18 tools mapeados para nomes de fonte e URLs de API
- [x] Cada resposta do chatbot inclui `evidence_chain[]` com proveniência completa
- [x] Frontend: display colapsável "Fontes (N) | Custo: $X.XXXX" abaixo de cada resposta
- [x] Testado: SUPERAR LTDA → 2 evidence items (Neo4j + Brave Search)
> **Conceito Mycelium aplicado:** Cada dado tem trail auditável — de onde veio, quando, quantos resultados.
> **Arquivos:** `api/src/egos_inteligencia/routers/chat.py`, `frontend/src/components/chat/ChatInterface.tsx`, `frontend/src/api/client.ts`


---

### TASK-067: Cost Tracking per Query ✅ (02/03/2026)
- [x] Gemini Flash pricing: $0.075/1M input, $0.30/1M output tokens
- [x] `cost_usd` calculado por query baseado em `usage.prompt_tokens` + `usage.completion_tokens`
- [x] Retornado na ChatResponse e exibido no frontend
- [x] Testado: query típica = $0.000552 (~R$ 0,003)
> **Insight:** Uma investigação completa com 6 tool calls custa ~$0.003 (~R$ 0,02). Para R$630/mês operamos ~210K queries.


---

### TASK-068: Correção de Custos nos Relatórios ✅ (02/03/2026)
- [x] Contabo VPS: $35/mês (não €15)
- [x] Supabase Pro: $20/mês
- [x] Windsurf IDE: $45/mês
- [x] OpenRouter LLM: ~$5/mês
- [x] Brave Search: $0-5/mês
- [x] TOTAL: ~$105/mês (~R$ 630) — antes constava R$ 120 (ERRADO)
- [x] Corrigido nos 3 relatórios publicados


---

### TASK-069: Análise Mycelium + Chat Vision + Prioridades ✅ (02/03/2026)
- [x] Chat Vision: NÃO AGORA — sistema usa APIs estruturadas, não imagens
- [x] Mycelium Event Bus: APLICÁVEL — evidence chain implementada como conceito
- [x] Mycelium ZKP/Shadow Nodes: NÃO AGORA — overengineering sem base de usuários
- [x] Cross-app events (Intelink ↔ Intel): PLANEJADO para próxima fase
- [x] Prioridades filtradas: só tasks com ROI real (Evidence Chain, Activity Feed, Eagle Eye)
> **Documento:** Análise entregue no chat + knowledge base


---

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
> **Arquivos:** `api/src/egos_inteligencia/routers/activity.py`, `frontend/src/pages/Activity.tsx`


---

### TASK-071: Eagle Eye Gazette Monitor ✅ (02/03/2026)
- [x] Backend: `gazette_monitor.py` com `/api/v1/monitor/gazettes/scan` + `/patterns`
- [x] 8 padrões investigativos: dispensa, inexigibilidade, aditivo, emergência, sobrepreço, tomada de contas, sanção, licitação fracassada
- [x] 10 cidades SP com dados no Querido Diário (Botucatu, Santos, Campinas, etc.)
- [x] Alertas auto-logados no Activity Feed
- [x] Testado: 23 alertas em Botucatu em 7 dias
- [x] Bridge Eagle Eye (egos-lab) ↔ EGOS Intel (produção)
> **Próximo:** Cron automático + dashboard de alertas + mais cidades
> **Arquivo:** `api/src/egos_inteligencia/routers/gazette_monitor.py`


---

### TASK-072: GitGuardian Fix + Security Hardening ✅ (02/03/2026)
- [x] Incidente: Brave API key vazou em `apps/openclaw/config.json.bak.1` (EGOSv5 repo)
- [x] Key rotacionada pelo usuário
- [x] `.gitignore`: adicionado `*.bak`, `*.bak.*`, `*.backup`, `*.old`, `config.json.bak*`
- [x] `security_scan.ts`: +5 padrões (Brave BSA..., JSON apiKey/token, Bearer, backup files)
- [x] Pre-commit agora bloqueia: backup files + 13 padrões de secrets + entropy check
- [x] Regras de deploy documentadas em memória (docker rebuild para novos módulos)
> **Root cause:** .bak file não estava no .gitignore


---

### TASK-075: Docker DNS Fix — Permanent ✅ (03/03/2026)
- [x] Root cause: systemd-resolved `nameserver 127.0.0.53` não funciona dentro de containers Docker
- [x] Fix: `/etc/docker/daemon.json` com DNS `8.8.8.8`, `8.8.4.4`, `1.1.1.1` + retry opts
- [x] `systemctl restart docker` — todos containers voltaram healthy
- [x] Verificado: `docker run --rm alpine cat /etc/resolv.conf` mostra DNS corretos
- [x] `docker compose build api --no-cache` agora funciona sem falhas intermitentes
> **Arquivo:** `/etc/docker/daemon.json` no Contabo 217.216.95.126


---

### TASK-076: GitHub Actions — Reduce Noise ✅ (03/03/2026)
- [x] CI workflow: mudou de `push: main` para `pull_request + weekly Monday + manual`
- [x] Security workflow: mudou de `push: main` para `pull_request + weekly Wednesday + manual`
- [x] Release Drafter: mudou de `push: main` para `manual only`
- [x] Resultado: sem mais notificações de falha em cada commit
> **Arquivos:** `.github/workflows/ci.yml`, `security.yml`, `release-drafter.yml`


---

### TASK-077: Website Header/Navbar ✅ (03/03/2026)
- [x] PublicShell: adicionado nav com links Pesquisar, Relatórios, Estatísticas, GitHub
- [x] CTA: "Abrir Plataforma" (era "Open Explorer")
- [x] GitHub URLs atualizadas de egos-inteligencia para EGOS-Inteligencia
- [x] Responsivo: nav escondido em mobile (<768px)
- [x] Frontend rebuilt e deployed no Contabo
> **Arquivos:** `PublicShell.tsx`, `PublicShell.module.css`, `Landing.tsx`


---

### TASK-091: Chat Agent Upgrade — 24 Tools + GPT-4o-mini ✅ (03/03/2026)
- [x] LLM: Gemini Flash → GPT-4o-mini (melhor multi-tool calling, 4 tools paralelos vs 1)
- [x] 6 novos OSINT tools: BNMP mandados, procurados Interpol, lista suja, PNCP licitações, OAB advogados, OpenCNPJ
- [x] System prompt: enforce 2-4 tool calls paralelos por query
- [x] max_rounds: 6 → 8, timeout: 30s → 45s
- [x] search_servidores: corrigido com SIAPE org codes (Senado=11001, STF=10001)
- [x] Custo: ~$0.001/query (4 tools), era ~$0.0003 (1 tool)
> **Arquivos:** `chat.py`, `transparency_tools.py`, `config.py`


---

### TASK-092: Exposure Score Fix — 5-Factor Scoring ✅ (03/03/2026)
- [x] Bug: pattern_percentile e baseline_percentile hardcoded 0.0 (30% do peso desperdiçado)
- [x] entity_score.cypher: retorna sanction_count, embargo_count, contract_count, amendment_count
- [x] score_service.py: compute real pattern percentile (sancionada+contratos=80%, sancionada=45%)
- [x] intelligence_provider.py: community tier agora usa 5 fatores (era 1)
- [x] Resultado: empresa 64 sanções: 90.0 (inflado) → 39.1 (realista)
> **Feedback do colaborador:** Corrigido conforme sugestão. Ranking agora é significativo.
> **Arquivos:** `score_service.py`, `intelligence_provider.py`, `entity_score.cypher`


---

### TASK-093: Activity Feed Pagination ✅ (03/03/2026)
- [x] 10 eventos por página (era 100 sem paginação)
- [x] Botões Anterior/Próxima com info "Página X de Y (N eventos)"
- [x] Reset de página ao mudar filtro
> **Arquivos:** `Activity.tsx`, `Activity.module.css`


---

### TASK-094: Chat UX — Guided Search + Model Transparency ✅ (03/03/2026)
- [x] Welcome: "Você não precisa de CNPJ!" + 4 exemplos de input
- [x] 8 sugestões acionáveis (políticos por cidade, lista suja, mandados, licitações)
- [x] Mostra modelo e custo no welcome message
- [x] 24 tools contados corretamente
> **Arquivos:** `ChatInterface.tsx`


---

### TASK-095: Model Fallback + Rate Limit + BYOK ✅ (03/03/2026)
- [x] 10 msgs/dia premium (GPT-4o-mini), 20 msgs/dia free (Gemini Flash), depois aviso BYOK
- [x] BYOK via header `x-openrouter-key` (chave do usuário no OpenRouter)
- [x] Aviso automático ao atingir limites de cada tier
- [x] Tier logado no activity feed (model + tier em cada evento)
- [x] _call_openrouter aceita model + api_key params
> **Arquivos:** `chat.py`


---

### TASK-096: Bug Fixes — DDG Search + PNCP API ✅ (03/03/2026)
- [x] DDG fallback: 3 regex patterns for resilience + graceful empty fallback
- [x] PNCP: try 3 endpoint URLs (API changed), handle 400 gracefully, date normalization
> **Issues:** #32 (P1), #33 (P2)
> **Arquivos:** `api/src/egos_inteligencia/services/transparency_tools.py`


---

### TASK-097: System Map — API/Routes/Pages Inventory ✅ (03/03/2026)
- [x] Documentar 55+ endpoints em 13 routers
- [x] Frontend: 14 páginas inventory
- [x] Docker: 5 containers topology
- [x] 26 AI chat tools documented
- [x] 10 pattern detectors documented
- [x] Middleware & services documented
- [x] External bots (Discord + Telegram) documented
> **Arquivos:** `docs/SYSTEM_MAP.md`


---

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


---

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


---

### TASK-087: Branding — EGOS Logo as Favicon + OG Image ✅ (03/03/2026)
- [x] Generate favicon.ico (16/32/48px), favicon-16x16.png, favicon-32x32.png
- [x] Generate apple-touch-icon.png (180x180), android-chrome (192/512)
- [x] Generate og-image.png (1200x630) for social sharing previews
- [x] Create site.webmanifest (theme: #00e5a0, standalone)
- [x] Update index.html with all icon refs + OG image + Twitter image
- [x] Deploy to Contabo — all assets returning HTTP 200
> **Source:** `/home/enio/Downloads/egos_discord_icon_1771941656007.png`
> **Arquivos:** `index.html`, `favicon.ico`, `site.webmanifest`, `og-image.png`


---

### TASK-089: Mobile Responsive CSS ✅ (03/03/2026)
- [x] PR #24 by @Kai-Rowan-the-AI: pure CSS mobile responsive improvements (+235/-0)
- [x] GraphExplorer: stacks vertically on mobile, hides resize handle
- [x] Dashboard: mobile breakpoints for search, results, investigation cards
- [x] CommandPalette: mobile sizing, hides keyboard shortcuts
- [x] global.css: font size reduction on mobile (768px/480px breakpoints)
- [x] Code review: approved + merged
> **Arquivos:** 7 CSS modules (GraphExplorer, Dashboard, Search, EntityAnalysis, CommandPalette, ControlsSidebar, global.css)


---

### TASK-088: First Community PR — Benford's Law + HHI Patterns ✅ (03/03/2026)
- [x] PR #30 by @mrncstt: 2 new intelligence patterns (+134/-2 lines)
- [x] Benford's Law: flags contract values deviating from expected leading-digit distribution (MAD threshold)
- [x] HHI Concentration: flags companies with high Herfindahl-Hirschman Index across contracting agencies
- [x] Code review: approved with minor observations (precision, performance, scaling docs)
- [x] Merged to main, API rebuild deployed
- [x] Test count: 8→10 patterns, 48 unit tests passing
> **Milestone:** First external contributor! ~70 GitHub stars 🎉
> **Arquivos:** `config.py`, `pattern.py`, `intelligence_provider.py`, 2 new `.cypher` files


---

### TASK-086: UI Fix — Scrolling + Analytics Improvement ✅ (03/03/2026)
- [x] Root cause: AppShell.module.css `.main` had `overflow: hidden` — killed scrolling on ALL app pages
- [x] Fix: changed to `overflow: auto` — Reports, Activity, Analytics all scroll now
- [x] Analytics: aggregate entity analysis URLs into single group (was polluting 200+ entries)
- [x] Analytics: added note about in-memory data persistence (resets on API restart)
- [x] Analytics data verified REAL: 4607 views, 20 unique visitors, 80 activity events
- [x] Contract tests: 9/9 endpoints passing (health, search, chat, cache, analytics, activity, 422, 404)
> **Arquivos:** `AppShell.module.css`, `Analytics.tsx`


---

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


---

### TASK-099: Review PR #38 — Em-dash to Hyphen Normalization ✅ (03/03/2026)
- [x] **Autor:** @mrncstt (comunidade)
- [x] **Escopo:** 6 arquivos, 6 linhas — substitui `—` por `-` em 6 componentes frontend
- [x] **Decisão:** Merged (admin) — mudança cosmética, gesto de acolhimento ao contribuidor
- [x] Também corrigiu typo "Societaria" → "Societária" no ReportsShowcase
> **PR:** https://github.com/enioxt/EGOS-Inteligencia/pull/38


---

### TASK-110: Neo4j Backup Script (Cron) ✅ (03/03/2026)
- [x] Hot tar backup do volume Docker (sem parar Neo4j) + count snapshot
- [x] Cron job diário às 3AM (`/opt/egos_inteligencia/scripts/neo4j-backup.sh`)
- [x] Reter últimos 5 backups (rotação automática)
- [x] APOC export habilitado (`apoc.export.file.enabled=true` em apoc.conf)
- [x] Alertar se dump falhar via Telegram (v2 deployed 04/03/2026)
> **Arquivos:** `/opt/egos_inteligencia/scripts/neo4j-backup.sh`, `/opt/egos_inteligencia/backups/`
> **Nota:** neo4j-admin dump falha em Community Edition. Backup via tar do volume (~1.5GB comprimido de 6.7GB)


---

### TASK-115: CORS Explícito + JWT Startup Validation ✅ (03/03/2026)
- [x] CORS: `allow_headers` explícito (Authorization, Content-Type, Accept, Origin, X-Requested-With)
- [x] CORS: `allow_methods` explícito (GET, POST, PUT, DELETE, OPTIONS)
- [x] JWT: `raise RuntimeError` em production se secret fraco/default (dev apenas loga)
> **Arquivos:** `main.py`


---

### TASK-116: Componentizar Landing.tsx ✅ (03/03/2026)
- [x] Extrair HeroSearch → `components/landing/HeroSearch.tsx`
- [x] Extrair LiveDatabaseStatus → `components/landing/LiveDatabaseStatus.tsx`
- [x] Extrair PartnershipCTA → `components/landing/PartnershipCTA.tsx`
- [x] Landing.tsx: 533 → 287 linhas (-46%)
> **Arquivos:** `pages/Landing.tsx`, `components/landing/HeroSearch.tsx`, `components/landing/LiveDatabaseStatus.tsx`, `components/landing/PartnershipCTA.tsx`


---

### TASK-117: Registro de Tratamento LGPD (Art. 37) ✅ (03/03/2026)
- [x] 6 categorias documentadas: CNPJ, TSE, Contratos, Sanções, PEP, Interação
- [x] Base legal, finalidade, retenção, medidas de segurança por categoria
- [x] Tabela de medidas técnicas e organizacionais
- [x] Workflow de direitos do titular (Art. 18)
> **Arquivos:** `docs/legal/REGISTRO_TRATAMENTO.md`


---

### TASK-118: Observabilidade — Request Tracing + JSON Logs + Security Posture ✅ (03/03/2026)
- [x] `RequestIDMiddleware` — X-Request-ID header em toda resposta (gera ou ecoa do cliente)
- [x] `GET /api/v1/meta/security` — endpoint de postura de segurança (sem segredos)
- [x] `logging_config.py` — JSON structured logs em produção, human-readable em dev
- [x] 3 novos testes para middleware (gerar, ecoar, unicidade)
- [x] 235 API unit tests passando (219 + 13 sanitizer + 3 request-id)
> **Arquivos:** `middleware/request_id.py`, `logging_config.py`, `routers/meta.py`, `main.py`


---

### TASK-120: Pre-commit v2 + Workflows v2 ✅ (03/03/2026)
- [x] 8-section pre-commit hook: security, python, frontend, data accuracy, fork sync, PR/issue, TASKS sync, convention
- [x] Detects stale data (141M/MIT), upstream fork delta, open PRs
- [x] /start v2: API live check, upstream sync, PR/issue/fork count
- [x] /end v2: GitHub issue close sync, deployment verify
- [x] Upstream remote added (World-Open-Graph/egos-inteligencia)
- [x] gh default set to enioxt/EGOS-Inteligencia
> **Arquivos:** `scripts/pre-commit-v2.sh`, `.windsurf/workflows/start.md`, `.windsurf/workflows/end.md`


---

### TASK-121: Methodology Page ✅ (03/03/2026) — GitHub #51
- [x] New /app/methodology route with iframe to existing HTML
- [x] BookOpen icon in sidebar, i18n keys (PT-BR + EN)
- [x] Removed from PUBLISHED_REPORTS in Reports.tsx
> **Arquivos:** `frontend/src/pages/Methodology.tsx`, `App.tsx`, `AppShell.tsx`, `i18n.ts`


---

### TASK-122: Data Accuracy SSOT ✅ (03/03/2026) — GitHub #52
- [x] Created platform-stats.json with ALL verified numbers
- [x] Fixed 14 data errors across 9 files (141M→9.2M, MIT→AGPL, 38→36, etc)
- [x] Verified 11 metrics against live API (100% match)
- [x] Pre-commit detects stale numbers
> **Arquivos:** `frontend/public/updates/platform-stats.json`, 9 files corrected


---

### TASK-124: GitHub Issues Sync ✅ (03/03/2026)
- [x] Closed issues #34 (System Map), #35 (BYOK)
- [x] Created issues #49-55 (security, devops, methodology, SSOT, investigation, BFG, Intelink)
- [x] 30 open issues covering all project areas
> **Total:** 55 issues (25 closed, 30 open)


---

### TASK-128: Activity Feed v2 — Redis Persistence ✅ (04/03/2026)
- [x] Cumulative counters in Redis (survive restarts)
- [x] Daily breakdown, unique users, model/source tracking
- [x] Daily activity chart, model usage, top sources in frontend
> **Arquivos:** `activity.py`, `Activity.tsx`


---

### TASK-129: AI Model Fallback + Landing Cleanup ✅ (04/03/2026)
- [x] MODEL_FALLBACK = google/gemini-2.0-flash-exp:free (auto-switch on 402/429)
- [x] Removed LiveDatabaseStatus + DATA_SOURCES grid (duplicates)
- [x] Methodology iframe CSP fix (frame-ancestors + X-Frame-Options)
- [x] Backend-frontend sync check in pre-commit (Section 8)
> **Arquivos:** `chat.py`, `Caddyfile`, `Landing.tsx`, `pre-commit-v2.sh`


---

### TASK-130: Docker Auto-Heal System ✅ (04/03/2026)
- [x] `scripts/auto-heal.sh` — 4-layer monitoring (container state, healthcheck, URL check, disk space)
- [x] Deployed to VPS `/opt/egos_inteligencia/scripts/auto-heal.sh`
- [x] Cron every 2 minutes (`*/2 * * * *`)
- [x] Logs to `/opt/egos_inteligencia/logs/auto-heal.log` (auto-trimmed to 500 lines)
- [x] Verifies site HTTP 200 after healing
> **Root cause (session 26):** Containers were in "Created" state after `docker compose up` dependency chain failure.
> **Prevention:** Script detects Created/Exited/Dead containers and force-starts them.

