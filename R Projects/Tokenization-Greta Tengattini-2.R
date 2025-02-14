
# STEP 1 : BUILDING A SMALL TEXT OBJECT
my_txt <- c("Rise up this morning",
            "smiled with the rising sun",
            "Three little birds pitch by my doorstep",
            "Singing sweet songs of melodies pure and true",
           "Saying This is my message to you-ou-ou",
           "Singing Don't worry about a thing",
           "Cause every little thing is gonna be alright")

######################################################

#STEP 2: PUTTING THE VECTOR IN A DATA 

install.packages("dplyr")
library(dplyr)
mydf <- data.frame(line=1:7, text=my_txt)
print(mydf)

######################################################
# STEP 3 - TOKENIZING THE MYDF DATAFRAME 

install.packages("tidytext")
install.packages("tidyverse")
library(tidytext)
library(tidyverse)
token_list <- mydf %>%
                   unnest_tokens(word,text)
            
print(token_list)

######################################################
# STEP 4 - TOKEN FREQUENCIES
frequencies_tokens <- mydf %>%
                       unnest_tokens(word,text) %>%
                        count(word,sort=TRUE)
print(frequencies_tokens)

######################################################
#STEP 5 - STOP WORDS


install.packages("stringr")
library(stringr)

data(stop_words)
frequencies_tokens_nostop <- mydf %>%
                           unnest_tokens(word,text) %>%
                           anti_join(stop_words) %>%
                           count(word, sort=TRUE)

print(frequencies_tokens_nostop)

 ######################################################
#STEP 6 - TOKEN FREQUENCY HISTOGRAM 

library(ggplot2)
freq_list <- mydf %>%
                  unnest_tokens(word,text) %>%
                  anti_join(stop_words) %>%
                  count(word, sort=TRUE) %>%
                  mutate(word=reorder(word, n)) %>%
                  ggplot(aes(word, n))+
                  geom_col()+
                  xlab(NULL)+
                  coord_flip()
print(freq_list)
