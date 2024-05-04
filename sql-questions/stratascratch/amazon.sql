use stratascratch;

show tables;

show columns from amazon_transactions;

alter table amazon_transactions
modify created_at date;

select * from amazon_transactions order by user_id;

/*
Write a query that'll identify returning active users.
A returning active user is a user that has made a second purchase within 7 days of any other of their purchases.
Output a list of user_ids of these returning active users.
*/
select
	distinct user_id
from (
	select
		user_id
		,created_at
        ,lag(created_at) over (partition by user_id order by created_at)
		-- ,rank() over (partition by user_id order by created_at)
		,datediff(created_at, lag(created_at) over (partition by user_id order by created_at)) < 7 returning_users
	from amazon_transactions
) t
where returning_users = 1;

select
	datediff('2024-04-01', '2024-04-02')
    ,datediff('2024-04-02', '2024-04-01');
    
/*
Given a table of purchases by date, calculate the month-over-month percentage change in revenue.
The output should include the year-month date (YYYY-MM) and percentage change,
rounded to the 2nd decimal point, and sorted from the beginning of the year to the end of the year.
The percentage change column will be populated from the 2nd month forward and can be calculated as
((this month's revenue - last month's revenue) / last month's revenue)*100.
*/
alter table sf_transactions
modify created_at date;

select * from sf_transactions limit 10;

-- group by date to cacl rev
-- then use lag() to calc the percentage change
select
	yr_mth
    ,round((rev - lag(rev) over (order by yr_mth)) / lag(rev) over (order by yr_mth)* 100, 2) revenue
from (
	select
		date_format(created_at, '%Y-%m') yr_mth
		,sum(value) rev
	from sf_transactions
	group by 1
	order by 1
	) t;
