# clear workspace
rm(list = ls())

# change directory
proj_dir <- getwd()
cd <- file.path(proj_dir, "pilots", "manipulation_posttest")
setwd(cd)

# load data from csv file
data <- read.csv("elexicon_AO.csv", na.strings = "#")

# calculate weighted mean
weighted_means <- lapply(data[ , 3:ncol(data)], weighted.mean, w = data$Occurrences, na.rm = T)
weighted_means_df <- as.data.frame(weighted_means)
weighted_means_df <- data.frame(t(weighted_means_df))
names(weighted_means_df) <- "w_mean"

# calculate weighted SD
weighted_vars <- lapply(data[ , 3:ncol(data)], Hmisc::wtd.var, w = data$Occurrences, na.rm = T)
weighted_vars_df <- as.data.frame(weighted_vars)
weighted_sd_df <- sqrt(weighted_vars_df)
weighted_sd_df <- data.frame(t(weighted_sd_df))
names(weighted_sd_df) <- "w_sd"

# collect all data in output table
out <- data.frame(var = row.names(weighted_means_df))
out$ao <- paste0(round(weighted_means_df$w_mean, 2), " (", round(weighted_sd_df$w_sd, 2), ")")

# load data from csv file
data <- read.csv("elexicon_nonAO.csv", na.strings = "#")

# calculate weighted mean
weighted_means <- lapply(data[ , 3:ncol(data)], weighted.mean, w = data$Occurrences, na.rm = T)
weighted_means_df <- as.data.frame(weighted_means)
weighted_means_df <- data.frame(t(weighted_means_df))
names(weighted_means_df) <- "w_mean"

# calculate weighted SD
weighted_vars <- lapply(data[ , 3:ncol(data)], Hmisc::wtd.var, w = data$Occurrences, na.rm = T)
weighted_vars_df <- as.data.frame(weighted_vars)
weighted_sd_df <- sqrt(weighted_vars_df)
weighted_sd_df <- data.frame(t(weighted_sd_df))
names(weighted_sd_df) <- "w_sd"

# collect all data in output table
out$nonAo <- paste0(round(weighted_means_df$w_mean, 2), " (", round(weighted_sd_df$w_sd, 2), ")")
write.csv(out, file = "elexikon_summary_stats.csv")
