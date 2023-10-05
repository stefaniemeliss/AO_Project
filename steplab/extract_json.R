extract_json <- function(x, data = "", col = ""){
  
  # convert json to r
  tmp <- rjson::fromJSON(x)
  
  # convert list to tibble
  tmp <- tibble(data = tmp)
  
  # add user_id
  tmp$user_id <- data[which(x == data[, col]), "user_id"]
  
  # spit out
  return(tmp)
  
}

# DEBUG
# x <- df[1, "raw_posttest"]
# data = df
# col = "raw_posttest"
# tmp <- extract_json(x, data = df, col = "raw_posttest")