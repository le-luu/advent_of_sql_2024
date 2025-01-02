/** ADVENT OF SQL - Day 21**/
-- Solved by: Le Luu
-- Level: Advanced
-- Source: https://adventofsql.com/
/** Description:
Find the quarter with the highest growth rate relative to the previous quarter's sales figures

Order by growth rate descending

Submit the year and quarter in the format YYYY,Q
**/

CREATE DATABASE aos_ch21;
USE aos_ch21;

CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    sale_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL
);

INSERT INTO sales (sale_date, amount) VALUES ('2024-01-10', 3500.25);
INSERT INTO sales (sale_date, amount) VALUES ('2023-01-15', 1500.50);
INSERT INTO sales (sale_date, amount) VALUES ('2023-04-20', 2000.00);
INSERT INTO sales (sale_date, amount) VALUES ('2023-07-12', 2500.75);
INSERT INTO sales (sale_date, amount) VALUES ('2023-10-25', 3000.00);


-- get the previous sales order by the quarter
WITH prev_sales_cte as (
	SELECT 
		YEAR(sale_date) as year, 
		QUARTER(sale_date) as quarter, 
		amount as total_sales,
		-- use the LAG function to assign the sales value of the previous quarter on the same row of the current quarter
		LAG(amount) OVER (ORDER BY YEAR(sale_date),QUARTER(sale_date)) as prev_sales
	FROM sales
	ORDER BY 1,2
)
SELECT 
	year, 
	quarter, 
	total_sales,
	-- find the growth_rate by taking the difference of the current and previous sales divided by the previous sales
	((total_sales-prev_sales)/(prev_sales)) as growth_rate
FROM prev_sales_cte
ORDER BY growth_rate DESC;