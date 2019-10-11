SELECT MAX(salary) as max_salary, unit_id
FROM (
SELECT salary, m.officer_id, m.unit_id
FROM data_salary
INNER JOIN most_problematic_units_with_officers m on data_salary.officer_id = m.officer_id) as temp
GROUP BY unit_id;