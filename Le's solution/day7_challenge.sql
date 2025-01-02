/** ADVENT OF SQL - Day 7**/
-- Solved by: Le Luu
-- Level: Intermediate
-- Source: https://adventofsql.com/
/** Description:
Create a query that returns pairs of elves who share the same primary_skill. The pairs should be comprised of the elf with the most (max) and least (min) years of experience in the primary_skill.

When you have multiple elves with the same years_experience, order the elves by elf_id in ascending order.

Your query should return:
The ID of the first elf with the Max years experience
The ID of the first elf with the Min years experience
Their shared skill
Notes:
Each pair should be returned only once.
Elves can not be paired with themselves, a primary_skill will always have more than 1 elf.
Order by primary_skill, there should only be one row per primary_skill.
In case of duplicates order first by elf_1_id, then elf_2_id.
In the inputs below provide one row per primary_skill in the format, with no spaces and comma separation:

max_years_experience_elf_id,min_years_experience_elf_id,shared_skill
Do not use any special characters such as " or ' in your answer.
**/

CREATE DATABASE aos_ch07;
USE aos_ch07;

DROP TABLE IF EXISTS workshop_elves CASCADE;
CREATE TABLE workshop_elves (
    elf_id SERIAL PRIMARY KEY,
    elf_name VARCHAR(100) NOT NULL,
    primary_skill VARCHAR(50) NOT NULL,
    years_experience INT NOT NULL
);

INSERT INTO workshop_elves (elf_name, primary_skill, years_experience) VALUES
    ('Tinker', 'Toy Making', 150),
    ('Sparkle', 'Gift Wrapping', 75),
    ('Twinkle', 'Toy Making', 90),
    ('Holly', 'Cookie Baking', 200),
    ('Jolly', 'Gift Wrapping', 85),
    ('Berry', 'Cookie Baking', 120),
    ('Star', 'Toy Making', 95);

-- Create a cte to find the max years_experience grouped on the primary_skill
WITH max_exp_cte as (
	SELECT primary_skill, MAX(years_experience) as years_experience
	FROM workshop_elves
	GROUP BY primary_skill
),
-- Create a cte to find the min years_experience grouped on the primary_skill
min_exp_cte as (
	SELECT primary_skill, MIN(years_experience) as years_experience
	FROM workshop_elves
	GROUP BY primary_skill
)
-- After finding the min and max year of experience of each skill
-- Compare if the max/min year experience of the skill EQUAL the year experience on the same skill
-- if that skill which has year experience = the max year experience on the same skill, store the elf_id on elf_1_id
-- same for the min, and store the elf_id in elf_2_id
SELECT 
    MAX(CASE WHEN w.years_experience = ma.years_experience THEN w.elf_id END) AS elf_1_id,
    MIN(CASE WHEN w.years_experience = mi.years_experience THEN w.elf_id END) AS elf_2_id,
    w.primary_skill
FROM workshop_elves w
JOIN max_exp_cte ma ON w.primary_skill=ma.primary_skill -- Join to assign the max year experience to each skill
JOIN min_exp_cte mi ON w.primary_skill=mi.primary_skill -- join to assign the min year experience to each skill
GROUP BY w.primary_skill
ORDER BY w.primary_skill;
