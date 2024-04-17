/* Assuming your Twitter dataset is named 'twitter_data', adjust the dataset name accordingly */

/* Explore the structure of the dataset */

/* Import the CSV file */
PROC IMPORT DATAFILE='/home/u63761698/databaseProject/statuses.csv'
            OUT=twitter_data
            DBMS=CSV REPLACE;
            DATAROW=2; /* Specify the row where the data starts */
            GUESSINGROWS=10000; /* Increase if necessary */
            DELIMITER=','; /* Specify the delimiter */
RUN;



/* Explore the structure of the dataset */
PROC CONTENTS DATA=twitter_data;
RUN;

/* Print the first few observations of the dataset */
PROC PRINT DATA=twitter_data (WHERE=(NOT MISSING(id_str))); /* Change OBS=10 to display more or fewer observations */
    VAR id_str text;
RUN;


/* Explore the distribution of variables */
PROC FREQ DATA=twitter_data;
  TABLES tweet_text user_id timestamp retweet_count favorite_count / NOPRINT;
RUN;


/* Step 1: Create a Text Parsing Node */
/* This node is used to parse the text data and extract relevant information */

data twitter_parsed; 
   set twitter_data; 
   text = upcase(text); /* Convert text to uppercase for consistency */
run;

/* Step 2: Preprocessing */
/* Apply preprocessing techniques to clean and prepare the text data */

/* Example: Remove punctuation */
data twitter_cleaned;
   set twitter_parsed;
   text = prxchange('s/[[:punct:]]/ /', -1, text); /* Remove punctuation */
run;

/* Step 3: Create a Text Mining Node */
/* This node is used to perform text mining analysis on the cleaned text data */

proc textmine data=twitter_cleaned out=twitter_sentiment;
   id id_str; /* Specify the unique identifier for each tweet */
   text text; /* Specify the text variable containing tweet text */
   process sentiment /method=sas; /* Perform sentiment analysis */
run;

/* Step 4: Evaluate Results */
/* Analyze the results of the text mining analysis */

/* Example: Print sentiment scores for each tweet */
proc print data=twitter_sentiment(obs=10); /* Display the first 10 observations */
   var id_str sentiment_score;
run;
