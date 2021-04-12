install.packages("readtext")
install.packages("tm")
install.packages("NLP")
install.packages("SnowballC")
install.packages("e1071")

library(readtext)
library(NLP)
library(tm)
library(SnowballC)
library(e1071)
library(gmodels)
library(wordcloud)

#Set part of directory
DATA_DIR <- system.file("/Users/pooranijagadeesan/Desktop/Semester 2/DMPA/PROJECT/review_polarity/", package = "readtext")
setwd("/Users/pooranijagadeesan/Desktop/Semester 2/DMPA/PROJECT/review_polarity/")

#Download all text files
movie_review_pos <- readtext(paste0(DATA_DIR, "txt_sentoken/pos/*"))
movie_review_neg <- readtext(paste0(DATA_DIR, "txt_sentoken/neg/*"))

#Create new column to identity the type of reviews
movie_review_pos$type <- 0
movie_review_pos$type <- replace(movie_review_pos$type, movie_review_pos$type == 0, "pos")
movie_review_neg$type <- 0
movie_review_neg$type <- replace(movie_review_neg$type, movie_review_neg$type == 0, "neg")

#Conbine to all movie review
movie_review <- rbind(movie_review_pos, movie_review_neg)
movie_review$type <- factor(movie_review$type)

#Random rows
movie_review <- movie_review[sample(nrow(movie_review)), ]


#Data Cleaning Processes
#Change the text to be list
mr_corpus <- VCorpus(VectorSource(movie_review$text))

#View the message text (one file)
as.character(mr_corpus[[1]])
#View the multiple message text files
lapply(mr_corpus[1:2], as.character)

#Standardize the message to be lowercase
mr_corpus_clean <- tm_map(mr_corpus, content_transformer(tolower))

#Remove numbers in the message
mr_corpus_clean <- tm_map(mr_corpus_clean, removeNumbers)

#Remove stopwords in the message
mr_corpus_clean <- tm_map(mr_corpus_clean, removeWords, c(stopwords("english"), "movie", "film", "character", "just", "people", "plot", "director"))

#Remove punctuations in the message
mr_corpus_clean <- tm_map(mr_corpus_clean, removePunctuation)

#Change the words in the message to be root form
mr_corpus_clean <- tm_map(mr_corpus_clean, stemDocument)

#Remove additional whitespace
mr_corpus_clean <- tm_map(mr_corpus_clean, stripWhitespace)

#Data Prepearation
#Change to be Document Term Matrix (DTM)
mr_dtm <- DocumentTermMatrix(mr_corpus_clean)

#Clean and combine (Alternative way)
mr_dtm <- DocumentTermMatrix(mr_corpus, control = list (tolower = TRUE, removeNumbers = TRUE, stopwords = TRUE, removePunctuation = TRUE, stemming = TRUE))

#Create training (75%) and test data (25%)
mr_dtm_train <- mr_dtm[1:1500, ]
mr_dtm_test <- mr_dtm[1501:2000, ]

#Crate labels to check later
mr_train_labels <- movie_review[1:1500, ]$type
mr_test_labels <- movie_review[1501:2000, ]$type

#Create indicator features for frequent words
mr_freq_words <- findFreqTerms(mr_dtm_train, 50)
mr_dtm_freq_train <- mr_dtm_train[ , mr_freq_words]
mr_dtm_freq_test <- mr_dtm_test[ , mr_freq_words]

convert_counts <- function(x) { x <- ifelse(x>0, "Yes", "No")}
mr_train <- apply(mr_dtm_freq_train, MARGIN = 2, convert_counts)
mr_test <- apply(mr_dtm_freq_test, MARGIN = 2, convert_counts)

#Build the classifier
mr_classifier <- naiveBayes(mr_train, mr_train_labels)

#Prediction
mr_test_pred <- predict(mr_classifier, mr_test)
CrossTable(mr_test_pred, mr_test_labels, prop.chisq = FALSE, prop.t = FALSE)

#Compare actual and predicted values
CrossTable(mr_test_pred, mr_test_labels,
           prop.chisq = FALSE, prop.t = FALSE, prop.r = FALSE,
           dnn = c('predicted', 'actual'))

#With Laplace smoothing
#Build the classifier
mr_classifier1 <- naiveBayes(mr_train, mr_train_labels, laplace = 1)

#Prediction
mr_test_pred1 <- predict(mr_classifier1, mr_test)

#Compare actual and predicted values
CrossTable(mr_test_pred1, mr_test_labels,
           prop.chisq = FALSE, prop.t = FALSE, prop.r = FALSE,
           dnn = c('predicted', 'actual'))

#plot wordcloud 
wordcloud(mr_corpus_clean ,min.freq = 20,max.words = 200,random.order = F,colors = brewer.pal(8,"Dark2"))

pos<- subset(movie_review[1:1500,],movie_review$type=="pos")
neg<-subset(movie_review[1:1500,],movie_review$type=="neg")

par(mfrow=c(1,2))

wordcloud(pos$text ,min.freq = 40,max.words = 100,random.order = F,scale=c(3,0.5), colors = brewer.pal(8,"Dark2"))
text(0.5,1,"positive")

wordcloud(neg$text ,min.freq = 40,max.words = 100,random.order = F,scale=c(3,0.5), colors = brewer.pal(8,"Dark2"))
text(0.5,1,"negitive")





