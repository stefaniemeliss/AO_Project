-- this script queries post-test data fom the user_mod_reflections table
-- the object was embedded in Course 2 ("Developing writing") Module 1 ("How pupils learn to write")    


-- cleaned post-test data
SELECT
    user_id, 
    --user_name, 
    "completedDt" AS posttest_completed,
    response AS posttest_raw
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%develop%writing'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%post%test%'
    

-- raw post-test data
SELECT
    *
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%develop%writing'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%post%test%' 
        
