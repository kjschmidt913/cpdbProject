-- create a catalog of current officers with their unit and salary
DROP TABLE salary_analysis, highest_salary, commanders, supervisors;

CREATE TEMP TABLE salary_analysis AS (SELECT o.id officer_id, pu.id unit_id, pu.unit_name, salary
FROM data_officer o, data_officerhistory oh, data_policeunit pu, data_salary s
WHERE o.id = oh.officer_id AND oh.unit_id = pu.id AND s.officer_id = o.id
AND oh.end_date IS NULL AND pu.active AND o.resignation_date IS NULL);

CREATE TEMP TABLE highest_salary AS (
       SELECT unit_id, max(salary) as max_unit_salary
       FROM salary_analysis
       GROUP BY unit_id);

CREATE TEMP TABLE commanders AS (SELECT officer_id, unit_id, unit_name
FROM salary_analysis s
WHERE salary = (SELECT max_unit_salary FROM highest_salary hs WHERE hs.unit_id = s.unit_id));

SELECT DISTINCT ON (unit_id) unit_id, unit_name, officer_id
INTO supervisors
FROM commanders;

DROP TABLE supervisors_and_complaint_percentiles;

CREATE TEMP TABLE supervisors_and_complaint_percentiles AS (
    SELECT officer_id, unit_id, unit_name, complaint_percentile
    FROM supervisors s, data_officer d
    WHERE s.officer_id = d.id
);

SELECT s.officer_id, s.unit_id, s.unit_name, s.complaint_percentile
FROM supervisors_and_complaint_percentiles s, most_problematic_units m
WHERE s.unit_id = m.unit_id
