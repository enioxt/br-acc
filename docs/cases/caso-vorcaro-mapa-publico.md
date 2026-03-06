# Caso Vorcaro / Banco Master — Mapa Público de Entidades e Sinais

> **TASK-074** | Criado: 2026-03-06
> **Regra:** Fatos = documento oficial ou registro público. Mídia = sinal/contexto, nunca conclusão.
> Nenhuma acusação. Nenhuma afirmação de culpa.

---

## 1. Fatos Confirmados (Fontes Oficiais)

### 1.1 BCB — Liquidação Extrajudicial

8 instituições liquidadas entre nov/2025 e fev/2026:

| # | Instituição | Data |
|---|-------------|------|
| 1 | Banco Master S/A | Nov/2025 |
| 2 | Banco Master de Investimento | Nov/2025 |
| 3 | Banco Letsbank (BlueBank) | Nov/2025 |
| 4 | Corretora do conglomerado | Nov/2025 |
| 5 | Will Financeira (Will Bank) | Jan/2026 |
| 6 | CBSF DTVM (ex-Reag Investimentos) | Jan/2026 |
| 7 | Banco Pleno (ex-Voiter) | Fev/2026 |
| 8 | Pleno DTVM | Fev/2026 |

**Fonte:** DOU, comunicados BCB (nov/2025, jan/2026, fev/2026).

### 1.2 CVM — PAS 19957.007976/2020-94

Em 02/12/2025, o Colegiado rejeitou unanimemente Termos de Compromisso:

| Acusado | Valor proposto |
|---------|----------------|
| Banco Master S.A. | R$ 5.940.000 |
| Viking Participações Ltda. | R$ 4.950.000 |
| Daniel Bueno Vorcaro | R$ 2.970.000 |
| Entre Investimentos e Participações Ltda. | R$ 4.950.000 |
| Antônio Carlos Freixo Júnior | R$ 2.475.000 |

**Total rejeitado:** ~R$ 21,3 milhões. O processo (aberto em 2020, 19 acusados) apura irregularidades na emissão e distribuição de cotas do FII Brazil Realty (BLZ11).

**Fonte:** https://www.gov.br/cvm/pt-br/assuntos/noticias/2025/cvm-rejeita-proposta-de-termo-de-compromisso-com-entre-investimentos-e-participacoes-ltda-banco-master-s-a-viking-participacoes-ltda-e-diretores

**Nota:** Rejeição de Termo de Compromisso ≠ condenação. Significa que o PAS prossegue.

### 1.3 Operação Compliance Zero

Deflagrada em nov/2025 em paralelo à liquidação. Investiga suspeitas relacionadas ao sistema financeiro.

**Fonte:** Comunicados oficiais; detalhes operacionais não confirmados em fonte primária nesta pesquisa.

---

## 2. Entidades Mapeadas (Registros Públicos)

### Pessoas Jurídicas

| Razão Social | Vínculo Confirmado |
|-------------|-------------------|
| Banco Master S.A. | Liquidação BCB; PAS CVM |
| Viking Participações Ltda. | PAS CVM |
| Entre Investimentos e Participações Ltda. | PAS CVM |
| Banco Pleno (ex-Voiter) | Liquidação BCB |

### Pessoas Físicas (citadas em docs oficiais)

| Nome | Citação |
|------|---------|
| Daniel Bueno Vorcaro | PAS CVM 19957.007976/2020-94 |
| Antônio Carlos Freixo Júnior | PAS CVM 19957.007976/2020-94 |

### Fundo de Investimento

| Nome | Código | Relevância |
|------|--------|-----------|
| Brazil Realty FII | BLZ11 | Objeto do PAS CVM |

---

## 3. Sinais e Contexto (Cobertura Jornalística)

> **ATENÇÃO:** Informações de imprensa. Incluídas como contexto, não como fatos confirmados.

- BCB teria apontado "insolvência financeira" e "suspeitas de fraudes contábeis" como motivação.
- Estadão (jan/2026): rede de empresas relacionadas aos executivos soma 2.500+ CNPJs (dados Receita Federal).
- FGC ativado para ressarcir investidores de CDBs — reportado como o maior acionamento da história do fundo.
- Grupo Fictor ofereceu aporte de R$ 3 bilhões antes da liquidação; oferta não prosseguiu.

---

## 4. Lacunas Investigativas

1. **CNPJs completos** — não foram verificados os CNPJs específicos das 8 instituições liquidadas no QSA público.
2. **Grafo Neo4j** — consulta ao grafo EGOS Inteligência não retornou resultados (query lenta; necessário indexar ou usar CNPJ direto).
3. **DataJud** — não foi verificada existência de processos judiciais (cível/criminal) relacionados.
4. **Diários Oficiais** — não foram cruzados com as entidades mapeadas.
5. **19 acusados CVM** — apenas 5 nomes são públicos; os demais 14 não foram identificados nesta pesquisa.
6. **FGC** — valores exatos de ressarcimento não confirmados em fonte primária.

---

## 5. Próximas Verificações

- [ ] Consultar CNPJs no QSA público (Receita Federal) para mapear estrutura societária completa
- [ ] Buscar entidades no grafo Neo4j por CNPJ (não por razão social — evitar full-text scan)
- [ ] Consultar DataJud por processos envolvendo as entidades mapeadas
- [ ] Cruzar com Diários Oficiais (Querido Diário) para publicações relacionadas
- [ ] Verificar se há sanções no CEIS/CNEP (Portal da Transparência) para as PJs
- [ ] Consultar licitações associadas às empresas no Portal de Compras
- [ ] Monitorar andamento do PAS CVM — decisão final pendente

---

## 6. Pontos Fracos Desta Análise

1. **Dependência de imprensa:** Seção 3 depende de cobertura jornalística. Se as fontes errarem, a análise herda o erro.
2. **Sem CNPJ verificado:** Nenhum CNPJ foi confirmado diretamente na Receita Federal nesta versão.
3. **Grafo incompleto:** Os dados de QSA no Neo4j podem não ter sido atualizados desde a liquidação (ETL parado em ~70%).
4. **Sem DataJud:** Ausência de cruzamento com o Judiciário é a maior lacuna.
5. **Temporal:** Dados coletados em 06/03/2026. Caso está em rápida evolução.

---

*Documento gerado automaticamente por EGOS Inteligência. Dados públicos, sem acusações, sem afirmações de culpa.*
