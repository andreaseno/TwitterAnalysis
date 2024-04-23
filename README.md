# Twitter Sentiment Analysis Project

## Project Description

In this project, we aim to conduct a sentiment analysis on Twitter data. Our primary objective is to compare traditional statistical methods against modern AI/ML techniques to evaluate tweets. We plan to analyze the sentiment of tweets stored in the PostgreSQL Twitter database using different approaches and tools. 


### Team Members and Roles

- **Owen Andreasen** 
  - **GitHub/GitLab Username:** andreaseno
  - **Role:** AI/ML sentiment analysis using Python and libraries like TensorFlow, Keras, SciKit-Learn, Scipy, and Torch.
  
- **Justin Park**
  - **GitHub/GitLab Username:** Chang-park
  - **Role:** Conducting traditional statistical analysis primarily using SAS and SAS Text Miner.

### Project Type

This is a sentiment analysis project with a unique angle of comparing  traditional statistics and AI/ML models such as BERT transformers and LSTM networks. Our analysis will include metrics like accuracy, recall, and precision and will consider the detection of sarcasm and complex sentiments.

## Data Source
The Twitter data used in this project is sourced from the PostgreSQL Twitter database. The dataset contains tweets collected over a specific timeframe and stored in a structured format. Prior to analysis, the data will be preprocessed to remove noise and irrelevant information.Additionally, we are referencing the following external datasets and resources to aid our research:

## Methodology
We will employ a combination of traditional statistical analysis and AI/ML techniques for sentiment analysis:
- **Traditional Statistical Analysis**: Justin will utilize SAS and SAS Text Miner to perform statistical analysis on the Twitter data. This approach may involve lexicon-based methods and other statistical techniques.
- **AI/ML Sentiment Analysis**: Owen will implement AI/ML models using Python and libraries such as TensorFlow, Keras, and Scikit-Learn. This approach may include using BERT transformers, LSTM networks, and other deep learning models.

## Evaluation Metrics
We will evaluate the performance of our sentiment analysis methods using the following metrics:
- Accuracy: The proportion of correctly classified tweets.
- Recall: The proportion of true positive tweets identified by the model.
- Precision: The proportion of correctly classified positive tweets out of all predicted positive tweets.

## Results and Discussion
Upon completion of the sentiment analysis, we will summarize the findings and discuss the implications of the results. We will compare the performance of traditional statistical methods with AI/ML techniques, highlighting any differences in accuracy, recall, and precision. Additionally, we will explore the detection of sarcasm and complex sentiments in the Twitter data.

**Datasets**
- Twitter Sentiment Dataset (Twitter_Data) [Kaggle Dataset](https://www.kaggle.com/datasets/saurabhshahane/twitter-sentiment-dataset)
    - This dataset was a possible training dataset for positive, neutral, negative multiclass models, but the data looked low quality
- Sentiment140 Dataset [Kaggle Dataset](https://www.kaggle.com/datasets/kazanova/sentiment140)
    - This dataset only uses positive and negative classes (no neutral), but the data looked high quality and there are a ton of rows
- Tweet Sentiment Extraction [Kaggle Dataset](https://www.kaggle.com/competitions/tweet-sentiment-extraction/data)
    - This dataset uses positive, negative, and neutral classes, and the data looks fairly high quality

**Other Resources**
- Twitter Sentiment Extraction Analysis [Kaggle Notebook](https://www.kaggle.com/code/tanulsingh077/twitter-sentiment-extaction-analysis-eda-and-model/notebook)
- Twitter Sentiment Analysis with BERT vs RoBERTa [Kaggle Notebook](https://www.kaggle.com/code/ludovicocuoghi/twitter-sentiment-analysis-with-bert-vs-roberta/notebook)
- Sentiment Analysis of Unlabelled Text Using Word2Vec Model [Stack Overflow Discussion](https://stackoverflow.com/questions/61185290/is-it-possible-to-do-sentiment-analysis-of-unlabelled-text-using-word2vec-model)
- Emojis in Social Media Sentiment Analysis [Article](https://towardsdatascience.com/emojis-aid-social-media-sentiment-analysis-stop-cleaning-them-out-bb32a1e5fc8e)
- Usage of SpaCy as a Text Meta Feature generator [Keggle Notebook](https://www.kaggle.com/code/shivamb/spacy-text-meta-features-knowledge-graphs)


