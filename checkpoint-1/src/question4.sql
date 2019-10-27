-- create a catalog of current officers with their unit and salary
-- Used for Checkpoint 1 regrade

DROP TABLE salary_analysis, highest_salary,commanders;

-- get salary and unit info
CREATE TABLE salary_analysis AS (SELECT o.id officer_id, o.complaint_percentile complaint_percentile, pu.id unit_id, pu.unit_name, pu.description, salary
FROM data_officer o, data_officerhistory oh, data_policeunit pu, data_salary s
WHERE o.id = oh.officer_id AND oh.unit_id = pu.id AND s.officer_id = o.id
AND oh.end_date IS NULL AND pu.active AND o.resignation_date IS NULL);

-- find the max salary per unit
CREATE TABLE highest_salary AS (
       SELECT unit_id, max(salary) as max_unit_salary
       FROM salary_analysis
       GROUP BY unit_id);

-- get the officer with the max salary, who is probably the commander
CREATE TABLE commanders AS (SELECT officer_id, unit_id, unit_name, description, complaint_percentile
FROM salary_analysis s
WHERE salary = (SELECT max_unit_salary FROM highest_salary hs WHERE hs.unit_id = s.unit_id));

-- get commanders, their unit info, the number of officer in each unit, the average complaint percentile per unit, and
-- the commander's complaint percentile
-- only do this for active officers
SELECT commanders.unit_id, COUNT(d.officer_id) AS number_of_officers, unit_name, description, commanders.complaint_percentile AS supervisor_complaint_percentile,
       AVG(o.complaint_percentile) as avg_unit_complaint_percentile
FROM commanders
INNER JOIN data_officerhistory d on commanders.unit_id = d.unit_id
INNER  JOIN data_officer o on d.officer_id = o.id
WHERE active = 'Yes'
GROUP BY commanders.unit_id, commanders.unit_name, description, commanders.complaint_percentile
ORDER BY COUNT(d.officer_id) DESC;