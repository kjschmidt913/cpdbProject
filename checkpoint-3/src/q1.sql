SELECT s.officer_id, s.unit_id, s.unit_name, s.description, s.complaint_percentile
FROM supervisors_and_complaint_percentiles s
WHERE s.officer_id IN (SELECT officer_id FROM allegation_commander_mapping)
GROUP BY s.officer_id, s.unit_id, s.unit_name, s.complaint_percentile, s.description
HAVING s.complaint_percentile > 75
ORDER BY s.complaint_percentile DESC;