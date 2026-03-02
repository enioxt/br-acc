MATCH (c:Company)
WHERE elementId(c) = $company_id
   OR c.cnpj = $company_identifier
   OR c.cnpj = $company_identifier_formatted
MATCH (c)-[:VENCEU]->(ct:Contract)
WHERE ct.value IS NOT NULL
  AND ct.value > 0
  AND ct.contract_id IS NOT NULL
  AND ct.contract_id <> ''
WITH c,
     collect({id: ct.contract_id, val: ct.value, date: ct.date}) AS contracts,
     count(*) AS total_contracts,
     sum(coalesce(ct.value, 0.0)) AS amount_total,
     min(ct.date) AS window_start,
     max(ct.date) AS window_end
WHERE total_contracts >= toInteger($pattern_benford_min_contracts)
WITH c, contracts, total_contracts, amount_total, window_start, window_end,
     [row IN contracts | toInteger(left(toString(toInteger(row.val)), 1))] AS leading_digits
WITH c, contracts, total_contracts, amount_total, window_start, window_end,
     leading_digits,
     [d IN range(1, 9) | {
       digit: d,
       observed: toFloat(size([x IN leading_digits WHERE x = d])) / total_contracts,
       expected: log(1.0 + 1.0 / toFloat(d)) / log(10.0)
     }] AS digit_analysis
WITH c, contracts, total_contracts, amount_total, window_start, window_end,
     reduce(mad = 0.0, row IN digit_analysis |
       mad + abs(row.observed - row.expected)
     ) / 9.0 AS benford_mad
WHERE benford_mad >= toFloat($pattern_benford_mad_threshold)
WITH c, total_contracts, amount_total, window_start, window_end, benford_mad,
     [row IN contracts | row.id] AS all_ids
WITH c, total_contracts, amount_total, window_start, window_end, benford_mad,
     [x IN all_ids WHERE x IS NOT NULL AND x <> ''] AS evidence_refs
WHERE size(evidence_refs) > 0
RETURN 'benford_contract_values' AS pattern_id,
       c.cnpj AS cnpj,
       c.razao_social AS company_name,
       toFloat(benford_mad * 1000) AS risk_signal,
       amount_total AS amount_total,
       window_start AS window_start,
       window_end AS window_end,
       evidence_refs[0..toInteger($pattern_max_evidence_refs)] AS evidence_refs,
       size(evidence_refs) AS evidence_count
