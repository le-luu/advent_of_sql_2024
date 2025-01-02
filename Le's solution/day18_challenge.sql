/** ADVENT OF SQL - Day 18**/
-- Solved by: Le Luu
-- Level: Advanced
-- Source: https://adventofsql.com/
/** Description:
Write a query that finds the number of peers for the employee with the most peers. Peers are defined as employees who share both the same manager and the same level in the hierarchy.

Find the employee with the most peers and lowest level (e.g. smaller number). If there's more than 1 order by staff_id ascending.

Note: When counting peers, include the employee themselves in the count. So two employees who are peers would give a count of 2.

Submit the id of the staff member
**/

CREATE DATABASE aos_ch18;
USE aos_ch18;

CREATE TABLE staff (
    staff_id INT PRIMARY KEY,
    staff_name VARCHAR(100) NOT NULL,
    manager_id INT,
    FOREIGN KEY (manager_id) REFERENCES Staff(staff_id)
);

INSERT INTO staff (staff_id, staff_name, manager_id) VALUES
    (1, 'Santa Claus', NULL),                -- CEO level
    (2, 'Head Elf Operations', 1),           -- Department Head
    (3, 'Head Elf Logistics', 1),            -- Department Head
    (4, 'Senior Toy Maker', 2),              -- Team Lead
    (5, 'Senior Gift Wrapper', 2),           -- Team Lead
    (6, 'Inventory Manager', 3),             -- Team Lead
    (7, 'Junior Toy Maker', 4),              -- Staff
    (8, 'Junior Gift Wrapper', 5),           -- Staff
    (9, 'Inventory Clerk', 6),               -- Staff
    (10, 'Apprentice Toy Maker', 7);         -- Entry Level

-- use the recursive cte to find the level and path (Copied from the challenge on day 8)    
WITH RECURSIVE hierarchy_cte as (
    -- declare the base case
	SELECT 
        staff_id,
        staff_name, 
        1 as level,
        CAST(staff_id as CHAR) as path,
        manager_id
    FROM staff
    WHERE manager_id is null

	UNION ALL
    
    -- declare the recursive case, we only match the staff_id with the manager_id
    -- each time it matched, the level will be increased by 1
	SELECT 
        s.staff_id,
        s.staff_name,
        h.level+1 as level,
        CONCAT(h.path, ",", s.staff_id) as path,
        s.manager_id
    FROM staff as s
    JOIN hierarchy_cte h 
    ON s.manager_id = h.staff_id
),
-- count the peer count if staff_name has the same level and manager id
-- do it by joining the table by itself on level and manager id. However, the staff_name cannot join by itself
peer_count_cte as (
	SELECT 
	   h1.level,
	   h1.manager_id,
	   COUNT(h2.staff_id) as peer_count -- count number of staff who shared the same level and manager
	FROM hierarchy_cte h1  -- Join the table by itself based on the condition that it has same level and manager id, but staff id is different
	JOIN hierarchy_cte h2
	ON 
       h1.level = h2.level
	   AND h1.manager_id = h2.manager_id 
	   AND h1.staff_id!=h2.staff_id
	GROUP BY 1,2
),
-- count the peers who have the same level
peer_same_level_cte as (
	SELECT 
        level,
        COUNT(level) as total_peers_same_level
    FROM hierarchy_cte
    GROUP BY level
)
SELECT 
    h.staff_id,
    h.staff_name,
    h.level,
    h.path,
    h.manager_id,
    IFNULL(p.peer_count,1) as peers_same_manager, -- if the peer_count is null (not share the level, manager id) then return 1
    l.total_peers_same_level
FROM hierarchy_cte h
LEFT JOIN peer_count_cte p
ON h.level=p.level
    AND h.manager_id=p.manager_id
JOIN peer_same_level_cte l
ON l.level=h.level
ORDER BY 
    total_peers_same_level DESC, 
    level ASC, 
    staff_id ASC
;