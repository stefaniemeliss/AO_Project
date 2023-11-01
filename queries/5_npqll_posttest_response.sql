-- this script queries post-test data fom the user_mod_reflections table
-- the object was embedded in Course 2 ("Developing writing") Module 1 ("How pupils learn to write")    

-- raw post-test data
SELECT
    *
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%develop%writing'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%post%test%'
    AND "completedDt" < '2023-11-01 00:00:00.000'

-- cleaned post-test data
SELECT
    user_id, 
    --user_name, 
    "completedDt" AS dt_posttest_complete,
    response AS raw_posttest
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%develop%writing'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%post%test%'
    AND "completedDt" < '2023-11-01 00:00:00.000' 
ORDER BY dt_posttest_complete
    
        
