/** ADVENT OF SQL - Day 9**/
-- Solved by: Le Luu
-- Level: Intermediate
-- Source: https://adventofsql.com/
/** Description:
Rudolph is retiring as lead reindeer, and Santa needs to analyze each reindeer's speed records to choose the new leader.

To do this you need to:

Calculate the average speed for each reindeer in each exercise type, excluding Rudolf.
Find the highest average speed for each reindeer amongst those average speeds.
Select the top 3 reindeer based on their highest average speed. Round the score to 2 decimal places.
Enter the name and score of the top 3 reindeer in the format name,highest_average_score, but remember Rudolph is retiring so don't pick him.
**/

CREATE DATABASE aos_ch09;
USE aos_ch09;

DROP TABLE IF EXISTS Reindeers CASCADE;
CREATE TABLE Reindeers (
    reindeer_id SERIAL PRIMARY KEY,
    reindeer_name VARCHAR(50) NOT NULL,
    years_of_service INTEGER NOT NULL,
    speciality VARCHAR(100)
);

DROP TABLE IF EXISTS Training_Sessions CASCADE;
CREATE TABLE Training_Sessions (
    session_id SERIAL PRIMARY KEY,
    reindeer_id INTEGER REFERENCES Reindeers(reindeer_id),
    exercise_name VARCHAR(100) NOT NULL,
    speed_record DECIMAL(5,2) NOT NULL,
    session_date DATE NOT NULL,
    weather_conditions VARCHAR(50)
);

INSERT INTO Reindeers (reindeer_name, years_of_service, speciality) VALUES
    ('Dasher', 287, 'Sprint Master'),
    ('Dancer', 283, 'Agility Expert'),
    ('Prancer', 275, 'High-Altitude Specialist'),
    ('Comet', 265, 'Long-Distance Expert'),
    ('Rudolf', 152, 'Night Navigation');

INSERT INTO Training_Sessions (reindeer_id, exercise_name, speed_record, session_date, weather_conditions) VALUES
    (1, 'Sprint Start', 88.5, '2024-11-15', 'Snowy'),
    (1, 'High-Speed Turn', 92.3, '2024-11-20', 'Clear'),
    (1, 'Rooftop Landing', 85.7, '2024-11-25', 'Windy'),
    (2, 'Sprint Start', 90.1, '2024-11-15', 'Snowy'),
    (2, 'High-Speed Turn', 94.8, '2024-11-20', 'Clear'),
    (2, 'Rooftop Landing', 89.2, '2024-11-25', 'Windy'),
    (3, 'Sprint Start', 87.3, '2024-11-15', 'Snowy'),
    (3, 'High-Speed Turn', 91.5, '2024-11-20', 'Clear'),
    (3, 'Rooftop Landing', 88.9, '2024-11-25', 'Windy'),
    (4, 'Sprint Start', 89.7, '2024-11-15', 'Snowy'),
    (4, 'High-Speed Turn', 93.2, '2024-11-20', 'Clear'),
    (4, 'Rooftop Landing', 87.8, '2024-11-25', 'Windy'),
    (5, 'Sprint Start', 86.9, '2024-11-15', 'Snowy'),
    (5, 'High-Speed Turn', 90.8, '2024-11-20', 'Clear'),
    (5, 'Rooftop Landing', 88.1, '2024-11-25', 'Windy');
    
SELECT *
FROM Training_Sessions t
JOIN Reindeers r
ON t.reindeer_id = r.reindeer_id
WHERE r.reindeer_name != 'Rudolf';
    
-- this cte helps to find the avg speed of each reindeer in each exercise without Rudolf
-- use the WINDOW function to find the best speed record of reindeer
WITH avg_speed_reindeer_cte as (
    SELECT 
        r.reindeer_name, 
        t.exercise_name,
        ROUND(AVG(t.speed_record),2) as avg_speed, --calculate the avg speed of each reindeer in each exercise
        MAX(ROUND(AVG(t.speed_record),2)) OVER (PARTITION BY r.reindeer_name) max_speed_each_reindeer -- find the max avg speed for each reindeer
    FROM Training_Sessions t
    JOIN Reindeers r
    ON t.reindeer_id = r.reindeer_id
    WHERE r.reindeer_name != 'Rudolf' -- Oh no! Rudolf is retiring. 
    GROUP BY 
        r.reindeer_name,
        t.exercise_name
)
SELECT 
    reindeer_name,
    max_speed_each_reindeer as top_speed
FROM avg_speed_reindeer_cte
WHERE avg_speed = max_speed_each_reindeer
ORDER BY top_speed DESC
LIMIT 3; -- only show top 3
    