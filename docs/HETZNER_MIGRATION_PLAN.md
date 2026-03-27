# Hetzner Migration Plan — Contabo → Hetzner

> **Urgência:** ESTE MÊS (evitar renovação Contabo)
> **Status:** PLAN READY — Executar assim que Hetzner provisionado
> **Servidor Atual:** Contabo Cloud VPS 40 SSD — 217.216.95.126 (12vCPU, 48GB, 500GB, $35/mês)
> **Servidor Target:** Hetzner CX41 (~€24/mês, 4vCPU, 16GB RAM, 160GB SSD) ou CPX31 (4vCPU, 8GB, €12/mês)
> **VPS Credentials:** Ver `/home/enio/egos-lab/.env` (chave CONTABO_*)

---

## PRÉ-REQUISITOS (fazer ANTES de cancelar Contabo)

### ✅ Checklist de Segurança Pré-Migração

- [ ] **Backup Neo4j completo** em máquina local ou S3
- [ ] **Backup arquivos ETL** (scripts, dados já baixados)
- [ ] **Novo VPS Hetzner** provisionado e testado
- [ ] **DNS testado** no novo IP (com TTL baixo primeiro)
- [ ] **Todos containers rodando** no Hetzner por 24h
- [ ] **SSL/HTTPS funcionando** no Hetzner
- [ ] **Contabo cancelado** APENAS após confirmação 48h estável

---

## FASE 1 — Backup Final no Contabo (SSH necessário)

```bash
# 1. Conectar ao Contabo
ssh root@217.216.95.126

# 2. Verificar espaço disponível
df -h

# 3. Verificar estado atual dos containers
docker compose -f /opt/bracc/infra/docker-compose.prod.yml ps

# 4. Executar backup Neo4j (script já existe)
/opt/bracc/scripts/neo4j-backup.sh

# 5. Verificar que backup foi criado
ls -lh /opt/bracc/backups/neo4j_data_*.tar.gz | tail -3

# 6. Criar backup adicional dos dados ETL
tar czf /tmp/etl_data_backup.tar.gz /opt/bracc/etl/ 2>/dev/null || true

# 7. Verificar size total a transferir
du -sh /opt/bracc/backups/neo4j_data_*.tar.gz | tail -1
```

**⚠️ ATENÇÃO:** Neo4j data deve ser ~20-50GB comprimido. Transferência via SCP pode levar 1-3h.

---

## FASE 2 — Provisionar Hetzner

### Especificação Recomendada

Para 77M entidades Neo4j + FastAPI + Frontend:

| Opção | Specs | Preço | Adequação |
|-------|-------|-------|-----------|
| **CX41** (recomendado) | 4 vCPU, 16GB, 160GB SSD | €24/mês | ✅ Boa (suficiente com tuning) |
| **CX51** | 8 vCPU, 32GB, 240GB SSD | €40/mês | ✅ Melhor (headroom confortável) |
| **CPX31** | 4 vCPU, 8GB, 160GB SSD | €12/mês | ⚠️ Apertado para Neo4j |

**Recomendação:** CX51 (mesmo preço que Contabo, mais RAM) ou CX41 (mais barato, funciona com Neo4j heap tuned para 6GB).

### Criar via Hetzner Console
1. Criar conta em cloud.hetzner.com
2. New Server → Ubuntu 22.04 → CX41
3. Adicionar SSH key: `cat ~/.ssh/id_rsa.pub`
4. **Networking:** Enable Firewall (abrir 80, 443, 22 only)
5. Anotar o IP do novo servidor

---

## FASE 3 — Setup Hetzner

```bash
# Conectar ao Hetzner novo
ssh root@<HETZNER_IP>

# Update + Docker install
apt update && apt upgrade -y
curl -fsSL https://get.docker.com | bash
usermod -aG docker $USER

# Instalar Docker Compose v2
apt install docker-compose-plugin -y

# Criar estrutura
mkdir -p /opt/bracc/{infra,backups,etl,scripts}
cd /opt/bracc

# Instalar Caddy (ou usar nginx)
apt install caddy -y
```

---

## FASE 4 — Transferir Dados

```bash
# Da sua máquina local, transferir backup do Contabo → Hetzner diretamente
# (Contabo → Hetzner via SCP intermediado pela sua máquina, ou usar rsync)

# Opção A: Via máquina local (mais seguro)
scp root@217.216.95.126:/opt/bracc/backups/neo4j_data_LATEST.tar.gz /tmp/
scp /tmp/neo4j_data_LATEST.tar.gz root@<HETZNER_IP>:/opt/bracc/backups/

# Opção B: SSH tunneling direto (mais rápido se Contabo→Hetzner na mesma DC)
ssh root@217.216.95.126 "cat /opt/bracc/backups/neo4j_data_LATEST.tar.gz" | \
  ssh root@<HETZNER_IP> "cat > /opt/bracc/backups/neo4j_data_LATEST.tar.gz"

# Transferir infra configs (sem .env com secrets)
rsync -av /home/enio/br-acc/infra/ root@<HETZNER_IP>:/opt/bracc/infra/ \
  --exclude='.env'
```

---

## FASE 5 — Restaurar Neo4j no Hetzner

```bash
# No Hetzner:

# 1. Configurar .env (criar com secrets reais)
cat > /opt/bracc/infra/.env << 'EOF'
NEO4J_PASSWORD=<COPIAR_DO_CONTABO>
JWT_SECRET_KEY=<COPIAR_DO_CONTABO>
DOMAIN=inteligencia.egos.ia.br
TELEGRAM_BOT_TOKEN=<COPIAR>
TELEGRAM_CHAT_ID=<COPIAR>
# ... outros secrets
EOF

# 2. Subir Neo4j vazio primeiro
cd /opt/bracc/infra
docker compose -f docker-compose.prod.yml up -d neo4j

# 3. Aguardar Neo4j iniciar (30s)
sleep 30
docker compose -f docker-compose.prod.yml ps

# 4. Restaurar dados do backup
# Parar neo4j, extrair volume, reiniciar
docker compose -f docker-compose.prod.yml stop neo4j
VOLUME=$(docker volume ls | grep neo4j | awk '{print $2}')
tar xzf /opt/bracc/backups/neo4j_data_LATEST.tar.gz \
  -C /var/lib/docker/volumes/${VOLUME}/
docker compose -f docker-compose.prod.yml start neo4j

# 5. Verificar count de nós
sleep 60
docker exec bracc-neo4j cypher-shell -u neo4j -p "$NEO4J_PASSWORD" \
  "MATCH (n) RETURN labels(n)[0] AS tipo, count(n) AS total ORDER BY total DESC LIMIT 5"

# 6. Subir resto dos containers
docker compose -f docker-compose.prod.yml up -d
```

---

## FASE 6 — Configurar SSL + DNS

```bash
# No Hetzner, configurar Caddy (já está no docker-compose.prod.yml)
# Ou usar Certbot diretamente

# Verificar que domínio aponta pro novo IP antes de ativar SSL
# Mudar TTL para 300s (5min) NO DIA ANTES da migração

# Após mudar DNS:
# inteligencia.egos.ia.br → <HETZNER_IP>

# Caddy vai pegar SSL automaticamente
docker compose -f docker-compose.prod.yml up -d caddy

# Testar
curl https://inteligencia.egos.ia.br/health
```

---

## FASE 7 — Verificação Final

```bash
# Verificar todos containers saudáveis
docker compose -f docker-compose.prod.yml ps

# Verificar Neo4j com dados
docker exec bracc-neo4j cypher-shell -u neo4j -p "$NEO4J_PASSWORD" \
  "MATCH (n:Company) RETURN count(n) AS empresas"
# Esperado: ~59,573,749

docker exec bracc-neo4j cypher-shell -u neo4j -p "$NEO4J_PASSWORD" \
  "MATCH ()-[r:SOCIO_DE]->() RETURN count(r) AS socios"
# Esperado: ~25,091,492

# Testar API pública
curl https://inteligencia.egos.ia.br/health
curl "https://inteligencia.egos.ia.br/api/v1/search?q=test"

# Verificar telegram bot
curl "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe"
```

---

## FASE 8 — Desligar Contabo (SOMENTE após 48h estável no Hetzner)

```bash
# No Contabo — parar containers mas NÃO deletar ainda
ssh root@217.216.95.126
docker compose -f /opt/bracc/infra/docker-compose.prod.yml stop

# Aguardar 48h confirmando Hetzner estável
# Depois: Acessar console Contabo → Cancelar servidor
```

---

## Configuração Neo4j Hetzner (Memory Tuning)

Para CX41 (16GB RAM), usar no docker-compose:
```yaml
environment:
  NEO4J_server_memory_heap_initial__size: "2G"
  NEO4J_server_memory_heap_max__size: "6G"
  NEO4J_server_memory_pagecache_size: "6G"
  # Deixa ~4GB para OS + containers
```

Para CX51 (32GB RAM):
```yaml
environment:
  NEO4J_server_memory_heap_initial__size: "4G"
  NEO4J_server_memory_heap_max__size: "16G"
  NEO4J_server_memory_pagecache_size: "10G"
```

---

## ETL Fix (fazer no Hetzner, não no Contabo)

Após migração, corrigir o bug bloqueante:

```python
# linking_hooks.py — Fix run_id ParameterMissing
# Adicionar run_id como parâmetro padrão ou UUID gerado automaticamente
import uuid

def run_linking_hooks(run_id=None):
    if run_id is None:
        run_id = str(uuid.uuid4())
    # ... resto do código
```

```bash
# Reiniciar ETL no Hetzner
cd /opt/bracc/etl
python runner.py --phase 4 --run-id $(uuidgen)
```

---

## Estimativa de Tempo Total

| Fase | Tempo Estimado |
|------|----------------|
| Provisionar Hetzner | 10 min |
| Setup Ubuntu + Docker | 20 min |
| Backup + Transfer | 1-3h (depende velocidade) |
| Restore Neo4j | 30 min |
| DNS + SSL | 30 min |
| Verificação | 30 min |
| **TOTAL** | **3-5 horas** |

---

## Rollback Plan

Se algo der errado no Hetzner, o Contabo ainda está rodando. Basta:
1. Reverter DNS para IP Contabo
2. Aguardar propagação (5min com TTL 300s)
3. Sistema volta 100%

**Por isso: NÃO desligar Contabo antes de 48h estável no Hetzner.**

---

## Custo Final Estimado

| Período | Custo |
|---------|-------|
| Hetzner CX41 | €24/mês (~R$140) |
| Hetzner CX51 | €40/mês (~R$230) |
| Contabo atual | $35/mês (~R$200) |
| **Economia CX41** | **~R$60/mês** |
| **Economia CX51** | **~R$0 (mesmo custo, mais specs)** |

---

**Próximos Passos Imediatos:**
1. Você assina Hetzner → me passa o IP
2. Eu gero os scripts de setup personalizados
3. Executamos Fase 1-3 juntos

