// Ingestion Priority Gates (Phase-by-Phase)
// Use in shadow before promote.

// --- Freshness ---
MATCH (b:Bid)
WHERE b.source = 'pncp' AND b.date =~ '\\d{4}-\\d{2}-\\d{2}'
RETURN max(date(b.date)) AS pncp_max_date;

MATCH (c:Contract)
WHERE c.source = 'comprasnet' AND c.date =~ '\\d{4}-\\d{2}-\\d{2}'
RETURN max(date(c.date)) AS comprasnet_max_date;

// --- CPMI/CPI coverage ---
MATCH (i:Inquiry)
RETURN count(i) AS inquiry_count;

MATCH (i:Inquiry)
WHERE toUpper(coalesce(i.name, '') + ' ' + coalesce(i.subject, '')) CONTAINS 'INSS'
   OR toUpper(coalesce(i.name, '') + ' ' + coalesce(i.subject, '')) CONTAINS 'PREVID'
RETURN count(i) AS inquiry_inss_or_previd_count;

MATCH (r:InquiryRequirement)
RETURN count(r) AS inquiry_requirement_count;

MATCH (:Inquiry)-[rel:TEM_REQUERIMENTO]->(:InquiryRequirement)
RETURN count(rel) AS inquiry_requirement_rel_count;

// --- Date sanity ---
MATCH (c:Contract)
WHERE c.date =~ '\\d{4}-\\d{2}-\\d{2}'
  AND date(c.date) > date() + duration('P365D')
RETURN count(c) AS absurd_future_contract_dates;

MATCH (c:MunicipalContract)
WHERE c.signed_at =~ '\\d{4}-\\d{2}-\\d{2}'
  AND date(c.signed_at) > date() + duration('P365D')
RETURN count(c) AS absurd_future_municipal_contract_dates;

MATCH (b:MunicipalBid)
WHERE b.published_at =~ '\\d{4}-\\d{2}-\\d{2}'
  AND date(b.published_at) > date() + duration('P365D')
RETURN count(b) AS absurd_future_municipal_bid_dates;

// --- Querido Diario quality ---
MATCH (a:MunicipalGazetteAct)
RETURN count(a) AS municipal_gazette_act_count;

MATCH (a:MunicipalGazetteAct)
RETURN count(a) AS total_acts,
       sum(CASE WHEN a.text_status = 'available' THEN 1 ELSE 0 END) AS available_text_acts;

MATCH (:Company)-[r:MENCIONADA_EM]->(:MunicipalGazetteAct)
RETURN count(r) AS municipal_gazette_mention_count;

// --- Identity integrity (must remain green) ---
MATCH (p:Person) WHERE p.cpf CONTAINS '*' RETURN count(p) AS person_cpf_masked;

MATCH (p:Person)
WHERE replace(replace(p.cpf, '.', ''), '-', '') =~ '\\d{14}'
RETURN count(p) AS person_cpf_14_digits;
