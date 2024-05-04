create database stratascratch;
use stratascratch;

-- Write a query that returns the user ID of all users that 
-- have created at least one ‘Refinance’ submission and at least one ‘InSchool’ submission.
show tables; -- ss-loans
-- rename table
rename table `ss-loans` to loans;
show tables; -- loans

describe loans; -- created_at set as text, should be date
-- create new `date` col and insert correct format into this new col
alter table loans
add new_created_at date;
  
update loans
set new_created_at = 
		cast(concat(right(created_at, 4), '-', substr(created_at, 4, 2), '-', left(created_at, 2)) as date)
;

-- count refinance and inschool application
-- then filter based on cte min 1 count for each application
with sub as (
	select
		user_id
        ,sum(type = 'Refinance') refinance
        ,sum(type = 'InSchool') inschool
	from loans
    group by 1
	)
select
	user_id
from
	sub
where
	refinance >= 1 and inschool >= 1;