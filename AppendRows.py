import csv
import pandas as pd

# Data to be written to the CSV file
data = pd.read_csv('Data/TweetSentimentExtraction.csv', encoding='utf-8')
# data = data.iloc[:600]
print(data)

# csv_file = pd.read_csv('Data/MultiClassLabeledCustomTwitterSentiments.csv')

data = data.rename(columns={'sentiment': 'target'})

data = data.drop(columns=['textID', 'selected_text'])

sentiment_mapping = {
    'negative': 0,
    'neutral': 2,
    'positive': 4
}

data['target'] = data['target'].replace(sentiment_mapping)


# df_combined = pd.concat([csv_file, data], ignore_index=True)

# print(df_combined)

data.to_csv('Data/test.csv', index=False, encoding='utf-8')


