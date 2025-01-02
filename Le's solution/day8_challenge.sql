/** ADVENT OF SQL - Day 8**/
-- Solved by: Le Luu
-- Level: Intermediate
-- Source: https://adventofsql.com/
/** Description:
We want to find out how many managers the most over-managed employee has (levels deep).

To do this, you're going to need to go through all the employees and find out who their manager is, and who their manger is, and who their manger is... you see where this is going

You need to produce a report that calculates this management depth for all employees

Order it by the number of levels in descending order.

Submit the highest total number of levels of all the staff in the DB.

If there are multiple with the same level submit that.
**/
CREATE DATABASE aos_ch08;
USE aos_ch08;

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

-- analyze from the table, we see that the path is the manager_id + comma + staff_id
SELECT 
    staff_id, 
    staff_name, 
    manager_id,
    GROUP_CONCAT(manager_id, ",",staff_id) as path
FROM staff
GROUP BY 1;


-- from the result, you can see that we need to find the path for each staff_id by joining the 
-- staff_id with the manager_id of each person to find the full path
-- start with the base case which staff_id is 1 and manager id is null
WITH RECURSIVE hierarchy_cte as (
    -- declare the base case
	SELECT 
        staff_id,
        staff_name, 
        1 as level, -- assign 1 to the level which has manager_id is null
        CAST(staff_id as CHAR) as path
    FROM staff
    WHERE manager_id is null

	UNION ALL
    
    -- declare the recursive case, we only match the staff_id with the manager_id
    -- each time it matched, the level will be increased by 1
	SELECT 
        s.staff_id,
        s.staff_name,
        h.level+1 as level, -- after each recursive function run, increase the level by 1
        CONCAT(h.path, ",", s.staff_id) as path -- concatenate the path with the staff_id, separated by comma
    FROM staff as s
    JOIN hierarchy_cte h 
    ON s.manager_id = h.staff_id -- the staff is also a manager of other staff. So need to join it to let the recursive case run to increase the level
)
SELECT *
FROM hierarchy_cte
ORDER BY 
    level DESC, 
    staff_name ASC;