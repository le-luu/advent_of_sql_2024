/** ADVENT OF SQL - Day 11**/
-- Solved by: Le Luu
-- Level: Intermediate
-- Source: https://adventofsql.com/
/** Description:
Mrs. Claus needs a comprehensive analysis of the tree farms. Using window functions, create a query that will shed some light on the field perfomance.

Show the 3-season moving average per field per season per year

Write a single SQL query using window functions that will reveal these vital patterns. Your analysis will help ensure that every child who wishes for a Christmas tree will have one for years to come.

Order them by three_season_moving_avg descending to make it easier to find the largest figure.

Seasons are ordered as follows:

Spring THEN 1
Summer THEN 2
Fall THEN 3
Winter THEN 4
Find the row with the most three_season_moving_avg
**/

CREATE DATABASE aos_ch11;
USE aos_ch11;

CREATE TABLE TreeHarvests (
    field_name VARCHAR(50),
    harvest_year INT,
    season VARCHAR(6),
    trees_harvested INT
);

INSERT INTO TreeHarvests VALUES
('Rudolph Ridge', 2023, 'Spring', 150),
('Rudolph Ridge', 2023, 'Summer', 180),
('Rudolph Ridge', 2023, 'Fall', 220),
('Rudolph Ridge', 2023, 'Winter', 300),
('Dasher Dell', 2023, 'Spring', 165),
('Dasher Dell', 2023, 'Summer', 195),
('Dasher Dell', 2023, 'Fall', 210),
('Dasher Dell', 2023, 'Winter', 285);


SELECT 
    field_name, 
    harvest_year, 
    season,
    ROUND(AVG(trees_harvested) OVER (PARTITION BY field_name ORDER BY ( --use WINDOW function to find the moving average
        -- the order starts from the Spring season and end at the Winter season
        -- decode each season by number to order
        CASE 
            WHEN season='Spring' THEN 1
            WHEN season='Summer' THEN 2
            WHEN season='Fall' THEN 3
            WHEN season='Winter' THEN 4
        END
    ) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) as three_season_moving_avg -- showing 3-season moving average, so 2 preceding and the current row
FROM TreeHarvests
ORDER BY three_season_moving_avg DESC;