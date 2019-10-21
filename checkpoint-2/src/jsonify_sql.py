"""
jsonify_sql.py

written by Aristana Scourtas
updated last: 10/21/19

Tool to transform SQL query results for supervisor data into JSON to feed to our D3 visualization.
For Q2 from the relational analytics questions?

"""

import json
import psycopg2


def main():
    conn = psycopg2.connect("dbname=cpdb")
    cursor = conn.cursor()
    cursor.execute("""
                    CREATE TEMP TABLE salary_analysis AS (SELECT o.id officer_id, o.complaint_percentile complaint_percentile, 
                        pu.id unit_id, pu.unit_name, salary
                    FROM data_officer o, data_officerhistory oh, data_policeunit pu, data_salary s
                    WHERE o.id = oh.officer_id AND oh.unit_id = pu.id AND s.officer_id = o.id
                    AND oh.end_date IS NULL AND pu.active AND o.resignation_date IS NULL);
                    
                    CREATE TEMP TABLE highest_salary AS (
                           SELECT unit_id, max(salary) as max_unit_salary
                           FROM salary_analysis
                           GROUP BY unit_id);
                    
                    CREATE TEMP TABLE commanders AS (SELECT officer_id, unit_id, unit_name, complaint_percentile
                    FROM salary_analysis s
                    WHERE salary = (SELECT max_unit_salary FROM highest_salary hs WHERE hs.unit_id = s.unit_id));
                    
                    
                    SELECT commanders.unit_id, COUNT(d.officer_id) AS number_of_officers, unit_name, 
                        commanders.complaint_percentile AS supervisor_complaint_percentile,
                           AVG(o.complaint_percentile) as avg_unit_complaint_percentile
                    FROM commanders
                    INNER JOIN data_officerhistory d on commanders.unit_id = d.unit_id
                    INNER  JOIN data_officer o on d.officer_id = o.id
                    WHERE active = 'Yes'
                    GROUP BY commanders.unit_id, commanders.unit_name, commanders.complaint_percentile;
                    """)
    headers = cursor.description
    rows = cursor.fetchall()

    unit_data = {"units": []}
    # cols are: unit_id, number_of_officers, unit_name, supervisor_complaint_percentile, avg_unit_complaint_percentile
    for i, row in enumerate(rows):
        curr_unit = {}
        # go through each item in the db row
        for j, cell in enumerate(row):
            if headers[j].type_code == 1700:  # it's a decimal, which JSON can't handle, so we need to cast it
                cell = round(float(cell), 2)  # round to 2nd decimal
            # set the header (i.e. column name) as the key and set the value
            curr_unit[headers[j].name] = cell
        unit_data["units"].append(curr_unit)

    # write JSON file to current folder
    with open('d3_unit_data.json', 'w+') as out:
        print("Writing JSON to file")
        json.dump(unit_data, out)


if __name__ == "__main__":
    main()

