use stratascratch;

show columns from car_launches;

/*
You are given a table of product launches by company by year. Write a query to count the net difference
between the number of products companies launched in 2020 with the number of products companies launched in the previous year.
Output the name of the companies and a net difference of net products released for 2020 
*/
select
	company_name
    ,yr_2020 - yr_2019
from (
	select
		company_name
		,sum(case when year = 2019 then 1 end) yr_2019
		,sum(case when year = 2020 then 1 end) yr_2020
	from car_launches
	group by 1
    ) t;
    
/*
ABC Corp is a mid-sized insurer in the US and in the recent past 
their fraudulent claims have increased significantly for their personal auto insurance portfolio.
They have developed a ML based predictive model to identify propensity of fraudulent claims.
Now, they assign highly experienced claim adjusters for top 5 percentile of claims identified by the model.
Your objective is to identify the top 5 percentile of claims from each state.
Your output should be policy number, state, claim cost, and fraud score.
*/
select
	policy_num
    ,state
    ,claim_cost
    ,fraud_score
from (
	select
		*
		,PERCENT_RANK() over (partition by state order by fraud_score desc) pct
	from fraud_score
    ) t
where pct <= .05;

/*
Find the total number of downloads for paying and non-paying users by date.
Include only records where non-paying customers have more downloads than paying customers.
The output should be sorted by earliest date first and contain 3 columns date, non-paying downloads, paying downloads.
*/
show columns from ms_download_facts;

update ms_download_facts
set `date` = str_to_date(`date`, '%d/%m/%Y');

alter table ms_download_facts
modify `date` date;

with cte as (
	select
		`date`
		,sum(case when paying_customer = 'no' then downloads end) non_paying
		,sum(case when paying_customer = 'yes' then downloads end) paying
	from ms_download_facts f
	join ms_user_dimension u using (user_id)
	join ms_acc_dimension a using (acc_id)
	group by 1
    )
select
	*
from cte
where non_paying > paying
order by `date`;

/*
We have a table with employees and their salaries, however, some of the records are old and contain outdated salary information.
Find the current salary of each employee assuming that salaries increase each year.
Output their id, first name, last name, department ID, and current salary.
Order your list by employee ID in ascending order.
*/
-- select
-- 	-- *
--     substring_index(id, '/', 1)
-- from ms_employee_salary;

select
	id
    ,first_name
    ,last_name
    ,department_id
    ,max(salary)
from ms_employee_salary
group by 1, 2, 3, 4;

/*
What is the overall friend acceptance rate by date? Your output should have the rate of acceptances by the date the request was sent.
Order by the earliest date to latest.
Assume that each friend request starts by a user sending (i.e., user_id_sender) a friend request to another user (i.e., user_id_receiver)
that's logged in the table with action = 'sent'.
If the request is accepted, the table logs action = 'accepted'. If the request is not accepted, no record of action = 'accepted' is logged.
*/
select * from fb_friend_requests;

update fb_friend_requests
set `date` = str_to_date(`date`, '%d/%m/%Y');

select
	sent
    ,count(accepted) / count(sent)
from (
	select
		user_id_sender
		,user_id_receiver
		,max(case when action = 'sent' then `date` end) sent
		,max(case when action = 'accepted' then `date` end) accepted
	from fb_friend_requests
    group by 1, 2
    ) t
-- where accepted is not null
group by sent;
    
/*
Find the number of apartments per nationality that are owned by people under 30 years old.
Output the nationality along with the number of apartments.
Sort records by the apartments count in descending order.

Tables: airbnb_hosts, airbnb_units
*/
select
	nationality
    ,n_apartments
from (
	select 
		host_id
		,count(unit_type) n_apartments
	from airbnb_units
	where unit_type = 'Apartment'
	group by host_id
    ) t1
join (
	select
		host_id
		,nationality
	from airbnb_hosts
	where age < 30
	group by 1, 2
    ) t2
	using (host_id);
    
/*
Find the number of Apple product users and the number of total users with a device and group the counts by language.
Assume Apple products are only MacBook-Pro, iPhone 5s, and iPad-air. Output the language along with the total number of Apple users and users with any device.
Order your results based on the number of total users in descending order.
*/
select *
from playbook_events;

show columns from playbook_events;
alter table playbook_events
modify occurred_at datetime;

select *
from playbook_users;

show columns from playbook_users;
alter table playbook_users
modify created_at datetime,
modify activated_at date;

select
	count(distinct user_id)
from playbook_events;

select
	-- language
	-- ,count(distinct user_id)
    *
from playbook_users
join playbook_events using (user_id)
where language = 'french' and device in ('macbook pro', 'iphone 5s', 'ipad air');

select
	*
from playbook_events
where user_id in (12103, 16170);

select
	user_id
    ,device
    ,count(distinct user_id)
from playbook_events
group by 1, 2;

select
	language
    ,count(distinct apple_users)
    ,count(distinct u.user_id) total_users
from (
	select
		user_id
		,case when device in ('macbook pro', 'iphone 5s', 'ipad air') then user_id end apple_users
	from playbook_events
    ) t
join playbook_users u
	using (user_id)
group by language
order by total_users desc;

select *
from facebook_posts;

/*
Calculate the percentage of spam posts in all viewed posts by day.
A post is considered a spam if a string "spam" is inside keywords of the post.
Note that the facebook_posts table stores all posts posted by users.
The facebook_post_views table is an action table denoting if a user has viewed a post.
*/
create table facebook_post_views (
	post_id INT
    ,viewer_id int
);

insert into facebook_post_views values
(4,0),
(4,1),
(4,2),
(5,0),
(5,1),
(5,2),
(3,1),
(3,2),
(3,3);

select
    post_date
    ,sum(if(post_keywords like '%spam%', 1, 0)) / count(v.post_id) * 100
from facebook_posts p
join facebook_post_views v using (post_id)
group by post_date;

/*
split columns
*/
drop table if exists split_text;
create table split_text (
	cnt int
    ,categories varchar(100)
);

replace into split_text values
(7, 'Bars;Restaurant;Travel;Fitness'),
(5, 'Fast Food;Travel;Beauty'),
(3, 'Travel;Beauty;Fitness');

drop temporary table if exists nums;
create TEMPORARY table nums
with recursive cte as (
	select 1 as n
    union all
    select n + 1
    from cte
    where n < 10 # this should be the length of the list not the records
    )
select n from cte;

select * from nums;

select
	cnt
    ,substring_index(categories, ';', n)
    ,substring_index(substring_index(categories, ';', n), ';', -1)
from split_text
join nums
	on char_length(categories) - char_length(replace(categories, ';', '')) >= n - 1
order by categories;
    
select
	char_length(categories)
    ,replace(categories, ';', '')
    ,char_length(replace(categories, ';', ''))
from split_text;

with recursive nums (n) as (
	select 1
    union all
    select n + 1
    from nums
    where n <= (select max(char_length(categories) - char_length(replace(categories, ';', ''))) from split_text)
    )
select * from nums;

/*
Find all wineries which produce wines by possessing aromas of plum, cherry, rose, or hazelnut. To make it more simple, look only for singular form of the mentioned aromas.
HINT: if one of the specified words is just a substring of another word, this should not be a hit, but a miss.
Example Description: Hot, tannic and simple, with cherry jam and currant flavors accompanied by high, tart acidity and chile-pepper alcohol heat.
Therefore the winery Bella Piazza is expected in the results.
*/
select * from winemag_p1;

select
	description
    ,split_text
from winemag_p1,
json_table	(	cast(concat('["',replace(description, ' ', '","'), '"]') as json),
				'$[*]' columns (split_text varchar(50) PATH '$')
			) t
where split_text like 'fairly%'
;

-- solution
select
    distinct winery
from winemag_p1
where lower(description) regexp '(plum|rose|cherry|hazelnut)([^a-z])';
### [^a-z] would ignore lowercase letter


