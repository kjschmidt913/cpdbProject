-- Q1: Can we predict a unit’s complaint percentile based on a supervisor’s complaint percentile?

DROP TABLE IF EXISTS units CASCADE;

CREATE TABLE units AS (
SELECT data_officerhistory.unit_id, data_policeunit.unit_name, data_policeunit.description, data_officerhistory.officer_id
FROM data_policeunit
INNER JOIN data_officerhistory on data_policeunit.id = data_officerhistory.unit_id
WHERE data_policeunit.active = TRUE and data_officerhistory.end_date IS NULL);

DROP TABLE IF EXISTS officers_and_units CASCADE;

 -- connect units to data_officer
CREATE TABLE officers_and_units AS(
SELECT units.unit_id, units.unit_name, units.description, units.officer_id, data_officer.complaint_percentile
FROM data_officer
INNER JOIN units on officer_id = data_officer.id);

SELECT * FROM officers_and_units;

-- create a catalog of current officers with their unit and salary
DROP TABLE IF EXISTS salary_analysis, highest_salary, commanders, supervisors CASCADE;

CREATE TEMP TABLE salary_analysis AS (SELECT o.id officer_id, pu.id unit_id, pu.unit_name, pu.description, salary
FROM data_officer o, data_officerhistory oh, data_policeunit pu, data_salary s
WHERE o.id = oh.officer_id AND oh.unit_id = pu.id AND s.officer_id = o.id
AND oh.end_date IS NULL AND pu.active AND o.resignation_date IS NULL);

CREATE TABLE highest_salary AS (
       SELECT unit_id, unit_name, description, max(salary) as max_unit_salary
       FROM salary_analysis
       GROUP BY unit_id, unit_name, description);

CREATE TABLE commanders AS (SELECT officer_id, unit_id, unit_name, description
FROM salary_analysis s
WHERE salary = (SELECT max_unit_salary FROM highest_salary hs WHERE hs.unit_id = s.unit_id));

SELECT DISTINCT ON (unit_id) unit_id, unit_name, description, officer_id
INTO supervisors
FROM commanders;

SELECT *
FROM supervisors;

DROP TABLE IF EXISTS supervisors_and_complaint_percentiles CASCADE;

CREATE TABLE supervisors_and_complaint_percentiles AS (
    SELECT officer_id, unit_id, unit_name, description, complaint_percentile as sup_complaint_percentile
    FROM supervisors s, data_officer d
    WHERE s.officer_id = d.id
);

SELECT * FROM supervisors_and_complaint_percentiles;

DROP TABLE IF EXISTS units_and_complaint_percentiles CASCADE;

CREATE TABLE units_and_complaint_percentiles AS (
    SELECT unit_id, unit_name, description, avg(complaint_percentile) as unit_complaint_percentile
    FROM officers_and_units
    GROUP BY unit_id, unit_name, description
);

SELECT * FROM units_and_complaint_percentiles;

-- *****FINAL TABLE for Q1
DROP TABLE IF EXISTS all_complaint_percentiles CASCADE;
CREATE TABLE all_complaint_percentiles AS (
    SELECT sacp.unit_id, sacp.unit_name, sacp.description, uacp.unit_complaint_percentile, sacp.sup_complaint_percentile
    FROM supervisors_and_complaint_percentiles as sacp, units_and_complaint_percentiles as uacp
    WHERE sacp.unit_id = uacp.unit_id AND sacp.description = uacp.description
);
SELECT * FROM all_complaint_percentiles;


-- Q2: Can we predict how much a unit will cost the department in settlements based on a unit’s complaint percentile?
DROP VIEW IF EXISTS allegation_officer_mapping CASCADE;
CREATE VIEW allegation_officer_mapping AS
(
   SELECT DISTINCT oa.allegation_id, oa.officer_id, cm.case_id, oau.unit_id, oau.description
   FROM cpdb.public.data_officerallegation oa, cpdb.public.data_allegation a, case_map cm, officers_and_units oau
   WHERE oa.officer_id = oau.officer_id AND
         oa.allegation_id = a.id AND
         a.id = cm.allegation_id
 );

SELECT * FROM allegation_officer_mapping;


DROP VIEW IF EXISTS allegation_supervisor_mapping CASCADE;
CREATE VIEW allegation_supervisor_mapping AS
(
   SELECT DISTINCT oa.allegation_id, oa.officer_id, cm.case_id, s.unit_id, s.description
   FROM cpdb.public.data_officerallegation oa, cpdb.public.data_allegation a, case_map cm, supervisors s
   WHERE oa.officer_id = s.officer_id AND
         oa.allegation_id = a.id AND
         a.id = cm.allegation_id
 );
SELECT * FROM allegation_supervisor_mapping;

-- average supervisor (no dups) settlment
DROP VIEW IF EXISTS supervisors_unit_settlement CASCADE;
CREATE VIEW supervisors_unit_settlement AS (
SELECT asm.officer_id as supervisor_id, asm.unit_id, asm.description, SUM(cp.payment + cp.fees_costs) as sup_total_cost, AVG(cp.payment + cp.fees_costs)  as sup_avg_cost, COUNT(asm.officer_id) as sup_total_settlements
FROM allegation_supervisor_mapping asm, cases_payment cp, cops_ipracop ci, cops_cop cc, cops_casecop ccc, cases_case casecase
WHERE asm.case_id = ci.case_id AND
      ci.cop_id = cc.id AND
      cc.id = ccc.cop_id AND
      ccc.case_id = casecase.id AND
      casecase.id = cp.case_id
GROUP BY asm.officer_id, asm.unit_id, asm.description
ORDER BY sup_total_cost DESC);
​
SELECT * FROM supervisors_unit_settlement;


-- unit settlement info
DROP VIEW IF EXISTS officers_unit_settlement;
CREATE VIEW officers_unit_settlement AS (
SELECT aom.unit_id, aom.description, SUM(cp.payment + cp.fees_costs) as unit_total_cost, AVG(cp.payment + cp.fees_costs)  as unit_avg_cost, COUNT(aom.unit_id) as unit_total_settlements
FROM allegation_officer_mapping aom, cases_payment cp, cops_ipracop ci, cops_cop cc, cops_casecop ccc, cases_case casecase
WHERE aom.case_id = ci.case_id AND
      ci.cop_id = cc.id AND
      cc.id = ccc.cop_id AND
      ccc.case_id = casecase.id AND
      casecase.id = cp.case_id
GROUP BY aom.unit_id, aom.description
ORDER BY unit_avg_cost DESC);
SELECT * FROM officers_unit_settlement;

-- ******FINAL TABLE all settlement info for Q4
DROP TABLE IF EXISTS all_settlement_info;
CREATE TABLE all_settlement_info AS (
    SELECT ous.unit_id, ous.description, unit_total_cost, unit_avg_cost, unit_total_settlements, sup_total_cost, sup_avg_cost, sup_total_settlements, sus.supervisor_id, uacp.unit_complaint_percentile
    FROM officers_unit_settlement ous, supervisors_unit_settlement sus, units_and_complaint_percentiles uacp
    WHERE ous.unit_id = sus.unit_id AND ous.description = sus.description AND uacp.unit_id = ous.unit_id
);
SELECT * FROM all_settlement_info;
