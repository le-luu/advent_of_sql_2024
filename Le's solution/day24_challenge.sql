/** ADVENT OF SQL - Day 24**/
-- Solved by: Le Luu
-- Level: Beginner
-- Source: https://adventofsql.com/
/** Description:
Find the most popular song with the most plays and least skips, in that order.

A skip is when the song hasn't been played the whole way through.

Submit the song name.
**/

CREATE DATABASE aos_ch24;
USE aos_ch24;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(255) NOT NULL
);
CREATE TABLE songs (
    song_id INT PRIMARY KEY,
    song_title VARCHAR(255) NOT NULL,
    song_duration INT  -- Duration in seconds, can be NULL if unknown
);
CREATE TABLE user_plays (
    play_id INT PRIMARY KEY,
    user_id INT,
    song_id INT,
    play_time DATE,
    duration INT,  -- Duration in seconds, can be NULL
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (song_id) REFERENCES songs(song_id)
);

-- Inserting data into users table
INSERT INTO users (user_id, username) VALUES (1, 'alice');
INSERT INTO users (user_id, username) VALUES (2, 'bob');
INSERT INTO users (user_id, username) VALUES (3, 'carol');

-- Inserting data into songs table, including a song with a NULL duration
INSERT INTO songs (song_id, song_title, song_duration) VALUES (1, 'Jingle Bells', 180);
INSERT INTO songs (song_id, song_title, song_duration) VALUES (2, 'Silent Night', NULL); -- NULL duration
INSERT INTO songs (song_id, song_title, song_duration) VALUES (3, 'Deck the Halls', 150);

-- Inserting example play records into user_plays table, including NULL durations
INSERT INTO user_plays (play_id, user_id, song_id, play_time, duration) VALUES (1, 1, 1, '2024-12-22', 180);  -- Full play
INSERT INTO user_plays (play_id, user_id, song_id, play_time, duration) VALUES (2, 2, 1, '2024-12-22', 100);  -- Skipped
INSERT INTO user_plays (play_id, user_id, song_id, play_time, duration) VALUES (3, 3, 2, '2024-12-22', NULL); -- NULL duration (unknown play)
INSERT INTO user_plays (play_id, user_id, song_id, play_time, duration) VALUES (4, 1, 2, '2024-12-23', 180);  -- Valid duration, but song duration unknown
INSERT INTO user_plays (play_id, user_id, song_id, play_time, duration) VALUES (5, 2, 2, '2024-12-23', NULL); -- NULL duration
INSERT INTO user_plays (play_id, user_id, song_id, play_time, duration) VALUES (6, 3, 3, '2024-12-23', 150);  -- Full play

-- Additional plays with NULLs and shorter durations
INSERT INTO user_plays (play_id, user_id, song_id, play_time, duration) VALUES (7, 1, 3, '2024-12-23', 150);  -- Full play
INSERT INTO user_plays (play_id, user_id, song_id, play_time, duration) VALUES (8, 2, 3, '2024-12-22', 140);  -- Skipped
INSERT INTO user_plays (play_id, user_id, song_id, play_time, duration) VALUES (9, 3, 1, '2024-12-23', NULL); -- NULL duration
INSERT INTO user_plays (play_id, user_id, song_id, play_time, duration) VALUES (10, 1, 3, '2024-12-22', NULL); -- NULL duration


-- Distinguish the full or skip play
WITH full_skip_cte as (
    SELECT 
        s.song_title,
        -- if the song_duration = the duration that a player plays, then it's full; otherwise, skip
        -- However, there is a case that no data in song_duration and no duration when the player plays
        -- In that case, if a player plays the song, but no data in song_duration => count it as full; otherwise, skip
        IF(s.song_duration = u.duration OR (s.song_duration is null and u.duration is not null), "full", "skip") as full_play
    FROM songs s 
    JOIN user_plays u 
    ON s.song_id = u.song_id
)
SELECT 
    song_title,
    COUNT(song_title) as total_plays,
    -- summarize how many songs were skipped
    SUM(
        CASE 
            WHEN full_play='skip' THEN 1 ELSE 0 END
    ) as total_skips
FROM full_skip_cte
GROUP BY 1
ORDER BY 
    total_plays DESC, 
    total_skips ASC;

