-- this script queries learner experience data fom the user_mod_reflections table
-- the object was embedded in Course 2 ("Developing writing") Module 1 ("How pupils learn to write")    

-- raw learner experience data
SELECT
    *
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%develop%writing'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%learner%experience%' 

-- cleaned learner experience data
SELECT
    user_id, 
    --user_name, 
    "completedDt" AS dt_learnerXP_complete,
    response AS raw_learnerXP
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%develop%writing'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%learner%experience%'
    


        
