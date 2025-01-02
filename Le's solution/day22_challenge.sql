/** ADVENT OF SQL - Day 22**/
-- Solved by: Le Luu
-- Level: Advanced
-- Source: https://adventofsql.com/
/** Description:
Find all the elves with SQL as a skill

Count each elf only once.

Only the skill SQL counts, MySQL etc. does not count.
**/

CREATE DATABASE aos_ch22;
USE aos_ch22;

DROP TABLE IF EXISTS elves CASCADE;
    CREATE TABLE elves (
      id SERIAL PRIMARY KEY,
      elf_name VARCHAR(255) NOT NULL,
      skills TEXT NOT NULL
    );
    
INSERT INTO elves (elf_name, skills)
VALUES 
    ('Eldrin', 'Elixir,Python,C#,JavaScript,MySQL'),           -- 4 programming skills
    ('Faenor', 'C++,Ruby,Kotlin,Swift,Perl'),          -- 5 programming skills
    ('Luthien', 'PHP,TypeScript,Go,SQL');              -- 4 programming skills
INSERT INTO elves (elf_name, skills)
VALUES (
'Test', 'SQL,Python,Java'
);
INSERT INTO elves (elf_name, skills)
VALUES (
'Test2', 'Python,SQL,Java'
);

-- I use the REGEX expression to find SQL in the string and count it
SELECT COUNT(*) as numofelvesqiwthsql
FROM elves
WHERE skills REGEXP '(,|^)SQL(,|$)'; 
-- the condition is skills should include 3 cases:
-- if SQL locates at the front of the string, then at the end of SQL should be a comma or end of string
-- if SQL locates at the middle of the string, then at the end of SQL should be a comma or end of string
-- if SQL locates at the end of the string, then the text at the front of SQL can be a comma or beginning of the string
