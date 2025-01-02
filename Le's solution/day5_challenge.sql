/** ADVENT OF SQL - Day 5**/
-- Solved by: Le Luu
-- Level: Beginner
-- Source: https://adventofsql.com/
/** Description:
Using the provided schema and data, write a SQL query that analyzes the daily toy production trends for each date in the table, comparing a date to the date before. The query should accomplish the following:

List each day's production date and the number of toys produced on that day.
Include the previous day's toy production next to each current day's production.
Calculate the change in the number of toys produced compared to the previous day.
Calculate the percentage change in production compared to the previous day.
The result set should display the following columns:

production_date: The current date.
toys_produced: Number of toys produced on the current date.
previous_day_production: Number of toys produced on the previous date.
production_change: Difference in toys produced between the current date and the previous date.
production_change_percentage: Percentage change in production compared to the previous day.
Submit the date of the day with the largest daily increase in percentage
**/
CREATE DATABASE aos_ch05;
USE aos_ch05;

DROP TABLE IF EXISTS toy_production CASCADE;
CREATE TABLE toy_production(
	production_date DATE PRIMARY KEY,
    toys_produced INT
);

INSERT INTO toy_production (production_date, toys_produced) VALUES
('2024-12-18', 500),
('2024-12-19', 550),
('2024-12-20', 525),
('2024-12-21', 600),
('2024-12-22', 580),
('2024-12-23', 620),
('2024-12-24', 610);

SELECT 
	production_date,
	toys_produced,
	-- Use the WINDOW function to assign the previous number of toy produced order by the production_date on the current row
	LAG(toys_produced) OVER (ORDER BY production_date) as previous_date_production, 
	-- subtract the current toys produced by date with the previous data production
	toys_produced - LAG(toys_produced) OVER (ORDER BY production_date) as production_change,
	-- find the rate by taking the latest toy produced minus the previous toys produced divided by the previous toys produced. 
	-- Then, keep result in only 2 decimal places
	ROUND(((toys_produced - LAG(toys_produced) OVER (ORDER BY production_date))/ LAG(toys_produced) OVER (ORDER BY production_date))*100,2) as production_change_percentage
FROM toy_production
ORDER BY production_change_percentage DESC;