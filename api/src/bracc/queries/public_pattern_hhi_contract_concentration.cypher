MATCH (c:Company)
WHERE elementId(c) = $company_id
   OR c.cnpj = $company_identifier
   OR c.cnpj = $company_identifier_formatted
MATCH (c)-[:VENCEU]->(ct:Contract)
WHERE ct.contracting_org IS NOT NULL
  AND trim(ct.contracting_org) <> ''
  AND ct.value IS NOT NULL
WITH c, ct.contracting_org AS org, sum(coalesce(ct.value, 0.0)) AS company_org_spend
CALL {
  WITH org
  MATCH (:Company)-[:VENCEU]->(all_ct:Contract)
  WHERE all_ct.contracting_org = org
    AND all_ct.value IS NOT NULL
  RETURN sum(coalesce(all_ct.value, 0.0)) AS market_total
}
WITH c, org, company_org_spend, market_total
WHERE market_total > 0
WITH c,
     collect({org: org, share: company_org_spend / market_total}) AS share_rows,
     sum(company_org_spend) AS amount_total
WITH c,
     amount_total,
     share_rows,
     reduce(hhi = 0.0, row IN share_rows | hhi + (row.share * row.share)) AS hhi_raw
WHERE hhi_raw >= toFloat($pattern_hhi_threshold)
MATCH (c)-[:VENCEU]->(risk_ct:Contract)
WHERE risk_ct.contracting_org IN [row IN share_rows | row.org]
WITH c,
     hhi_raw,
     amount_total,
     collect(DISTINCT risk_ct.contract_id) AS contract_ids,
     min(risk_ct.date) AS window_start,
     max(risk_ct.date) AS window_end
WITH c,
     hhi_raw,
     amount_total,
     window_start,
     window_end,
     [x IN contract_ids WHERE x IS NOT NULL AND x <> ''] AS evidence_refs
WHERE size(evidence_refs) > 0
RETURN 'hhi_contract_concentration' AS pattern_id,
       c.cnpj AS cnpj,
       c.razao_social AS company_name,
       toFloat(hhi_raw * 10000) AS risk_signal,
       amount_total AS amount_total,
       window_start AS window_start,
       window_end AS window_end,
       evidence_refs[0..toInteger($pattern_max_evidence_refs)] AS evidence_refs,
       size(evidence_refs) AS evidence_count
