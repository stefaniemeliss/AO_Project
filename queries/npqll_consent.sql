-- counts for consent
SELECT
    response -> 0 -> 'response' -> 'choices' -> 0 ->> 'selected' AS consent_given
    , count(*)
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%orient%'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%research%'
GROUP BY
    1;

-- create list of consenting ppt for LMS
SELECT
    user_id, user_name,
    response -> 0 -> 'response' -> 'choices' -> 0 ->> 'selected' AS consent_given,
    response
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%orient%'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%research%';


-- behaviour throughout the orientation module
SELECT
--*
    count(accessed) AS count_accessed
    , count(completed) AS count_completed
FROM
    user_modules AS um
WHERE
    usercourse_name ILIKE '%npqll%orient%feb%'
    --AND mod_name ILIKE '%welcome%' -- counts for 1. welcome
    --AND mod_name ILIKE '%programme%overview%' -- counts for 2. programme overview
    --AND mod_name ILIKE '%online%module%' -- counts for 3. online modules
    --AND mod_name ILIKE '%clinics%conf%' -- counts for 4. clinics and conferences
    --AND mod_name ILIKE '%assessment%' -- counts for 5. assessment
    AND mod_name ILIKE '%research%' -- counts for 6. research
    --AND mod_name ILIKE '%next%step%' -- counts for 7. next steps
    AND usercourse_name NOT ILIKE '%test%'
    AND accessed->>'first' IS NOT NULL

    
-- behaviour throughout the orientation module
-- use CASE WHEN instead of above
SELECT
    -- counts for 1. welcome
    sum(CASE WHEN mod_name ILIKE '%welcome%' THEN 1 ELSE 0 END) AS total_welcome ,
    sum(CASE WHEN mod_name ILIKE '%welcome%' AND completed IS NOT NULL THEN 1 ELSE 0 END) AS completed_welcome ,
    -- counts for 2. programme overview
    sum(CASE WHEN mod_name ILIKE '%programme%overview%' THEN 1 ELSE 0 END) AS total_overview ,
    sum(CASE WHEN mod_name ILIKE '%programme%overview%' AND completed IS NOT NULL THEN 1 ELSE 0 END) AS completed_overview ,
    -- counts for 3. online modules
    sum(CASE WHEN mod_name ILIKE '%online%module%' THEN 1 ELSE 0 END) AS total_online ,
    sum(CASE WHEN mod_name ILIKE '%online%module%' AND completed IS NOT NULL THEN 1 ELSE 0 END) AS completed_online ,
    -- counts for 4. clinics and conferences
    sum(CASE WHEN mod_name ILIKE '%assessment%' THEN 1 ELSE 0 END) AS total_assessment ,
    sum(CASE WHEN mod_name ILIKE '%assessment%' AND completed IS NOT NULL THEN 1 ELSE 0 END) AS completed_assessment ,
    -- counts for 6. research
    sum(CASE WHEN mod_name ILIKE '%research%' THEN 1 ELSE 0 END) AS total_research ,
    sum(CASE WHEN mod_name ILIKE '%research%' AND completed IS NOT NULL THEN 1 ELSE 0 END) AS completed_research ,
    -- counts for 7. next steps
    sum(CASE WHEN mod_name ILIKE '%next%step%' THEN 1 ELSE 0 END) AS total_next ,
    sum(CASE WHEN mod_name ILIKE '%next%step%' AND completed IS NOT NULL THEN 1 ELSE 0 END) AS completed_next
FROM
    user_modules AS um
WHERE
    usercourse_name ILIKE '%npqll%orient%feb%'
    AND usercourse_name NOT ILIKE '%test%'
    -- differentiate between accessed * and accessed **
    --AND accessed->>'first' IS NOT NULL