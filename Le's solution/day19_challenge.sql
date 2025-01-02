/** ADVENT OF SQL - Day 19**/
-- Solved by: Le Luu
-- Level: Advanced
-- Source: https://adventofsql.com/
/** Description:
How much total salary was paid to all employees including those bonuses?

Employees will receive a bonus if their last performance review score is higher than the average last performance review score of all employees. 
The bonus is 15% extra on top of their salary.
**/

CREATE DATABASE aos_ch19;
USE aos_ch19;

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    year_end_performance_scores JSON NOT NULL
);

INSERT INTO employees (name, salary, year_end_performance_scores) VALUES
('Alice Johnson', 75000.00, '[85, 90, 88, 92]'),
('Bob Smith', 68000.00, '[78, 82, 80, 81]'),
('Charlie Brown', 72000.00, '[91, 89, 94, 96]'),
('Dana White', 64000.00, '[70, 75, 73, 72]'),
('Eliot Green', 70000.00, '[88, 85, 90, 87]');

-- this challenge contains the array. In mysql, I use data type is JSON
-- explode the array using JSON_UNQUOTE function
WITH explode_array_cte as (
	SELECT 
		name, 
		salary,
		-- extract data from the array for 4 elements in the year_end_performance_scores column
		JSON_UNQUOTE(JSON_EXTRACT(year_end_performance_scores,'$[0]')) as score_1,
		JSON_UNQUOTE(JSON_EXTRACT(year_end_performance_scores,'$[1]')) as score_2,
		JSON_UNQUOTE(JSON_EXTRACT(year_end_performance_scores,'$[2]')) as score_3,
		JSON_UNQUOTE(JSON_EXTRACT(year_end_performance_scores,'$[3]')) as score_4
	FROM employees
),
-- calculate the avg score of all of the last value in the year_end_performance_scores
avg_last_all_score_cte as (
	SELECT 
		AVG(score_4) as avg_last_score
	FROM explode_array_cte
),
-- calculate the salary plus the bonus (inclduing the condition)
salary_inc_bonus_cte as (
	SELECT 
		name, 
		salary,
		score_4,
		(
			CASE -- condition to get bonus is the last performance score is greater than the average of all last score
				WHEN score_4 > (
					SELECT avg_last_score 
					FROM avg_last_all_score_cte
				) 
			-- if the condition is true, then add 15% on salary; otherwise, keep the salary
			THEN salary*(1.15)
			ELSE salary
			END
		) as salary_with_bonus
	FROM explode_array_cte
)
-- find the total salary including bonus
SELECT ROUND(SUM(salary_with_bonus),2) as total_salary_with_bonuses
FROM salary_inc_bonus_cte;