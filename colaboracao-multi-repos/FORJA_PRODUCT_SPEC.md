# FORJA — Assistente Operacional Corporativo (Chat-First ERP)

> **Codename:** Forja ("Forge" — forjando operações na palma da mão)
> **Versão:** 0.1.0-spec | **Data:** 2026-03-05
> **Origem:** Conversa completa em `egos-lab/docs/chat.md` + PR #56

---

## 1) Visão do Produto

**Forja** é um assistente operacional conversacional multi-tenant que permite:
- Consultar e operar dados (produtos, custos, orçamento, estoque, produção, financeiro)
- Criar relatórios (PDF/Excel) sob demanda ou agendados
- Fazer entrada/edição de dados via chat (texto/áudio)
- Rodar automações ("workers") com governança (aprovação/quórum)
- Integrar caixa de e-mail corporativa com IA (leitura, classificação, resposta sugerida)
- Notificar via WhatsApp/Push/E-mail
- Tudo com segurança, trilha de auditoria e controle de acesso

**Público-alvo inicial:** Metalúrgicas e oficinas mecânicas (UX para mãos grandes, visão limitada, campo).

**UI:** Chat + áudio + cards de confirmação. Dashboard admin separado.

---

## 2) Stack Recomendada

### Frontend
- **Next.js + Tailwind** (Chat PWA + Dashboard Admin)
- **Capacitor** para wrapper Android (APK/AAB)
- Chat UI com SSE/WebSocket (streaming LLM)
- Áudio via MediaRecorder + upload chunked

### Backend
- **FastAPI (Python)** — integração IA/ETL rápida
- **Postgres + RLS** — multi-tenant seguro
- **pgvector** — RAG sem banco extra no MVP
- **Redis** — cache/rate-limit/locks
- **S3/MinIO** — anexos/relatórios/PDFs

### Orquestração (aprovação, jobs, SLAs)
- **Temporal** ou **Conductor** (robustez enterprise)
- MVP: Celery + Redis + cron

### IA e Áudio
- **STT:** Whisper (self-host ou API)
- **LLM:** OpenRouter adapter (Gemini/GPT/Claude) com tool-calling
- **Document AI:** PyMuPDF + OCR (Tesseract) + Apache Tika
- **Guardrails:** schema validation + policy gate + tool allowlist

### WhatsApp
- MVP: Evolution API (já temos no carteira-livre) ou Twilio
- V1: Meta WhatsApp Business Cloud API

### E-mail
- Inbound: Gmail API (Pub/Sub) ou Microsoft Graph (webhooks) ou IMAP
- Outbound: SES / Postmark / SendGrid

---

## 3) Módulos Reaproveitáveis (Pesquisa Cross-Repo)

### Do `egos-lab` (Orquestração e IA)

| Módulo | Caminho | Reuso na Forja |
|--------|---------|----------------|
| **AI Client** | `packages/shared/src/ai-client.ts` | Adapter LLM com OpenRouter, pricing tracking, fallback. Reaproveitar 100% como base do LLM Router |
| **Rate Limiter** | `packages/shared/src/rate-limiter.ts` | Rate limit por tenant/usuário. Reaproveitar diretamente |
| **Telegram Client** | `packages/shared/src/social/telegram-client.ts` | Notificações Telegram. Reaproveitar como canal de notificação |
| **API Registry** | `packages/shared/src/api-registry.ts` | Risk Tiers (T0-T3), automation levels, route categorization. Reaproveitar padrão de governança |
| **MCP Tool Runner** | `packages/mcp/src/index.ts` | Padrão de Tool Runner com `executeTool()`, validação de input, event emitting. Reaproveitar como base do Tool Runner da Forja |
| **Telegram Bot** | `apps/telegram-bot/src/index.ts` | Bot Telegraf + Supabase + AI. Modelo de como integrar chat + IA + persistência |
| **Agent Runtime** | `agents/runtime/runner.ts` | Registry de agentes + execução. Inspiração para workers/automações |

### Do `carteira-livre` (APIs, Webhooks, Auth)

| Módulo | Caminho | Reuso na Forja |
|--------|---------|----------------|
| **Evolution API (WhatsApp)** | `services/whatsapp/evolution-api.ts` | Cliente WhatsApp completo (text, buttons, lists). Reaproveitar 100% para notificações |
| **API Utils** | `services/api-utils.ts` | `getSupabaseAdmin()`, `errorResponse()`, `isAdmin()`, `isInstructor()`. Padrão de auth/RBAC |
| **Asaas Sync** | `services/payments/asaas-sync.ts` | Padrão de sync assíncrono com webhook. Modelo para email ingestion |
| **API Usage Logger** | `services/api-usage-logger.ts` | Tracking de uso de API por request. Reaproveitar para cost tracking por tenant |
| **Face API (Biometrics)** | `services/biometrics/face-api.ts` | Padrão de integração com API externa + validação. Modelo para Document AI |

### Do `br-acc / EGOS Inteligência` (Chat + Tools + Grafo)

| Módulo | Caminho | Reuso na Forja |
|--------|---------|----------------|
| **Chat Router (26 tools)** | `api/src/bracc/routers/chat.py` | Padrão completo de LLM + tool-calling + conversation memory + rate limiting por tier. **Reaproveitar arquitetura inteira** |
| **Transparency Tools** | `api/src/bracc/services/transparency_tools.py` | 26 tools com schema estrito. Modelo para criar tools de ERP (consultar preço, alterar estoque, etc) |
| **Public Guard / LGPD** | `api/src/bracc/services/public_guard.py` | Masking de dados sensíveis. Reaproveitar para LGPD multi-tenant |
| **Cache Service** | `api/src/bracc/services/cache.py` | Redis cache layer. Reaproveitar diretamente |
| **Activity Feed** | `api/src/bracc/routers/activity.py` | Event logging + feed. Modelo para audit log |
| **Evidence Chain** | `chat.py` (evidence_chain) | Rastreabilidade de fontes. Reaproveitar para trilha de auditoria |

---

## 4) Pipeline de E-mail (Motor Central do Produto)

### Modelo de Eventos (Event-Driven)
```
EmailReceived → AttachmentStored → DocumentExtracted →
EmailClassified → NotificationDispatched → ReplyDrafted →
WorkflowTriggered → ApprovalRequested → Approved/Rejected
```

### Estados do E-mail
1. `RECEIVED` (raw guardado)
2. `SCANNED` (virus scan ok)
3. `PARSED` (texto + metadados)
4. `CLASSIFIED` (tipo, prioridade, confidencialidade)
5. `ROUTED` (para quem vai)
6. `NOTIFIED` (WhatsApp/e-mail/push enviado)
7. `ACTIONED` (workflow/tarefa aberta)
8. `CLOSED` (resolvido)
9. `FAILED` (com retry e dead-letter)

### Conectores (plugáveis)
- `connector_gmail` — OAuth2 + Gmail API + Pub/Sub
- `connector_m365` — OAuth2 + Microsoft Graph + webhooks
- `connector_imap` — IMAP IDLE (fallback genérico)

Todos emitem o evento canônico `EmailReceived`.

---

## 5) Modelo de Governança

### Mutações Críticas (ex: alterar preço exige 2 admins)
1. Preview de mudança (antes/depois)
2. Checagem de política (RBAC + ABAC)
3. Aprovação N-de-M (ex: 2/2 admins)
4. Execução transacional
5. Auditoria imutável (append-only)
6. Notificação de conclusão

### Risk Tiers (do egos-lab api-registry)
- **T0:** Read-only, sem efeitos colaterais
- **T1:** Escrita user-scoped (próprios dados)
- **T2:** Mutação de sistema (cross-user, IA)
- **T3:** Destrutiva/externa (delete, pagamentos, envio de e-mail)

---

## 6) UX para Campo (Mecânicos/Leigos)

- Área de toque mínima: **56px** (ideal 64dp)
- Tipografia base: **18-20px** + modo fonte gigante
- Alto contraste (AA/AAA) + modo "oficina" (dark, alto contraste)
- Poucos passos, muitos cards e botões
- Confirmação explícita para ações de risco
- Feedback visual/sonoro de sucesso/erro
- Voz como first-class citizen

---

## 7) Estrutura de Repositório Proposta

```
forja/
├── apps/
│   ├── chat-pwa/          # Next.js + Tailwind (Chat + Áudio)
│   └── dashboard/         # Next.js + Tailwind (Admin/Operação)
├── services/
│   ├── api-gateway/       # FastAPI BFF
│   ├── core-domain/       # ERP-lite (produtos, fornecedores, custos)
│   ├── email-ingestor/    # Conectores Gmail/M365/IMAP
│   ├── ai-orchestrator/   # LLM Router + Tool Runner + Guardrails
│   ├── workflow-engine/   # Temporal/Conductor (aprovações, jobs)
│   └── notifications/     # WhatsApp/Email/Push
├── packages/
│   ├── contracts/         # Schemas/eventos canônicos
│   ├── policies/          # RBAC/ABAC rules
│   └── design-system/     # Componentes acessíveis
├── infra/
│   └── docker-compose.yml # Dev environment
└── docs/
    └── ...
```

---

## 8) Roadmap

### Fase 0 — Fundação (1-2 semanas)
- [ ] Contratos de dados e políticas (schemas)
- [ ] Auth multi-tenant + RLS
- [ ] Chat base + Tool Runner seguro
- [ ] Modelo de dados mínimo (tenant, user, role, conversation, message, tool_call, audit_log)

### Fase 1 — MVP (2-4 semanas)
- [ ] STT (Whisper) + transcrição de áudio
- [ ] 10 consultas core (produtos, custos, orçamento, fornecedores, produção)
- [ ] 1 relatório PDF (financeiro ou produção)
- [ ] 1 fluxo de aprovação 2-de-2 (alterar preço)
- [ ] Conector e-mail (Gmail ou M365)
- [ ] Resumo + sugestão de resposta de e-mail
- [ ] Notificação WhatsApp (via Evolution API)

### Fase 2 — Dashboard (4-8 semanas)
- [ ] Dashboard operacional completo
- [ ] KPIs + relatórios agendados
- [ ] Worker specs configuráveis
- [ ] Regras de roteamento de e-mail

### Fase 3 — Enterprise
- [ ] Conectores ERP legado (planilhas, CSV)
- [ ] Otimização de custo IA por tenant
- [ ] Observabilidade completa (OpenTelemetry + Grafana)
- [ ] Android APK via Capacitor

---

## 9) Gaps Críticos (a fechar antes de produção)

- Política formal de retenção de e-mails e anexos por tenant
- Classificação de dados sensíveis e estratégia de redaction
- Plano de contingência para falha de provedor WhatsApp
- Testes de autorização por papel + tenant para 100% das mutações
- Catálogo de prompts / versionamento / avaliação de qualidade do agente
- Prompt injection via e-mail/anexo → mitigação com Tool Runner + Policy Gate

---

## 10) Referências de Mercado

| Categoria | Ferramentas |
|-----------|-------------|
| Shared inbox/helpdesk | Front, Zendesk, Freshdesk, Help Scout, Intercom |
| iPaaS | Zapier, Make, n8n, Pipedream, Workato |
| RPA | UiPath, Automation Anywhere |
| IA no e-mail | Copilot (M365), Gemini (Workspace) |
| Chat-first ERP | Há poucos concorrentes diretos — oportunidade |

---

*"Forja: ERP na conversa. Operações na palma da mão."*
