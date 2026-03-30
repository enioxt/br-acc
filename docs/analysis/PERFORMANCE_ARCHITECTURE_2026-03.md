# BR/ACC Performance Architecture — Big Tech Patterns for 55M+ Node Graph

> **Date:** 2026-03-02 | **Author:** EGOS Intelligence
> **Context:** After CNPJ ETL loads 53.6M companies into Neo4j

---

## Current State vs Target

| Metric | Before CNPJ | After ETL | With Optimization |
|--------|------------|-----------|-------------------|
| Nodes | 317k | ~90M+ | ~90M+ |
| CNPJ lookup latency | 404 Not Found | ~5-30s (no index) | **<5ms** |
| Name fuzzy search | N/A | N/A | **50-200ms** |
| 1-hop graph expand | ~1s | ~30s (no index) | **<100ms** |
| 2-hop expand | ~5s | timeout | **500ms-2s** |
| Neo4j heap | 512MB | 512MB | **16GB** |
| Neo4j pagecache | 512MB | 512MB | **22GB** |

---

## Layer 0: Memory Configuration (Critical — Apply After ETL)

**Current (broken for 55M nodes):**
```
heap = 512MB  # can't hold 55M nodes in working memory
pagecache = 512MB  # can't cache 26GB of extracted data
```

**Optimized for 48GB Contabo:**
```
NEO4J_HEAP_INITIAL=8g
NEO4J_HEAP_MAX=16g     # Java heap for queries/transactions
NEO4J_PAGECACHE=22g    # Stores ALL 26GB data in RAM → sub-10ms reads
# Leaves: 10GB for OS + bots + API + Python
```

**Why pagecache=22G changes everything:**
With 22GB pagecache, ALL of Neo4j's store files fit in RAM. Every CNPJ lookup becomes a RAM read (~4KB page load) instead of disk I/O. LinkedIn, Facebook, and Palantir all solve scale with RAM-first architectures. This is the single highest-ROI change.

**Apply with:**
```bash
bash /opt/egos_inteligencia/neo4j-memory-upgrade.sh
cd /opt/egos_inteligencia/infra && docker compose -f docker-compose.prod.yml up -d neo4j
```

---

## Layer 1: Indexes (Must Create After ETL)

Run: `bash /opt/egos_inteligencia/post-etl-optimize.sh`

### B-Tree Indexes (exact lookup, O(log n)):
```cypher
CREATE INDEX company_cnpj IF NOT EXISTS FOR (c:Company) ON (c.cnpj)
CREATE INDEX company_cnpj_basico IF NOT EXISTS FOR (c:Company) ON (c.cnpj_basico)
CREATE INDEX company_name IF NOT EXISTS FOR (c:Company) ON (c.name)
CREATE INDEX company_uf IF NOT EXISTS FOR (c:Company) ON (c.uf)
CREATE INDEX company_cnae IF NOT EXISTS FOR (c:Company) ON (c.cnae_principal)
CREATE INDEX person_cpf IF NOT EXISTS FOR (p:Person) ON (p.cpf)
CREATE INDEX person_name IF NOT EXISTS FOR (p:Person) ON (p.name)
CREATE INDEX partner_doc IF NOT EXISTS FOR (p:Partner) ON (p.document)
CREATE INDEX sanction_cnpj IF NOT EXISTS FOR (s:Sanction) ON (s.cnpj)
```

### Full-Text Indexes (fuzzy name search):
```cypher
CREATE FULLTEXT INDEX company_name_ft IF NOT EXISTS
  FOR (n:Company) ON EACH [n.name, n.name_fantasy]

CREATE FULLTEXT INDEX person_name_ft IF NOT EXISTS
  FOR (n:Person|Partner) ON EACH [n.name]
```

**Expected latency after indexing:**

| Query | Complexity | Target |
|-------|-----------|--------|
| `MATCH (c:Company {cnpj: $cnpj})` | O(log 55M) | <5ms |
| `CALL db.index.fulltext.queryNodes("company_name_ft", $name)` | Lucene | 20-100ms |
| `MATCH path=shortestPath((a:Company)-[*..3]-(b:Company))` | BFS | 100ms-5s |
| `MATCH (c:Company)-[:SOCIO_DE]->(owner)` (1-hop) | O(degree) | <50ms |

---

## Layer 2: Redis Cache (Next Priority)

Pattern: **Cache-Aside** (used by Netflix, Twitter, Airbnb for hot data)

```
Request → API → Redis lookup
  [HIT] → Return cached result (< 1ms)
  [MISS] → Query Neo4j → Store in Redis (TTL 24h) → Return
```

### What to cache:
| Key Pattern | TTL | Reason |
|-------------|-----|--------|
| `company:{cnpj}` | 24h | CNPJ data changes monthly |
| `company:graph:{cnpj}:depth1` | 6h | 1-hop partners stable |
| `company:patterns:{cnpj}` | 12h | Fraud patterns computed |
| `bndes:{cnpj}` | 24h | Historical, rarely changes |
| `sanctions:{cnpj}` | 1h | Can update more frequently |

### Expected cache hit rates:
- Popular CNPJs (Petrobras, Vale, etc.): 95%+
- Investigation targets (Patense, etc.): 80%+ after first query
- Random long-tail: 10-20%

### Implementation (add to `api/src/egos_inteligencia/cache.py`):
```python
import redis
from functools import wraps
import json

redis_client = redis.Redis(host='redis', port=6379, decode_responses=True)

def cached(prefix: str, ttl: int = 86400):
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            key = f"{prefix}:{':'.join(str(a) for a in args)}"
            cached = redis_client.get(key)
            if cached:
                return json.loads(cached)
            result = await func(*args, **kwargs)
            redis_client.setex(key, ttl, json.dumps(result))
            return result
        return wrapper
    return decorator
```

### Add Redis to docker-compose.prod.yml:
```yaml
redis:
  image: redis:7-alpine
  restart: unless-stopped
  command: redis-server --maxmemory 4gb --maxmemory-policy allkeys-lru
  networks:
    - egos_inteligencia
```

---

## Layer 3: Query Patterns (Big Tech Discipline)

### ALWAYS limit traversal depth:
```cypher
# WRONG — can traverse entire 90M graph
MATCH (c:Company)-[*]-(related) RETURN related

# RIGHT — bounded depth, limited results
MATCH (c:Company {cnpj: $cnpj})-[*1..3]-(related)
RETURN related LIMIT 50
```

### ALWAYS paginate:
```cypher
# Cursor-based pagination (LinkedIn/Twitter pattern)
MATCH (c:Company) WHERE c.cnpj > $cursor
RETURN c ORDER BY c.cnpj LIMIT 20
```

### ALWAYS index-anchor first:
```cypher
# WRONG — starts with relationship scan
MATCH (a)-[:SOCIO_DE]->(c:Company {cnpj: $cnpj})

# RIGHT — starts with indexed node
MATCH (c:Company {cnpj: $cnpj})<-[:SOCIO_DE]-(a)
```

### Use EXPLAIN/PROFILE before shipping:
```cypher
PROFILE MATCH (c:Company {cnpj: "33000167000101"})
RETURN c
```

---

## Layer 4: Graph Data Science (GDS) — Phase 7

Neo4j GDS runs algorithms on in-memory projected subgraphs. Used by LinkedIn for People You May Know, Uber for route optimization.

```cypher
-- Project CNPJ companies into GDS
CALL gds.graph.project(
  'company_graph',
  ['Company', 'Person'],
  {SOCIO_DE: {orientation: 'UNDIRECTED'}}
)

-- PageRank: find most connected entities
CALL gds.pageRank.stream('company_graph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC LIMIT 20

-- Community Detection (Louvain): find corporate families
CALL gds.louvain.stream('company_graph')
YIELD nodeId, communityId
RETURN communityId, count(*) as size ORDER BY size DESC LIMIT 20
```

---

## Layer 5: API Design Patterns

### Streaming for large results (Palantir pattern):
Instead of returning 53M companies at once, stream:
```python
@app.get("/api/v1/public/companies/stream")
async def stream_companies():
    async def generate():
        async for company in neo4j_stream("MATCH (c:Company) RETURN c"):
            yield json.dumps(company) + "\n"
    return StreamingResponse(generate(), media_type="application/x-ndjson")
```

### Rate limiting (critical for public API):
```python
# Use token bucket (Google/AWS pattern)
from slowapi import Limiter
limiter = Limiter(key_func=get_remote_address)

@app.get("/api/v1/public/graph/company/{cnpj}")
@limiter.limit("10/minute")  # prevent graph scraping
async def get_company_graph(cnpj: str):
    ...
```

---

## Layer 6: Architecture Overview

```
Internet
    │
    ▼
Caddy (TLS + rate limiting)
    │
    ├── /api/v1/public/* ──► FastAPI
    │                            │
    │                            ├── Redis (L1 cache, <1ms)
    │                            │
    │                            └── Neo4j (L2, <10ms with indexes)
    │                                     │
    │                                     └── 90M+ nodes in 22GB pagecache
    │
    └── /* ──► React Frontend (static, CDN-cached)


Bot Layer (separate PM2 processes):
    Discord/Telegram → ai-engine.ts
        │
        ├── 14 OSINT tools → Neo4j API
        ├── BNDES API (external)
        ├── Querido Diário API (external)
        └── Redis (conversation memory)
```

---

## Comparison with Big Tech Approaches

| Company | Scale | Stack | Our Equivalent |
|---------|-------|-------|----------------|
| **LinkedIn** (connections) | 1B nodes, 10B edges | Espresso + Voldemort KV cache | Neo4j + Redis |
| **Facebook TAO** (social graph) | 3T+ reads/day | MySQL + memcache shards | Neo4j + Redis |
| **Palantir Gotham** (OSINT) | 100M+ entities | Proprietary graph + Cassandra | Neo4j + CNPJ data |
| **Google KG** (knowledge graph) | 1T+ triples | Spanner + custom graph engine | Neo4j GDS |
| **Twitter/X** (follows) | 800M nodes | MySQL + Redis + Cassandra | Neo4j + Redis |

**Key insight:** None of these companies invented magic. They all use the same fundamentals:
1. Index everything you query
2. Cache hot data aggressively
3. Never scan full datasets
4. Paginate all results
5. Bound all traversals

We can implement all 5 with what we have.

---

## Immediate Action Plan (After ETL Completes)

```
1. bash /opt/egos_inteligencia/neo4j-memory-upgrade.sh   # Update .env
2. cd /opt/egos_inteligencia/infra && docker compose -f docker-compose.prod.yml up -d neo4j  # Restart with 16G heap
3. bash /opt/egos_inteligencia/post-etl-optimize.sh       # Create all indexes
4. curl http://217.216.95.126/api/v1/public/meta  # Verify 55M+ nodes
5. curl "http://217.216.95.126/api/v1/public/graph/company/62232140000139"  # Test Patense CNPJ
6. Add Redis to docker-compose.prod.yml        # Phase 7.1
```

---

## Expected Impact After Optimization

| Action | Latency Improvement | Effort |
|--------|-------------------|--------|
| pagecache=22G | **10-100x** | 5 min |
| heap=16G | **2-5x** | 5 min |
| B-tree indexes | **1000x** for exact lookup | 15 min |
| Full-text indexes | Enables name search | 10 min |
| Redis cache | **10x** for repeat queries | 2h |
| Query optimization | **2-10x** per query | ongoing |

**Total time to implement layers 0-1: 30 minutes.**
**Total expected speedup: 1000x for common CNPJ lookups.**

---

*"Performance isn't magic. It's RAM, indexes, and bounded queries. The same fundamentals that power Google, LinkedIn, and Palantir."*
