DROP VIEW IF EXISTS officers_unit_settlement;
​
CREATE VIEW officers_unit_settlement AS (
SELECT aom.unit_id, aom.description, SUM(cp.payment + cp.fees_costs) as total_cost, AVG(cp.payment + cp.fees_costs)  as avg_cost, COUNT(aom.unit_id) as total_settlements
FROM allegation_officer_mapping aom, cases_payment cp, cops_ipracop ci, cops_cop cc, cops_casecop ccc, cases_case casecase
WHERE aom.case_id = ci.case_id AND
      ci.cop_id = cc.id AND
      cc.id = ccc.cop_id AND
      ccc.case_id = casecase.id AND
      casecase.id = cp.case_id
GROUP BY aom.unit_id, aom.description
ORDER BY avg_cost DESC);
​
SELECT * FROM officers_unit_settlement;