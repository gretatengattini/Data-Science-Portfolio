# Install necessary packages if not already installed
install.packages("mongolite") # Install MongoDB client for R
install.packages("tidyverse") # Install suite of data manipulation and visualization packages
install.packages("reshape2") # Install package for reshaping data

# Load the required libraries
library(tidyverse) # Load tidyverse for data manipulation and visualization
library(tidytext) # Load tidytext for text mining
data(stop_words) # Load dataset containing stopwords
library(mongolite) # Load mongolite for MongoDB database operations
library(dplyr) # Load dplyr for data manipulation
library(tidyr) # Load tidyr for data tidying
library(tm) # Load tm for text mining
library(tidytext) # Load tidytext for tidy text mining
library(wordcloud) # Load wordcloud for generating word clouds
library(ggplot2) # Load ggplot2 for data visualization
library(cld3) # Load cld3 for language detection
library(syuzhet) # Load syuzhet for sentiment analysis
library(topicmodels) # Load topicmodels for topic modeling
library(wordcloud2) # Load wordcloud2 for enhanced word clouds
library(igraph) # Load igraph for network analysis
library(ggraph) # Load ggraph for graph visualization

# Setup the connection to MongoDB database
connection_string <- 'mongodb+srv://gtengattini:1234@cluster0.fticpi0.mongodb.net/' # MongoDB connection string
airbnb_collection <- mongo(collection="listingsAndReviews", db="sample_airbnb", url=connection_string) # Connect to Airbnb collection

# Download all Airbnb data from MongoDB
airbnb_all <- airbnb_collection$find() # Fetch all data from the collection

# View the structure and summary of the downloaded data
head(airbnb_all) # Display the first few rows
summary(airbnb_all) # Summarize the data
str(airbnb_all) # Show the structure of the data frame

# Handling missing values in the data
colSums(is.na(airbnb_all)) # Sum up NA values across all columns

# Impute missing values for bathrooms and bedrooms with median values
median_bathrooms <- median(airbnb_all$bathrooms, na.rm = TRUE) # Calculate median for bathrooms
airbnb_all$bathrooms[is.na(airbnb_all$bathrooms)] <- median_bathrooms # Impute missing bathrooms with median

median_bedrooms <- median(airbnb_all$bedrooms, na.rm = TRUE) # Calculate median for bedrooms
airbnb_all$bedrooms[is.na(airbnb_all$bedrooms)] <- median_bedrooms # Impute missing bedrooms with median

# Replace missing text data in summary and description with an empty string
airbnb_all$summary[is.na(airbnb_all$summary)] <- ""
airbnb_all$description[is.na(airbnb_all$description)] <- ""

# Confirm no remaining missing values for bathrooms and bedrooms
any(is.na(airbnb_all$bathrooms))
any(is.na(airbnb_all$bedrooms))

# Preparing the data frame for analysis
airbnb_df <- airbnb_all %>%
  filter(!is.na(description)) %>%
  unnest(address, host, review_scores) %>%
  select(description, summary, neighborhood_overview, property_type, room_type, price, number_of_reviews, review_scores_rating, host_identity_verified, country, reviews)

# Detect and add a language column based on the description content
airbnb_df <- airbnb_df %>%
  mutate(language = sapply(description, function(desc) {
    lang <- cld3::detect_language(desc)
    if (is.null(lang)) NA else if (is.list(lang) || is.data.frame(lang)) lang$language else as.character(lang)
  }))

# Filter descriptions to keep only those in English
airbnb_df <- airbnb_df %>% filter(language == "en")

# Add a document ID column for identification
airbnb_df <- airbnb_df %>% mutate(document_id = row_number())
airbnb_df$document_id <- as.integer(airbnb_df$document_id)

# Text preprocessing steps
corpus <- VCorpus(VectorSource(airbnb_df$description)) # Create a text corpus
corpus <- tm_map(corpus, content_transformer(tolower)) # Convert text to lowercase
corpus <- tm_map(corpus, removePunctuation) # Remove punctuation
corpus <- tm_map(corpus, removeNumbers) # Remove numbers
corpus <- tm_map(corpus, removeWords, c(stopwords("english"), "checkbox", "☐", "☑")) # Remove stopwords and specific symbols
corpus <- tm_map(corpus, stripWhitespace) # Remove extra whitespace


# Convert the corpus to a tidy text dataset
dtm <- DocumentTermMatrix(corpus)
tidy_dtm <- tidy(dtm)
tidy_dtm_idf <- tidy_dtm %>%
  bind_tf_idf(term, document, count)

# Convert the corpus to a tidy text dataset
tidy_corpus <- tidy(corpus)
tidy_corpus
# Word frequencies
word_freq <- tidy_dtm_idf %>%
  count(term, sort = TRUE)

# Filter words based on TF-IDF threshold
filtered_words <- tidy_dtm_idf %>%
  filter(tf_idf >= mean(tf_idf)) %>%
  count(term, sort = TRUE)

# Generate word cloud with filtered words
wordcloud2(filtered_words, 
           color='random-dark', 
           shape='cloud', 
           rotateRatio=1)

wordcloud2(word_freq, 
           color = 'random-dark',
           shape = 'cloud',
           rotateRatio = 1) # Generate word cloud with all word frequencies


# view certain columns
View (airbnb_all$availability)
View(airbnb_all$review_scores)
View(airbnb_all$reviews)
View(airbnb_all$weekly_price)
View(airbnb_all$monthly_price)
View(airbnb_all$reviews_per_month)
str(airbnb_all)

################################################################################
#### LDA MODEL - 
################################################################################

# Run Latent Dirichlet Allocation (LDA) on the Document-Term Matrix (DTM) with 3 topics
lda_model <- LDA(dtm, k = 3)

# Extract and view the terms most associated with each topic based on their beta values
topics <- tidy(lda_model, matrix = "beta")

# Select the top 10 terms for each topic based on their beta values and arrange them
top_terms <- topics %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

# Print the selected top terms for each topic to the console for inspection
print(top_terms,n=30)

# Plot the top 3 terms for each topic based on their beta values
ggplot(top_terms, aes(x = reorder(term, beta), y = beta, fill = factor(topic))) +
  geom_bar(stat = "identity") + # Use bars to represent the beta values
  coord_flip() + # Flip coordinates for horizontal bar chart
  labs(title = "Top 3 Terms in Each Topic from LDA Model", x = "Terms", y = "Beta") + # Set plot labels
  scale_fill_discrete(name = "Topic") + # Color bars based on the topic
  theme_minimal() + # Use a minimal theme for the plot
  theme(legend.title = element_text(size = 10), legend.text = element_text(size = 8)) # Adjust legend text size

################################################################################
#### PERFORMING SENTIMENT ANALYSIS ON THE 'DESCRIPTION' COLUMN OF THE AIRBNB DATASET

#### 1. Tokenize the 'description' column into individual words
#### 2. Join the tokens with the AFINN sentiment lexicon to assign sentiment scores
#### 3. Group the data by 'document_id' to aggregate at the listing level
#### 4. Calculate the mean sentiment score for each listing 
################################################################################

sentiment_scores <- airbnb_df %>%
  unnest_tokens(word, description) %>%
  inner_join(get_sentiments("afinn")) %>%
  group_by(document_id) %>%
  summarise(Sentiment_Score = mean(value))
# Display the calculated sentiment scores
sentiment_scores

# Visualize the distribution of sentiment scores for the Airbnb listings
# 1. Plot the sentiment scores using a histogram
# 2. Customize the histogram appearance and labels
ggplot(sentiment_scores, aes(x = Sentiment_Score)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "black") +
  labs(title = "Sentiment analysis on the 'description' column of the Airbnb dataset (AFINN)",
       x = "Sentiment Score",
       y = "Count")

# Display the mean and sum of sentiment scores for additional insights
mean(sentiment_scores$Sentiment_Score)
sum(sentiment_scores$Sentiment_Score)

################################################################################
#### SEGMENTING LISTINGS INTO PRICE CATEGORIES AND CONDUCTING SENTIMENT ANALYSIS 
#### WITH BING AND NRC LEXICONS
################################################################################

# Create price categories based on terciles
airbnb_df <- airbnb_df %>%
  mutate(price_category = ntile(price, 3))

# View the first few rows to confirm the price categories are added
head(airbnb_df)

# Split the dataset into three separate data frames for low, medium, and high price categories
low_price <- airbnb_df %>% filter(price_category == 1)
medium_price <- airbnb_df %>% filter(price_category == 2)
high_price <- airbnb_df %>% filter(price_category == 3)

# Tokenize the 'description' text for each price category into individual words
low_price_tokens <- low_price %>%
  unnest_tokens(word, description)

medium_price_tokens <- medium_price %>%
  unnest_tokens(word, description)

high_price_tokens <- high_price %>%
  unnest_tokens(word, description)

# Load pre-defined sentiment lexicons for sentiment analysis
afinn <- get_sentiments("afinn") # AFINN lexicon
nrc <- get_sentiments("nrc") # NRC lexicon
bing <- get_sentiments("bing") # Bing lexicon

# Combine all three sentiment lexicons into a single dataframe
sentiments <- bind_rows(
  mutate(afinn, lexicon = "afinn"),
  mutate(nrc, lexicon = "nrc"),
  mutate(bing, lexicon = "bing")
)

###### BING 

# Merge the tokenized words with sentiment scores for the low-price category
low_price_sentiment <- low_price_tokens %>%
  inner_join(sentiments, by = "word")

# Visualize the sentiment counts for the low-price category using the Bing lexicon
df_low_price_bing_counts <- low_price_sentiment %>%
  filter(lexicon == "bing") %>%
  count(sentiment)

# Plot showing count of positive vs negative sentiments for low-price listings
ggplot(df_low_price_bing_counts, aes(x = sentiment, y = n, fill = sentiment)) +
  geom_bar(stat = "identity") +
  labs(title = "Low-Price Listing Descriptions: Count of Positive vs Negative Sentiments (Bing)", x = "Sentiment", y = "Count") +
  scale_fill_manual(values = c("positive" = "green", "negative" = "red"))

# Process and visualize sentiment counts for medium-price category in a similar manner
medium_price_sentiment <- medium_price_tokens %>%
  inner_join(sentiments, by = "word")

# Visualize sentiment counts for medium-price category
df_medium_price_bing_counts <- medium_price_sentiment %>%
  filter(lexicon == "bing") %>%
  count(sentiment)

# Plot for medium-price listings
ggplot(df_medium_price_bing_counts, aes(x = sentiment, y = n, fill = sentiment)) +
  geom_bar(stat = "identity") +
  labs(title = "Medium-Price Listing Descriptions: Count of Positive vs Negative Sentiments (Bing)", x = "Sentiment", y = "Count") +
  scale_fill_manual(values = c("positive" = "green", "negative" = "red"))

# Process and visualize sentiment counts for high-price category in a similar manner
high_price_sentiment <- high_price_tokens %>%
  inner_join(sentiments, by = "word")

# Visualize sentiment counts for high-price category
df_high_price_bing_counts <- high_price_sentiment %>%
  filter(lexicon == "bing") %>%
  count(sentiment)

# Plot for high-price listings
ggplot(df_high_price_bing_counts, aes(x = sentiment, y = n, fill = sentiment)) +
  geom_bar(stat = "identity") +
  labs(title = "High-Price Listing Descriptions: Count of Positive vs Negative Sentiments (Bing)", x = "Sentiment", y = "Count") +
  scale_fill_manual(values = c("positive" = "green", "negative" = "red"))

######## NRC 
# Filter for NRC lexicon
nrc <- get_sentiments("nrc")

# Join tokens with NRC sentiments for the low_price category
low_price_nrc_sentiment <- low_price_tokens %>%
  inner_join(nrc, by = "word")

# Count the frequency of each sentiment/emotion for low_price
low_price_nrc_counts <- low_price_nrc_sentiment %>%
  count(sentiment, sort = TRUE)

# Visualize the sentiment/emotion counts for low_price using NRC
ggplot(low_price_nrc_counts, aes(x = sentiment, y = n, fill = sentiment)) +
  geom_bar(stat = "identity") +
  labs(title = "Low-Price Listing Descriptions: Sentiment and Emotions Counts (NRC)", x = "Sentiment/Emotion", y = "Count") +
  scale_fill_viridis_d(begin = 0.5, end = 1) + # Using viridis for a colorful palette
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Improve readability of x labels

# Join tokens with NRC sentiments for the medium_price category
medium_price_nrc_sentiment <- medium_price_tokens %>%
  inner_join(get_sentiments("nrc"), by = "word")

# Count the frequency of each sentiment/emotion for medium_price
medium_price_nrc_counts <- medium_price_nrc_sentiment %>%
  count(sentiment, sort = TRUE)

# Visualize the sentiment/emotion counts for medium_price using NRC
ggplot(medium_price_nrc_counts, aes(x = sentiment, y = n, fill = sentiment)) +
  geom_bar(stat = "identity") +
  labs(title = "Medium-Price Listing Descriptions: Sentiment and Emotions Counts (NRC)", x = "Sentiment/Emotion", y = "Count") +
  scale_fill_viridis_d(begin = 0.5, end = 1) + # Using viridis for a colorful palette
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 

# Join tokens with NRC sentiments for the high_price category
high_price_nrc_sentiment <- high_price_tokens %>%
  inner_join(get_sentiments("nrc"), by = "word")

# Count the frequency of each sentiment/emotion for high_price
high_price_nrc_counts <- high_price_nrc_sentiment %>%
  count(sentiment, sort = TRUE)

# Visualize the sentiment/emotion counts for high_price using NRC
ggplot(high_price_nrc_counts, aes(x = sentiment, y = n, fill = sentiment)) +
  geom_bar(stat = "identity") +
  labs(title = "High-Price Listing Descriptions: Sentiment and Emotions Counts (NRC)", x = "Sentiment/Emotion", y = "Count") +
  scale_fill_viridis_d(begin = 0.5, end = 1) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Improve readability of x labels

###############################################################################
#### TOKENIZATION
###############################################################################


# Tokenize text descriptions into bigrams (pairs of adjacent words)
airbnb_bigrams <- airbnb_df %>%
  unnest_tokens(bigram, description, token = "ngrams", n = 2)

# Separate the bigrams into their constituent words for further processing
bigrams_separated <- airbnb_bigrams %>%
  separate(bigram, into = c("word1", "word2"), sep = " ")

# Load the list of common stop words
data("stop_words")

# Remove common stop words from the bigrams to focus on more meaningful word pairs
bigrams_filtered <- bigrams_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word)

# Combine the words back into bigrams and count the frequency of each unique bigram
bigram_counts <- bigrams_filtered %>%
  unite(bigram, word1, word2, sep = " ") %>%
  count(bigram, sort = TRUE)

# Visualize the top 20 most common bigrams across all listing
ggplot(bigram_counts[1:20,], aes(x = reorder(bigram, n), y = n)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 20 Most Common Bigrams in Airbnb Listing Descriptions",
       x = "Bigram",
       y = "Frequency")


###############################################################################
#### VISUALIZATION FUNCTION 
###############################################################################

# Function to tokenize text into bigrams, filter out stop words, and visualize the top 20 most common bigrams
process_and_visualize_bigrams <- function(data, title_prefix) {
  # Tokenize text descriptions into bigrams
  bigrams <- data %>%
    unnest_tokens(bigram, description, token = "ngrams", n = 2)
  
  
  # Separate the bigrams into their constituent words
  bigrams_separated <- bigrams %>%
    separate(bigram, into = c("word1", "word2"), sep = " ")
  

  # Filter out common stop words from the bigrams
  data("stop_words")
  bigrams_filtered <- bigrams_separated %>%
    filter(!word1 %in% stop_words$word) %>%
    filter(!word2 %in% stop_words$word)
  
  # Combine words back into bigrams, count their frequency, and sort
  bigram_counts <- bigrams_filtered %>%
    unite(bigram, word1, word2, sep = " ") %>%
    count(bigram, sort = TRUE)

  # Visualize the top 20 most common bigrams for the given dataset
  ggplot(bigram_counts[1:20,], aes(x = reorder(bigram, n), y = n)) +
    geom_col(fill = "steelblue") +
    coord_flip() +
    labs(title = paste("Top 20 Most Common Bigrams in", title_prefix, "Airbnb Listing Descriptions"),
         x = "Bigram",
         y = "Frequency")
}


# Apply the visualization function to datasets of low, medium, and high price categories
process_and_visualize_bigrams(low_price, "Low Price")
process_and_visualize_bigrams(medium_price, "Medium Price")
process_and_visualize_bigrams(high_price, "High Price")

# Define a function to perform n-gram analysis
perform_ngram_analysis <- function(df, category_name) {
  # Tokenize descriptions into bigrams, filter out stop words, and count frequency of bigrams
  bigrams <- df %>%
    unnest_tokens(bigram, description, token = "ngrams", n = 2) %>%
    separate(bigram, into = c("word1", "word2"), sep = " ") %>%
    filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word) %>%
    unite(bigram, word1, word2, sep = " ") %>%
    count(bigram, sort = TRUE) %>%
    top_n(10, n) # Select top 10 most frequent bigrams
  
  # Plot the top 10 bigrams for the specified category
  ggplot(bigrams, aes(x = reorder(bigram, n), y = n, fill = bigram)) +
    geom_col() +
    coord_flip() +
    labs(title = paste("Top 10 Bigrams in", category_name, "Price Category"),
         x = NULL,
         y = "Frequency") +
    theme_minimal() +
    theme(legend.position = "none")
  
  # Tokenize descriptions into quadrograms, filter out stop words, and count frequency of quadrograms
  quadrograms <- df %>%
    unnest_tokens(quadrogram, description, token = "ngrams", n = 4) %>%
    separate(quadrogram, c("word1", "word2", "word3", "word4"), sep=" ") %>%
    filter(!word1 %in% stop_words$word) %>%
    filter(!word2 %in% stop_words$word) %>%
    filter(!word3 %in% stop_words$word) %>%
    filter(!word4 %in% stop_words$word) %>%
    unite(quadrogram, word1, word2, word3, word4, sep = " ") %>%
    count(quadrogram, sort = TRUE) %>%
    top_n(10, n) # Select top 10 most frequent quadrograms
  
  # Plot the top 10 quadrograms for the specified category
  ggplot(quadrograms, aes(x = reorder(quadrogram, n), y = n, fill = quadrogram)) +
    geom_col() +
    coord_flip() +
    labs(title = paste("Top 10 Quadrograms in", category_name, "Price Category"),
         x = NULL,
         y = "Frequency") +
    theme_minimal() +
    theme(legend.position = "none")
}

# Apply the n-gram analysis function to each price category dataset
perform_ngram_analysis(low_price, "Low")
perform_ngram_analysis(medium_price, "Medium")
perform_ngram_analysis(high_price, "High")

# Tokenizing descriptions into words for neighborhood overview analysis
tokenized_words <- airbnb_df %>%
  unnest_tokens(word, description) %>%
  count(neighborhood_overview, word, sort = TRUE) # Count word frequencies by neighborhood overview


# If you want to see the dataframe used for plotting, print it to the console
print(top_terms)

# Install and load the writexl package to enable writing data frames to Excel files
install.packages('writexl')
library(writexl)

# Write the high_price dataframe to an Excel file on the specified path
write_xlsx(high_price,'/Users/greta/Desktop/untitled folder/highprice.xlsx')
