/** ADVENT OF SQL - Day 1**/
-- Solved by: Le Luu
-- Level: Beginner
-- Source: https://adventofsql.com/
/** Description:
 Create a report showing what gifts children want, with difficulty ratings and categorization.
 The primary wish will be the first choice
 The secondary wish will be the second choice
 You can presume the favorite color is the first color in the wish list
 Gift complexity can be mapped from the toy difficulty to make. Assume the following:
    Simple Gift = 1
    Moderate Gift = 2
    Complex Gift >= 3
 We assign the workshop based on the primary wish's toy category. Assume the following:
  outdoor = Outside Workshop
  educational = Learning Workshop
  all other types = General Workshop
Order the list by name in ascending order.

Your answer should limit its return to only 5 rows
**/

CREATE DATABASE ADVENT_OF_CODE_DAY1;
USE ADVENT_OF_CODE_DAY1;
  CREATE TABLE children (
      child_id INT PRIMARY KEY,
      name VARCHAR(100),
      age INT
  );
  CREATE TABLE wish_lists (
      list_id INT PRIMARY KEY,
      child_id INT,
      wishes JSON,
      submitted_date DATE
  );
  CREATE TABLE toy_catalogue (
      toy_id INT PRIMARY KEY,
      toy_name VARCHAR(100),
      category VARCHAR(50),
      difficulty_to_make INT
  );
  
    INSERT INTO children VALUES
  (1, 'Tommy', 8),
  (2, 'Sally', 7),
  (3, 'Bobby', 9);

  INSERT INTO wish_lists VALUES
  (1, 1, '{"first_choice": "bike", "second_choice": "blocks", "colors": ["red", "blue"]}', '2024-11-01'),
  (2, 2, '{"first_choice": "doll", "second_choice": "books", "colors": ["pink", "purple"]}', '2024-11-02'),
  (3, 3, '{"first_choice": "blocks", "second_choice": "bike", "colors": ["green"]}', '2024-11-03');

  INSERT INTO toy_catalogue VALUES
  (1, 'bike', 'outdoor', 3),
  (2, 'blocks', 'educational', 1),
  (3, 'doll', 'indoor', 2),
  (4, 'books', 'educational', 1);
  
  -- Use the wish_option_cte to extract the data from JSON. 
  WITH wish_option_cte as (
	  SELECT c.name, 
			  JSON_UNQUOTE(JSON_EXTRACT(w.wishes, '$.first_choice')) as primary_wish,
			  JSON_UNQUOTE(JSON_EXTRACT(w.wishes, '$.second_choice')) as backup_wish,
			  JSON_UNQUOTE(JSON_EXTRACT(w.wishes, '$.colors[0]')) as favorite_color, -- favorite color is the first choice in the color array
			  JSON_LENGTH(JSON_EXTRACT(w.wishes, '$.colors')) AS color_count -- count how many items in the colors array using JSON_LENGTH
	  FROM children c
	  JOIN wish_lists w
	  ON c.child_id=w.child_id
  )
  SELECT w.name, 
		    w.primary_wish, 
        w.backup_wish, 
        favorite_color, 
        color_count,
        (CASE -- Distinguish the gift_complexity based on the difficulty_to_make field
  		     WHEN t.difficulty_to_make = 1 THEN "Simple Gift" 
           WHEN t.difficulty_to_make = 2 THEN "Moderate Gift"
           WHEN t.difficulty_to_make >=3 THEN "Complex Gift"
         END
        ) AS gift_complexity,
        (
        CASE -- Also use CASE WHEN for distinguishing the workshop_assignment based on the category
  		     WHEN t.category="outdoor" THEN "Outside Workshop"
           WHEN t.category="educational" THEN "Learning Workshop"
           ELSE "General Workshop"
        END
        ) AS workshop_assignment
  FROM wish_option_cte w
  JOIN toy_catalogue t
  ON w.primary_wish = t.toy_name
  ORDER BY name ASC;
  
  