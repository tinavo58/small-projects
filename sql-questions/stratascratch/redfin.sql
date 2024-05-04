use stratascratch;

describe redfin_call_tracking;

select * from redfin_call_tracking;

select
	created_on
    -- ,str_to_date(created_on, '%d/%m/%Y %H:%i')
    ,hour(created_on)
from redfin_call_tracking;

-- update created_on column
update redfin_call_tracking
set created_on = str_to_date(created_on, '%d/%m/%Y %H:%i');

alter table redfin_call_tracking
modify created_on datetime;

/*
Redfin helps clients to find agents. Each client will have a unique request_id and each request_id has several calls.
For each request_id, the first call is an “initial call” and all the following calls are “update calls”.
How many customers have called 3 or more times between 3 PM and 6 PM (initial and update calls combined)?
*/
select * from redfin_call_tracking;

with cte as (
	select
		request_id
		-- ,count(request_id) as calls
	from redfin_call_tracking
	where hour(created_on) between 15 and 18
	group by request_id
	having count(request_id) >= 3
    )
select count(*) as customers
from cte;


/*
Redfin helps clients to find agents. Each client will have a unique request_id and each request_id has several calls.
For each request_id, the first call is an “initial call” and all the following calls are “update calls”.
What's the average call duration for all update calls?
*/
select
	avg(call_duration
    )
from redfin_call_tracking
where (request_id, created_on) not in (
	select
		request_id
		,min(created_on) created_on
	from redfin_call_tracking
	group by request_id
    );
    
-- another method
with cte as (
	select
		id
		,request_id
		,created_on
        ,call_duration
		,rank() over (partition by request_id order by created_on) ranking
	from redfin_call_tracking
    )
select
	avg(call_duration)
from cte
where ranking > 1;


/*
Redfin helps clients to find agents. Each client will have a unique request_id and each request_id has several calls.
For each request_id, the first call is an “initial call” and all the following calls are “update calls”.
What's the average call duration for all initial calls?
*/
select
	avg(call_duration)
from redfin_call_tracking
where (request_id, created_on) in (	select request_id, min(created_on)
									from redfin_call_tracking
                                    group by 1);
                                    
-- use window function
with cte as (
	select
		request_id
		,call_duration
		,created_on
		,rank() over (PARTITION BY request_id order by created_on) ranking
	from redfin_call_tracking
	order by ranking
    )
select avg(call_duration)
from cte
where ranking = 1;
