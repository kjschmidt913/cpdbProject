DROP TABLE IF EXISTS allegation_keys;
CREATE TABLE allegation_keys AS (SELECT id, CASE WHEN crid LIKE 'C%' THEN SUBSTRING(crid, 2)::integer
   ELSE crid::integer END crid, summary
   FROM data_allegation);

DROP TABLE IF EXISTS allegation_labels;
CREATE TEMP TABLE allegation_labels AS(
SELECT dt.allegation_id, nudity_penetration, sexual_harassment_remarks, sexual_humiliation_extortion_or_sex_work, tasers, trespass, racial_slurs, planting_drugs_guns, neglect_of_duty, irrational_aggressive_unstable, searching_arresting_minors
FROM allegation_keys ak, document_tags_all dt
WHERE ak.crid = dt.allegation_id AND nudity_penetration IS NOT NULL AND sexual_harassment_remarks IS NOT NULL AND sexual_humiliation_extortion_or_sex_work IS NOT NULL AND  tasers IS NOT NULL AND  trespass IS NOT NULL
    AND  racial_slurs IS NOT NULL AND  planting_drugs_guns IS NOT NULL AND  neglect_of_duty IS NOT NULL AND  irrational_aggressive_unstable IS NOT NULL AND  searching_arresting_minors IS NOT NULL);

DROP TABLE IF EXISTS officer_units;
CREATE TEMP TABLE officer_units AS (SELECT o.id officer_id, pu.id unit_id, pu.description
FROM data_officer o JOIN data_officerhistory doh ON o.id = doh.officer_id
     JOIN data_policeunit pu ON doh.unit_id = pu.id
WHERE doh.end_date IS NULL);

-- make a list of of allegations with their tags, then join with cops
DROP TABLE IF EXISTS allegation_all_info;
CREATE TABLE allegation_all_info AS(
SELECT a.id allegation_id, doa.officer_id, ou.unit_id, ou.description, nudity_penetration, sexual_harassment_remarks, sexual_humiliation_extortion_or_sex_work, tasers, trespass, racial_slurs, planting_drugs_guns, neglect_of_duty, irrational_aggressive_unstable, searching_arresting_minors
FROM data_allegation a JOIN allegation_keys ak ON a.id = ak.id
   JOIN allegation_labels al ON al.allegation_id = ak.crid
   JOIN data_officerallegation doa ON doa.allegation_id = a.id
   JOIN officer_units ou ON ou.officer_id = doa.officer_id);
SELECT * FROM allegation_all_info;

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

-- allegations for the supervisors only
DROP TABLE IF EXISTS allegation_supervisor_info;
CREATE TABLE allegation_supervisor_info AS(
    SELECT *
    FROM allegation_all_info aai
    WHERE aai.officer_id IN (SELECT officer_id FROM supervisors));
SELECT * FROM allegation_supervisor_info;