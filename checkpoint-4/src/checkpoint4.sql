/* Conenct data_officerhistory to data_policeunit */
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
    SELECT officer_id, unit_id, unit_name, description, complaint_percentile
    FROM supervisors s, data_officer d
    WHERE s.officer_id = d.id
);

-- checkpoint 4 question 1
DROP TABLE IF EXISTS supervisor_officer_coaccusals CASCADE;

CREATE TABLE supervisor_officer_coaccusals AS (
SELECT oau.officer_id as officer_id, oau.complaint_percentile as officer_complaint_percentile, oau.unit_id as officer_unit_id, oau.description as officer_unit_description, oau.unit_name as officer_unit_name,
       sacp.officer_id as supervisor_id, sacp.complaint_percentile as supervisor_complaint_percentile, sacp.unit_id as supervisor_unit_id, sacp.description as supervisor_unit_description, sacp.unit_name as supervisor_unit_name,
       doa1.allegation_id
FROM officers_and_units oau, supervisors_and_complaint_percentiles sacp, data_officerallegation doa1, data_officerallegation doa2
WHERE oau.officer_id = doa1.officer_id
AND sacp.officer_id = doa2.officer_id
AND doa1.allegation_id = doa2.allegation_id);

SELECT * FROM supervisor_officer_coaccusals;