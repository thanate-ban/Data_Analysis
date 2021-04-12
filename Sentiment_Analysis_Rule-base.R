install.packages("readtext")
install.packages("tidyverse")
install.packages("tidytext")
install.packages("stringr")
install.packages("textdata")

library(tidyverse)
library(tidytext)
library(stringr)
library(readtext)
library(dplyr)

#Set part of directory
DATA_DIR <- system.file("/Users/pooranijagadeesan/Desktop/Semester 2/DMPA/PROJECT/review_polarity/", package = "readtext")
setwd("/Users/pooranijagadeesan/Desktop/Semester 2/DMPA/PROJECT/review_polarity/")

#Download all text files
movie_review_pos <- as_tibble(readtext(paste0(DATA_DIR, "txt_sentoken/pos/*")))
movie_review_neg <- as_tibble(readtext(paste0(DATA_DIR, "txt_sentoken/neg/*")))

#Split the columns into tokens and add the Type column
movie_review_pos <- movie_review_pos %>% unnest_tokens(word, text)
movie_review_neg <- movie_review_neg %>% unnest_tokens(word, text)

#Conbine to all movie review
movie_review <- rbind(movie_review_pos, movie_review_neg)

#Compare the reviews with sentiment database
sentiment_result <- movie_review %>% right_join(get_sentiments("nrc")) %>% filter(!is.na(sentiment)) %>% count(sentiment, sort = TRUE)

#Remove stop_words for better analysis - Choosing the top 10 most common words
senti_review <- movie_review %>%
  anti_join(stop_words) %>%
  count(word, sort = TRUE) %>%
  top_n(10)

senti_review

#Compare the reviews with sentiment database
sentiment_result1 <- senti_review %>% right_join(get_sentiments("nrc")) %>% filter(!is.na(sentiment)) %>% count(sentiment, sort = TRUE)

sentiment_result1

#Setniment results for bing lexicon
sentiment_result2 <- movie_review %>% inner_join(get_sentiments("bing")) %>% filter(!is.na(sentiment)) %>% count(sentiment, sort = TRUE)

sentiment_result2

#Visualizing the results -nrc
ggplot(sentiment_result1, aes(sentiment, n, fill = sentiment)) +
  geom_bar(stat = "identity", show.legend = FALSE) 

#Visualizing the results - bing
bing_word_counts <- movie_review %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE)

bing_word_counts%>%
  filter(n > 200) %>%
  mutate(n = ifelse(sentiment == "negative", -n, n)) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = sentiment)) +
  geom_col() +
  coord_flip() +
  labs(y = "Contribution to sentiment")








