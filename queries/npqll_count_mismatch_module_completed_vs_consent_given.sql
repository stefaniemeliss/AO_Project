-- COUNT all users that have accessed the research module in the Feb 2023 Orientation module
-- count = 349 (as of 09/03/2023)
SELECT count(user_id)
FROM 
    user_modules AS um
WHERE
    usercourse_name ILIKE '%npqll%orient%feb%'
    AND mod_name ILIKE '%research%' -- counts for 6. research
    AND usercourse_name NOT ILIKE '%test%'
    AND accessed->>'first' IS NOT NULL

-- show all available module data of users that have accessed the research module ordered by completed time stamp
SELECT *
FROM 
    user_modules AS um
WHERE
    usercourse_name ILIKE '%npqll%orient%feb%'
    AND mod_name ILIKE '%research%' -- counts for 6. research
    AND usercourse_name NOT ILIKE '%test%'
    AND accessed->>'first' IS NOT NULL
ORDER BY completed ASC

-- COUNT all users that have provided a consent response (i.e., user_mod_reflection object exists)
-- count = 348 (as of 09/03/2023)
SELECT count(user_id)
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%orient%feb%'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%research%' 

-- query all available user mod reflection data of users that provided a consent response, ordered by "completedDt"
SELECT *
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%orient%feb%'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%research%' 
ORDER BY "completedDt"

-- number of users that completed research module > number of users that provided consent response
-- subquery to identify all available information of uers that have completed the research module but no reflection object exist
-- ordered by time stamp when module was marked as completed
SELECT *
FROM 
    user_modules AS um
WHERE
    usercourse_name ILIKE '%npqll%orient%feb%'
    AND mod_name ILIKE '%research%' -- counts for 6. research
    AND usercourse_name NOT ILIKE '%test%'
    AND accessed->>'first' IS NOT NULL
    AND user_display_name NOT IN    (SELECT user_name
                                    FROM
                                    user_mod_reflections AS umr
                                    WHERE
                                        mod_course_name ILIKE '%npqll%orient%feb%'
                                        AND mod_course_name NOT ILIKE '%test%'
                                        AND object_name ILIKE '%research%')
ORDER BY completed ASC