use stratascratch;

/*
Find all wine varieties which can be considered cheap based on the price.
A variety is considered cheap if the price of a bottle lies between 5 to 20 USD.
Output unique variety names only.
*/
select * from winemag_p1;

select
	count(*)
    ,count(distinct variety)
from winemag_p1;

select
	distinct variety
from winemag_p1
where price between 5 and 20;

/*
Find the number of apartments per nationality that are owned by people under 30 years old.
Output the nationality along with the number of apartments.
Sort records by the apartments count in descending order.
*/
select * from airbnb_hosts limit 10;
select * from airbnb_units limit 10;
select count(*) from airbnb_hosts;

select
	distinct host_id
    ,nationality
from airbnb_hosts
where age < 30;

-- this is the corret way
-- extract a list of unique host_ids
-- extract a list of num of apartments
select
	nationality
    ,n_apartments
from (
	select
		DISTINCT host_id
		,unit_type
		,count(unit_id) n_apartments
	from airbnb_units
    where unit_type = 'Apartment'
	group by 1, 2
    ) t1
join (
	select
		distinct host_id
        ,nationality
	from airbnb_hosts
    where age < 30
	) t2
using (host_id);

/*
Find all owners which have only a single facility.
Output the owner_name and order the results alphabetically.
*/
select * from los_angeles_restaurant_health_inspections limit 10;

update los_angeles_restaurant_health_inspections
set activity_date = str_to_date(activity_date, '%d/%m/%Y');

select
	owner_name
    -- ,count(distinct facility_id)
from los_angeles_restaurant_health_inspections
group by owner_name
having count(distinct facility_id) = 1
order by 1;

/*
Find the growth rate of active users for Dec 2020 to Jan 2021 for each account.
The growth rate is defined as the number of users in January 2021 divided by the number of users in Dec 2020. Output the account_id and growth rate.
*/
select * from sf_events;

update sf_events
set `date` = str_to_date(`date`, '%d/%m/%Y');

-- the below method does not factor if duplicate records of user_ids which generates incorrect results
-- use subquery to generate unique user_ids
select
	account_id
    ,sum(date_format(`date`, '%Y-%m') = '2021-01') jan
    ,sum(date_format(`date`, '%Y-%m') = '2020-12') as `dec`
    ,sum(date_format(`date`, '%Y-%m') = '2021-01') / sum(date_format(`date`, '%Y-%m') = '2020-12') as growth_rate
from sf_events
group by 1;

with cte as (
	select
		account_id
		,date_format(`date`, '%Y-%m') `date`
		,count(distinct user_id) n_users
		,count(*)
	from sf_events
	group by 1, 2
    ),
    pivot_tbl as (
    select
		account_id
        ,max(if(`date`='2021-01', n_users, 0)) `jan`
        ,max(if(`date`='2020-12', n_users, 0)) `dec`
	from cte
    group by 1
    )
select
	account_id
    ,`jan`/`dec` growth_rate
from pivot_tbl;