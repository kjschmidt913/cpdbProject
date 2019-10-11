# Checkpoint 1

## Getting Started
Start running the CPDP database, then run our queries from either copying and pasting from here, or opening the sql files that correspond to the question. **Our queries need to be run in order**, as some build off of one another.

## Our Questions
* Which police units have average complaint_percentiles above the 75th percentile?
* Which commanders oversee these high complaint units from Q1? What are their personal complaint_percentiles?
* Of those commanders, what is the percentage of high complaints units they’ve overseen (over all units they’ve overseen)? How does this compare to the average commander?
* What is the average allegation_count for these units, and percentage of those allegations have been sustained? How does this compare to the average police unit?


## Queries

### Which police units have average complaint_percentiles above the 75th percentile?

First we ran a query to connect the data_officerhistory to data_policeunit:
```
SELECT data_officerhistory.unit_id, data_policeunit.unit_name, data_policeunit.description, data_officerhistory.officer_id
INTO units
FROM data_policeunit
INNER JOIN data_officerhistory on data_policeunit.id = data_officerhistory.unit_id
WHERE active = TRUE;
```
Then connected units to data_officer:
```
SELECT units.unit_id, units.unit_name, units.description, units.officer_id, data_officer.complaint_percentile
INTO officers_and_units
FROM data_officer
INNER JOIN units on officer_id = data_officer.id;
```
Then we averaged the percentiles of each unit, and showed only those above the 75th percentile:
```
SELECT unit_id, unit_name, description, AVG(complaint_percentile)
FROM officers_and_units
GROUP BY unit_id, unit_name, description
HAVING AVG(complaint_percentile) > 75;
```

### Which commanders oversee these high complaint units from Q1? What are their personal complaint_percentiles?

To figure out who the supervisor is of each unit, we saw on Piazza to look at the highest salary of the unit.

Looking at the unit numbers from the previous query, we looked up the salaries of those units and found the highest. We then looked at their complaint_percentiles:
```
SELECT MAX(salary) as max_salary, unit_id
FROM (
SELECT salary, m.officer_id, m.unit_id
FROM data_salary
INNER JOIN most_problematic_units_with_officers m on data_salary.officer_id = m.officer_id) as temp
GROUP BY unit_id;
```
*This isn't working as we thought it would. There are multiple officers within the same unit that have the same salary. So, we're unable to identify supervisors of units by their salary. We're looking for feedback on how to improve this query and determine supervisors within units.

### Of those commanders, what is the percentage of high complaints units they’ve overseen (over all units they’ve overseen)? How does this compare to the average commander?
```
code here
```

### What is the average allegation_count for these units, and percentage of those allegations have been sustained? How does this compare to the average police unit?

To find the average allegation count per unit:

```
SELECT AVG(allegation_count)
FROM data_officer
INNER JOIN officers_and_units oau on data_officer.id = oau.officer_id
GROUP BY unit_id, unit_name, description;
```
