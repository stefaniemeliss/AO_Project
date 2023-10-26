###############################################################################
# this script processes data collected at posttest
###############################################################################


#### --- set ups --- ####

# empty work space
rm(list = ls())

# define directory
dir <- getwd()
dir_sql <- file.path(dir, "queries")

# load in functions
source(file.path(dir, "steplab", "extract_json.R"))
library(tidyr)
library(dplyr)

#### --- load in posttest data --- ####

# load in file
file <- list.files(path = dir_sql, pattern = glob2rx("5*posttest*.csv"), full.names = T)
df <- read.csv(file)

# process date
df$dt_posttest_complete <- as.POSIXct(df$dt_posttest_complete)

#### --- process raw quiz responses --- ####

# extract json info into list
tmp <- apply(df[grep("raw_posttest", names(df))], MARGIN = 1, extract_json, data = df, col = "raw_posttest")

# make list to df
tmp <- as.data.frame(do.call(rbind, tmp))

#### - free text data - ####

# rectangle 
text <- tmp %>% 
  unnest_wider(data) %>% 
  unnest_wider(question) %>%
  unnest_wider(requirements) %>%
  filter(answer_type == "text") %>%
  unnest_wider(response) %>%
  unnest_wider(free_text, names_sep = "_")

# reduce to question and answer columns only
text <- text[, c("user_id", "text", "free_text_text")]

# rename
names(text)[grepl("text", names(text))] <- c("question_text", "response")

# add question number
text$iter <- rep.int(1:length(unique(text$question_text)), times = nrow(df))

# get questions into wide format
questions <- reshape2::dcast(text, user_id ~ iter, value.var = "question_text") # reshape from long to wide
names(questions)[2:ncol(questions)] <- paste0("question_text_", names(questions)[2:ncol(questions)]) # rename

# get answers into wide format
responses <- reshape2::dcast(text, user_id ~ iter, value.var = "response") # reshape from long to wide
names(responses)[2:ncol(responses)] <- paste0("response_", names(responses)[2:ncol(responses)]) # rename

# merge questions and responses for scoring
text <- merge(questions, responses, by = "user_id")

#### - multiple choice data - ####

# rectangle 
mc <- tmp %>% 
  unnest_wider(data) %>% 
  unnest_wider(question) %>%
  unnest_wider(requirements) %>%
  filter(answer_type != "text") %>%
  unnest_wider(response) %>%
  unnest_wider(choices, names_sep = "_") %>%
  unnest_wider(choices_1, names_sep = "_") %>%
  unnest_wider(choices_2, names_sep = "_") %>%
  unnest_wider(choices_3, names_sep = "_") %>%
  unnest_wider(choices_4, names_sep = "_") 


# rename
names(mc)[names(mc) == "text"] <- "question_text"

# reduce to question and answer columns only
mc <- mc[, grep("user_id|_text|selected|answers", names(mc))]

# add question number
mc$iter <- rep.int(1:length(unique(mc$question_text)), times = nrow(df))

# identify any errors
index_error <- mc %>% group_by(iter) %>%
  summarise(mean = mean(max_answers)) %>% # if settings had been correct, max_answers would have always been set to NA, max_answer == 1 is error
  filter(mean == 1) %>%
  select(1) %>% 
  unlist(., use.names=FALSE)

# get questions into wide format
questions <- reshape2::dcast(mc, user_id ~ iter, value.var = "question_text") # reshape from long to wide
names(questions)[2:ncol(questions)] <- paste0("question_text_", names(questions)[2:ncol(questions)]) # rename

# get choice options into wide format
n_choice <- ncol(mc[, grep(glob2rx('choices*text'), names(mc))])

for (i in 1:n_choice) {
  
  # choice text
  choice <- reshape2::dcast(mc, user_id ~ iter, value.var = paste0("choices_", i, "_text")) # reshape from long to wide
  names(choice)[2:ncol(choice)] <- paste0("question_", names(choice)[2:ncol(choice)], "_choice_", i) # rename
  
  # selected
  selected <- reshape2::dcast(mc, user_id ~ iter, value.var = paste0("choices_", i, "_selected")) # reshape from long to wide
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
mc <- merge(questions, responses, by = "user_id")

#### --- score free text answers --- ####

# extract all qs
qs_text <- as.data.frame(t(unique(text[, grep("question_text", names(text))])))
names(qs_text) <- "question_text"

# add solution
qs_text$solution <- c("prosody", #i1
                       "5", #i3
                       "morpheme", #i6
                       "suffix", #i7
                       "(comprehension) strategies / active comprehension", #i8
                       "(language) comprehension", #i9
                       "disciplinary literacy / subject-specific literacy", # i10
                       "6", #i11
                       "inference / inferencing / (verbal) reasoning", #i13
                       "decoding / word recognition / fluency", #i14
                       "systematic", #i15
                       "phonemes", #i17
                       "(an) orthography", #i18
                       "(reading) fluency", #i21
                       "3" #i22
)

# define acceptable solutions 
# this will be used for a grepl comparison for scoring
# check again once data collection is complete
accepted <- list(c("prosody"), #i1
                 c("5", "five"), #i3
                 c("morpheme"), #i6
                 c("suffix"), #i7
                 c("comprehension strategies"), #i8
                 c("language comprehension"), #i9
                 c("literacy"), # i10
                 c("6", "six"), #i11
                 c("inference", "inferencing", "reasoning"), #i13
                 c("decoding", "word recognition", "fluency"), #i14
                 c("systematic"), #i15
                 c("phonemes"), #i17
                 c("orthography"), #i18
                 c("fluency"), #i21
                 c("3", "three") #i22
)


for (i in 1:nrow(qs_text)) {
  
  cat("\n", i, "**ITEM:", qs_text$question_text[i], "**\n")
  cat("\n*CORRECT:*", qs_text$solution[i], "\n")
  
  # show all unique responses
  cat("\n\n*GIVEN ANSWERS:*", unique(tolower(text[,paste0("response_", i)])), sep = " -/- ")
  
  # show accepted
  cat("\n\n*ACCEPTED STEMS:*", accepted[[i]], sep = " -/- ")
  
  cat("\n\n\n\n")
  
  # ONCE DATA COLLECTION IS COMPLETE #
  # award points
  # if the provided answer matches any of the accepted patterns defined above, award point
  text[,paste0("score_", i)] <- ifelse(grepl(paste(accepted[[i]], collapse = "|"), tolower(text[,paste0("response_", i)])), 1, 0)
  text[,paste0("question_", i, "_score")] <- ifelse(grepl(paste(accepted[[i]], collapse = "|"), tolower(text[,paste0("response_", i)])), 1, 0)
  
}

# compute total score for free text items
text$score_text <- rowSums(text[, grep("_score", names(text))])

# remove all unnecessary columns
tmp <- text[, c("user_id", "score_text")]

# merge df and mc
df <- merge(tmp, df, by = "user_id")

#### --- score multiple choice answers --- ####

# extract all qs
question <- apply(mc[, grep("text", names(mc))], 2, unique)
option_1 <- apply(mc[, grep("choice_1", names(mc))], 2, unique)
option_2 <- apply(mc[, grep("choice_2", names(mc))], 2, unique)
option_3 <- apply(mc[, grep("choice_3", names(mc))], 2, unique)
option_4 <- apply(mc[, grep("choice_4", names(mc))], 2, unique)

qs_mc <- data.frame(question, option_1, option_2, option_3, option_4)

# add solutions
qs_mc$solution <- c(paste0(qs_mc$option_3[1]), # CAVEAT: max_answers as set to 1, making it de facto a single choice question
                    paste0(qs_mc$option_2[2]),
                    paste0(qs_mc$option_1[3]," / ", qs_mc$option_2[3], " / ", qs_mc$option_3[3]),
                    paste0(qs_mc$option_1[4], " / ", qs_mc$option_2[4]),
                    paste0(qs_mc$option_2[5]),
                    paste0(qs_mc$option_2[6], " / ", qs_mc$option_4[6]),
                    paste0(qs_mc$option_4[7]),
                    paste0(qs_mc$option_1[8], " / ", qs_mc$option_2[8]))

# - score answers -

for (i in 1:nrow(qs_mc)) {
  
  
  for (ii in 1:n_choice) {
    
    # combine choice and selected into one column: tmpresponse
    mc[, paste0("question_", i, "_tmpresponse_", ii)] <- ifelse(mc[, paste0("question_", i, "_selected_", ii)] == T, mc[, paste0("question_", i, "_choice_", ii)], "")
    
    if (!i %in% index_error) { # score like multiple choice
      
      # select the answer option wording
      option <- qs_mc[i, paste0("option_", ii)] # current answer option
      
      # determine correct answer (whether the option should have been selected or not)
      correct <- ifelse(grepl(option, qs_mc$solution[i]), option, "") # part of solution
      
      # compare given answer with correct answer to assign score
      mc[, paste0("question_", i, "_tmpscore_", ii)] <- ifelse(mc[, paste0("question_", i, "_tmpresponse_", ii)] == correct, 1, 0)
      
    }
  }
  
  if (i %in% index_error) { # score like single choice
    
    # concatenate tmp response into single response
    mc[, paste0("question_", i, "_response")] <- paste0(mc[, paste0("question_", i, "_tmpresponse_1")], 
                                                        mc[, paste0("question_", i, "_tmpresponse_2")],
                                                        mc[, paste0("question_", i, "_tmpresponse_3")],
                                                        mc[, paste0("question_", i, "_tmpresponse_4")])
    
    # determine correct answer string
    correct <- qs_mc$solution[i]
    
    # create score variable for each question
    mc[,paste0("question_", i, "_score")] <- ifelse(mc[, paste0("question_", i, "_response")] == correct, 1, 0)
    
  } else { # score like multiple choice

    # sum up points for question
    mc[, paste0("question_", i, "_score")] <- rowSums(mc[, grepl(paste0("question_", i, "_tmpscore"), names(mc))])
    
  }
  
}

# compute total sum score
mc$score_mc <- rowSums(mc[, grep("_score", names(mc))])

# remove all unnecessary columns
tmp <- mc[, c("user_id", "score_mc")]

# merge df and mc
posttest <- merge(tmp, df, by = "user_id")

# delete raw data
posttest$raw_posttest <- NULL



#### - learning experience data - ####

# load in file
file <- list.files(path = dir_sql, pattern = glob2rx("5*learnerXP*.csv"), full.names = T)
df <- read.csv(file)

# process date
df$dt_learnerxp_complete <- as.POSIXct(df$dt_learnerxp_complete)

# extract json info into list
tmp <- apply(df[grep("raw_learnerxp", names(df))], MARGIN = 1, extract_json, data = df, col = "raw_learnerxp")

# make list to df
tmp <- as.data.frame(do.call(rbind, tmp))


# rectangle 
xp <- tmp %>% 
  unnest_wider(data) %>% 
  unnest_wider(question) %>%
  unnest_wider(requirements) %>%
  unnest_wider(response) %>%
  unnest_wider(choices, names_sep = "_") %>%
  unnest_wider(choices_1, names_sep = "_") %>%
  unnest_wider(choices_2, names_sep = "_") %>%
  unnest_wider(choices_3, names_sep = "_") %>%
  unnest_wider(choices_4, names_sep = "_") %>%
  unnest_wider(choices_5, names_sep = "_") %>%
  unnest_wider(choices_6, names_sep = "_") %>%
  unnest_wider(choices_7, names_sep = "_")

# rename questions
names(xp)[names(xp) == "text"] <- "question_text"

# reduce to question and answer columns only
xp <- xp[, grep("user_id|_text|selected|answers", names(xp))]

# add question number
xp$iter <- rep.int(1:length(unique(xp$question_text)), times = nrow(df))

# check for any errors
xp %>% group_by(iter) %>%
  summarise(mean = mean(max_answers))

# get questions into wide format
questions <- reshape2::dcast(xp, user_id ~ iter, value.var = "question_text") # reshape from long to wide
names(questions)[2:ncol(questions)] <- paste0("question_text_", names(questions)[2:ncol(questions)]) # rename

# get choice options into wide format
n_choice <- ncol(xp[, grep(glob2rx('choices*text'), names(xp))])

for (i in 1:n_choice) {
  
  # choice text
  choice <- reshape2::dcast(xp, user_id ~ iter, value.var = paste0("choices_", i, "_text")) # reshape from long to wide
  names(choice)[2:ncol(choice)] <- paste0("question_", names(choice)[2:ncol(choice)], "_choice_", i) # rename
  
  # selected
  selected <- reshape2::dcast(xp, user_id ~ iter, value.var = paste0("choices_", i, "_selected")) # reshape from long to wide
  names(selected)[2:ncol(selected)] <- paste0("question_", names(selected)[2:ncol(selected)], "_selected_", i) # rename
  
  # merge and combine
  if (i == 1) {
    responses <- merge(choice, selected, by = "user_id")
  } else {
    responses <- merge(responses, merge(choice, selected, by = "user_id"), by = "user_id")
  }
  
  rm(choice, selected)
  
}

# merge questions and responses for xporing
xp <- merge(questions, responses, by = "user_id")

#### --- process answers --- ####

# extract all qs
question <- apply(xp[, grep("text", names(xp))], 2, unique)
option_1 <- apply(xp[, grep("choice_1", names(xp))], 2, unique)
option_2 <- apply(xp[, grep("choice_2", names(xp))], 2, unique)
option_3 <- apply(xp[, grep("choice_3", names(xp))], 2, unique)
option_4 <- apply(xp[, grep("choice_4", names(xp))], 2, unique)
option_5 <- apply(xp[, grep("choice_5", names(xp))], 2, unique)
option_6 <- apply(xp[, grep("choice_6", names(xp))], 2, unique)
option_7 <- apply(xp[, grep("choice_7", names(xp))], 2, unique)

qs_xp <- data.frame(question, option_1, option_2, option_3, option_4, option_5, option_6, option_7)


vars <- c("sat_im", "sat_lm", "effort", "difficulty")

for (i in 1:length(question)) {
  
  
  for (ii in 1:n_choice) {
    
    # combine choice and selected into one column: tmpresponse
    xp[, paste0("question_", i, "_tmpresponse_", ii)] <- ifelse(xp[, paste0("question_", i, "_selected_", ii)] == T, xp[, paste0("question_", i, "_choice_", ii)], "")
    
    # create numeric representation
    xp[, paste0("question_", i, "_tmpscore_", ii)] <- ifelse(xp[, paste0("question_", i, "_selected_", ii)] == T, ii, NA)
    
  }
  
  # concatenate tmp response into single response
  xp[, paste0(vars[i], "_response")] <- paste0(xp[, paste0("question_", i, "_tmpresponse_1")], 
                                                      xp[, paste0("question_", i, "_tmpresponse_2")],
                                                      xp[, paste0("question_", i, "_tmpresponse_3")],
                                                      xp[, paste0("question_", i, "_tmpresponse_4")],
                                                      xp[, paste0("question_", i, "_tmpresponse_5")],
                                                      xp[, paste0("question_", i, "_tmpresponse_6")],
                                                      xp[, paste0("question_", i, "_tmpresponse_7")]
                                                      )
  
  # determine score
  xp[, paste0(vars[i], "_score")] <- rowMeans(xp[, grep(paste0("question_", i, "_tmpscore_"), names(xp))] , na.rm = T)
  

}

# remove all unnecessary columns
xp <- xp[, grep("user_id|_score|_response", names(xp))]

# merge df and sc
df <- merge(df, xp, by = "user_id")

# delete raw data
df$raw_learnerxp <- NULL


# MERGE
df <- merge(posttest, df, by = "user_id")

# save data
write.csv(df, file = "steplab/processed_data_course_4_module_1.csv", row.names = F)

