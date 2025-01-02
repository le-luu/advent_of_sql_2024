/** ADVENT OF SQL - Day 17**/
-- Solved by: Le Luu
-- Level: Intermediate
-- Source: https://adventofsql.com/
/** Description:
Challenge Requirements:

Find all possible 60-minute meeting windows where all participating workshops are within their business hours
Return results in UTC format
Submit the earliest meeting start time that all offices can make.
**/

CREATE TABLE Workshops (
    workshop_id INT PRIMARY KEY,
    workshop_name VARCHAR(100),
    timezone VARCHAR(50),
    business_start_time TIME,
    business_end_time TIME
);

INSERT INTO Workshops (workshop_id, workshop_name, timezone, business_start_time, business_end_time) VALUES
(1, 'North Pole HQ', 'UTC', '09:00', '17:00'),
(2, 'London Workshop', 'Europe/London', '09:00', '17:00'),
(3, 'New York Workshop', 'America/New_York', '09:00', '17:00');

-- after converting the business_start_time and business_end_time to UTC timezone
-- we need to find the max value of the business_start_time, the min value of the business_end_time in UTC
-- from there, add 1 hour to the start time to get => the end time
-- for the new row, add 30 minutes to the start time and stop when the end time +30 minutes less than the mi value of business_end_time
-- the challenge is the recursive_cte should be on the top, so I have sub-queries in the FROM to find max of start time and min end time in UTC
-- I do this challenge in Postgresql
WITH RECURSIVE time_intervals_cte AS (
  -- Base case
  SELECT 
    utc_start_time AS meeting_start_utc, -- meeting_start_utc is the max value of the business_start time in UTC
    utc_start_time + INTERVAL '1 hour' AS meeting_end_utc -- from the start time, plus 1 hour to get the meeting_end_utc
  FROM (
    -- this step will convert the current timezone into UTC timezone and output the timestamp at UTC timezone
    -- only get the MAX value of the START time because most people can join at that time
    -- get the MIN value of the END time because most people can join until that time
    -- for the timestamp, needs to add the date, assign any dates
    SELECT 
      MAX(('2024-12-24'::date + business_start_time) AT TIME ZONE timezone AT TIME ZONE 'UTC') AS utc_start_time,
      MIN(('2024-12-24'::date + business_end_time) AT TIME ZONE timezone AT TIME ZONE 'UTC') AS utc_end_time
    FROM 
      Workshops
  ) time_bound
  WHERE 
    -- (upper bound) stop adding the interval if the start time plus interval is greater than the end time
    utc_start_time + INTERVAL '1 hour' <= utc_end_time 
  
  UNION ALL

  -- Recursively case to add 30 minutes
  SELECT 
    meeting_start_utc + INTERVAL '30 minutes', -- for the new row, add 30 minutes to the current meeting_start_utc 
    meeting_end_utc + INTERVAL '30 minutes' -- also add 30 minutes to the meeting_end_utc in the new row
  FROM 
    time_intervals_cte, ( -- because this is a recursive, so run this cte again if still satisfying the WHERE condition
      SELECT 
        MAX(('2024-12-24'::date + business_start_time) AT TIME ZONE timezone AT TIME ZONE 'UTC') AS utc_start_time,
        MIN(('2024-12-24'::date + business_end_time) AT TIME ZONE timezone AT TIME ZONE 'UTC') AS utc_end_time
      FROM 
        Workshops
    ) time_bound
  WHERE 
    -- (lower bound) when adding 30 minutes to the end time. make sure it less than the min of business end time in UTC
    meeting_end_utc + INTERVAL '30 minutes' <= time_bound.utc_end_time 
)
SELECT 
  -- return only the time from the timezone
  meeting_start_utc::time AS meeting_start_utc,
  meeting_end_utc::time AS meeting_end_utc
FROM 
  time_intervals_cte
ORDER BY 
  meeting_start_utc;
