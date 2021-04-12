Naive Bayes Classifier and Rule-Based algorithm for polarity analysis in movie review  dataset

Overview
********

This is a file explaining how to execute the Sentiment_Compare_2000reviews.R code in RStudio with the data set file poarity_review with 1000 positive reviews and 1000 negative reviews. 


Files:

Sentiment_Compare_2000reviews.R

Dataset Files:

There is one top-level directory [txt_sentoken/] 
and it contains [pos/, neg/]corresponding to the training and test sets.

Procedure:

DATA PROCESSING
1.Import necessary packages, set directory and load the text files onto the R environment using readtext() function.
2. Gather the positive and negative movie review data files into one-token-per-row using the unnest_tokens() function for converting the data frame into a text column.
3.Combine the positive and negative review tibbles into a single object using rbind() function and Consolidate the text files into single corpus.
4.Perform data cleaning techniques to make the corpus useful for sentiment analysis.
	a.Remove numbers.
	b.Remove Stopwords.
	c.Remove commonwords
	d.Remove punctuations.
	e.Strip white space.
5.Transform the data to DocumentTermMatrix form.	

TRAINING THE NAIVE BAYES MODEL
6.Split and create training (75% - 1500 reviews) and testing data (25% - 500 reviews).
7.Create labels for positive and negative reviews for validation.
8.Perform frequent word search and indicate the features for training the model.
9.Build the Naïve Bayes Classifier model for the training data.

TRAINING THE RULE-BASED SENTIMENT ANALYSIS MODEL
10.Create sentiment polarity by ‘left_join’ with ‘bing’ lexicon on the document term matrix.
11.Count the net sentiment of the movie reviews and classify them into positive and negative movie reviews using ruled-based sentiment analysis.

EVALUATION
12.Use the classifier model to predict the polarity in the testing data and obtain CrossTable for Naive Bayes and ruled-based Sentiment Analysis models.


Contact:

For questions/comments/corrections please contact 
Poorani Jagadeesan 
pjagadee@fitchburgstate.edu
Thanate Banchonhattakij
tbanchon@student.fitchburgstate.edu
Yashwanth Gangapuram
ygangapu@student.fitchburgstate.edu