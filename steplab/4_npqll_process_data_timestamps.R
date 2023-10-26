###############################################################################
# this script checks timestamps to evaluate intervention fidelity
###############################################################################


# this script extracts all time stamps from the steplab data needed to conduct analysis specified in the pre-reg

#### --- from data analysis plan in pre-reg --- ####

# EXCLUSION: 
# Steplab collects timestamps for each module, showing when a module was first and most recently accessed, and when it was marked as completed. 
# For objects within a module, timestamps are collected every time if an object is accessed and when an object is marked as completed. 
# These timestamps are a proxy of participant engagement with the research content and can thereby be used to estimate adherence to the study protocol. 
# Participants will be excluded if their engagement data suggests that the manipulation was invalidated. 
# The manipulation is regarded as invalidated if participants meet either of the following criteria: 
# (1) The timestamp of when the object containing the to-be-learned material (Course 3, Module 1) was accessed predates the timestamp of when the object containing the prior knowledge assessment (Course 2, Module 1) was marked as completed; or 
# (2) the object containing the to-be-learned material was accessed before the object containing the introductory material.

# SENSITIVITY:
# There may be other special cases where the participants have fallen behind in their online studies and Course 3 is released to them before they have completed the prior knowledge assessment in Course 2, Module 1. 
# Likewise, participants may complete modules within a course in non-sequential order. In these cases, sensitivity analyses will be conducted to determine whether the inclusion or exclusion of such participants impacts the results.

# ROBUSTNESS:
# the intervals between (1) introductory material and evidence summary and (2) evidence summary and learning outcome assessment will be included as additional covariates

#### --- list of timestamps required --- ####

# 1. timestamps of when pretest and posttests were completed
#       included in 'dt_[pre/post]test_complete' queried in 3_npqll_pretest_response.sql and 5_npqll_posttest_response.sql
# 2. timestamps of when all modules in Courses 1-4 were accessed/marked as completed/last modified
#       included in 'dt_mod_access_[first/last]' and 'dt_mod_complete' queried in 4_npqll_engagement_modules.sql
# 3. timestamp of when objects that contain AO/non-AO and learning material were accessed/marked as completed/last modified
#       included as 'dt_event' queried in 4_npqll_engagement_objects.sql


#### --- set ups --- ####

# empty work space
rm(list = ls())

# define directory
dir <- getwd()
dir_sql <- file.path(dir, "queries")
dir_export <- file.path(dir_sql, "usermodobjects_export")

# load in functions
library(dplyr)
library(arrow)
library(tidyr)

#### --- load data --- ####

# - usermods (User modules) data - #

# usermods data (queried using 4_npqll_engagement_modules.sql) contains information on study modules (e.g., name, ids) 
# as well as information when they were unlocked, first and last accessed, and completed
# the data below was filtered to only include consenting participants and relevant NPQ courses (1-4)

# load in file #
file <- list.files(path = dir_sql, pattern = glob2rx("4*modules*.csv"), full.names = T)
um <- read.csv(file)

# process time stamps #

# module released
um$dt_mod_release <- as.POSIXct(um$dt_mod_release) # convert to dt object 

# module accessed first time
um$dt_mod_access_first <- gsub("T", " ", um$dt_mod_access_first) # remove weird T
um$dt_mod_access_first <- ifelse(um$dt_mod_access_first != "", um$dt_mod_access_first, NA) # replace "" with NA
um$dt_mod_access_first <- as.POSIXct(um$dt_mod_access_first) # convert to dt object

# module accessed most recent time
um$dt_mod_access_last <- gsub("T", " ", um$dt_mod_access_last) # remove weird T
um$dt_mod_access_last <- ifelse(um$dt_mod_access_last != "", um$dt_mod_access_last, NA) # replace "" with NA
um$dt_mod_access_last <- as.POSIXct(um$dt_mod_access_last) # convert to dt object

# module marked as completed
um$dt_mod_complete <- gsub(".000", " ", um$dt_mod_complete) # remove hyper precision
um$dt_mod_complete <- ifelse(um$dt_mod_complete != "", um$dt_mod_complete, NA) # replace "" with NA
um$dt_mod_complete <- as.POSIXct(um$dt_mod_complete) # convert to dt object

# rename id for consistency #

names(um)[names(um) == "id"] <- "mod_id"

# get list of unique user and module ids #

id_user <- unique(um$user_id)
id_mod <- unique(um$mod_id)

# - usermodobjects (User module objects) data - #

# the usermodobjects (User module objects) data is not recorded reliably in Aircury
# data was exported by Steplab manually and made available in tabular form in .parquet format for each month separately
# data captures engagements with objects in each module

# create list of files in export folder #
files <- list.files(path = dir_export, pattern = ".parquet")

# loop through each file in folder #
for (f in 1:length(files)) {
  
  # load data 
  tmp <- read_parquet(file = file.path(dir_export, files[f]))
  
  # reduce data
  tmp <- tmp %>%
    filter(userMod_id %in% id_mod) %>% # filter to only include relevant modules
    mutate( # modify columns
      user_id = userId,
      mod_id = userMod_id,
      event_subject = eventSubject,
      object_type = object_objectType,
      object_id = object_objectId,
      event_type = eventType,
      dt_event = eventDt
      ) %>%
    select( # select relevant columns only
      user_id,
      mod_id,
      event_subject,
      object_name,
      event_type,
      dt_event)
  
  # save data: combine across months
  if (f == 1) {
    umo <- tmp
  } else {
    umo <- rbind(umo, tmp)
  }
  
  # handle memory demands
  rm(tmp)
  gc()
}

# process time stamp
umo$dt_event <- gsub("T", " ", umo$dt_event) # remove weird T
umo$dt_event <- as.POSIXct(umo$dt_event) # convert to dt object

# # - combine um and umo to df - #
# df <- merge(um, umo, by = c("user_id", "mod_id"), all = T)
# df <- df[order(df$user_id, df$dt_event), ]

#### --- process data: define exclusion criteria --- ####

# - simplify umo data - #

# for all objects, determine when it was first and last accessed by each user
a <- umo %>% 
  filter(event_subject == "object" & event_type == "a") %>%
  group_by(user_id, object_name) %>%
  summarise(dt_obj_access_first = min(dt_event, na.rm = T),
            dt_obj_access_last = max(dt_event, na.rm = T))

# for all objects, determine when it was marked as completed by each user
c <- umo %>% 
  filter(event_subject == "object" & event_type == "c") %>%
  group_by(user_id, object_name) %>%
  summarise(dt_obj_complete = dt_event) # object only completed once

# combine
obj <- merge(a, c, by = c("user_id", "object_name"), all = T)
rm(a, c)

# - define objects that are used for research - #
objects_research <- c(
  "Pre-test",
  "NPQLL_3_1_AO",
  "NPQLL_3_1_NON-AO",
  "NPQLL_3_1_Evidence Summary Text",
  "NPQLL_4_1_research project_post-test"
)
# declare their component
comp_research <- c(
  "baseline",
  "mat_intr_exp",
  "mat_intr_cont",
  "mat_learn",
  "post"
)

# - transform data from long into wide format for each time stamp (first/last/complete) - #

# has to be done for each time stamp separately before merging 

# object marked as completed #
c <- obj %>% 
  # only research objects
  filter(object_name %in% objects_research) %>%
  # rename objects
  mutate(object_name = ifelse(object_name == objects_research[1], comp_research[1],
                              ifelse(object_name == objects_research[2], comp_research[2],
                                     ifelse(object_name == objects_research[3], comp_research[3],
                                            ifelse(object_name == objects_research[4], comp_research[4],
                                                   ifelse(object_name == objects_research[5], comp_research[5], NA)))))) %>%
  # reduce number of columns
  select(user_id, object_name, dt_obj_complete) %>%
  # long to wide
  pivot_wider(names_from = object_name, values_from = dt_obj_complete, names_prefix = "dt_c_") %>%
  # combine info fro both groups in one column
  mutate(dt_c_mat_intr = if_else(!is.na(dt_c_mat_intr_exp), dt_c_mat_intr_exp, dt_c_mat_intr_cont))

# object accessed first #
a_first <- obj %>% 
  # only research objects
  filter(object_name %in% objects_research) %>%
  # rename objects
  mutate(object_name = ifelse(object_name == objects_research[1], comp_research[1],
                              ifelse(object_name == objects_research[2], comp_research[2],
                                     ifelse(object_name == objects_research[3], comp_research[3],
                                            ifelse(object_name == objects_research[4], comp_research[4],
                                                   ifelse(object_name == objects_research[5], comp_research[5], NA)))))) %>%
  # reduce number of columns
  select(user_id, object_name, dt_obj_access_first) %>%
  # long to wide
  pivot_wider(names_from = object_name, values_from = dt_obj_access_first, names_prefix = "dt_a_f_") %>%
  # combine info fro both groups in one column
  mutate(dt_a_f_mat_intr = if_else(!is.na(dt_a_f_mat_intr_exp), dt_a_f_mat_intr_exp, dt_a_f_mat_intr_cont))

# object accessed last #
a_last <- obj %>% 
  # only research objects
  filter(object_name %in% objects_research) %>%
  # rename objects
  mutate(object_name = ifelse(object_name == objects_research[1], comp_research[1],
                              ifelse(object_name == objects_research[2], comp_research[2],
                                     ifelse(object_name == objects_research[3], comp_research[3],
                                            ifelse(object_name == objects_research[4], comp_research[4],
                                                   ifelse(object_name == objects_research[5], comp_research[5], NA)))))) %>%
  # reduce number of columns
  select(user_id, object_name, dt_obj_access_last) %>%
  # long to wide
  pivot_wider(names_from = object_name, values_from = dt_obj_access_last, names_prefix = "dt_a_l_") %>%
  # combine info fro both groups in one column
  mutate(dt_a_l_mat_intr = if_else(!is.na(dt_a_l_mat_intr_exp), dt_a_l_mat_intr_exp, dt_a_l_mat_intr_cont))

# merge data from all three time stamps #
dt <- merge(a_first, a_last, by = "user_id")
dt <- merge(dt, c, by = "user_id")
rm(a_first, a_last, c)

# - add module data from course 3 - #

# define relevant modules #
mods <- unique(um$mod_name[um$usercourse_name == "NPQLL Developing Reading"])

# module marked as completed #
tmp <- um %>% 
  # only research objects
  filter(mod_name %in% mods) %>%
  # reduce number of columns
  select(user_id, mod_code, dt_mod_complete) %>%
  # long to wide
  pivot_wider(names_from = mod_code, values_from = dt_mod_complete, names_prefix = "dt_c_c3_m") 

# add to dt #
dt <- merge(dt, tmp, by = "user_id")

# module accessed first #
tmp <- um %>% 
  # only research objects
  filter(mod_name %in% mods) %>%
  # reduce number of columns
  select(user_id, mod_code, dt_mod_access_first) %>%
  # long to wide
  pivot_wider(names_from = mod_code, values_from = dt_mod_access_first, names_prefix = "dt_a_f_c3_m") 

# add to dt #
dt <- merge(dt, tmp, by = "user_id")

# - code exclusion criteria - #

# exclude if #

# (1) timestamp learning material accessed first smaller timestamp baseline test completed
dt$exclude_1 <- dt$dt_a_f_mat_learn < dt$dt_c_baseline

# (2) timestamp learning material accessed first smaller timestamp introductory material accessed
dt$exclude_2 <- dt$dt_a_f_mat_learn < dt$dt_a_f_mat_intr

# - code sensitivity check criteria - #

# sensitivity analyses will be conducted to determine whether the inclusion or exclusion of pre-defined participants impacts the results

# (1) participants have fallen behind in their online studies 
# Course 3 released before baseline completed

dt_release_course3 <- 
  min(um$dt_mod_release[um$mod_name == "Learning to read" & ! um$user_id %in% c("USm5lky0f_c4", "USq4kmbe8pr0")]) # NOTE: USER IDs belong to users that should be excluded
dt$sens_excl_1 <- dt_release_course3 < dt$dt_c_baseline

# (2) participants may complete modules within a course in non-sequential order
# user user_modules data to  identify participants that *complete* modules in course in a different order
# 3.1 = "Learning to read" - dt$dt_c_c3_m1
# 3.2 = "Effective reading instruction" - dt$dt_c_c3_m2
# 3.3 = "Leading reading" - dt$dt_c_c3_m3
# if completed in sequential order, this should be reflected in the timestamps

dt$sens_excl_2 <- dt$dt_c_c3_m1 < dt$dt_c_c3_m2 & dt$dt_c_c3_m2 < dt$dt_c_c3_m3

# - code covariates - #

# intervals between 
# (1) introductory material and evidence summary 
# (2) evidence summary and learning outcome assessment

dt$int_1 <- difftime(dt$dt_c_mat_learn, dt$dt_c_baseline, units = "days")
dt$int_2 <- difftime(dt$dt_c_post, dt$dt_c_mat_learn, units = "days")

# (3) intro and learning material

dt$int_3 <- difftime(dt$dt_a_f_mat_learn, dt$dt_a_f_mat_intr)

# engagement duration
dt$dur_baseline <- difftime(dt$dt_c_baseline, dt$dt_a_f_baseline, units = "min")
dt$dur_mat_intro <- difftime(dt$dt_c_mat_intr, dt$dt_a_f_mat_intr, units = "secs")
dt$dur_mat_learn <- difftime(dt$dt_c_mat_learn, dt$dt_a_f_mat_learn, units = "secs")

# save data
write.csv(dt, file = "steplab/processed_data_timestamps.csv", row.names = F)
