import sys
import json
from datetime import datetime
from TpCsv2Json import fetch_items

sheets = [
    { 'name': "21 dec - 27 dec-Tabell 1.csv", 'basedate': "15-12-21", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "30 dec - 4 jan-Tabell 1.csv", 'basedate': "15-12-30", 'columns': [0, 2, 4, 6, 8, 10]},
    { 'name': "5 jan - 10 jan-Tabell 1.csv", 'basedate': "16-01-05", 'columns': [0, 2, 4, 6, 8, 10]},
    { 'name': "11 jan - 17 jan-Tabell 1.csv", 'basedate': "16-01-11", 'columns': [1, 3, 5, 7, 9, 11, 13]},
    { 'name': "18 jan - 22 jan-Tabell 1.csv", 'basedate': "16-01-18", 'columns': [0, 2, 4, 6, 8]},
    { 'name': "25 jan - 31 jan-Tabell 1.csv", 'basedate': "16-01-25", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "1 feb - 7 feb-Tabell 1.csv", 'basedate': "16-02-01", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "8 feb - 14 feb-Tabell 1.csv", 'basedate': "16-02-08", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "15 feb - 21 feb-Tabell 1.csv", 'basedate': "16-02-15", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "22 feb - 28 feb-Tabell 1.csv", 'basedate': "16-02-22", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "29 feb - 6 mar-Tabell 1.csv", 'basedate': "16-02-29", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "7 mars - 13 mars-Tabell 1.csv", 'basedate': "16-03-07", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "21 mars - 27 mars-Tabell 1.csv", 'basedate': "16-03-21", 'columns': [1, 3, 5, 7, 9, 11, 13]},
    { 'name': "28 mars - 3 april-Tabell 1.csv", 'basedate': "16-03-28", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "4 apr - 10 apr-Tabell 1.csv", 'basedate': "16-04-04", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "11 april - 17 april-Tabell 1.csv", 'basedate': "16-04-11", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "18 april - 24 april-Tabell 1.csv", 'basedate': "16-04-18", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "25 april - 1 maj-Tabell 1.csv", 'basedate': "16-04-25", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "2 maj - 8 maj-Tabell 1.csv", 'basedate': "16-05-02", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "9 maj - 15 maj-Tabell 1.csv", 'basedate': "16-05-09", 'columns': [1, 3, 5, 7, 9, 11, 13]},
    { 'name': "16 maj - 19 maj-Tabell 1.csv", 'basedate': "16-05-16", 'columns': [0, 2, 4, 6]},
    { 'name': "20 maj - 22 maj-Tabell 1.csv", 'basedate': "16-05-20", 'columns': [0, 2, 4]},
    { 'name': "23 maj - 29 maj-Tabell 1.csv", 'basedate': "16-05-23", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "30 maj - 5 juni-Tabell 1.csv", 'basedate': "16-05-30", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "6 juni - 12 juni-Tabell 1.csv", 'basedate': "16-06-06", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "14 juni - 19 juni-Tabell 1.csv", 'basedate': "16-06-14", 'columns': [0, 2, 4, 6, 8]},
    { 'name': "20 juni - 26 juni-Tabell 1.csv", 'basedate': "16-06-20", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "27 juni - 3 juli-Tabell 1.csv", 'basedate': "16-06-27", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "4 juli - 8 juli-Tabell 1.csv", 'basedate': "16-07-04", 'columns': [0, 2, 4, 6, 8]},
    { 'name': "8 aug - 14 aug-Tabell 1.csv", 'basedate': "16-08-08", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "16 aug - 21 aug-Tabell 1.csv", 'basedate': "16-08-15", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "22 aug - 28 aug-Tabell 1.csv", 'basedate': "16-08-22", 'columns': [0, 2, 4, 6, 8, 10]},
    { 'name': "29 aug - 4 sep-Tabell 1.csv", 'basedate': "16-08-29", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "12 sep - 18 sep-Tabell 1.csv", 'basedate': "16-09-12", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "19 sep - 25 sep-Tabell 1.csv", 'basedate': "16-09-19", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "27 sep - 2 okt-Tabell 1.csv", 'basedate': "16-09-26", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "3 okt - 9 okt-Tabell 1.csv", 'basedate': "16-10-03", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "10 okt - 16 okt-Tabell 1.csv", 'basedate': "16-10-10", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "17 okt - 23 okt-Tabell 1.csv", 'basedate': "16-10-17", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "31 okt - 6 nov-Tabell 1.csv", 'basedate': "16-10-31", 'columns': [0, 2, 4, 6, 8, 10, 12]},
    { 'name': "7 nov - 13 nov-Tabell 1.csv", 'basedate': "16-11-07", 'columns': [0, 2, 4, 6, 8, 10, 12]}
]

def date_handler(obj):
    if hasattr(obj, 'isoformat'):
        return obj.isoformat()
    elif isinstance(obj, ...):
        return ...
    else:
        raise TypeError('Object of type %s with value of %s is not JSON serializable' % (type(obj), repr(obj)))

def main(basedirectory, json_store):
    f = open(json_store, 'wb')
    sessions = list()
    for sheet in sheets:
        for column in sheet['columns']:
            items = fetch_items(basedirectory+"/"+sheet['name'], "utf-8", ';', datetime.strptime(sheet['basedate'], "%y-%m-%d"), column)
            for session in items:
                sessions.append(session)
    f.write(json.dumps(sessions, sort_keys=True, indent=4, default=date_handler, ensure_ascii=False).encode('utf8'))


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
