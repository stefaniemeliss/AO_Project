### process tmp data ###

# empty work space
rm(list = ls())


# define directory
dir <- getwd()
dir_sql <- file.path(dir, "queries")

# load in functions
source(file.path(dir, "steplab", "extract_json.R"))

# - get pretest data

# load in file
file <- list.files(path = dir_sql, pattern = glob2rx("3*pretest*.csv"), full.names = T)
df <- read.csv(file)

# process date
df$dt_pretest_complete <- as.POSIXct(df$dt_pretest_complete)

# - process raw responses -

# test characteristics
n_choice <- 4
n_quest <- 10

# extract json info into list
tmp <- apply(df[grep("raw_pretest", names(df))], MARGIN = 1, extract_json, data = df, col = "raw_pretest")
# make list to df
tmp <- as.data.frame(do.call(rbind, tmp))

# rename questions
names(tmp)[grep("question.text", names(tmp))] <- paste0("question_text_", 1:n_quest)

# rename response options
for (i in 1:n_quest) {
  if (i == 1) {
    names <- paste0("question_", i, paste0("_choice_", 1:n_choice))
  } else {
    names <- c(names, paste0("question_", i, paste0("_choice_", 1:n_choice)))
  }
}
names(tmp)[grep("response.choices.text", names(tmp))] <- names

# rename response choices
for (i in 1:n_quest) {
  if (i == 1) {
    names <- paste0("question_", i, paste0("_selected_", 1:n_choice))
  } else {
    names <- c(names, paste0("question_", i, paste0("_selected_", 1:n_choice)))
  }
}
names(tmp)[grep("response.choices.selected", names(tmp))] <- names

# - define pretest -

# create vector with all questions and answer options
question <- apply(tmp[, grep("text", names(tmp))], 2, unique)
option_1 <- apply(tmp[, grep("choice_1", names(tmp))], 2, unique)
option_2 <- apply(tmp[, grep("choice_2", names(tmp))], 2, unique)
option_3 <- apply(tmp[, grep("choice_3", names(tmp))], 2, unique)
option_4 <- apply(tmp[, grep("choice_4", names(tmp))], 2, unique)

# create vector with soluations
solution <- c("Go beyond the literal meaning of the text.",
              "Extrapolating.",
              "Morphemes.",
              "A phoneme.",
              "Accuracy, automaticity and prosody.",
              "Knowledge of comprehension strategies.",
              "The smallest chunk of spoken sound that can distinguish one word from another.",
              "The set of conventions associated with a written language.",
              "Word recognition and language comprehension.",
              "Words that are quite low frequency and restricted to specific domains.")


# integrate into df
solutions <- data.frame(question, option_1, option_2, option_3, option_4, solution, order = 1:n_quest)

# - score answers -

for (i in 1:n_quest) {
  
  for (ii in 1:n_choice) {
    
    # combine choice and selected into one column: tmpresponse
    tmp[, paste0("question_", i, "_tmpresponse_", ii)] <- ifelse(tmp[, paste0("question_", i, "_selected_", ii)] == T, tmp[, paste0("question_", i, "_choice_", ii)], "")
    
  }
  
  # concatenate tmp response into single response
  tmp[, paste0("question_", i, "_response")] <- paste0(tmp[, paste0("question_", i, "_tmpresponse_1")], 
                                                       tmp[, paste0("question_", i, "_tmpresponse_2")],
                                                       tmp[, paste0("question_", i, "_tmpresponse_3")],
                                                       tmp[, paste0("question_", i, "_tmpresponse_4")])
  
  # determine correct answer string
  correct <- solutions$solution[solutions$order == i]
  
  # create score variable for each question
  tmp[,paste0("question_", i, "_score")] <- ifelse(tmp[, paste0("question_", i, "_response")] == correct, 1, 0)
  
}

# compute total sum score
tmp$score_pretest <- rowSums(tmp[, grep("_score", names(tmp))])

# remove all unnecessary columns
tmp <- tmp[, c("user_id", "score_pretest")]

# merge df and tmp
pretest <- merge(tmp, df, by = "user_id")

# delete raw data
pretest$raw_pretest <- NULL



# - get demogs data

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


# MERGE
df <- merge(df, pretest, by = "user_id")
