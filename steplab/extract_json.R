extract_json <- function(x, data = "", col = ""){
  
  # convert json to r
  tmp <- rjson::fromJSON(x)
  
  # convert json list to df
  tmp <- as.data.frame(tmp)
  
  # select relevant columns
  tmp <- tmp[, c(grep("question.text|response.choices.text|response.choices.selected", names(tmp)))]
  
  # add user_id
  tmp$user_id <- data[which(x == data[, col]), "user_id"]
  
  # spit out
  return(tmp)
  
}

# DEBUG
# x <- df[1, "raw_pretest"]
# data = df
# col = "raw_pretest"
# tmp <- extract_json(x, data = df, col = "raw_pretest")

