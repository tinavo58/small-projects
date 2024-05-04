use stratascratch;

show columns from fb_active_users;

select
	max(length(name)) `name`
    ,max(length(country)) `country`
from fb_active_users;

alter table fb_active_users
modify name varchar(20),
modify country varchar(10),
modify status enum('open', 'closed');

select * from fb_active_users;

/*
Output share of US users that are active. Active users are the ones with an "open" status in the table.
*/
select
	sum(status = 'open' and country = 'USA') / sum(country = 'USA')
from fb_active_users;

select
	active_usa/total
from (
	select
		count(*) total
		,count(nullif(status='closed',1)) active_usa
	from fb_active_users
	where country = 'USA'
    ) t;
    
/*
Return a distribution of users activity per day of the month.
By distribution we mean the number of posts per day of the month.
*/
show columns from fb_posts;

alter table fb_posts
modify post_date date;

rename table fb_posts to facebook_posts;

select * from fb_posts;

-- this method generates results faster
select
	day(post_date)
    ,count(post_id)
from facebook_posts
group by day(post_date);

select
	extract(day from post_date)
    ,count(post_id)
from facebook_posts
group by extract(day from post_date);

/*
Return the total number of comments received for each user in the 30 or less days before 2020-02-10.
Don't output users who haven't received any comment in the defined time period.
*/
show columns from fb_comments_count;

alter table fb_comments_count
modify created_at date;

select c.*, country from fb_comments_count c
join fb_active_users using (user_id)
where country = 'Denmark';

select
	user_id
    ,sum(number_of_comments)
from fb_comments_count
where created_at between ('2020-02-10' - interval 30 day) and '2020-02-10'
group by user_id;

/*
Which countries have risen in the rankings based on the number of comments between Dec 2019 vs Jan 2020?
Hint: Avoid gaps between ranks when ranking countries.
*/
select
	country
    ,extract(year_month from created_at)
    ,count(*) total_comments
    ,count(*) - lag(count(*)) over (partition by country order by extract(year_month from created_at)) as different
from fb_comments_count
join fb_active_users using (user_id)
where extract(year_month from created_at) between 201912 and 202001
group by 1, 2;

-- check comment in Dec 2019 and Jan 2020
-- create ranking in Dec 2019, then in Jan 2020
-- then compare 2 ranking
with cte as (
	select
		country
		,sum(case when extract(year_month from created_at) = 201912 then number_of_comments end) dec_2019
		,sum(case when extract(year_month from created_at) = 202001 then number_of_comments end) jan_2020
	from fb_comments_count
	join fb_active_users using (user_id)
	group by country
    ),
    ranking as (
	select
		country
        ,dec_2019
		,dense_rank() over (order by dec_2019 desc) rk_19
        ,jan_2020
		,dense_rank() over (order by jan_2020 desc) rk_20
	from cte
    where jan_2020 is not null
    )
select
	country
from ranking
where rk_20 < rk_19 or dec_2019 is null;

-- other ppl's solution
with dec_ranking as (
	select
		country
        ,sum(number_of_comments) total
        ,dense_rank() over (order by sum(number_of_comments) desc) dec_rank
	from fb_comments_count
    join fb_active_users using (user_id)
    where extract(year_month from created_at) = 201912
    group by country
    ),
    jan_ranking as (
    select
		country
        ,sum(number_of_comments) total
        ,dense_rank() over (order by sum(number_of_comments) desc) jan_rank
	from fb_comments_count
    join fb_active_users using (user_id)
    where extract(year_month from created_at) = 202001
    group by country
    )
select
	d.country
    ,dec_rank
    ,jan_rank
from dec_ranking d
join jan_ranking using (country)
where jan_rank < dec_rank;

-- compare only comments
select
	country
from (
	select
		country
		,sum(case when extract(year_month from created_at) = 201912 then number_of_comments end) dec_2019
		,sum(case when extract(year_month from created_at) = 202001 then number_of_comments end) jan_2020
	from fb_comments_count
	join fb_active_users using (user_id)
	group by country
    ) t
where jan_2020 > dec_2019;

/*
Calculate each user's average session time. A session is defined as the time difference between a page_load and page_exit.
For simplicity, assume a user has only 1 session per day and if there are multiple of the same events on that day,
consider only the latest page_load and earliest page_exit, with an obvious restriction that load time event should happen before exit time event.
Output the user_id and their average session time.
*/
show columns from facebook_web_log;

-- update facebook_web_log
-- set `timestamp` = str_to_date(`timestamp`, '%d/%m/%Y %H:%i');

select * from facebook_web_log;

-- solution from platform
SELECT user_id, AVG(TIMESTAMPDIFF(SECOND, load_time, exit_time)) AS session_time
FROM (
    SELECT 
        DATE(timestamp), 
        user_id, 
        MAX(IF(action = 'page_load', timestamp, NULL)) as load_time,
        MIN(IF(action = 'page_exit', timestamp, NULL)) as exit_time
    FROM facebook_web_log
    GROUP BY 1, 2
) t 
GROUP BY user_id
HAVING session_time IS NOT NULL;

select
	user_id
    ,avg(timestampdiff(second, page_load, page_exit))
from (
	select
		user_id
		,date(timestamp) `date`
		,max(case when action='page_load' then timestamp end) page_load
		,min(case when action='page_exit' then timestamp end) page_exit
	from facebook_web_log
	group by 1, 2
	) t
where page_load < page_exit
group by 1;
