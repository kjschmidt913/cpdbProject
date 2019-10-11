-- to be run after previous questions

-- get the appropriate allegation data per officer, so we can associate it with the unit
SELECT num_allegations, num_allegations_disciplined, oau.officer_id, oau.unit_id, oau.description, oau.unit_name
INTO num_allegations_per_officer
FROM officers_and_units oau
INNER JOIN (
   SELECT COUNT(allegation_id) AS num_allegations, COUNT(CASE WHEN disciplined THEN 1 END) AS num_allegations_disciplined, data_officerallegation.officer_id
FROM data_officerallegation
GROUP BY data_officerallegation.officer_id
    ) temp ON oau.officer_id = temp.officer_id;


-- get the average allegations per unit, along with the total allegations per unit and relevant unit information
SELECT temp.unit_id, temp.unit_name, temp.description, num_allegations, avg_num_allegations
FROM (
SELECT AVG(num_allegations) AS avg_num_allegations, unit_id, unit_name, description
FROM num_allegations_per_officer
GROUP BY unit_id, unit_name, description
ORDER BY avg_num_allegations DESC) as temp
INNER JOIN num_allegations_per_officer temp2 ON temp.unit_id = temp2.unit_id
GROUP BY temp.unit_id, temp.unit_name, temp.description, avg_num_allegations, num_allegations
ORDER BY avg_num_allegations DESC;