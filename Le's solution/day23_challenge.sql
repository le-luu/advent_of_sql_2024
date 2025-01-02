/** ADVENT OF SQL - Day 23**/
-- Solved by: Le Luu
-- Level: Advanced
-- Source: https://adventofsql.com/
/** Description:
Find the missing tags

Assume the first and last tags are in the database

Group them in islands, a group starts as the first missing element and finishes as the last missing element. 
A group is a sequential number of missing values.

Submit the tags in the missing groups as in the example
**/

CREATE DATABASE aos_ch23;
USE aos_ch23;

CREATE TABLE sequence_table (
    id INT PRIMARY KEY
);

INSERT INTO sequence_table (id) VALUES 
    (1),
    (2),
    (3),
    (7),
    (8),
    (9),
    (11),
    (15),
    (16),
    (17),
    (22);

-- create a recursive cte to generate number from the min id of the sequence table and end at the max id of the sequence table
WITH RECURSIVE sequence_table_cte as (
-- base case
	SELECT MIN(id) as id
    FROM sequence_table
    
    UNION ALL
-- recursive case
    SELECT id+1
    FROM sequence_table_cte
    WHERE id < (
        SELECT MAX(id) 
        FROM sequence_table
    ) -- stop when id < the max id
),
-- after creating the recursive number to get the full sequence
-- join it with our dataset to find the miss number
find_miss_num_cte as (
    SELECT 
        c.id as full_num, 
        s.id as org_num,
    	IF(s.id is NULL,1,0) as miss_num
    FROM sequence_table_cte c
    LEFT JOIN sequence_table s -- should do the left join to show the full sequence from the recursive cte
    ON c.id=s.id
),
-- count the missing number and group them all by the each gap
missing_groups as (
    SELECT
    	full_num,
    	-- ROW_NUMBER() OVER (ORDER BY full_num) this line will count the missing number from 1 to the end,
    	-- therefore, if subtracting the full_num with that counting missing number, we will get the group_id
    	full_num - ROW_NUMBER() OVER (ORDER BY full_num) AS group_id
    FROM find_miss_num_cte
    WHERE miss_num = 1 -- only get the miss number
)
-- by each gap group, find the min, max for gap_start and gap_end
SELECT
	MIN(full_num) AS gap_start,
	MAX(full_num) AS gap_end,
	CONCAT('{',GROUP_CONCAT(full_num ORDER BY full_num),'}') AS missing_numbers
FROM missing_groups
GROUP BY group_id;

