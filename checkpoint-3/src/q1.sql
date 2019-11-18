DROP TABLE IF EXISTS supervisors_and_complaint_percentiles;

CREATE TEMP TABLE supervisors_and_complaint_percentiles AS (
    SELECT officer_id, unit_id, unit_name, complaint_percentile
    FROM supervisors s, data_officer d
    WHERE s.officer_id = d.id
);
​
SELECT s.officer_id, s.unit_id, s.unit_name, s.complaint_percentile
FROM supervisors_and_complaint_percentiles s
WHERE s.officer_id IN (SELECT officer_id FROM allegation_officer_mapping)
GROUP BY s.officer_id, s.unit_id, s.unit_name, s.complaint_percentile
HAVING s.complaint_percentile > 75;