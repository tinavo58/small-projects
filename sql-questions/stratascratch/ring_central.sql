use `stratascratch`;

show columns from rc_calls;

alter table rc_calls
modify `date` datetime;

select * from rc_calls;
select * from rc_users;

/*
Return a list of users with status free who didn’t make any calls in Apr 2020.
*/
select
	distinct user_id
from rc_users u
where not exists (	select 1 from rc_calls
					where extract(year_month from `date`) = 202004
                    and u.user_id = user_id)
				and status = 'free';

/*
How many paid users had any calls in Apr 2020?
*/
select
	count(user_id)
from rc_users u
where exists (	select 1 from rc_calls
				where extract(year_month from `date`) = 202004
                and u.user_id = user_id)
                and status = 'paid';
                
/*
Return the top 2 users in each company that called the most.
Output the company_id, user_id, and the user's rank.
If there are multiple users in the same rank, keep all of them.
*/
select
	company_id
    ,user_id
    ,`rank`
from (
	select
		company_id
		,user_id
		,count(user_id)
		,DENSE_RANK() over (partition by company_id order by count(user_id) desc) as `rank`
	from rc_users u
	join rc_calls c using (user_id)
	group by 1, 2
    ) t
where `rank` < 3;

/*
Which company had the biggest month call decline from March to April 2020?
Return the company_id and calls difference for the company with the highest decline.
*/
select
	company_id
    ,decline
from (
	select
		company_id
		,sum(extract(year_month from `date`) = 202003) mar_calls
		,sum(extract(year_month from `date`) = 202004) apr_calls
        ,sum(extract(year_month from `date`) = 202004) - sum(extract(year_month from `date`) = 202003) decline
	from rc_calls c
	join rc_users u using (user_id)
	group by 1
	) t
where apr_calls < mar_calls
order by decline # if less -> negative thus order by normal order to return the biggest decline
limit 1;