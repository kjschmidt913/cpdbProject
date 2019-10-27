-- DROP TABLE units, officers_and_units, most_problematic_units;

/* Conenct data_officerhistory to data_policeunit */
SELECT data_officerhistory.unit_id, data_policeunit.unit_name, data_policeunit.description, data_officerhistory.officer_id
INTO units
FROM data_policeunit
INNER JOIN data_officerhistory on data_policeunit.id = data_officerhistory.unit_id
WHERE active = TRUE;

/* Connect units to data_officer */
SELECT units.unit_id, units.unit_name, units.description, units.officer_id, data_officer.complaint_percentile
INTO officers_and_units
FROM data_officer
INNER JOIN units on officer_id = data_officer.id;

/* Calculate average complaint_percentile and filter by avg_complaint_percentile > 75% */
SELECT unit_id, unit_name, description, AVG(complaint_percentile)
INTO most_problematic_units
FROM officers_and_units
GROUP BY unit_id, unit_name, description
HAVING AVG(complaint_percentile) > 75;

SELECT * FROM most_problematic_units;