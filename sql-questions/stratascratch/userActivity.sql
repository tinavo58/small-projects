use stratascratch;

show tables;

describe userActivity;

select * from userActivity;

select
	start_timestamp
	,str_to_date(start_timestamp, '%d/%m/%Y %H:%i') start
    ,end_timestamp
    ,str_to_date(end_timestamp, '%d/%m/%Y %H:%i') end
from userActivity;
