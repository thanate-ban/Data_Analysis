install.packages("readtext")
install.packages("tidyverse")
install.packages("tidytext")
install.packages("stringr")
install.packages("textdata")
install.packages("e1071")
install.packages("hunspell")
install.packages("spelling")

library(tidyverse)
library(tidytext)
library(stringr)
library(NLP)
library(tm)
library(readtext)
library(dplyr)
library(SnowballC)
library(e1071)
library(gmodels)

#Set part of directory
DATA_DIR <- system.file("/Users/pooranijagadeesan/Desktop/Semester 2/DMPA/PROJECT/review_polarity/", package = "readtext")
setwd("/Users/pooranijagadeesan/Desktop/Semester 2/DMPA/PROJECT/review_polarity/")

#Download all review
movie_review_pos <- as_tibble(readtext(paste0(DATA_DIR, "txt_sentoken/pos/*")))
movie_review_neg <- as_tibble(readtext(paste0(DATA_DIR, "txt_sentoken/neg/*")))

#Split text to be words
movie_review_pos <- movie_review_pos %>% unnest_tokens(word, text)
movie_review_neg <- movie_review_neg %>% unnest_tokens(word, text)

#Group words in the same file
movie_review_pos <- movie_review_pos %>% group_by(doc_id) %>% summarise(word = paste(word, collapse = " "))
movie_review_neg <- movie_review_neg %>% group_by(doc_id) %>% summarise(word = paste(word, collapse = " "))

#Create new column to identity the type of reviews
movie_review_pos$type <- "pos"
movie_review_neg$type <- "neg"

#Conbine to all movie review
movie_review <- rbind(movie_review_pos, movie_review_neg)
movie_review$type <- factor(movie_review$type)

#Random rows (neg reviews are row 5 and 23)
set.seed(5)
movie_review <- movie_review[sample(nrow(movie_review), replace = FALSE), ]

#Data Cleaning Processes
#Change the text to be list
mr_corpus <- VCorpus(VectorSource(movie_review$word))

#Remove numbers in the message
mr_corpus_clean <- tm_map(mr_corpus, removeNumbers)

#Remove stopwords in the message
mr_corpus_clean <- tm_map(mr_corpus_clean, removeWords, stopwords(kind = "en"))

#Remove common words
mr_corpus_clean <- tm_map(mr_corpus_clean, removeWords, c("movie", "movies", "film", "films", "character", "people", "plot", "director"))

#Remove punctuations in the message
mr_corpus_clean <- tm_map(mr_corpus_clean, removePunctuation)

#Remove additional whitespace
mr_corpus_clean <- tm_map(mr_corpus_clean, stripWhitespace)

#Data Prepearation
#Change to be Document Term Matrix (DTM)
mr_dtm <- DocumentTermMatrix(mr_corpus_clean)

#Create training (75%) and test data (25%)
mr_dtm_train <- mr_dtm[1:1500, ]
mr_dtm_test <- mr_dtm[1501:2000, ]

#Crate labels to check later
mr_labels <- movie_review$type
mr_train_labels <- movie_review[1:1500, ]$type
mr_test_labels <- movie_review[1501:2000, ]$type

#Create indicator features for frequent words
mr_freq_words <- findFreqTerms(mr_dtm_train, 20)
mr_dtm_freq_train <- mr_dtm_train[ , mr_freq_words]
mr_dtm_freq_test <- mr_dtm_test[ , mr_freq_words]

convert_counts <- function(x) { x <- ifelse(x>0, "Yes", "No")}
mr_train <- apply(mr_dtm_freq_train, MARGIN = 2, convert_counts)
mr_test <- apply(mr_dtm_freq_test, MARGIN = 2, convert_counts)

#Build the classifier
mr_classifier <- naiveBayes(mr_train, mr_train_labels, laplace = 1)

#Prediction
mr_test_pred <- predict(mr_classifier, mr_test)

#Compare actual and predicted values
CrossTable(mr_test_pred, mr_test_labels,
           prop.chisq = FALSE, prop.t = FALSE, prop.r = FALSE,
           dnn = c('predicted', 'actual'))

#Setniment results for bing lexicon
sentiment_result <- tidy(mr_dtm) %>% left_join(get_sentiments("bing"), by = c(term = "word"))
sentiment_result$document <- sapply(sentiment_result$document, as.integer)

#Count negative and positive documents
sentiment_count <- sentiment_result %>%
  count(document, sentiment, wt = count) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative) %>%
  mutate(type = ifelse(sentiment >= 0, "pos", "neg"))

#Count the sentiment results for the data
sentiment_polarity <- sentiment_count%>%
  count(document, type)

#Display the actual vs predicted values for sentiment analysis
CrossTable(sentiment_polarity$type, mr_labels,
           prop.chisq = FALSE, prop.t = FALSE, prop.r = FALSE,
           dnn = c('predicted', 'actual'))

#Display the actual vs predicted test values for comparison
CrossTable(sentiment_polarity[1501:2000,]$type, mr_test_labels,
           prop.chisq = FALSE, prop.t = FALSE, prop.r = FALSE,
           dnn = c('predicted', 'actual'))
