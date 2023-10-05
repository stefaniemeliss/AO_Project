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

