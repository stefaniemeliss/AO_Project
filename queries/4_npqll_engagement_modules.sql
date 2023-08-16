-- this script queries module completion data fom courses 1-4
-- data is queried for consenting participants only

-- query raw data
SELECT
    *
FROM user_modules um
WHERE
    user_id IN 
        (SELECT -- create list of consenting ppt for LMS
            user_id
        FROM
            user_mod_reflections AS umr
        WHERE
            mod_course_name ILIKE '%npqll%orient%'
            AND response -> 0 -> 'response' -> 'choices' -> 0 ->> 'selected' = 'true'
            AND mod_course_name NOT ILIKE '%test%'
            AND object_name ILIKE '%research%'
            AND "completedDt" < '2023-03-17 00:07:00.000'
        )
    AND usercourse_name ILIKE '%npqll%enabling%cond%' -- NPQLL DATA : course 1
    OR usercourse_name ILIKE '%npqll%develop%language%' -- NPQLL DATA : course 2
    OR usercourse_name ILIKE '%npqll%develop%read%' -- NPQLL DATA : course 3
    OR usercourse_name ILIKE '%npqll%develop%writ%' -- NPQLL DATA : course 4
    AND "unlockDt" > '2023-02-01 00:00:00.000' -- ONLY present cohort
ORDER BY user_display_name, "unlockDt", mod_code

-- cleaned data    
SELECT
    um.id, -- same as um.id, UNIQUE MODULE id
    mod_name, -- MODULE name
    mod_code, -- number indicating the POSITION OF the MODULE IN course
    um.user_id, -- UNIQUE USER id
    --user_display_name, -- USER name
    usercourse_id, --UNIQUE course id
    usercourse_name, -- course name 
    "unlockDt" AS dt_mod_release, -- time stamp WHEN CONTENT was released AND/OR unlocked 
    accessed->>'first' AS dt_mod_access_first, -- time stamp WHEN MODULE was FIRST accessed
    accessed->>'last' AS dt_mod_access_last, -- time stamp WHEN MODULE was LAST accessed
    completed AS dt_mod_complete -- timestamp WHEN MODULE was completed
/*    umo."eventSubject" event_subject, -- engagement WITH MODULE vs OBJECT
    umo."object" ->> 'objectType' AS object_type, -- TYPE OF OBJECT: v(ideo), m(arkdown), q(uiz), r(eflection)
    umo."object" ->> 'name' AS object_name, -- TYPE OF OBJECT: v(ideo), m(arkdown), q(uiz), r(eflection)
    umo."eventType" AS event_type, -- OBJECT a(ssessed) OR c(ompleted)
    umo."eventDt" AS dt_event -- time stamp OF engagement WITH object*/
FROM user_modules um
WHERE
    user_id IN 
        (SELECT -- create list of consenting ppt for LMS
            user_id
        FROM
            user_mod_reflections AS umr
        WHERE
            mod_course_name ILIKE '%npqll%orient%'
            AND response -> 0 -> 'response' -> 'choices' -> 0 ->> 'selected' = 'true'
            AND mod_course_name NOT ILIKE '%test%'
            AND object_name ILIKE '%research%'
            AND "completedDt" < '2023-03-17 00:07:00.000'
        )
    AND usercourse_name ILIKE '%npqll%enabling%cond%' -- NPQLL DATA : course 1
    OR usercourse_name ILIKE '%npqll%develop%language%' -- NPQLL DATA : course 2
    OR usercourse_name ILIKE '%npqll%develop%read%' -- NPQLL DATA : course 3
    OR usercourse_name ILIKE '%npqll%develop%writ%' -- NPQLL DATA : course 4
    AND "unlockDt" > '2023-02-01 00:00:00.000' -- ONLY present cohort
ORDER BY user_display_name, "unlockDt", mod_code