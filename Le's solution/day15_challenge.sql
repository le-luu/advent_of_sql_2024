/** ADVENT OF SQL - Day 15**/
-- Solved by: Le Luu
-- Level: Advanced
-- Source: https://adventofsql.com/
/** Description:
Using the list of areas you need to find which city the last sleigh_location is located in.

Submit the city name only.

Note: This task might seem simple but its going to get much trickier tomorrow and its essential you nail this part first.
**/


CREATE TABLE sleigh_locations (
    id INT IDENTITY(1,1) PRIMARY KEY, -- Auto-increment primary key
    timestamp DATETIMEOFFSET NOT NULL,  -- Use DATETIMEOFFSET for timestamp with time zone
    coordinate GEOGRAPHY NOT NULL  -- Store geography type (point)
);

CREATE TABLE areas (
    id INT IDENTITY(1,1) PRIMARY KEY, -- Auto-increment primary key
    place_name VARCHAR(255) NOT NULL,
    polygon GEOGRAPHY NOT NULL  -- Store geography type (polygon)
);

INSERT INTO sleigh_locations (timestamp, coordinate)
VALUES
    ('2024-12-24 22:00:00 +00:00', GEOGRAPHY::STPointFromText('POINT(-73.985130 40.758896)', 4326)),  -- Times Square, New York
    ('2024-12-24 23:00:00 +00:00', GEOGRAPHY::STPointFromText('POINT(-118.243683 34.052235)', 4326)), -- Downtown Los Angeles
    ('2024-12-25 00:00:00 +00:00', GEOGRAPHY::STPointFromText('POINT(139.691706 35.689487)', 4326)); -- Tokyo

INSERT INTO areas (place_name, polygon)
VALUES
    ('New_York', GEOGRAPHY::STPolyFromText('POLYGON((-74.25909 40.477399, -73.700272 40.477399, -73.700272 40.917577, -74.25909 40.917577, -74.25909 40.477399))', 4326)),
    ('Los_Angeles', GEOGRAPHY::STPolyFromText('POLYGON((-118.668176 33.703652, -118.155289 33.703652, -118.155289 34.337306, -118.668176 34.337306, -118.668176 33.703652))', 4326)),
    ('Tokyo', GEOGRAPHY::STPolyFromText('POLYGON((138.941375 35.523222, 140.68074 35.523222, 140.68074 35.898782, 138.941375 35.898782, 138.941375 35.523222))', 4326));

-- this challenge contains the spatial data with POINT and POLYGON. My MySQL doesn't activate the spatial, so I did in Postgresql
SELECT 
    a.place_name
FROM sleigh_locations as s
JOIN areas as a
-- join 2 tables together based on the condition that the polygon contain the point 
ON a.polygon.STContains(s.coordinate) = 1
-- filter the data with the last time on 12/24/2024 
WHERE CAST(s.timestamp AS DATE) = '2024-12-24'
-- also compare to make sure that the timestamp is max on that date and the date is 2024-12-24
AND s.timestamp = (
  SELECT 
    MAX(timestamp)
  FROM sleigh_locations
  WHERE CAST(timestamp AS DATE) = '2024-12-24'
)
;