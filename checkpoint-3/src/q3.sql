SELECT sus.unit_id, sus.description, sacp.officer_id as supervisor_id, sacp.complaint_percentile as supervisor_complaint_percentile, AVG(o.complaint_percentile) as avg_unit_complaint_percentile
FROM supervisors_unit_settlement sus, supervisors_and_complaint_percentiles sacp, officers_and_units oau, cpdb.public.data_officer o
WHERE oau.officer_id = o.id AND
      oau.unit_id = sus.unit_id
GROUP BY sus.unit_id, sus.description, sacp.officer_id, sacp.complaint_percentile;