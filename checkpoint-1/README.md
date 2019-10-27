# Checkpoint 1

## Getting Started
Start running the CPDP database, then run our queries from either copying and pasting from here, or opening the sql files that correspond to the question. **Our queries need to be run in order**, as some build off of one another.

## Our Questions
* Which police units have average complaint_percentiles above the 75th percentile?
* Which commanders have complaint_percentiles above the 75th percentile?
* Across all units, what is the average complaint percentile on a per-unit and per-rank basis?
* How do unit sizes relate to complaint_percentiles of units and their commanding officers?


## Queries

### Which police units have average complaint_percentiles above the 75th percentile?
**Run question1.sql or copy and paste the queries below**
<br><br>
```
SELECT data_officerhistory.unit_id, data_policeunit.unit_name, data_policeunit.description, data_officerhistory.officer_id
INTO units
FROM data_policeunit
INNER JOIN data_officerhistory on data_policeunit.id = data_officerhistory.unit_id
WHERE active = TRUE;
SELECT units.unit_id, units.unit_name, units.description, units.officer_id, data_officer.complaint_percentile
INTO officers_and_units
FROM data_officer
INNER JOIN units on officer_id = data_officer.id;
SELECT unit_id, unit_name, description, AVG(complaint_percentile)
FROM officers_and_units
GROUP BY unit_id, unit_name, description
HAVING AVG(complaint_percentile) > 75;
```


### Which commanders have complaint_percentiles above the 75th percentile?
**Run question2.sql or copy and paste the queries below**
<br><br>



### Across all units, what is the average complaint percentile on a per-unit and per-rank basis?
**Run question3.sql or copy and paste the queries below**
<br><br>



### How do unit sizes relate to complaint_percentiles of units and their commanding officers?
**Run question4.sql or copy and paste the queries below** 
<br><br>
