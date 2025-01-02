/** ADVENT OF SQL - Day 13**/
-- Solved by: Le Luu
-- Level: Intermediate
-- Source: https://adventofsql.com/
/** Description:
Create a list of all the domains that exist in the contacts list emails.

Submit the domain names with the most emails.
**/


CREATE DATABASE aos_ch13;
USE aos_ch13;

CREATE TABLE contact_list (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email_addresses JSON NOT NULL -- the original data is an array, but I'm using MySQL, so I need to use the JSON data type
);

INSERT INTO contact_list (name, email_addresses) VALUES
('Santa Claus', 
 '["santa@northpole.com", "kringle@workshop.net", "claus@giftsrus.com"]'),
('Head Elf', 
 '["supervisor@workshop.net", "elf1@northpole.com", "toys@workshop.net"]'),
('Grinch', 
 '["grinch@mountcrumpit.com", "meanie@whoville.org"]'),
('Rudolph', 
 '["red.nose@sleigh.com", "rudolph@northpole.com", "flying@reindeer.net"]');
 
 -- parse the JSON to extract the data
 WITH parse_cte as (
	 SELECT e.value as email_addr
	 FROM 
	 	contact_list c,
	 	-- use JSON_TABLE function to parse each value in the column email_addresses
	 	JSON_TABLE(c.email_addresses, '$[*]' COLUMNS (value VARCHAR(100) PATH '$')) e
 ),
 -- this cte will extractt the domain of each email which is the text after '@' character
 split_str_cte as (
	 SELECT 
	 	email_addr,
	 	-- use SUBSTRING_INDEX function to get the domain after @ -> -1
	 	SUBSTRING_INDEX(email_addr,'@',-1) as Domain
	 FROM parse_cte
 )
 -- count the users use each domain
 SELECT 
 	Domain,
 	COUNT(DISTINCT email_addr) as "Total Users",
 	-- format the value same as the output table
 	CONCAT('{',GROUP_CONCAT(email_addr ORDER BY email_addr SEPARATOR ','),'}') as Users
 FROM split_str_cte
 GROUP BY Domain
 ORDER BY 2 DESC; -- Order the table by the total users in descending