import csv
import pandas as pd

# Data to be written to the CSV file
data = pd.read_csv('Data/TweetSentimentExtraction.csv', encoding='utf-8')

# Fieldnames in the order you want them to appear in the CSV
fieldnames = ['Name', 'Age', 'Job']

# Writing to a CSV file
with open('people.csv', 'w', newline='') as file:
    writer = csv.DictWriter(file, fieldnames=fieldnames)

    # Writing the header (fieldnames)
    writer.writeheader()

    # Writing data rows
    for row in data:
        writer.writerow(row)