/** ADVENT OF SQL - Day 4**/
-- Solved by: Le Luu
-- Level: Beginner
-- Source: https://adventofsql.com/
/** Description:
Help the elves analyze toy tags by finding:

New tags that weren't in previous_tags (call this added_tags)
Tags that appear in both previous and new tags (call this unchanged_tags)
Tags that were removed (call this removed_tags)
For each toy, return toy_name and these three categories as arrays.

Find the toy with the most added tags, there is only 1, and submit the following:

toy_id
added_tags length
unchanged_tags length
removed_tags length
Remember to handle cases where the array is empty, their output should be 0.
**/

CREATE DATABASE aos_ch04;
USE aos_ch04;

CREATE TABLE toy_production(
	toy_id INT,
    toy_name VARCHAR(100),
    previous_tag JSON,
    new_tag JSON
);

SELECT 
    t.toy_id,
    t.toy_name,
    -- get the added_tag values which are items not exist in the previous tag
    CONCAT('{', IFNULL(GROUP_CONCAT(DISTINCT t_newtag.value ORDER BY t_newtag.value SEPARATOR ','),''), '}') as added_tag,
    -- only get the common items between the previous_tags and new_tags
    CONCAT('{', IFNULL(GROUP_CONCAT(DISTINCT t_commontag.value ORDER BY t_commontag.value SEPARATOR ','),''), '}') as unchanged_tag,
    -- only get the values from the previous_tag which not exist in the new_tag column
    CONCAT('{', IFNULL(GROUP_CONCAT(DISTINCT t_prevtag.value ORDER BY t_prevtag.value SEPARATOR ','),''), '}') as removed_tag,
    COUNT(DISTINCT t_newtag.value) as count_addtag -- count the value from the new_tag
FROM toy_production t
-- the JSON_TABLE will parse the JSON from new_tags column
LEFT JOIN JSON_TABLE(t.new_tags, '$[*]' COLUMNS (value VARCHAR(100) PATH '$')) t_newtag
-- THEN compare items in the t_newtag with items in the previous_tags column
ON JSON_CONTAINS(t.previous_tags, JSON_QUOTE(t_newtag.value))=0
-- parse JSON from the new_tags column and save it as the common tag
LEFT JOIN JSON_TABLE(t.new_tags, '$[*]' COLUMNS (value VARCHAR(100) PATH '$')) t_commontag
-- left join the common tag with the previous tag. However, in this case, we want common items. So the condition is =1
ON JSON_CONTAINS(t.previous_tags, JSON_QUOTE(t_commontag.value))=1
-- opposite to the first left join, in this case, parse JSON values from the previous_tags column
LEFT JOIN JSON_TABLE(t.previous_tags, '$[*]' COLUMNS (value VARCHAR(100) PATH '$')) t_prevtag
-- only returns the value if not contains value in the new_tags column
ON JSON_CONTAINS(t.new_tags, JSON_QUOTE(t_prevtag.value))=0
GROUP BY 1,2
ORDER BY count_addtag DESC;