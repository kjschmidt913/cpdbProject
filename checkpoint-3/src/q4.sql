SELECT aom.officer_id, SUM(cp.payment + cp.fees_costs) total_cost
FROM allegation_officer_mapping aom, cases_payment cp, cops_ipracop ci, cops_cop cc, cops_casecop ccc, cases_case casecase
WHERE aom.case_id = ci.case_id AND
      ci.cop_id = cc.id AND
      cc.id = ccc.cop_id AND
      ccc.case_id = casecase.id AND
      casecase.id = cp.case_id
GROUP BY aom.officer_id
ORDER BY total_cost DESC;