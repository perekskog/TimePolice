# TimePolice

The app is available on AppStore: https://itunes.apple.com/se/app/timepolice/id1104784162?l=en&mt=8

Also see the companion website: http://timepolice.perekskog.se/

## Using data exported from TimePolice

Scripts and sample data referred to here can be found in my repo "bigdata":

- `ingest/timepolice_ingest.py`
- `analyze/timepolice_report.py`
- `sample_data/timepolice`

### Convert TimePolice data to JSON

1. Export sessions from TimePolice as "session details".
2. In a spreadsheet app, export the data as CSV files.
3. Edit `sample_csv.json` to add the exported CSV. The columns field indicate which columns to process.
4. Convert data.  
        `>python3 timepolice_ingest.py sample_csv.json csv sessions.json`


### Extract data from JSON


One example is provided in `timepolice_report.py`.

Report types:

- "timesheet" summarize time spent on tasks in a project named "Kostnad".  
        `>python3 timepolice_report.py sessions.json timesheet 16-12-21 16-12-27`
