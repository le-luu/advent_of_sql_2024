/** ADVENT OF SQL - Day 16**/
-- Solved by: Le Luu
-- Level: Advanced
-- Source: https://adventofsql.com/
/** Description:
In which timezone has Santa spent the most time?

Assume that each timestamp is when Santa entered the timezone.

Ignore the last timestamp when Santa is in Lapland.
**/

CREATE TABLE sleigh_locations (
    id INT IDENTITY(1,1) PRIMARY KEY, 
    timestamp DATETIMEOFFSET NOT NULL,  
    coordinate GEOGRAPHY NOT NULL  
);

CREATE TABLE areas (
    id INT IDENTITY(1,1) PRIMARY KEY, 
    place_name VARCHAR(255) NOT NULL,
    polygon GEOGRAPHY NOT NULL 
);

INSERT INTO sleigh_locations (timestamp, coordinate) VALUES
    ('2024-12-24 21:00:00 +00:00', GEOGRAPHY::STPointFromText('POINT(-73.985130 40.758896)', 4326)), -- Times Square, New York
    ('2024-12-24 22:00:00 +00:00', GEOGRAPHY::STPointFromText('POINT(-73.850272 40.817577)', 4326)), -- Albany, New York State
    ('2024-12-24 23:00:00 +00:00', GEOGRAPHY::STPointFromText('POINT(-118.243683 34.052235)', 4326)), -- Downtown Los Angeles
    ('2024-12-25 00:00:00 +00:00', GEOGRAPHY::STPointFromText('POINT(139.691706 35.689487)', 4326)), -- Tokyo
    ('2024-12-25 01:00:00 +00:00', GEOGRAPHY::STPointFromText('POINT(25.729066 66.500000)', 4326)); -- Rovaniemi, Lapland

INSERT INTO areas (place_name, polygon) VALUES
    ('New_York', GEOGRAPHY::STPolyFromText('POLYGON((-74.25909 40.477399, -73.700272 40.477399, -73.700272 40.917577, -74.25909 40.917577, -74.25909 40.477399))', 4326)),
    ('Los_Angeles', GEOGRAPHY::STPolyFromText('POLYGON((-118.668176 33.703652, -118.155289 33.703652, -118.155289 34.337306, -118.668176 34.337306, -118.668176 33.703652))', 4326)),
    ('Tokyo', GEOGRAPHY::STPolyFromText('POLYGON((138.941375 35.523222, 140.68074 35.523222, 140.68074 35.898782, 138.941375 35.898782, 138.941375 35.523222))', 4326)),
    ('Lapland', GEOGRAPHY::STPolyFromText('POLYGON((25.629066 66.450000, 25.829066 66.450000, 25.829066 66.550000, 25.629066 66.550000, 25.629066 66.450000))', 4326));

-- find the next timestamp of the next location by using the LEAD function
WITH lead_cte as (
    SELECT 
        s.timestamp, 
        a.place_name,
        -- find the next row in timestamp column order by the timestamp ascending, then assigning it on the same row of the current timestamp
        LEAD(s.timestamp,1) OVER (ORDER BY s.timestamp) as next_point 
    FROM sleigh_locations as s
    JOIN areas as a
    -- join 2 tables together based on the condition that the polygon contain the point 
    ON a.polygon.STContains(s.coordinate) = 1
),
-- find the different hour by subtracting the current timestamp with the timestamp on the next point
hour_diff_cte as (
    SELECT 
        place_name,
        DATEDIFF(HOUR,timestamp,next_point) as hour_diff
    FROM lead_cte
)
-- calculate the total time at each place
SELECT 
    place_name, 
    SUM(hour_diff) as total_hours_spent
FROM hour_diff_cte
GROUP BY place_name
ORDER BY total_hours_spent DESC;