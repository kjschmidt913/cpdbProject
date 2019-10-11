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
**Run question1.sql or copy and paste the queries below**
<br><br>
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
**Run question2.sql or copy and paste the queries below**
<br><br>
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
**Run question3.sql or copy and paste the queries below**
<br><br>
We looked up the appropriate allegation data per officer, so we can associate it with the unit:
```
SELECT num_allegations, num_allegations_disciplined, oau.officer_id, oau.unit_id, oau.description, oau.unit_name
INTO num_allegations_per_officer
FROM officers_and_units oau
INNER JOIN (
   SELECT COUNT(allegation_id) AS num_allegations, COUNT(CASE WHEN disciplined THEN 1 END) AS num_allegations_disciplined, data_officerallegation.officer_id
FROM data_officerallegation
GROUP BY data_officerallegation.officer_id
    ) temp ON oau.officer_id = temp.officer_id;
```

Then we got the average allegations per unit, along with the total allegations per unit and relevant unit information:

```
SELECT temp.unit_id, temp.unit_name, temp.description, num_allegations, avg_num_allegations
FROM (
SELECT AVG(num_allegations) AS avg_num_allegations, unit_id, unit_name, description
FROM num_allegations_per_officer
GROUP BY unit_id, unit_name, description
ORDER BY avg_num_allegations DESC) as temp
INNER JOIN num_allegations_per_officer temp2 ON temp.unit_id = temp2.unit_id
GROUP BY temp.unit_id, temp.unit_name, temp.description, avg_num_allegations, num_allegations
ORDER BY avg_num_allegations DESC;
```

### What is the average allegation_count for these units, and percentage of those allegations have been sustained? How does this compare to the average police unit?
**Run question4.sql or copy and paste the queries below** 
<br><br>
To find the average allegation count per unit:

```
SELECT AVG(allegation_count)
FROM data_officer
INNER JOIN officers_and_units oau on data_officer.id = oau.officer_id
GROUP BY unit_id, unit_name, description;
```
