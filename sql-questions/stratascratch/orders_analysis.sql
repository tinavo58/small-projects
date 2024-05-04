use stratascractch;

describe orders_analysis;

alter table orders_analysis
add ordered_date date;

update orders_analysis
set ordered_date = str_to_date(week, '%d/%m/%Y');


/*
For each week, find the total number of orders. Include only the orders that are from the first quarter of 2023.
The output should contain 'week' and 'quantity'.
*/
select distinct stage_of_order
from orders_analysis;

select
	week(ordered_date)
    ,sum(case when stage_of_order='ordered' then quantity end) ordered
    ,sum(case when stage_of_order='shipped' then quantity end) shipped
    ,sum(case when stage_of_order='received' then quantity end) received
    ,sum(quantity)
from orders_analysis
where year(ordered_date) >= 2023
group by 1;


/*
You are provided with a transactional dataset from Amazon that contains detailed information about sales across different products and marketplaces.
Your task is to list the top 3 sellers in each product category for January.
The output should contain 'seller_id' , 'total_sales' ,'product_category' , 'market_place', and 'month'.
*/
describe sales_data;
-- noted: month in text

select * from sales_data;

with sub as (
	select
		seller_id
		,total_sales
		,product_category
		,market_place
		,month
		,dense_rank() over (partition by product_category order by total_sales desc) ranking
	from sales_data
	where month = '2024-01'
    )
select
	seller_id
    ,total_sales
    ,product_category
    ,market_place
    ,month
from sub
where ranking <= 3;