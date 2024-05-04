use stratascratch;

/*
Find the top business categories based on the total number of reviews.
Output the category along with the total number of reviews. Order by total reviews in descending order.
*/
show columns from yelp_business;

select * from yelp_business;

-- check how many occurrences in the col
-- then find the max occurrences to create the temp num table
select
	max(char_length(categories) - char_length(replace(categories, ';', '')))
from yelp_business;

-- create temp table with cte
with recursive num (n) as (
	select 1
    union
    select n + 1
    from num
    where n < (	select max(char_length(categories) - char_length(replace(categories, ';', '')))
				from yelp_business)
    )
select
    substring_index(substring_index(categories, ';', n), ';', -1) category
    ,SUM(review_count) review_cnt
from yelp_business
left join num
	on char_length(categories) - char_length(replace(categories, ';', '')) >= n - 1
GROUP BY
	substring_index(substring_index(categories, ';', n), ';', -1)
order by 1 -- review_cnt desc;
;

### using json_table()
SELECT
   cat, -- This is the column that will house the unnested categories
   SUM(review_count) review_cnt
FROM yelp_business,
JSON_TABLE(
           CAST(CONCAT('["', REPLACE(categories, ';', '","'), '"]') AS JSON),  --  here will make the categories column into Json 
           '$[*]' COLUMNS(cat VARCHAR(50) PATH '$')) AS t
GROUP BY cat
ORDER BY 2 DESC;

select
	CONCAT('["', REPLACE(categories, ';', '","'), '"]')
    ,CAST(CONCAT('["', REPLACE(categories, ';', '","'), '"]') AS JSON)
from yelp_business;

select
	*
from
	yelp_business
	,JSON_TABLE(CAST(CONCAT('["', REPLACE(categories, ';', '","'), '"]') AS JSON),
				'$[*]' COLUMNS(category varchar(50) PATH '$')) t;
                