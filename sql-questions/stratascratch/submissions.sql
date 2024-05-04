use stratascratch;

show tables;

describe submissions;

select * from submissions;

alter table submissions
add constraint pk_id primary key (id);

-- Write a query that returns the rate_type, loan_id, loan balance ,
-- and a column that shows with what percentage the loan's balance contributes
-- to the total balance among the loans of the same rate type.
select
	rate_type
    ,loan_id
    ,balance
    ,round(balance / sum(balance) over (partition by rate_type) * 100, 2) percentage
from submissions;

-- Write a query that returns binary description of rate type per loan_id.
-- The results should have one row per loan_id and two columns: for fixed and variable type.
select
	loan_id
    ,case when rate_type = 'fixed' then 1 else 0 end fixed
    ,if(rate_type='variable', 1, 0) variable
from submissions;