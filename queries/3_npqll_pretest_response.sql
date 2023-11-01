-- this script queries pre-test data fom the user_mod_reflections table
-- the object was embedded in Course 2 ("Developing language") Module 1 ("Developing spoken language")    

-- raw pretest data
SELECT
    *
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%develop%language'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%pre%test%' 
    AND "completedDt" < '2023-11-01 00:00:00.000'

-- cleaned pre-test data
SELECT
    user_id, 
    --user_name, 
    "completedDt" AS dt_pretest_complete,
    response AS raw_pretest
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%develop%language'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%pre%test%'
    AND "completedDt" < '2023-11-01 00:00:00.000'
    


    
