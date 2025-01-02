/** ADVENT OF SQL - Day 14**/
-- Solved by: Le Luu
-- Level: Intermediate
-- Source: https://adventofsql.com/
/** Description:
Mrs. Claus needs to find the receipt for Santa's green suit that was dry cleaned.

She needs to know when it was dropped off, so submit the drop off date.

Order by the latest drop off date
**/

CREATE DATABASE aos_ch14;
USE aos_ch14;

CREATE TABLE SantaRecords (
    record_id INT PRIMARY KEY,
    record_date DATE,
    cleaning_receipts JSON
);

INSERT INTO SantaRecords (record_id, record_date, cleaning_receipts) VALUES 
(1, '2024-11-25', '[
    {
        "receipt_id": "R120",
        "garment": "hat",
        "color": "red",
        "cost": 15.99,
        "drop_off": "2024-11-25",
        "pickup": "2024-11-27"
    },
    {
        "receipt_id": "R121",
        "garment": "mittens",
        "color": "white",
        "cost": 12.99,
        "drop_off": "2024-11-25",
        "pickup": "2024-11-27"
    }
]');

INSERT INTO SantaRecords (record_id, record_date, cleaning_receipts) VALUES 
(2, '2024-12-01', '[
    {
        "receipt_id": "R122",
        "garment": "suit",
        "color": "red",
        "cost": 25.99,
        "drop_off": "2024-12-01",
        "pickup": "2024-12-03"
    },
    {
        "receipt_id": "R123",
        "garment": "boots",
        "color": "black",
        "cost": 18.99,
        "drop_off": "2024-12-01",
        "pickup": "2024-12-03"
    }
]');

-- Here's the record with the green suit
INSERT INTO SantaRecords (record_id, record_date, cleaning_receipts) VALUES 
(3, '2024-12-10', '[
    {
        "receipt_id": "R124",
        "garment": "suit",
        "color": "green",
        "cost": 29.99,
        "drop_off": "2024-12-10",
        "pickup": "2024-12-12"
    },
    {
        "receipt_id": "R125",
        "garment": "scarf",
        "color": "green",
        "cost": 10.99,
        "drop_off": "2024-12-10",
        "pickup": "2024-12-12"
    }
]');

-- this challenge contains the JSON data, so need to parse it
WITH parse_json_cte as (
	SELECT 
        s.record_id,
        s.record_date,
    	j.receipt_id, -- column starts from table j are parsed from the JSON data in cleaning_receipts column
    	j.garment,
    	j.color,
    	j.cost,
    	j.drop_off,
    	j.pickup
	FROM SantaRecords s,
    -- use JSON_TABLE to extract data to each different column in the cleaning_receipts JSON data
	JSON_TABLE(
		s.cleaning_receipts,
		'$[*]' COLUMNS (
			receipt_id VARCHAR(10) PATH '$.receipt_id',
			garment VARCHAR(10) PATH '$.garment',
			color VARCHAR(10) PATH '$.color',
			cost DECIMAL(10,2) PATH '$.cost',
			drop_off DATE PATH '$.drop_off',
			pickup DATE PATH '$.pickup'
		)
	) as j
)
SELECT 
    record_date, 
    drop_off, 
    receipt_id, 
    garment, 
    color, 
    cost, 
    pickup
FROM parse_json_cte
WHERE garment='suit' AND color='green' -- filter the data by getting only the green suit
ORDER BY drop_off DESC;
