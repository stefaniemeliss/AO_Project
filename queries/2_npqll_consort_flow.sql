-- this script queries data related to the participant flow
-- this information is included in the consort file

-- ELIGIBLE (n = 391)
SELECT
    -- counts for 1. welcome
    sum(CASE WHEN mod_name ILIKE '%welcome%' THEN 1 ELSE 0 END) AS total_welcome ,
    sum(CASE WHEN mod_name ILIKE '%welcome%' AND completed IS NOT NULL THEN 1 ELSE 0 END) AS completed_welcome, 
    -- counts for 6. research
    sum(CASE WHEN mod_name ILIKE '%research%' THEN 1 ELSE 0 END) AS total_research ,
    sum(CASE WHEN mod_name ILIKE '%research%' AND completed IS NOT NULL THEN 1 ELSE 0 END) AS completed_research 
FROM
    user_modules AS um
WHERE
    usercourse_name ILIKE '%npqll%orient%feb%'
    AND usercourse_name NOT ILIKE '%test%'
    -- differentiate between accessed * and accessed **
    AND accessed->>'first' < '2023-03-17 00:00:00.000'
    
-- -- create list of consenting ppt for LMS
SELECT
    user_id, user_name,
    response -> 0 -> 'response' -> 'choices' -> 0 ->> 'selected' AS consent_given,
    "completedDt",
    response
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%orient%'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%research%'
    AND "completedDt" < '2023-03-17 00:00:00.000'
    
