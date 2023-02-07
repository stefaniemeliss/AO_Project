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
-- counts of assessment access and completion
SELECT
    count(accessed) AS count_accessed
    , count(completed) AS count_completed
FROM
    user_modules AS um
WHERE
    usercourse_name ILIKE '%npqll%orient%feb%'
    AND mod_name ILIKE '%assessment%'
    AND usercourse_name NOT ILIKE '%test%'