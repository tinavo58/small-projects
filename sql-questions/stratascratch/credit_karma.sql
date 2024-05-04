use stratascratch;

show columns from submissions;

select * from submissions;

/*
Write a query that returns the rate_type, loan_id, loan balance , and a column that shows
with what percentage the loan's balance contributes to the total balance among the loans of the same rate type.
*/
select
	rate_type
    ,loan_id
    ,balance
    ,round(balance / (select sum(balance) from submissions where rate_type = 'variable') * 100) prc
from submissions
where rate_type = 'variable'
union
select
	rate_type
    ,loan_id
    ,balance
    ,round(balance / (select sum(balance) from submissions where rate_type = 'fixed') * 100)
from submissions
where rate_type = 'fixed';

-- other method
select
	rate_type
    ,loan_id
    ,balance
    ,round(balance / total_bal * 100)
from submissions
left join (
	select
		rate_type
		,sum(balance) total_bal
	from submissions
	group by 1
    ) t
using (rate_type);

/*
Write a query that returns the user ID of all users that have created at least one ‘Refinance’ submission and at least one ‘InSchool’ submission.
*/
select * from loans;

with cte (user_id, refinance, inschool) as (
	select
		user_id
		,sum(type='Refinance')
		,sum(type='InSchool')
	from loans
    group by user_id
    )
select
	user_id
from cte
where refinance >= 1 and inschool >= 1;

/*
Write a query that returns binary description of rate type per loan_id.
The results should have one row per loan_id and two columns: for fixed and variable type.
*/
select
	loan_id
    ,if(rate_type='fixed', 1, 0) as fixed
    ,if(rate_type='variable', 1, 0) as variable
from submissions;

/*
Write a query that joins this submissions table to the loans table and
returns the total loan balance on each user’s most recent ‘Refinance’ submission.
Return all users and the balance for each of them.
*/
select * from submissions;
select * from loans;

update loans
set created_at = str_to_date(created_at, '%d/%m/%Y');

alter table loans
drop new_created_at;

select
	user_id
    ,balance
from submissions s
join loans l
	on s.loan_id = l .id
where (user_id, created_at) in (
	select
		user_id,
		max(created_at)
	from loans
	where type = 'Refinance'
	group by user_id
	);
