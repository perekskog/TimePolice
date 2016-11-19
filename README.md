# TimePolice

The app is available on AppStore: https://itunes.apple.com/se/app/timepolice/id1104784162?l=en&mt=8

Also see the companion website: http://timepolice.perekskog.se/

## Using data exported from TimePolice

### Convert TimePolice data to JSON

1. Export sessions from TimePOlice as "Session details".
2. In your spreadsheet app, export the data as CSV.

Convert one column from a single CSV file

1. scripts>python3 TpCsv2Json.py csv/21\ dec\ -\ 27\ dec-Tabell\ 1.csv utf-8 ';' 15-12-21 0 TpSessions.json

Batch convert several CSV files

1. Edit "batch_convert" to add the exported CSV. The columns field indicate which columns to process.
2.  scripts>python3 batch_convert.py csv sessions.json

### Extract data from JSON

One example is provided in "tpsessionsreport.py".

Report types:

- "timesheet" summurize time spent on tasks in a project named "Kostnad".

scripts>python3 tpsessionreports.py sessions.json timesheet 16-11-01 16-11-10
