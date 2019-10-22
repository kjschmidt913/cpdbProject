# Checkpoint 2

## Getting Started
### To run Tableau
We've saved our charts in a Tableau workbook. As long as you have the CPDP database on your computer, it should run without an issue. Double click on the .twb (or .twbx) file to open the workbook in Tableau. You may be prompted to enter your password for the 'cpdb' user. The descriptions below correspond to the tabs at the bottom left of the workbook. 

### To run d3
In the `src` folder, open `dataVis.html` in your browser by right-clicking the file in your file explorer and selecting "Open With..." and then your prefered browser. This will display the interactive data visualization. To see the code, use a text editor to open `dataVis.html` for the html, `styles.css` for the css, and `chart.js` (percentile chart) and `chart2.js` (unit size chart) for the javascript.

## Our Questions
* Which police units have average complaint_percentiles above the 75th percentile?
* Which commanders oversee these high complaint units from Q1? What are their personal complaint_percentiles?
* Across all units, what is the average complaint percentile on a per-unit and per-rank basis?
* How do unit sizes relate to complaint percentiles of units?


## Our Visualizations

### Supervisors above the 75th percentile
In the tab supervisors, we can see the supervisors above the 75th complaint percentile and the unit IDs of the units they manage.

### Complaint percentiles of units with supervisors above the 75th complaint percentile
The tab named units uses those units that have supervisors above the 75th percentile and shows the unit’s complaint percentile.

### Unit / Rank vs. Average Complaint Percentile Graphs I & II
Both graphs display the average complaint percentile on a per-unit and per-rank basis. This is to give us a general overview of how the units / ranks stack-up against one-another, to be later compared to each units supervisor and their own complaint percentile.

### D3 chart
Our D3 chart is a bubble chart that shows the units as individual bubbles. The bubbles that are red have a supervisor above the 75th complaint percentile. The bubbles can be sized by their collective complaint percentile (showing how large or small of a "problem unit" they are) or they can be sized by the actual number of officers in the unit. Upon hovering over a bubble, you can see the unit's complaint percentile, their supervisor's complaint percentile, and the number of officers in the unit.

