-- ### engagement with NPQLL ### --

-- NPQLL Course 1 Module 1 study modules + objects 
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
FROM user_modules um
LEFT JOIN user_module_objects umo ON um.id = umo.usermod_id -- JOIN WITH events data
WHERE
    usercourse_name ILIKE '%npq%ll%' -- NPQ LL DATA : ALL modules
    AND usercourse_name NOT ILIKE '%test%' -- EXCLUDE test modules
    AND usercourse_name NOT ILIKE '%clinic%' -- EXCLUDE clinic modules
    AND "unlockDt" > '2023-02-01 00:00:00.000' -- ONLY present cohort
    --AND accessed->>'first' IS NOT NULL -- only include modules that were accessed
    --AND umo."eventSubject" = 'object' -- ONLY INCLUDE OBJECT DATA (not module data)
ORDER BY um.user_display_name, umo."eventDt" ASC
 



