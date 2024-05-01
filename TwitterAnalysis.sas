proc import datafile='/home/u63761698/databaseProject/TweetSentimentExtraction.csv' out=trainData dbms=csv replace;
run;
libname mylib '/home/u63761698/databaseProject/';

data trainData;
    set trainData;
run;

proc copy in=work out=mylib;
    select trainData;
run;

/* Print the first 100 observations of the dataset */
proc print data=trainData(obs=100);
run;


data trainDataCleaned;
    set trainData; /* Replace 'testData' with the name of your dataset */
    
    /* Other preprocessing steps */
    /* For example, remove punctuation, links, hashtags, illegal characters, and back-to-back spaces */
    selected_text = prxchange('s/[[:punct:]]|https?:\/\/[[:alnum:].\/?&_=-]+//', -1, selected_text);
    selected_text = prxchange('s/#\w+//', -1, selected_text);
    selected_text = prxchange('s/[^[:alnum:]\s]//', -1, selected_text);
    selected_text = prxchange('s/\s{2,}//', -1, selected_text);
run;

proc print data = trainDataCleaned(obs=10);
run;

%let text_len_threshhold = 20;

/* Step 1: Calculate text length */
data MultiClassTrain;
    set trainDataCleaned;
    length text_len 8;
    text_len = countw(selected_text);
run;

/* Step 2: Filter out tweets with text length <= threshold */
data MultiClassTrain_filtered;
    set MultiClassTrain;
    where text_len > &text_len_threshhold;
run;

/* Display dataset information */
proc contents data = MultiClassTrain_filtered;
run;

/* Plot the count of tweets with <= text_len_threshhold words */
proc sgplot data=MultiClassTrain_filtered;
    vbar text_len / datalabel;
    xaxis label="Number of Words in Tweet";
    yaxis label="Count of Tweets";
    title "Number of Words in Every Tweet With > &text_len_threshhold Total Words";
run;

/* Print total count of rows */
proc sql noprint;
    select count(*) into :total_rows trimmed
    from MultiClassTrain_filtered;
quit;

%put Total Rows: &total_rows;

/*  */
data MultiClassTrainFiltered;
    set MultiClassTrain;
    where text_len <= &text_len_threshhold;
run;

proc sql noprint;
    select count(*) into :total_obs_filtered trimmed
    from MultiClassTrainFiltered;
quit;
%put Total Rows: &total_obs_filtered;


data MultiClassTrainFiltered;
	set MultiClassTrain;
run;


/* Plot the distribution of token counts */
proc univariate data=MultiClassTrainFiltered;
    histogram text_len / BARWIDTH=1;
    title "Distribution of Token Counts";
run;

proc sort data=MultiClassTrainFiltered;
    by sentiment;
run;

proc surveyselect data=MultiClassTrainFiltered
                method=URS
                outhits
                seed=12345
                out=train_os
                sampsize=1000; /* Specify the sample size */
    strata sentiment;
run;

proc print data = train_os;
run;

/* Step 1: Tokenize the text data */
data tokens;
    set train_os;
    length word $50.;
    retain word;
    do i = 1 to countw(selected_text);
        word = scan(selected_text, i);
        if not anydigit(word) then output;
    end;
    keep word selected_text sentiment;
run;

/* Step 2: Create a vocabulary table with distinct tokens */
proc sort data=tokens;
    by word;
run;

data vocab;
    set tokens;
run;

/* Step 3: Count the frequency of each term */
proc freq data=vocab;
    tables word / out=word_freq;
run;


/* Step 4: Select terms with a minimum frequency and add information about the original text and sentiment */
data frequent_terms;
    merge word_freq (in=a) tokens;
    by word;
    if a and count >= 1; /* Keep only words with frequency greater than or equal to 1 */
run;

/* Print the first few observations of the frequent_terms dataset */
proc print data=frequent_terms(obs=100);
run;

/* Step 5: Pivot the frequent_terms dataset to have one column for every word indicating the sentiment it belongs to */
proc sort data=frequent_terms;
    by word;
run;

data frequent_terms_pivoted;
    set frequent_terms;
    by word;

    length sentiment_positive sentiment_neutral sentiment_negative dominant_sentiment $8;
	retain sentiment_positive sentiment_neutral sentiment_negative;
    /* Initialize the variables */
    if first.word then do;
        sentiment_positive = 0;
        sentiment_neutral = 0;
        sentiment_negative = 0;
    end;

    /* Count the occurrences of each sentiment */
    if sentiment = "positive" then sentiment_positive = sentiment_positive + 1;
    else if sentiment = "neutral" then sentiment_neutral = sentiment_neutral + 1;
    else if sentiment = "negative" then sentiment_negative = sentiment_negative + 1;
	
	put word=;
	put sentiment_positive=;
	put sentiment_neutral=;
	put sentiment_negative=;


    /* Output the result for each observation */
    if last.word then do;
        if count >= 30 then
            dominant_sentiment = 'PSW';
        /* Determine the dominant sentiment */
        else if sentiment_positive > sentiment_neutral and sentiment_positive > sentiment_negative then
            dominant_sentiment = 'positive';
        else if sentiment_neutral > sentiment_positive and sentiment_neutral > sentiment_negative then
            dominant_sentiment = 'neutral';
        else if sentiment_negative > sentiment_positive and sentiment_negative > sentiment_neutral then
            dominant_sentiment = 'negative';
        else
            dominant_sentiment = 'neutral'; /* If multiple sentiments or all sentiments */
    
        output;
    end;
run;

/*     drop sentiment_positive sentiment_neutral sentiment_negative; */
run;

proc freq data=frequent_terms_pivoted;
    tables dominant_sentiment / nocum nocol;
run;



/* Print the first few observations of the frequent_terms_pivoted dataset */
proc print data=frequent_terms_pivoted(obs=10);
run;

/* Step 6: Prepare data for modeling */
/* bag of words */
/* Logistic regression modeling */
proc logistic data=frequent_terms_pivoted;
    class dominant_sentiment (ref='neutral');
    model dominant_sentiment = / selection=stepwise;
run;

/* Step 1: Tokenize the text data */
/* data tokens; */
/*     set train_os; */
/*     length word $50.; */
/*     retain word; */
/*     do i = 1 to countw(text); */
/*         word = scan(text, i); */
/*         if not anydigit(word) then output; */
/*     end; */
/*     keep word; */
/* run; */
/*  */
/* Step 2: Create a vocabulary table with distinct tokens */
/* proc sort data=tokens; */
/*     by word; */
/* run; */
/*  */
/* data vocab; */
/*     set tokens; */
/* run; */
/*  */
/* Step 3: Count the frequency of each term */
/* proc freq data=vocab; */
/*     tables word / out=word_freq; */
/* run; */
/*  */
/* proc print data=word_freq; */
/* run; */
/* Step 4: Select terms with a minimum frequency */
/* data frequent_terms; */
/*     set word_freq (where=(count >= 2)); /* Change 2 to your desired minimum frequency */
/* run; */
/*  */
/* Step 5: View the frequent terms */
/* proc print data=frequent_terms; */
/*     title 'Frequent Terms'; */
/* run; */


/* --------------------------- */
/* Import the test dataset */
proc import datafile='/home/u63761698/databaseProject/MultiClassLabeledCustomTwitterSentiments.csv' out=testData dbms=csv replace;
run;

/* Clean the test data */
data testDataCleaned;
    set testData;
    /* Preprocessing steps */
    text = prxchange('s/[[:punct:]]|https?:\/\/[[:alnum:].\/?&_=-]+//', -1, text);
    text = prxchange('s/#\w+//', -1, text);
    text = prxchange('s/[^[:alnum:]\s]//', -1, text);
    text = prxchange('s/\s{2,}//', -1, text);
run;

/* Use the bag-of-words from frequent_terms_pivoted to classify sentiments in testDataCleaned */
data testData_with_sentiment;
    set testDataCleaned;
    length sentiment_positive sentiment_neutral sentiment_negative $8;

    /* Initialize sentiment counts */
    sentiment_positive = 0;
    sentiment_neutral = 0;
    sentiment_negative = 0;

    /* Tokenize the text */
    do i = 1 to countw(text);
        word = scan(text, i);
        /* Check if the word exists in the bag-of-words */
        set frequent_terms_pivoted;
        if word = word then do;
            /* Increment corresponding sentiment count */
            if dominant_sentiment = 'positive' then sentiment_positive = sentiment_positive + 1;
            else if dominant_sentiment = 'neutral' then sentiment_neutral = sentiment_neutral + 1;
            else if dominant_sentiment = 'negative' then sentiment_negative = sentiment_negative + 1;
        end;
    end;

    /* Determine the dominant sentiment */
    if sentiment_positive > sentiment_neutral and sentiment_positive > sentiment_negative then
        dominant_sentiment = 'positive';
    else if sentiment_neutral > sentiment_positive and sentiment_neutral > sentiment_negative then
        dominant_sentiment = 'neutral';
    else if sentiment_negative > sentiment_positive and sentiment_negative > sentiment_neutral then
        dominant_sentiment = 'negative';
    else
        dominant_sentiment = 'neutral'; /* If multiple sentiments or all sentiments */

    /* Output the result */
    output;

    /* Reset variables for the next observation */
    drop i word sentiment_positive sentiment_neutral sentiment_negative;
run;

/* Calculate accuracy */
data testData_with_sentiment_acc;
    set testData_with_sentiment;

    accuracy = (dominant_sentiment = sentiment); /* Correct prediction is 1, incorrect prediction is 0 */
run;

/* Calculate total accuracy */
proc means data=testData_with_sentiment_acc noprint;
    var accuracy;
    output out=accuracy_summary sum=total_count mean=accuracy;
run;

/* Display total accuracy */
proc print data=accuracy_summary;
    var _freq_ accuracy total_count;
    format accuracy percent8.2;
run;

proc sql;
    create table sentiment_metrics as
    select 
        'Positive' as sentiment,
        /* Precision */
        sum(case when dominant_sentiment='positive' and sentiment='positive' then 1 else 0 end) /
        sum(case when dominant_sentiment='positive' then 1 else 0 end) as precision,
        
        /* Recall */
        sum(case when dominant_sentiment='positive' and sentiment='positive' then 1 else 0 end) /
        sum(case when sentiment='positive' then 1 else 0 end) as recall,
        
        /* F-measure */
        (2 * sum(case when dominant_sentiment='positive' and sentiment='positive' then 1 else 0 end) /
             sum(case when dominant_sentiment='positive' then 1 else 0 end) *
         sum(case when dominant_sentiment='positive' and sentiment='positive' then 1 else 0 end) /
             sum(case when sentiment='positive' then 1 else 0 end)) /
        (sum(case when dominant_sentiment='positive' and sentiment='positive' then 1 else 0 end) /
             sum(case when dominant_sentiment='positive' then 1 else 0 end) +
         sum(case when dominant_sentiment='positive' and sentiment='positive' then 1 else 0 end) /
             sum(case when sentiment='positive' then 1 else 0 end)) as f_measure
    from testData_with_sentiment_acc

    union all

    select 
        'Negative' as sentiment,
        /* Precision */
        sum(case when dominant_sentiment='negative' and sentiment='negative' then 1 else 0 end) /
        sum(case when dominant_sentiment='negative' then 1 else 0 end) as precision,
        
        /* Recall */
        sum(case when dominant_sentiment='negative' and sentiment='negative' then 1 else 0 end) /
        sum(case when sentiment='negative' then 1 else 0 end) as recall,
        
        /* F-measure */
        (2 * sum(case when dominant_sentiment='negative' and sentiment='negative' then 1 else 0 end) /
             sum(case when dominant_sentiment='negative' then 1 else 0 end) *
         sum(case when dominant_sentiment='negative' and sentiment='negative' then 1 else 0 end) /
             sum(case when sentiment='negative' then 1 else 0 end)) /
        (sum(case when dominant_sentiment='negative' and sentiment='negative' then 1 else 0 end) /
             sum(case when dominant_sentiment='negative' then 1 else 0 end) +
         sum(case when dominant_sentiment='negative' and sentiment='negative' then 1 else 0 end) /
             sum(case when sentiment='negative' then 1 else 0 end)) as f_measure
    from testData_with_sentiment_acc

    union all

    select 
        'Neutral' as sentiment,
        /* Precision */
        sum(case when dominant_sentiment='neutral' and sentiment='neutral' then 1 else 0 end) /
        sum(case when dominant_sentiment='neutral' then 1 else 0 end) as precision,
        
        /* Recall */
        sum(case when dominant_sentiment='neutral' and sentiment='neutral' then 1 else 0 end) /
        sum(case when sentiment='neutral' then 1 else 0 end) as recall,
        
        /* F-measure */
        (2 * sum(case when dominant_sentiment='neutral' and sentiment='neutral' then 1 else 0 end) /
             sum(case when dominant_sentiment='neutral' then 1 else 0 end) *
         sum(case when dominant_sentiment='neutral' and sentiment='neutral' then 1 else 0 end) /
             sum(case when sentiment='neutral' then 1 else 0 end)) /
        (sum(case when dominant_sentiment='neutral' and sentiment='neutral' then 1 else 0 end) /
             sum(case when dominant_sentiment='neutral' then 1 else 0 end) +
         sum(case when dominant_sentiment='neutral' and sentiment='neutral' then 1 else 0 end) /
             sum(case when sentiment='neutral' then 1 else 0 end)) as f_measure
    from testData_with_sentiment_acc;
quit;

proc print data=sentiment_metrics;
    title 'Sentiment Metrics';
run;

/* Calculate confusion matrix */
proc freq data=testData_with_sentiment_acc;
    tables dominant_sentiment*sentiment / nocum norow nocol nopercent out=confusion_matrix;
run;

/* Plot confusion matrix as heatmap */
proc sgplot data=confusion_matrix;
    heatmap x=dominant_sentiment y=sentiment / response=count colormodel=(CXFFFFFF CXCCCCFF CXFFFFCC CXFFCCCC);
    xaxis discreteorder=data;
    yaxis discreteorder=data;
    keylegend / title='Count';
    title 'Confusion Matrix';
run;




/* INPUTTTT____________________+====----------------------------- */
/* Input sentence */
%let input_sentence = "Muslim woman in Hijab makes valid points and audience members tell her to calm down Funny that Muslim woman who doesnt…";
data newText;
    /* Preprocessing steps */
    text = prxchange('s/[[:punct:]]|https?:\/\/[[:alnum:].\/?&_=-]+//', -1, &input_sentence);
    text = prxchange('s/#\w+//', -1, text);
    text = prxchange('s/[^[:alnum:]\s]//', -1, text);
    text = prxchange('s/\s{2,}//', -1, text);
run;

data result;
    length sentiment_positive sentiment_neutral sentiment_negative $8;
    retain sentiment_positive sentiment_neutral sentiment_negative;
    /* Initialize sentiment counts */
    sentiment_positive = 0;
    sentiment_neutral = 0;
    sentiment_negative = 0;
    
    /* Set the text field */
    set newText;

    /* Tokenize the text */
    do i = 1 to countw(text);
        word = scan(text, i);

        /* Print each word */
        put word=;

        /* Check if the word exists in the bag-of-words */
        if word ne '' then do;
            set frequent_terms_pivoted (keep=word dominant_sentiment) point=_n_ nobs=numobs;
            do j = 1 to numobs until(found);
                if word = word then do;
                    /* Increment corresponding sentiment count */
                    if dominant_sentiment = 'positive' then sentiment_positive = sentiment_positive + 1;
                    else if dominant_sentiment = 'neutral' then sentiment_neutral = sentiment_neutral + 1;
                    else if dominant_sentiment = 'negative' then sentiment_negative = sentiment_negative + 1;
                    found = 1;
                end;
            end;
            put "Sentiment of &word is " dominant_sentiment;
        end;
    end;

    /* Determine the dominant sentiment */
    if sentiment_positive > sentiment_neutral and sentiment_positive > sentiment_negative then
        dominant_sentiment = 'positive';
    else if sentiment_neutral > sentiment_positive and sentiment_neutral > sentiment_negative then
        dominant_sentiment = 'neutral';
    else if sentiment_negative > sentiment_positive and sentiment_negative > sentiment_neutral then
        dominant_sentiment = 'negative';
    else
        dominant_sentiment = 'neutral'; /* If multiple sentiments or all sentiments */

    /* Output the result */
    output;

    /* Reset variables for the next observation */
    drop i j word sentiment_positive sentiment_neutral sentiment_negative;
run;


/* data result; */
/*     length sentiment_positive sentiment_neutral sentiment_negative $8; */
/*      */
/*     Initialize sentiment counts */
/*     sentiment_positive = 0; */
/*     sentiment_neutral = 0; */
/*     sentiment_negative = 0; */
/*  */
/*     Tokenize the text */
/*     do i = 1 to countw(&input_sentence); */
/*         word = scan(&input_sentence, i); */
/*          */
/*         Check if the word exists in the bag-of-words */
/*         if word ne '' then do; */
/*             set frequent_terms_pivoted (keep=word dominant_sentiment) point=_n_; */
/*             if word = word then do; */
/*                 Increment corresponding sentiment count */
/*                 if dominant_sentiment = 'positive' then sentiment_positive = sentiment_positive + 1; */
/*                 else if dominant_sentiment = 'neutral' then sentiment_neutral = sentiment_neutral + 1; */
/*                 else if dominant_sentiment = 'negative' then sentiment_negative = sentiment_negative + 1; */
/*             end; */
/*         end; */
/*     end; */
/*      */
/*     Determine the dominant sentiment */
/*     if sentiment_positive > sentiment_neutral and sentiment_positive > sentiment_negative then */
/*         dominant_sentiment = 'positive'; */
/*     else if sentiment_neutral > sentiment_positive and sentiment_neutral > sentiment_negative then */
/*         dominant_sentiment = 'neutral'; */
/*     else if sentiment_negative > sentiment_positive and sentiment_negative > sentiment_neutral then */
/*         dominant_sentiment = 'negative'; */
/*     else */
/*         dominant_sentiment = 'neutral'; /* If multiple sentiments or all sentiments */
/*      */
/*     Output the result */
/*     output; */
/*  */
/*     Reset variables for the next observation */
/*     drop i word sentiment_positive sentiment_neutral sentiment_negative; */
/* run; */
