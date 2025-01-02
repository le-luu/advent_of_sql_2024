/** ADVENT OF SQL - Day 10**/
-- Solved by: Le Luu
-- Level: Intermediate
-- Source: https://adventofsql.com/
/** Description:
You are working with a table named drinks, which logs various types of beverages consumed over the Christmas parties, along with the date and quantity consumed. Your task is to determine which drinks were the most popular by calculating the total quantity consumed for each type of drink.

Submit the date where the following total quantity of drinks were consumed:

HotCocoa: 38
PeppermintSchnapps: 298
Eggnog: 198
**/

CREATE DATABASE aos_ch10;
USE aos_ch10;

DROP TABLE IF EXISTS Drinks CASCADE;
CREATE TABLE Drinks (
    drink_id SERIAL PRIMARY KEY,
    drink_name VARCHAR(50) NOT NULL,
    date DATE NOT NULL,
    quantity INTEGER NOT NULL
);

INSERT INTO Drinks (drink_name, date, quantity) VALUES
    ('Eggnog', '2024-12-24', 50),
    ('Eggnog', '2024-12-25', 60),
    ('Hot Cocoa', '2024-12-24', 75),
    ('Hot Cocoa', '2024-12-25', 80),
    ('Peppermint Schnapps', '2024-12-24', 30),
    ('Peppermint Schnapps', '2024-12-25', 40);

-- the challenge is pivot the data from rows to columns
WITH pivot_cte as (
    SELECT 
        date,
        -- depend on the drink name, find the quantity, need to use aggregate function
        MAX(CASE WHEN drink_name='Eggnog' THEN quantity END) as Eggnog,
        MAX(CASE WHEN drink_name='Hot Cocoa' THEN quantity END) as "Hot Cocoa",
        MAX(CASE WHEN drink_name='Peppermint Schnapps' THEN quantity END) as "Peppermint Schnapps"
    FROM Drinks
    GROUP BY date
    ORDER BY date
)
SELECT date
FROM pivot_cte
WHERE 
    Eggnog=50 OR 
    "Hot Cocoa"=75 OR 
    "Peppermint Schnapps"=30;