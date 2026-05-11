# TASKS.md — EGOS Inteligência (SSOT)

> **Updated:** 2026-03-18 | **Patterns:** 10 | **Nodes:** 77.0M | **Rels:** 25.1M | **Tools:** 27 | **Tasks:** 103/141 ✅ | **GitHub Issues:** https://github.com/enioxt/EGOS-Inteligencia/issues

---

## Strategic Reset — Product Focus (2026-03-18)

- [ ] TASK-136: Reposition `EGOS-Inteligencia` as the strongest reference implementation for `EGOS Guard Brasil`, not as the entire business thesis
- [ ] TASK-137: Expose guardrail primitives from this repo as reusable proof surfaces — LGPD/public guard, masking, evidence-aware chat, public-safe investigation flows
- [ ] TASK-138: Prove one lighthouse use case with hard evidence and neutral language — a public-safe assistant for investigations/due diligence under Brazilian constraints
- [ ] TASK-140: Adopt the kernel `docs/SSOT_REGISTRY.md` in `egos-inteligencia` — map local SSOTs (`AGENTS`, `TASKS`, local maps, legal docs) to the cross-repo contract and document what remains public-safe local truth

> **Directive:** New work in `egos-inteligencia` should either strengthen the reference implementation, improve truthfulness of public claims, or help package the flagship guardrails product.

## P0 — Em Andamento (Blockers)

### TASK-001: CNPJ ETL — 53.6M empresas ⏳ 🚨 CRITICAL
- [ ] Phase 1: Build estab_lookup (status unknown — check if still running)
- [ ] **Phase 3: Create Person/Partner nodes + SOCIO_DE relationships** 🚨
- [ ] Phase 4: Post-load hooks (entity linking)
> **Server:** 217.216.95.126 | **Service target:** `egos-inteligencia-etl.service` (reality check 2026-03-06: inactive)
> **Reality check 2026-03-06:** Docker stack está saudável (5/5 containers), mas o ETL não está rodando pelo systemd. O último comando ativo ficou preso em `tmux` e o log final mostra erro em `linking_hooks.py`: `Neo.ClientError.Statement.ParameterMissing: Expected parameter(s): run_id`.
> **Estado real do grafo:** 59,573,749 `Company` + 17,454,980 `Partner` + 7,074 `Person` = **77,035,803 entidades** e **25,091,492 `SOCIO_DE`**.
> **Control-plane drift:** `etl-monitor.sh` segue registrando “ETL running” com `CPU 0.0%` e delta zero, enquanto `/api/v1/meta/etl-progress` retorna `running=false`, `percent=90` e `last_update=2026-03-06 00:06:36`.
> **Impact:** A Fase 3 carregou massa crítica de sócios/relacionamentos, mas o pós-load falhou, a telemetria pública está stale e a Fase 4 permanece bloqueada.
> **Local fix já aplicado (06/03/2026):** `etl/src/egos_inteligencia_etl/linking_hooks.py`, `etl/src/egos_inteligencia_etl/runner.py`, `etl/tests/test_linking_hooks.py` — faltam redeploy/reexecução controlada no VPS.

### TASK-002: Neo4j Performance Optimization ⏳
- [ ] Aplicar memory upgrade APÓS ETL completar
- [ ] Executar `post-etl-optimize.sh` APÓS ETL completar
- [ ] Verificar query < 5ms para CNPJ lookup
> **Depende de:** TASK-001
> **Arquivos:** `infra/scripts/neo4j-memory-upgrade.sh`, `infra/scripts/post-etl-optimize.sh`

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

### TASK-075: Integrar Chatbot "Padrão 852" (Vercel AI SDK) ao EGOS ⬜ 🚨
- [ ] Analisar arquitetura do `/home/enio/852` (Next.js App Router, `ai` sdk, persistência Supabase)
- [ ] Mapear lacunas do atual `frontend/src/components/chat/ChatInterface.tsx` (que usa UI customizada Vite/React)
- [ ] Portar formatação refinada de Markdown, exibição de fontes e retenção de contexto para o EGOS
- [ ] Adequar o OpenRouter do EGOS aos padrões máximos encontrados no 852
> **Motivo:** O repositório 852 possui o chatbot mais avançado de todo o workspace. Torná-lo o benchmark oficial.

### TASK-072: Reality Check — VPS, ETL e Métricas do Sistema ⬜
- [ ] Verificar estado real do `egos-inteligencia-etl.service` e processos relacionados no VPS
- [ ] Atualizar porcentagem real do ETL e gargalo atual (Phase 1/3/4) com evidência
- [ ] Atualizar métricas canônicas de nós, relacionamentos, fontes, tools e capacidade em `AGENTS.md`, `TASKS.md` e relatório técnico
- [ ] Validar se widgets/endpoints públicos de progresso refletem o estado real do sistema
- [ ] Consolidar relatório técnico 2026-03 com capacidade, limites e próximos bloqueios
> **Evidência já coletada (2026-03-06):** `egos-inteligencia-etl.service` inactive; stack 5/5 healthy; `etl-monitor-state.json` = 17,454,980 Partner / 59,573,749 Company / 25,091,492 `SOCIO_DE`; `cnpj-etl.log` encerra com erro `Expected parameter(s): run_id`; endpoint `/api/v1/meta/etl-progress` stale em 90%.
> **Progresso local nesta sessão:** fix mínimo do `run_id` implementado e validado com `ruff` + `pytest` (`40 passed`).

### TASK-073: Relatório Técnico 2026-03 — EGOS Inteligência ⬜
- [ ] Revisar claims públicos vs código vs VPS real
- [ ] Consolidar arquitetura atual (API, frontend, Neo4j, Redis, bots, ETLs)
- [ ] Explicitar o que está estável, em beta e bloqueado
- [ ] Publicar versão atualizada do relatório em local SSOT apropriado

### TASK-074: Caso Vorcaro — Mapa Público de Entidades e Sinais (GitHub #57) 🔄 (06/03/2026)
- [ ] Cruzar web pública, grafo, DataJud, diários, contratos e sanções sem linguagem acusatória
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

### TASK-014: Website Redesign (GitHub #21) ⬜
- [ ] CMD+K global search (portar do Intelink)
- [ ] Search history (últimos acessos)
- [ ] Connection preview on hover
- [ ] Entity Detail Modal from search
- [ ] Mobile responsive improvements
- [ ] Accessibility (a11y)
> **Referência:** Intelink `components/shared/GlobalSearch.tsx`

### TASK-015: Bot Integration — Discord/Telegram (GitHub #8) ✅ (02/03/2026)
- [ ] WhatsApp: estrutura pronta para qualquer número
> **Arquivos:** `/opt/egos-bot/packages/shared/src/social/` (discord-bot.ts, telegram-bot.ts, ai-engine.ts)

### TASK-016: Pipeline Extrateto — Supersalários (GitHub #5) ⬜
- [ ] ETL para dados de salários do judiciário
- [ ] Detecção de supersalários acima do teto

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

### TASK-028: Investigações — Export Formats ✅ (03/03/2026)
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
- [ ] Primeiro deploy no website EGOS Inteligência
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

### TASK-034: Gem Hunter — Keywords de Busca ⬜
- [ ] Implementar busca por semântica no GitHub API
- [ ] Keywords mapeadas: CEAP, cota parlamentar, transparencia brasil, CNPJ consulta, licitacao anomalia, benford brazil, Neo4j governo, OSINT brasil, serenata amor, TCU auditoria, CGU dados
- [ ] Engenharia reversa do EGOS Inteligência para extrair tags
- [ ] Monitoramento periódico de novos repos

### TASK-036: Pipeline Social Integrado (/postar) ⏳
- [ ] X.com: precisa API keys (X_API_KEY, X_API_SECRET, X_ACCESS_TOKEN, X_ACCESS_TOKEN_SECRET)
- [ ] Conta @anoineim precisa verificacao por telefone
> **Arquivos:** `.windsurf/workflows/postar.md`, bot x-client.ts

### TASK-037: Bot Self-Healing ✅ (02/03/2026)
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

### TASK-047: Chat Links New Tab + Journey System ✅ (02/03/2026)
- [ ] Journey: persistencia no backend com login (futuro)
> **Arquivos:** `frontend/src/lib/journey.ts`, `frontend/src/components/journey/JourneyPanel.tsx`, `frontend/src/components/chat/ChatInterface.tsx`

### TASK-042: /app — Plataforma de Pesquisa Colaborativa ⏳ (P1)
- [ ] Auth: Login com Google/GitHub (precisa backend auth)
- [ ] /app/public: Feed comunitario de pesquisas publicadas
- [ ] Incentivo: Badge "Pesquisador Cidadao" para quem publica
- [ ] Cross-link: Quando pesquisas diferentes encontram mesmas entidades, destacar
- [ ] Feedback loop: Conexoes de usuarios -> melhorar ETL
> **Status:** Frontend JA TEM 8 paginas funcionais + Journey. Falta auth backend + feed comunitario.
> **Arquivos:** `frontend/src/pages/Dashboard.tsx`, `Investigations.tsx`, `SharedInvestigation.tsx`, `Search.tsx`, `EntityAnalysis.tsx`, `GraphExplorer.tsx`, `Patterns.tsx`, `Baseline.tsx`

### TASK-049: Avaliação Unikraft + ESAA ✅ (02/03/2026)
- [ ] Implementar event sourcing no egos-lab agent runtime (inspirado ESAA) — P2
> **Unikraft:** github.com/unikraft/unikraft — 4.1k★. Boot em ms, footprint mínimo. Não roda Neo4j/Redis.
> **ESAA:** github.com/elzobrito/ESAA — Event Sourcing for Autonomous Agents. Append-only .jsonl, SHA-256 verified projections, contracts YAML.

### TASK-050: Observabilidade — Analytics + Error Tracking ✅ (02/03/2026)
- [ ] Sentry para error tracking (ou self-hosted alternative)
> **Arquivos:** `api/src/egos_inteligencia/routers/analytics.py`, `frontend/src/App.tsx`, `frontend/index.html`, `frontend/src/pages/Analytics.tsx`

### TASK-062: Sincronização GitHub Issues ↔ Tasks ✅ (02/03/2026)
- [ ] Criar issues para novas tasks pendentes
- [ ] Automatizar sync (script ou GitHub Action)

### TASK-073: Website Overhaul — SEO + Copy + Crawlers ✅ (02/03/2026)
- [ ] OG image para compartilhamento em redes sociais
> **Arquivos:** `index.html`, `robots.txt`, `sitemap.xml`, `Landing.tsx`

### TASK-074: Chatbot Intelligence — Reports + Proactive ✅ (02/03/2026)
- [ ] Chatbot ainda pede cidade para queries nacionais (emendas, supersalários)
- [ ] Memória entre mensagens (histórico de sessão)
- [ ] Mais testes de hallucination e edge cases
> **Arquivo:** `chat.py` (SYSTEM_PROMPT), `ChatInterface.tsx`

### TASK-043: Gem Hunter v2 — Melhorar Busca de Projetos ⏳ (P2)
- [ ] Monitorar repos novos com cron semanal
- [ ] Manter registro de projetos avaliados (evitar re-avaliar)
- [ ] Implementar health check de APIs (inspirado Brazil Visible)
> **Projetos avaliados:** 9 + LMCache + 3 RokoOfficial + Bruin + 4 OSINT + Transparencia-360 + Brazil Visible (total: 20)
> **Transparencia-360:** github.com/MatheusMarkies/Transparencia-360 — Spring Boot + Neo4j, 26-step pipeline, Super Reports
> **Brazil Visible:** github.com/nferdica/brazil-visible — 92+ APIs, health check automático, receitas cruzamento

### TASK-118: Transparency Report + Pattern Engine ✅ (03/03/2026)
> **Arquivos:** `frontend/public/reports/transparencia-metodologia.html`, `frontend/src/pages/Reports.tsx`, `api/src/egos_inteligencia/config.py`
- [ ] OSINT: 24 tools com rate limits
- [ ] Observability: structured logging, request tracing
> **Issue:** #34 (P2)

### TASK-090: UI Polish — Scrollbar, Reports HTML, Privacy, Sidebar ✅ (03/03/2026)
- [ ] X.com post: API returning 503 (Twitter outage), retry later
> **Arquivos:** `global.css`, `AppShell.module.css`, `Reports.tsx`, `Activity.tsx`, `ReportsShowcase.tsx`, 3 HTML reports

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

### TASK-100: Review PR #39 — Índice Central de Documentação ⏳ (P1 — Split)
- [ ] **AÇÃO:** Merge apenas docs (README.md, STACK_SCALING_DECISION, MYCELIUM_AUDIT_TRAIL)
- [ ] **AÇÃO:** Separar código ETL (base.py, provenance.py, test_provenance.py) → TASK-104
> **PR:** https://github.com/enioxt/EGOS-Inteligencia/pull/39

### TASK-104: Review ETL Provenance Code (split de PR #39) ⬜ (P2 — Análise Técnica)
- [ ] `etl/src/egos_inteligencia_etl/provenance.py` — SHA-256 hash de linhas brutas, source fingerprint
- [ ] `etl/src/egos_inteligencia_etl/base.py` — método `build_audit_fields()` no Pipeline base
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
- [ ] **Aguardando:** Resposta do Douglas com PRs separadas
- [ ] **Valor:** Monitor de upstream é útil para acompanhar forks e contribuições
- [ ] **Risco:** Modifica TASKS.md/ROADMAP/README (nossos SSOT docs)
> **PR:** https://github.com/enioxt/EGOS-Inteligencia/pull/31

### TASK-103: Intelink Copy — Linguagem Neutra (só no que migrarmos) ⏳ (P1)
- [ ] "operação/operações" → "caso/casos" ou "análise/análises" (não encontrado em uso)
- [ ] "acusado/acusados" → "envolvido/envolvidos" (não encontrado em UI)
- [ ] "suspeito/suspeitos" → "pessoa de interesse" (não encontrado em UI)
- [ ] "Inteligência Policial" → "Inteligência em Dados Públicos" (não encontrado em UI)
> **Contexto Discord:** @ericklucioh perguntou "oq seria investigacoes e relatorios?" — @enioxt respondeu "Resquícios do Intelink, vou mudar o nome"
> **Arquivos:** `Reports.tsx`, `Dashboard.tsx`, `PartnershipCTA.tsx`, `i18n.ts`

---

## Audit Tasks (Dossiê Técnico 2026-03-03)

> Geradas pela auditoria completa do código-fonte. Ref: `docs/TECHNICAL_DOSSIE_2026-03.md`

### TASK-105: Rotacionar API Keys Expostas ✅ (03/03/2026)
- [ ] Considerar BFG Repo Cleaner para limpar git history (P2)
> **Arquivos:** `/opt/egos_inteligencia/infra/.env`

### TASK-106: Whitelist Cypher Injection em `_tool_cypher` ✅ (03/03/2026)
- [ ] Adicionar teste de regressão (P2)
> **Evidência:** `api/src/egos_inteligencia/routers/chat.py:264-281`
> **Esforço:** 1h | **Impacto:** Fecha maior vetor de ataque

### TASK-107: Migrar Conversas para Redis ⏳ (parcial)
- [ ] Migrar `_usage_counts` e `_usage_day` para Redis INCR com TTL 24h
- [ ] Graceful degradation (Redis down = in-memory fallback)
- [ ] Key pattern: `egos:usage:{date}:{client_id}`
> **Evidência:** Redis em `conversations.py`; `_usage_counts`/`_usage_day` ainda em memória em `api/src/egos_inteligencia/routers/chat.py` (migração pendente).
> **Esforço:** 2h | **Impacto:** Conversas sobrevivem restart/deploy

### TASK-108: Split `chat.py` em Módulos ✅ (03/03/2026)
- [ ] Extrair `chat_openrouter.py` — `_call_openrouter()` + tool execution loop (P2)
> **Arquivos:** `chat_models.py`, `chat_tools.py`, `chat_prompt.py`

### TASK-109: Testes Backend — Integration Tests ⏳
- [ ] Integration tests with testcontainers Neo4j
- [ ] Test chat tool calling + tier fallback + rate limit
> **Status (session 17-18):** 219 API unit + 18 live integration + 955 ETL = **1,192 tests**
> **Arquivos:** `api/tests/integration/test_live_api.py`, `api/tests/unit/`, `etl/tests/`
> **Esforço restante:** 2h | **Impacto:** Qualidade e confiança

### TASK-111: Circuit Breaker para APIs Externas ✅ (03/03/2026)
- [ ] Migrar todas as 21 tools para usar `safe_get()` (progressivo, P2)
> **Arquivos:** `services/circuit_breaker.py`, `services/transparency_tools.py`

### TASK-112: Input Sanitization (Prompt Injection) ✅ (03/03/2026)
- [ ] Rate limit agressivo para IPs com inputs suspeitos (P2 futuro)
> **Arquivos:** `middleware/input_sanitizer.py`, `tests/unit/test_input_sanitizer.py`, `routers/chat.py`

### TASK-113: BFG Repo Cleaner — Git History ⬜ (P2)
- [ ] Executar BFG para remover API keys do history completo
- [ ] Force push (coordenar com contribuidores)
- [ ] Verificar que keys não aparecem mais em `git log -p`
> **Depende de:** TASK-105 (rotacionar primeiro)
> **Esforço:** 1h

### TASK-114: DSAR Workflow Automatizado ⏳ (P2)
- [ ] Endpoint `/api/v1/dsar` para submissão programática
- [ ] Workflow: register → verify scope → produce decision log
- [ ] Prazo LGPD: 15 dias úteis para resposta
> **Arquivos:** `.github/ISSUE_TEMPLATE/dsar_request.yml`
> **Evidência:** LGPD Art. 18 — template criado, API pendente

### TASK-123: Multi-hop Connection Finder (Tool #27) ✅ (03/03/2026)
- [ ] **BLOCKED:** Only 4 SOCIO_DE relationships in Neo4j — tool works but graph too sparse
> **Arquivos:** `api/src/egos_inteligencia/routers/chat.py`, `api/src/egos_inteligencia/routers/chat_tools.py`
> **Depende de:** TASK-001 (CNPJ ETL Phase 3 must re-run to load 24.6M SOCIO_DE)

### TASK-125: Codex CLI Integration ✅ (04/03/2026)
- [ ] Login and register GitHub (`codex login`)
- [ ] Run first delegated task (code review)
> **Arquivos:** `.windsurfrules`, `start.md`, `end.md`, `pre-commit-v2.sh`

### TASK-126: Análise Transparencia-360 ✅ (04/03/2026)
- [ ] Agradecer no repositório deles (GitHub star/issue)
> **Ref:** https://github.com/MatheusMarkies/Transparencia-360

### TASK-127: Análise Brazil Visible ✅ (04/03/2026)
- [ ] Agradecer no repositório deles (GitHub star/issue)
> **Ref:** https://github.com/nferdica/brazil-visible

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
- [ ] TASK-NB-002: Criar router `/api/v1/interop/` no egos-inteligencia (FastAPI)
- [ ] TASK-NB-003: Endpoint `GET /interop/entity/{cnpj}` — busca empresa + sócios
- [ ] TASK-NB-004: Endpoint `GET /interop/network/{cnpj}` — grafo de rede (1 hop)
- [ ] TASK-NB-005: Endpoint `GET /interop/pep/{cpf_or_name}` — check PEP
- [ ] TASK-NB-006: Endpoint `GET /interop/sanctions/{cnpj}` — sanções CEIS/CNEP
- [ ] TASK-NB-007: Endpoint `GET /interop/health` — status do Neo4j + contagens
- [ ] TASK-NB-008: Criar `egos_inteligencia-client.ts` no egos-lab (`packages/shared/src/`)
- [ ] TASK-NB-009: Criar tool `egos_inteligencia.query-entity` no MCP do egos-lab
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
- [ ] Aplicar padrão ao relatório Vorcaro v2 (disclaimer legal, rodapé, fontes por afirmação)
- [ ] Aplicar padrão a todos os relatórios futuros gerados pelo bot/sistema
- [ ] Criar validador automático (agent) que verifica conformidade de relatórios
> **Princípio:** Nenhuma acusação, fontes rastreáveis, convite à correção.
> **Arquivo:** `docs/standards/REPORT_STANDARDS.md`

### TASK-136: Provenance/Não-Repúdio — Integrar em Pipelines ⬜ (P0)
- [ ] Integrar `build_audit_fields()` no pipeline CNPJ/QSA
- [ ] Integrar no pipeline Sanctions (CEIS/CNEP)
- [ ] Integrar no pipeline DataJud
- [ ] Marcar dados legados como `audit_status = "legacy"` via script Cypher
- [ ] Criar nó `:DataSource` + rel `[:PROVENANCE]` no grafo para fontes críticas
- [ ] Validar que hash é estável (mesmo input → mesmo hash) em produção
> **Arquivo:** `etl/src/egos_inteligencia_etl/provenance.py`
> **Plano:** `docs/analysis/MYCELIUM_AUDIT_TRAIL_2026-03.md`

### TASK-137: Mapa de Bases Governamentais + Posicionamento ⬜ (P1)
- [ ] Adicionar seção "Para Autoridades" na landing page do egos-inteligencia
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
> **Pipeline:** `etl/src/egos_inteligencia_etl/pipelines/datajud.py` (existe, 0 dados carregados)
> **Depende de:** Acesso à API DataJud

### TASK-139: Caso Vorcaro v3 — Expansão com Dados Cruzados ⬜ (P1)
- [ ] v3: Aplicar REPORT_STANDARDS (disclaimer, rodapé, provenance)
- [ ] v3: Expandir rede 2º grau (sócios dos sócios)
- [ ] v3: Cruzar com DataJud (quando disponível)
- [ ] v3: Cruzar com Diários Oficiais (Querido Diário)
- [ ] v3: Identificar os 14 acusados CVM restantes (requer corpo do PAS)
> **Arquivo:** `docs/cases/caso-vorcaro-mapa-publico.md`

---

*"Siga o dinheiro público. Dados abertos, código aberto."*
