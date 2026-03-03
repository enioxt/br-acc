// Gather exposure metrics for a given entity
// Aggregates across SAME_AS equivalent Person nodes
MATCH (e)
WHERE elementId(e) = $entity_id
  AND (e:Person OR e:Company OR e:Contract OR e:Sanction OR e:Election
       OR e:Amendment OR e:Finance OR e:Embargo OR e:Health OR e:Education
       OR e:Convenio OR e:LaborStats OR e:PublicOffice)
WITH e, labels(e) AS lbls
// Collect equivalent nodes: self + SAME_AS neighbors (up to 2 hops for chains)
OPTIONAL MATCH (e)-[:SAME_AS*1..2]-(other)
WITH e, lbls, collect(DISTINCT other) AS others
WITH e, lbls, [e] + others AS equivs
// Count all connections from any equivalent (exclude SAME_AS links)
UNWIND equivs AS eq
OPTIONAL MATCH (eq)-[r]-(connected) WHERE type(r) <> 'SAME_AS'
WITH e, lbls, equivs,
     count(r) AS connection_count,
     collect(DISTINCT
       CASE
         WHEN connected:Contract THEN 'transparencia'
         WHEN connected:Sanction THEN 'ceis_cnep'
         WHEN connected:Election THEN 'tse'
         WHEN connected:Health THEN 'cnes'
         WHEN connected:Finance THEN 'pgfn'
         WHEN connected:Embargo THEN 'ibama'
         WHEN connected:Education THEN 'inep'
         WHEN connected:Convenio THEN 'transferegov'
         WHEN connected:LaborStats THEN 'rais'
         WHEN connected:Amendment THEN 'transparencia'
         WHEN connected:Company THEN 'cnpj'
         WHEN connected:Person THEN 'cnpj'
         ELSE 'cnpj'
       END
     ) AS source_list
// Contract volume across all equivalents
UNWIND equivs AS eq2
OPTIONAL MATCH (eq2)-[:VENCEU]->(c:Contract)
WITH e, lbls, equivs, connection_count, source_list,
     COALESCE(sum(c.value), 0) AS contract_volume
// Donation volume across all equivalents
UNWIND equivs AS eq3
OPTIONAL MATCH (eq3)-[:DOOU]->(d)
WITH e, lbls, equivs, connection_count, source_list, contract_volume,
     COALESCE(sum(d.valor), 0) AS donation_volume
// Debt/loan volume across all equivalents
UNWIND equivs AS eq4
OPTIONAL MATCH (eq4)-[:RECEBEU_EMPRESTIMO|DEVE]->(f:Finance)
WITH e, lbls, equivs, connection_count, source_list, contract_volume, donation_volume,
     COALESCE(sum(f.value), 0) AS debt_loan_volume
// Pattern signals: sanctions, embargoes, contract count, amendments
UNWIND equivs AS eq5
OPTIONAL MATCH (eq5)-[:SANCIONADA]->(s:Sanction)
WITH e, lbls, equivs, connection_count, source_list, contract_volume, donation_volume, debt_loan_volume,
     count(DISTINCT s) AS sanction_count
UNWIND equivs AS eq6
OPTIONAL MATCH (eq6)-[:EMBARGADA]->(emb:Embargo)
WITH e, lbls, equivs, connection_count, source_list, contract_volume, donation_volume, debt_loan_volume, sanction_count,
     count(DISTINCT emb) AS embargo_count
UNWIND equivs AS eq7
OPTIONAL MATCH (eq7)-[:VENCEU]->(ct:Contract)
WITH e, lbls, equivs, connection_count, source_list, contract_volume, donation_volume, debt_loan_volume, sanction_count, embargo_count,
     count(DISTINCT ct) AS contract_count
UNWIND equivs AS eq8
OPTIONAL MATCH (eq8)-[:BENEFICIOU]->(am:Amendment)
WITH e, lbls, connection_count, source_list, contract_volume, donation_volume, debt_loan_volume, sanction_count, embargo_count, contract_count,
     count(DISTINCT am) AS amendment_count
RETURN
  elementId(e) AS entity_id,
  lbls AS entity_labels,
  connection_count,
  size(source_list) AS source_count,
  contract_volume + donation_volume + debt_loan_volume AS financial_volume,
  e.cnae_principal AS cnae_principal,
  e.role AS role,
  sanction_count,
  embargo_count,
  contract_count,
  amendment_count
