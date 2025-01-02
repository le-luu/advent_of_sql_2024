/** ADVENT OF SQL - Day 3**/
-- Solved by: Le Luu
-- Level: Intermediate
-- Source: https://adventofsql.com/
/** Description:
The challenge is that some records are stored in different XML schemas. Mrs. Claus needs help writing a SQL query that can search through all schema versions to find the most beloved dishes from the busiest celebrations. As she's having more than 78 guests this year, she wants to make sure the dishes are popular with a large crowd, so only use years where she had more than 78 guests.

You will have to do some prep-work before you write your final query, like understanding how many unique schema versions exist and how to parse each schema using SQL.

Help Mrs. Claus write a SQL query that can:

Parse through all different schema versions of menu records
Find menu entries where the guest count was above 78
Extract the food_item_ids from those successful big dinners
From this enormous list of items, determine which dish (by food_item_id) appears most frequently across all of the dinners.
Input the food_item_id of the food item that appears the most often.
**/
CREATE TABLE christmas_menus (
  id SERIAL PRIMARY KEY,
  menu_data TEXT
);

INSERT INTO christmas_menus (id, menu_data) VALUES
(1, '<menu version="1.0">
    <dishes>
        <dish>
            <food_item_id>99</food_item_id>
        </dish>
        <dish>
            <food_item_id>102</food_item_id>
        </dish>
    </dishes>
    <total_count>80</total_count>
</menu>');

INSERT INTO christmas_menus (id, menu_data) VALUES
(2, '<menu version="2.0">
    <total_guests>85</total_guests>
    <dishes>
        <dish_entry>
            <food_item_id>101</food_item_id>
        </dish_entry>
        <dish_entry>
            <food_item_id>102</food_item_id>
        </dish_entry>
    </dishes>
</menu>');

INSERT INTO christmas_menus (id, menu_data) VALUES
(3, '<menu version="beta">
  <guestCount>15</guestCount>
  <foodList>
      <foodEntry>
          <food_item_id>102</food_item_id>
      </foodEntry>
  </foodList>
</menu>');

-- parse the XML data using unnest function in Postgresql
WITH extracted_data AS (
    SELECT id,
           -- use unnest function to extract the data with the path, convert it to int
           unnest(xpath('//food_item_id/text()', menu_data::xml))::text::int AS food_item_id, -- cast the menu_data is in xml format, after unnest it, cast it to int
           -- in case no values in the total count, return 0 
           -- The total guest could come from 2 paths total_cunt or total_guests
           COALESCE(
               (xpath('//total_count/text()', menu_data::xml))[1]::text::int,
               (xpath('//total_guests/text()', menu_data::xml))[1]::text::int,
               0 
           ) AS total_count
    FROM christmas_menus
)
-- count each item in the food_item_id group by itself
SELECT food_item_id, 
       COUNT(food_item_id) AS food_item_count
FROM extracted_data
WHERE total_count > 78 -- filter that the guest should greater than 78
GROUP BY food_item_id -- use the aggregate function COUNT, so need to use GROUP BY
ORDER BY food_item_id DESC
LIMIT 1; -- print out the food_item_id has the most order








