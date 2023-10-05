###############################################################################
# this script randomises consenting participants to groups
###############################################################################


# --- randomise ppt to groups ---
rm(list = ls())
set.seed(1212) # make reproducible

# load dplr
library(dplyr)

# read in ppt list
dir <- getwd()
ppts <- read.csv(file = file.path(dir, "queries", "npqll_consent_20230317.csv"))

# get all consenting IDs
ppts <- ppts[ppts$consent_given == "TRUE", ]

# remove unnessary cols
ppts <- ppts[,c("user_id", "user_name")]

# remove inactive ppt
inactive <- c("USy31loncpx0", "UShxd-tyde6o")
ppts <- ppts[! ppts$user_id %in% inactive, ]

# randomly assign to group
ao <- sample(ppts$user_id, size = nrow(ppts)/2)
ppts$group <- ifelse(ppts$user_id %in% ao, "AO", "non-AO")

# write file
write.csv(ppts, "npqll_random_group_assignment.csv", row.names = F)

# remove group to create a list of consenting participants for posttest
ppts$group <- NULL
write.csv(ppts, "npqll_posttest_ids.csv", row.names = F)
