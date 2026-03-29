# 📥 Guia Completo de Download de Dados Públicos

> **Última atualização:** 2026-03-02
> **Status do grafo:** 180k+ nós | 10+ datasets carregados
> **Servidor:** 204.168.217.125 (Hetzner VPS)

---

## ⚡ Resumo Rápido — Como baixar com aria2

```bash
# Instalar aria2 (se não tiver)
sudo apt install aria2

# Download básico com resume (para/volta automaticamente)
aria2c -c -x4 -d ~/Downloads/bracc-data "URL_DO_ARQUIVO"

# Se o PC desligar, rode o MESMO comando — ele retoma de onde parou!
# O -c (--continue) é a mágica.

# Download múltiplos arquivos de uma lista
aria2c -c -x4 -i lista_urls.txt -d ~/Downloads/bracc-data

# Rodar aria2 como daemon (para extensão Chrome interceptar downloads)
aria2c --enable-rpc --rpc-listen-port=6800 --rpc-allow-origin-all \
  --daemon=true --dir=~/Downloads/bracc-data --continue=true \
  --max-connection-per-server=4
```

### 🔄 Persistência de Download (PC desligou?)

| Ferramenta | Comportamento |
|---|---|
| **aria2c -c** | Retoma automaticamente. Rode o mesmo comando de novo. |
| **tmux no servidor** | `tmux new -s download` → rode o script → `Ctrl+B D` para desconectar. Volta com `tmux attach -t download` |
| **Chrome nativo** | ❌ NÃO retoma. Use aria2 ou extensão "Aria2 Explorer". |

---

## 📊 Datasets — Status e Links

### ✅ JÁ CARREGADOS NO GRAFO (180k+ nós)

| # | Dataset | Registros | Fonte | Status |
|---|---|---|---|---|
| 1 | **CEIS** (Empresas Sancionadas) | 22.000 | Portal Transparência | ✅ Neo4j |
| 2 | **CNEP** (Entidades Punidas) | 1.500 | Portal Transparência | ✅ Neo4j |
| 3 | **PEP** (Pessoas Expostas Politicamente) | 133.859 | Portal Transparência | ✅ ETL rodando |
| 4 | **CEAF** (Servidores Expulsos) | 4.131 | Portal Transparência | ✅ ETL rodando |
| 5 | **CEPIM** (ONGs Impedidas) | 3.590 | Portal Transparência | ✅ ETL rodando |
| 6 | **Acordos de Leniência** | 146 | Portal Transparência | ✅ ETL rodando |
| 7 | **CPGF** (Cartão Gov Federal) | 9.679 | Portal Transparência | ✅ ETL rodando |
| 8 | **Viagens a Serviço** | 14.247 | Portal Transparência | ✅ ETL rodando |
| 9 | **OpenSanctions** | 4.1M entidades | opensanctions.org | 🔄 ETL rodando |
| 10 | **ICIJ Offshore** | 73MB | icij.org | ✅ Baixado, ETL pendente |

### ✅ BAIXADOS, AGUARDANDO ETL

| # | Dataset | Tamanho | Download |
|---|---|---|---|
| 11 | **TSE Candidaturas 2022** | 4.2MB | `aria2c -c -x4 "https://cdn.tse.jus.br/estatistica/sead/odsele/consulta_cand/consulta_cand_2022.zip"` |
| 12 | **TSE Candidaturas 2024** | 61MB | `aria2c -c -x4 "https://cdn.tse.jus.br/estatistica/sead/odsele/consulta_cand/consulta_cand_2024.zip"` |
| 13 | **TSE Prestação de Contas 2022** | 375MB | `aria2c -c -x4 "https://cdn.tse.jus.br/estatistica/sead/odsele/prestacao_contas/prestacao_de_contas_eleitorais_candidatos_2022.zip"` |
| 14 | **TSE Bens de Candidatos 2022** | 5.3MB | `aria2c -c -x4 "https://cdn.tse.jus.br/estatistica/sead/odsele/bem_candidato/bem_candidato_2022.zip"` |

### 🔄 EM DOWNLOAD / MANUAL

| # | Dataset | Tamanho | Como baixar |
|---|---|---|---|
| 15 | **CNPJ** (Receita Federal) | ~25GB | **Manual:** https://arquivos.receitafederal.gov.br/index.php/s/YggdBLfdninEJX9 |

### ❌ FALTAM BAIXAR (Prioridade)

#### ⭐⭐⭐ Alta Prioridade

| # | Dataset | Tamanho | Download automático |
|---|---|---|---|
| 16 | **TSE Doações 2024** | ~400MB | `aria2c -c -x4 "https://cdn.tse.jus.br/estatistica/sead/odsele/prestacao_contas/prestacao_de_contas_eleitorais_candidatos_2024.zip"` |
| 17 | **TSE Filiação Partidária** | ~500MB | `aria2c -c -x4 "https://cdn.tse.jus.br/estatistica/sead/odsele/filiacao_partidaria/filiacao_partidaria_2024.zip"` |
| 18 | **DataJud CNJ** (80M+ processos) | API | `bash scripts/download-datajud.sh tjsp` (ver seção abaixo) |
| 19 | **SICONV/Plataforma+Brasil** | ~2GB | `aria2c -c -x4 "http://plataformamaisbrasil.gov.br/images/docs/CGSIS/csv/siconv_convenio.csv.zip"` |
| 20 | **PNCP** (Compras.gov) | API | https://pncp.gov.br/api/consulta/v1/contratacoes |

#### ⭐⭐ Média Prioridade

| # | Dataset | Tamanho | Download |
|---|---|---|---|
| 21 | **Câmara Deputados** | ~50MB | `aria2c -c -x4 "https://dadosabertos.camara.leg.br/arquivos/deputados/csv/deputados.csv"` |
| 22 | **Câmara Despesas** | ~200MB/ano | `aria2c -c -x4 "https://dadosabertos.camara.leg.br/arquivos/despesas/csv/Ano-2024.csv"` |
| 23 | **Senado Federal** | ~100MB | `aria2c -c -x4 "https://www12.senado.leg.br/dados-abertos/arquivos/dados-abertos-senado/SenadorArquivos.csv"` |
| 24 | **CEAP Senado** (Cota Parlamentar) | ~50MB | `aria2c -c -x4 "https://www12.senado.leg.br/dados-abertos/arquivos/dados-abertos-ceaps/CEAPS.csv"` |
| 25 | **BCB** (Banco Central) | API | https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/odata/ |
| 26 | **Querido Diário** (5.570+ municípios) | API | Já integrado no bot via API queridodiario.ok.org.br |

#### ⭐ Baixa Prioridade (Grandes)

| # | Dataset | Tamanho | Nota |
|---|---|---|---|
| 27 | **RAIS** (Emprego formal) | ~20GB | ftp://ftp.mtps.gov.br/pdet/microdados/ |
| 28 | **CAGED** (Admissões/demissões) | ~5GB | ftp://ftp.mtps.gov.br/pdet/microdados/ |
| 29 | **DataSUS** (Saúde) | ~50GB | https://datasus.saude.gov.br/transferencia-de-arquivos |
| 30 | **INEP** (Educação/ENEM/Censo) | ~10GB | https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/microdados |
| 31 | **IBAMA** (Autos de infração) | ~500MB | https://dadosabertos.ibama.gov.br/ |
| 32 | **SICONFI** (Finanças públicas) | ~2GB | https://siconfi.tesouro.gov.br/siconfi/pages/public/consulta_finbra/finbra_list.jsf |
| 33 | **Cadastro de Expulsões CGU** | API | https://api.portaldatransparencia.gov.br/ |

---

## 🏛️ DataJud CNJ — 80M+ Processos Judiciais

A API do DataJud é baseada em **Elasticsearch** e permite consultar processos de TODOS os tribunais do Brasil.

### API Key (pública, pode mudar)
```
Authorization: APIKey cDZHYzlZa0JadVREZDJCendQbXY6SkJlTzNjLV9TRENyQk1RdnFKZGRQdw==
```

### Endpoints por Tribunal

```
Base: https://api-publica.datajud.cnj.jus.br

Superiores:
  TST  → /api_publica_tst/_search
  TSE  → /api_publica_tse/_search
  STJ  → /api_publica_stj/_search
  STM  → /api_publica_stm/_search

Federal (TRF1-6):
  TRF1 → /api_publica_trf1/_search
  TRF2 → /api_publica_trf2/_search
  TRF3 → /api_publica_trf3/_search
  TRF4 → /api_publica_trf4/_search
  TRF5 → /api_publica_trf5/_search
  TRF6 → /api_publica_trf6/_search

Trabalho (TRT1-24):
  TRT1..TRT24 → /api_publica_trt{N}/_search

Estadual (27 TJs):
  TJAC → /api_publica_tjac/_search
  TJAL → /api_publica_tjal/_search
  TJAM → /api_publica_tjam/_search
  ...até...
  TJTO → /api_publica_tjto/_search
```

### Exemplo de consulta (curl)
```bash
curl -X POST "https://api-publica.datajud.cnj.jus.br/api_publica_tjsp/_search" \
  -H "Authorization: APIKey cDZHYzlZa0JadVREZDJCendQbXY6SkJlTzNjLV9TRENyQk1RdnFKZGRQdw==" \
  -H "Content-Type: application/json" \
  -d '{
    "size": 3,
    "query": { "match": { "classe.nome": "Ação Penal" } },
    "sort": [{ "@timestamp": { "order": "desc" } }]
  }'
```

### Download em massa
```bash
# Um tribunal específico
bash scripts/download-datajud.sh tjsp /opt/bracc/data/datajud

# TODOS os tribunais (demorado — ~80M registros)
bash scripts/download-datajud.sh all /opt/bracc/data/datajud

# Listar tribunais disponíveis
bash scripts/download-datajud.sh list
```

---

## 📥 Script Master de Downloads (aria2)

```bash
# Baixar TUDO que é automático (TSE, OpenSanctions, ICIJ)
bash scripts/download-all-datasets.sh all

# Apenas TSE
bash scripts/download-all-datasets.sh tse

# Apenas sanções (CEIS, CNEP, PEP, CEAF, CEPIM, Leniência)
bash scripts/download-all-datasets.sh sanctions
```

---

## 🔗 Links Diretos para Download Manual

### Portal da Transparência (download manual — tem captcha)
- CEIS: https://portaldatransparencia.gov.br/sancoes/consulta?cadastro=1
- CNEP: https://portaldatransparencia.gov.br/sancoes/consulta?cadastro=2
- PEP: https://portaldatransparencia.gov.br/download-de-dados/pep
- CEAF: https://portaldatransparencia.gov.br/download-de-dados/ceaf
- CEPIM: https://portaldatransparencia.gov.br/download-de-dados/cepim
- Leniência: https://portaldatransparencia.gov.br/download-de-dados/acordos-leniencia
- CPGF: https://portaldatransparencia.gov.br/download-de-dados/cpgf
- Viagens: https://portaldatransparencia.gov.br/download-de-dados/viagens

### TSE (download automático ✅)
- Candidaturas: https://cdn.tse.jus.br/estatistica/sead/odsele/consulta_cand/
- Prestação de contas: https://cdn.tse.jus.br/estatistica/sead/odsele/prestacao_contas/
- Bens: https://cdn.tse.jus.br/estatistica/sead/odsele/bem_candidato/
- Filiação: https://cdn.tse.jus.br/estatistica/sead/odsele/filiacao_partidaria/

### CNPJ Receita Federal (download manual — ~25GB)
- https://arquivos.receitafederal.gov.br/index.php/s/YggdBLfdninEJX9

### OpenSanctions (download automático ✅)
- https://data.opensanctions.org/datasets/latest/default/entities.ftm.json

### ICIJ (download automático ✅)
- https://offshoreleaks-data.icij.org/offshoreleaks/csv/full-oldb.LATEST.zip

### Câmara dos Deputados
- https://dadosabertos.camara.leg.br/swagger/api.html

### Senado Federal
- https://www12.senado.leg.br/dados-abertos

### DataJud CNJ
- Wiki: https://datajud-wiki.cnj.jus.br/
- API: https://api-publica.datajud.cnj.jus.br/

---

*Documento mantido pelo EGOS Intelligence — github.com/enioxt/br-acc*
