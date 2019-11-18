DROP TABLE IF EXISTS salary_analysis, highest_salary, commanders CASCADE;
​
-- get salary and unit info
CREATE TABLE salary_analysis AS (SELECT o.id officer_id, o.complaint_percentile complaint_percentile, pu.id unit_id, pu.unit_name, pu.description, salary
FROM data_officer o, data_officerhistory oh, data_policeunit pu, data_salary s
WHERE o.id = oh.officer_id AND oh.unit_id = pu.id AND s.officer_id = o.id
AND oh.end_date IS NULL AND pu.active AND o.resignation_date IS NULL);
​
-- find the max salary per unit
CREATE TABLE highest_salary AS (
       SELECT unit_id, max(salary) as max_unit_salary
       FROM salary_analysis
       GROUP BY unit_id);
​
-- get the officer with the max salary, who is probably the commander
CREATE TABLE commanders AS (SELECT officer_id, unit_id, unit_name, description, complaint_percentile
FROM salary_analysis s
WHERE salary = (SELECT max_unit_salary FROM highest_salary hs WHERE hs.unit_id = s.unit_id));
​
DROP TABLE IF EXISTS supervisors;
​
SELECT DISTINCT ON (unit_id) unit_id, unit_name, description, officer_id
INTO supervisors
FROM commanders;
​
SELECT *
FROM supervisors;
​
DROP TABLE IF EXISTS supervisors_and_complaint_percentiles;
​
CREATE TABLE supervisors_and_complaint_percentiles AS (
    SELECT officer_id, unit_id, unit_name, complaint_percentile, description
    FROM supervisors s, data_officer d
    WHERE s.officer_id = d.id
);

--Part 2:

DROP VIEW IF EXISTS allegation_officer_mapping;
​
CREATE VIEW allegation_officer_mapping AS
(
   SELECT DISTINCT oa.allegation_id, oa.officer_id, cm.case_id, c.unit_id, c.description
   FROM cpdb.public.data_officerallegation oa, cpdb.public.data_allegation a, case_map cm, commanders c
   WHERE oa.officer_id = c.officer_id AND
         oa.allegation_id = a.id AND
         a.id = cm.allegation_id
 );
​
​
SELECT * FROM allegation_officer_mapping;