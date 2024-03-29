-- query module objects data from consenting research participants
-- returns empty as user_id is NULL in umo
SELECT 
*
FROM user_module_objects
WHERE
        user_id IN 
        (SELECT -- create list of consenting ppt
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
ORDER BY "eventDt" ASC


-- left-join user_modules and user_module_objects for research participants and NPQLL programme
-- this adds reliable user_id data from um
SELECT 
    *
FROM user_modules um -- MODULE data
LEFT JOIN user_module_objects umo ON um.id = umo.usermod_id -- JOIN with MODULE OBJECT data
WHERE
        um.user_id IN 
        (SELECT -- create list of consenting ppt
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
    AND usercourse_name ILIKE '%NPQLL%' -- NPQLL data
ORDER BY um.user_display_name, umo."eventDt" ASC


-- left-join user_modules and user_module_objects for research participants and NPQLL programme
-- CLEANED
SELECT 
    umo.usermod_id, -- same as um.id, UNIQUE MODULE id
    mod_name, -- MODULE name
    mod_code, -- number indicating the POSITION OF the MODULE IN course
    um.user_id, -- UNIQUE USER id
    user_display_name, -- USER name
    usercourse_id, --UNIQUE course id
    usercourse_name, -- course name 
    "unlockDt" AS dt_mod_release, -- time stamp WHEN CONTENT was released AND/OR unlocked 
    accessed->>'first' AS dt_mod_access_first, -- time stamp WHEN MODULE was FIRST accessed
    accessed->>'last' AS dt_mod_access_last, -- time stamp WHEN MODULE was LAST accessed
    completed AS dt_mod_complete, -- timestamp WHEN MODULE was completed
    umo."eventSubject" event_subject, -- engagement WITH MODULE vs OBJECT
    umo."object" ->> 'objectType' AS object_type, -- TYPE OF OBJECT: v(ideo), m(arkdown), q(uiz), r(eflection)
    umo."object" ->> 'name' AS object_name, -- TYPE OF OBJECT: v(ideo), m(arkdown), q(uiz), r(eflection)
    umo."eventType" AS event_type, -- OBJECT a(ssessed) OR c(ompleted)
    umo."eventDt" AS dt_event -- time stamp OF engagement WITH object
FROM user_modules um -- MODULE data
LEFT JOIN user_module_objects umo ON um.id = umo.usermod_id -- JOIN with MODULE OBJECT data
WHERE
        um.user_id IN 
        (SELECT -- create list of consenting ppt
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
    AND usercourse_name ILIKE '%NPQLL%' -- NPQLL data
ORDER BY um.user_display_name, umo."eventDt" ASC


-- user module object data from NPQLL Feb 2023 cohort 
-- when filtering by date: data *appears* complete as all empty fields are removed
SELECT 
    umo.usermod_id, -- same as um.id, UNIQUE MODULE id
    mod_name, -- MODULE name
    mod_code, -- number indicating the POSITION OF the MODULE IN course
    um.user_id, -- UNIQUE USER id
    user_display_name, -- USER name
    usercourse_id, --UNIQUE course id
    usercourse_name, -- course name 
    "unlockDt" AS dt_mod_release, -- time stamp WHEN CONTENT was released AND/OR unlocked 
    accessed->>'first' AS dt_mod_access_first, -- time stamp WHEN MODULE was FIRST accessed
    accessed->>'last' AS dt_mod_access_last, -- time stamp WHEN MODULE was LAST accessed
    completed AS dt_mod_complete, -- timestamp WHEN MODULE was completed
    umo."eventSubject" event_subject, -- engagement WITH MODULE vs OBJECT
    umo."object" ->> 'objectType' AS object_type, -- TYPE OF OBJECT: v(ideo), m(arkdown), q(uiz), r(eflection)
    umo."object" ->> 'name' AS object_name, -- TYPE OF OBJECT: v(ideo), m(arkdown), q(uiz), r(eflection)
    umo."eventType" AS event_type, -- OBJECT a(ssessed) OR c(ompleted)
    umo."eventDt" AS dt_event -- time stamp OF engagement WITH object
FROM user_modules um -- MODULE data
LEFT JOIN user_module_objects umo ON um.id = umo.usermod_id -- JOIN with MODULE OBJECT data
WHERE
        um.user_id IN 
        (SELECT -- create list of consenting ppt
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
    AND usercourse_name ILIKE '%NPQLL%' -- NPQLL data
    AND umo."eventDt" BETWEEN '2023-02-01 00:00:00.000' AND '2023-11-01 00:00:00.000' -- whole NPQLL Feb course
    --AND umo."eventDt" BETWEEN '2023-09-01 00:00:00.000' AND '2023-11-01 00:00:00.000' -- september and october data
ORDER BY um.user_display_name, umo."eventDt" ASC




-- NPQLL Course 3 Module 1 study modules + objects 
-- AO manipulation
SELECT 
    umo.usermod_id, -- same as um.id, UNIQUE MODULE id
    mod_name, -- MODULE name
    mod_code, -- number indicating the POSITION OF the MODULE IN course
    um.user_id, -- UNIQUE USER id
    user_display_name, -- USER name
    usercourse_id, --UNIQUE course id
    usercourse_name, -- course name 
    "unlockDt" AS dt_mod_release, -- time stamp WHEN CONTENT was released AND/OR unlocked 
    accessed->>'first' AS dt_mod_access_first, -- time stamp WHEN MODULE was FIRST accessed
    accessed->>'last' AS dt_mod_access_last, -- time stamp WHEN MODULE was LAST accessed
    completed AS dt_mod_complete, -- timestamp WHEN MODULE was completed
    umo."eventSubject" event_subject, -- engagement WITH MODULE vs OBJECT
    umo."object" ->> 'objectType' AS object_type, -- TYPE OF OBJECT: v(ideo), m(arkdown), q(uiz), r(eflection)
    umo."object" ->> 'name' AS object_name,
    umo."eventType" AS event_type, -- OBJECT a(ssessed) OR c(ompleted)
    umo."eventDt" AS dt_event -- time stamp OF engagement WITH object
FROM user_modules um -- MODULE data
LEFT JOIN user_module_objects umo ON um.id = umo.usermod_id -- JOIN with object events data
WHERE
        um.user_id IN 
        (SELECT -- create list of consenting ppt
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
    AND usercourse_name = 'NPQLL Developing Reading' -- NPQLL DATA : course 3
    AND mod_name = 'Learning to read' -- NPQLL DATA: module 1
    --AND "unlockDt" > '2023-05-22 00:00:00.000' -- ONLY present cohort: MODULE 3 released ON 2023/05/22
    --AND accessed->>'first' IS NOT NULL -- only include modules that were accessed
    --AND umo."eventSubject" = 'object' -- ONLY INCLUDE OBJECT DATA (not module data)
ORDER BY um.user_display_name, umo."eventDt" ASC





