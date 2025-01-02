/** ADVENT OF SQL - Day 20**/
-- Solved by: Le Luu
-- Level: Advanced
-- Source: https://adventofsql.com/
/** Description:
Parse out all the query parameters from the urls.

A query param is a list of key value pairs that follow this syntax ?item=toy&id=1

Note the & is how to list multiple key value pairs.

Once you extract all the query params filter them so only the urls with utm_source=advent-of-sql are returned.

Submit the url with the most query params (including the utm-source)

If there are multiple rows order by the url ascending
**/

CREATE DATABASE aos_ch20;
USE aos_ch20;

CREATE TABLE web_requests (
    request_id SERIAL PRIMARY KEY,
    url TEXT NOT NULL
);

INSERT INTO web_requests (url) VALUES
('http://example.com/page?param1=value1¶m2=value2'),
('https://shop.example.com/items?item=toy&color=red&size=small&ref=google&utm_source=advent-of-sql'),
('http://news.example.org/article?id=123&source=rss&author=jdoe&utm_source=advent-of-sql'),
('https://travel.example.net/booking?dest=paris&date=2024-12-19&class=business'),
('http://music.example.com/playlist?genre=pop&duration=long&listener=guest&utm_source=advent-of-sql');

-- extract all parameters from the url
WITH parameter_only_cte as (
    SELECT 
        url,
        SUBSTRING_INDEX(url,'?',-1) as param_split -- extract the parameters which are after the ? 
    FROM web_requests
),
-- format the parameter in the list, same as the output table
format_param_cte as (
    SELECT 
        url,
        -- replace the '=' by ':'
        -- replace the '&' by ','
        -- all are wrapped by the '{}'
        CONCAT('{"',REPLACE(REPLACE(param_split,'=','":"'),'&','","'),'"}') as query_parameters 
    FROM parameter_only_cte
    WHERE param_split LIKE '%advent-of-sql%' -- only get url which contains the 'advent-of-sql' text
)
SELECT 
    url, 
    CAST(query_parameters AS JSON) as query_parameters,  -- convert the query_parameters as JSON data type
    -- calculate the number of parameter by counting the number of colon ':' in the string
    -- taking the length of whole query_parameters subtract the length of query_parametes without the ':' => then, will get number of colon ':'
    LENGTH(query_parameters) - LENGTH(REPLACE(query_parameters,':','')) as count_params 
FROM format_param_cte
ORDER BY 
    count_params DESC, 
    url ASC;