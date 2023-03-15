-- NPQLL Course 1: study modules
-- https://steplab.notion.site/usermods-User-modules-62bc34a1feee4e3f8a82befce387c7f4
SELECT
    *
    --count(*)
    --count(accessed) AS count_accessed, count(completed) AS count_completed
    --accessed->>'first' AS accessed_first
FROM
    user_modules AS um
WHERE
    usercourse_name ILIKE '%npqll%enab%'
    AND mod_name ILIKE '%effect%learn%instr%' -- module 1: Effective learning and instruction
    --AND mod_name ILIKE '%motivation%' -- module 2: Motivation
    --AND mod_name ILIKE '%lead%lit%' -- module 3: Leading literacy
    AND "unlockDt" > '2023-02-01 00:00:00.000' -- Feb 2023 cohort
    AND accessed->>'first' IS NOT NULL -- have engaged with module
ORDER BY user_display_name, mod_code

-- NPQLL Course 1: apply modules
--https://steplab.notion.site/userapplymods-User-apply-modules-66c1a3657cd44406855bb500db42055d
SELECT
    *
    --user_id, user_display_name, usercourse_name, mod_name, completed, "modifiedDt", "_modified", "_modification_datetime"
    --count(accessed) AS count_accessed, count(completed) AS count_completed
    --accessed->>'first' AS accessed_first
FROM
    user_apply_mods uam
WHERE
    usercourse_name ILIKE '%npqll%enab%'
    AND mod_name ILIKE '%effect%learn%instr%' -- module 1: Effective learning and instruction
    --AND mod_name ILIKE '%motivation%' -- module 2: Motivation
    --AND mod_name ILIKE '%lead%lit%' -- module 3: Leading literacy
    AND "_modified" > '2023-02-01 00:00:00.000' -- Feb 2023 cohort
    AND "modifiedDt" IS NOT NULL -- have engaged with module
ORDER BY user_display_name, mod_code



-- NPQLL Course 1 Module 1 study modules + objects 
SELECT * FROM user_modules AS um
INNER JOIN user_module_objects AS umo ON um.id = umo.usermod_id
WHERE
    usercourse_name ILIKE '%npqll%enab%'
    AND mod_name ILIKE '%effect%learn%instr%' -- module 1: Effective learning and instruction
    --AND mod_name ILIKE '%motivation%' -- module 2: Motivation
    --AND mod_name ILIKE '%lead%lit%' -- module 3: Leading literacy
    AND "unlockDt" > '2023-02-01 00:00:00.000'
    AND accessed->>'first' IS NOT NULL
    AND umo."eventSubject" = 'object'
ORDER BY um.user_id, umo."eventDt" ASC