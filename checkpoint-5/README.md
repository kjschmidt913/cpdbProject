# checkpoint-5

## Getting Started
To run our code for our machine learning questions, databricks workbook `file`, upload the html file to databricks. You'll also need to upload our data for these questions `csvs`.
We got this data through queries for our past checkpoints. If you'd like to see how we got it, you can find these queries at `queries`.

To run our code for our text analytics questions, upload the databricks workbook, `src/text_analytics.html` to databricks, as well as the csv `src/cpdb_public_allegation_all_info.csv`. 
<br>Our `src/cpdb_public_allegation_all_info` was created through the sql queries found in `src/text_analytics.sql`. Feel free to run these sql commands to get the data yourself.
<br>The `top_allegation_label_per_unit.csv` is the results of our text analytics questions that we'll be discussing in findings.

## Our questions
### Machine Learning
Can we predict a unit’s complaint percentile based on a supervisor’s complaint percentile?<br>
Can we predict how much a unit will cost the department in settlements based on a unit’s complaint percentile?

### Text Analytics
What is the top tag associated with allegations for supervisors above the 75th complaint percentile?<br>
What is the top tag associated with allegations for the units the supervisors oversee from the question above?
