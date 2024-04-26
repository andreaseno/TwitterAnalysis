# The only purpose of this code is to count csv lines. This is necessary because some data spans multiple lines 
# in the csv data, so I cannot accuractely count rows using line numbers

import csv
import sys

def count_csv_rows(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        reader = csv.reader(file)
        row_count = sum(1 for row in reader)
    return row_count

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 CountRows.py filename.csv")
        sys.exit(1)

    filename = sys.argv[1]
    print(count_csv_rows(filename))