-- this script queries demographic data fom the user_mod_reflections table
-- the object was embedded in Course 2 ("Developing language") Module 1 ("Developing spoken language")    
    
-- query demographic data
-- [{"question":{"id":3832303,"text":"How would you describe your gender?","question_id":1324,"requirements":{"answer_type":"multi_choice","max_answers":1,"min_answers":1}},"response":{"choices":[{"id":"3832303_c_329","text":"Male","selected":true,"answer_id":329},{"id":"3832303_c_330","text":"Female","selected":false,"answer_id":330},{"id":"3832303_c_331","text":"I describe my gender differently","selected":false,"answer_id":331},{"id":"3832303_c_332","text":"Prefer not to say","selected":false,"answer_id":332}]}},
-- {"question":{"id":3832304,"text":"How old are you? If you prefer not to say, please leave blank.","question_id":1325,"requirements":{"answer_type":"text","text_required":false}},"response":{"free_text":{"id":"3832304_ft","text":null}}},
-- {"question":{"id":3832305,"text":"How many years of experience do you have working as a qualified classroom teacher? Please provide an estimate rounded to full years. If you prefer not to say, please leave blank.","question_id":1326,"requirements":{"answer_type":"text","text_required":false}},"response":{"free_text":{"id":"3832305_ft","text":null}}}]


-- raw data
SELECT
    *
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%develop%language'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%demographic%'
    AND "completedDt" < '2023-11-01 00:00:00.000'

-- cleaned data
SELECT
    user_id, 
    --user_name, 
    "completedDt" AS dt_demogs_complete, -- same AS "lastUpdatedDt" due TO one-time submission
    -- gender
    response -> 0 -> 'response' -> 'choices' -> 0 ->> 'selected' AS male,
    response -> 0 -> 'response' -> 'choices' -> 1 ->> 'selected' AS female,
    response -> 0 -> 'response' -> 'choices' -> 2 ->> 'selected' AS different,
    response -> 0 -> 'response' -> 'choices' -> 3 ->> 'selected' AS not_disclosed,
    -- age
    response -> 1 -> 'response' -> 'free_text' -> 'text' AS age,
    -- experience
    response -> 2 -> 'response' -> 'free_text' -> 'text' AS experience,
    response AS raw_demogs
FROM
    user_mod_reflections AS umr
WHERE
    mod_course_name ILIKE '%npqll%develop%language'
    AND mod_course_name NOT ILIKE '%test%'
    AND object_name ILIKE '%demographic%'
    AND "completedDt" < '2023-11-01 00:00:00.000'

    
