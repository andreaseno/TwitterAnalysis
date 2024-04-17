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
