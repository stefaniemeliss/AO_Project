-- NPQLL Course 3 Module 1 study modules + objects 
SELECT 
    umo.usermod_id, -- same as um.id, UNIQUE MODULE id
    mod_name, -- MODULE name
    mod_code, -- number indicating the POSITION OF the MODULE IN course
    um.user_id, -- UNIQUE USER id
    user_display_name, -- USER name
    --usercourse_id, --UNIQUE course id
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
    AND "unlockDt" > '2023-05-22 00:00:00.000' -- ONLY present cohort: MODULE 3 released ON 2023/05/22
    --AND accessed->>'first' IS NOT NULL -- only include modules that were accessed
    --AND umo."eventSubject" = 'object' -- ONLY INCLUDE OBJECT DATA (not module data)
ORDER BY um.user_display_name, umo."eventDt" ASC





-- DEBUG: any NPQLL Feb 2023 cohort 
SELECT 
    umo.usermod_id, -- same as um.id, UNIQUE MODULE id
    mod_name, -- MODULE name
    mod_code, -- number indicating the POSITION OF the MODULE IN course
    um.user_id, -- UNIQUE USER id
    user_display_name, -- USER name
    --usercourse_id, --UNIQUE course id
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
    AND usercourse_name ILIKE '%NPQLL%' -- NPQLL DATA : course 3
    --AND mod_name = 'Learning to read' -- NPQLL DATA: module 1
    AND "unlockDt" > '2023-05-22 00:00:00.000' -- ONLY present cohort: MODULE 3 released ON 2023/05/22
    --AND accessed->>'first' IS NOT NULL -- only include modules that were accessed
    --AND umo."eventSubject" = 'object' -- ONLY INCLUDE OBJECT DATA (not module data)
ORDER BY um.user_display_name, umo."eventDt" ASC