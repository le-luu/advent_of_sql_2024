/** ADVENT OF SQL - Day 12**/
-- Solved by: Le Luu
-- Level: Intermediate
-- Source: https://adventofsql.com/
/** Description:
Find the toy with the second highest percentile of requests. Submit the name of the toy and the percentile value.

If there are multiple values, choose the first occurrence.

Order by percentile descending, then gift name ascending.
**/

CREATE DATABASE aos_ch12;
USE aos_ch12;

DROP TABLE IF EXISTS gifts CASCADE;
CREATE TABLE gifts (
    gift_id INT PRIMARY KEY,
    gift_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2)
);
DROP TABLE IF EXISTS gift_requests CASCADE;
CREATE TABLE gift_requests (
    request_id INT PRIMARY KEY,
    gift_id INT,
    request_date DATE,
    FOREIGN KEY (gift_id) REFERENCES Gifts(gift_id)
);

INSERT INTO gifts VALUES 
(1, 'Robot Kit', 89.99),
(2, 'Smart Watch', 149.99),
(3, 'Teddy', 199.99),
(4, 'Hat', 59.99);

INSERT INTO gift_requests VALUES
(1, 1, '2024-12-25'),
(2, 1, '2024-12-25'),
(3, 1, '2024-12-25'),
(4, 2, '2024-12-25'),
(5, 2, '2024-12-25'),
(6, 2, '2024-12-25'),
(7, 3, '2024-12-25'),
(8, 3, '2024-12-25'),
(9, 3, '2024-12-25'),
(10, 3, '2024-12-25'),
(11, 4, '2024-12-25'),
(12, 4, '2024-12-25'),
(13, 4, '2024-12-25'),
(14, 4, '2024-12-25'),
(15, 4, '2024-12-25');

-- declare a cte to count the number of gift by each gift_name
WITH temp_count_cte as (
    SELECT 
        gift_name,
        COUNT(r.request_id) as num_gift_name
    FROM gifts g
    JOIN gift_requests r
    ON g.gift_id = r.gift_id
    GROUP BY 1
),
-- after counting the number of each gift, find the percent rank of each gift using WINDOW function PERCENT_RANK()
percent_rank_cte as (
    SELECT 
        gift_name,
        ROUND(PERCENT_RANK() OVER (ORDER BY num_gift_name),2) as overall_rank -- use the percent_rank to find the percentile of each gift order by the number of each gift
    FROM temp_count_cte
),
-- because we want the second highest percentile of requests. so use the DENSE_RANK function
rank_overall_cte as (
    SELECT 
        gift_name,
        overall_rank,
        DENSE_RANK() OVER (ORDER BY overall_rank DESC) as rank_by_overall
    FROM percent_rank_cte
)
SELECT 
    gift_name,
    overall_rank
FROM rank_overall_cte
WHERE rank_by_overall=2; -- print the second highest percentile 