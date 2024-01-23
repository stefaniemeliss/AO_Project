###############################################################################
# this script processes data collected at baseline
###############################################################################


#### --- set ups --- ####

# empty work space
rm(list = ls())


# define directory
dir <- getwd()
dir_sql <- file.path(dir, "queries")

# load in functions
devtools::source_url("https://github.com/stefaniemeliss/AO_Project/blob/main/steplab/extract_json.R?raw=TRUE")
library(tidyr)
library(dplyr)

#### --- get pretest data --- ####

# load in file
file <- list.files(path = dir_sql, pattern = glob2rx("3*pretest*.csv"), full.names = T)
df <- read.csv(file)

# process date
df$dt_pretest_complete <- as.POSIXct(df$dt_pretest_complete)

#### --- process raw responses --- ####

# extract json info into list
sc <- apply(df[grep("raw_pretest", names(df))], MARGIN = 1, extract_json, data = df, col = "raw_pretest")

# make list to df
sc <- as.data.frame(do.call(rbind, sc))

# rectangle 
sc <- sc %>% 
  unnest_wider(data) %>% 
  unnest_wider(question) %>%
  unnest_wider(requirements) %>%
  unnest_wider(response) %>%
  unnest_wider(choices, names_sep = "_") %>%
  unnest_wider(choices_1, names_sep = "_") %>%
  unnest_wider(choices_2, names_sep = "_") %>%
  unnest_wider(choices_3, names_sep = "_") %>%
  unnest_wider(choices_4, names_sep = "_")

# rename questions
names(sc)[names(sc) == "text"] <- "question_text"

# reduce to question and answer columns only
sc <- sc[, grep("user_id|_text|selected|answers", names(sc))]

# add question number
sc$iter <- rep.int(1:length(unique(sc$question_text)), times = nrow(df))

# check for any errors
sc %>% group_by(iter) %>%
  summarise(mean = mean(max_answers))

# get questions into wide format
questions <- reshape2::dcast(sc, user_id ~ iter, value.var = "question_text") # reshape from long to wide
names(questions)[2:ncol(questions)] <- paste0("question_text_", names(questions)[2:ncol(questions)]) # rename

# get choice options into wide format
n_choice <- ncol(sc[, grep(glob2rx('choices*text'), names(sc))])

for (i in 1:n_choice) {
  
  # choice text
  choice <- reshape2::dcast(sc, user_id ~ iter, value.var = paste0("choices_", i, "_text")) # reshape from long to wide
  names(choice)[2:ncol(choice)] <- paste0("question_", names(choice)[2:ncol(choice)], "_choice_", i) # rename
  
  # selected
  selected <- reshape2::dcast(sc, user_id ~ iter, value.var = paste0("choices_", i, "_selected")) # reshape from long to wide
  names(selected)[2:ncol(selected)] <- paste0("question_", names(selected)[2:ncol(selected)], "_selected_", i) # rename
  
  # merge and combine
  if (i == 1) {
    responses <- merge(choice, selected, by = "user_id")
  } else {
    responses <- merge(responses, merge(choice, selected, by = "user_id"), by = "user_id")
  }
  
  rm(choice, selected)
  
}

# merge questions and responses for scoring
sc <- merge(questions, responses, by = "user_id")


#### --- define pretest --- ####

# extract all qs
question <- apply(sc[, grep("text", names(sc))], 2, unique)
option_1 <- apply(sc[, grep("choice_1", names(sc))], 2, unique)
option_2 <- apply(sc[, grep("choice_2", names(sc))], 2, unique)
option_3 <- apply(sc[, grep("choice_3", names(sc))], 2, unique)
option_4 <- apply(sc[, grep("choice_4", names(sc))], 2, unique)

qs_sc <- data.frame(question, option_1, option_2, option_3, option_4)

# add solutions
qs_sc$solution <-  c("Go beyond the literal meaning of the text.",
                     "Extrapolating.",
                     "Morphemes.",
                     "A phoneme.",
                     "Accuracy, automaticity and prosody.",
                     "Knowledge of comprehension strategies.",
                     "The smallest chunk of spoken sound that can distinguish one word from another.",
                     "The set of conventions associated with a written language.",
                     "Word recognition and language comprehension.",
                     "Words that are quite low frequency and restricted to specific domains.")



#### --- score answers --- ####

for (i in 1:nrow(qs_sc)) {
  
  
  for (ii in 1:n_choice) {
    
    # combine choice and selected into one column: tmpresponse
    sc[, paste0("question_", i, "_tmpresponse_", ii)] <- ifelse(sc[, paste0("question_", i, "_selected_", ii)] == T, sc[, paste0("question_", i, "_choice_", ii)], "")
    
  }
  
  # concatenate tmp response into single response
  sc[, paste0("question_", i, "_response")] <- paste0(sc[, paste0("question_", i, "_tmpresponse_1")], 
                                                      sc[, paste0("question_", i, "_tmpresponse_2")],
                                                      sc[, paste0("question_", i, "_tmpresponse_3")],
                                                      sc[, paste0("question_", i, "_tmpresponse_4")])
  
  # determine correct answer string
  correct <- qs_sc$solution[i]
  
  # create score variable for each question
  sc[,paste0("question_", i, "_score")] <- ifelse(sc[, paste0("question_", i, "_response")] == correct, 1, 0)
  
  
}

# compute total sum score
sc$score_pretest <- rowSums(sc[, grep("_score", names(sc))])

# remove all unnecessary columns
sc <- sc[, grep("user_id|score", names(sc))]

# merge df and sc
pretest <- merge(sc, df, by = "user_id")

# delete raw data
pretest$raw_pretest <- NULL

#### --- get demogs data --- ####

# load in file
file <- list.files(path = dir_sql, pattern = glob2rx("3*demogs*.csv"), full.names = T)
df <- read.csv(file)

# process date
df$dt_demogs_complete <- as.POSIXct(df$dt_demogs_complete)

# process gender
df$gender <- ifelse(df$male == "true", "male",
                    ifelse(df$female == "true", "female",
                           ifelse(df$different == "true", "describe differently",
                                  ifelse(df$not_disclosed == "true", NA, NA))))

# process age
df$age <- gsub("[[:punct:]]", "", df$age) # remove all speical characters
df$age <- ifelse(df$age == "null", NA, as.numeric(df$age))

# process experience
df$experience <- gsub("[[:punct:]]", "", df$experience) # remove all speical characters
df$experience <- ifelse(df$experience == "null", NA, df$experience)
df$experience <- gsub("and 2 terms", "", df$experience)
df$experience <- gsub("years", "", df$experience)
df$experience <- gsub("nearly", "", df$experience)
df$experience <- gsub("Nine", "9", df$experience)
df$experience <- as.numeric(df$experience)

df <- df[, c("user_id", "gender", "age", "experience", "dt_demogs_complete")]


# one participant indicated to be 3 years old
# replace with NA
df$age <- ifelse(df$age == 3, NA, df$age)


# MERGE
df <- merge(df, pretest, by = "user_id")

# remove data from staff
df <- subset(df, user_id != "US6x_3lb9169") # BK
df <- subset(df, user_id != "USl5714-8b-z") # KM

# save data
write.csv(df, file = "steplab/processed_data_course_2_module_1.csv", row.names = F)
