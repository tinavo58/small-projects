use `stratascratch`;

select * from postmates_orders;

show columns from postmates_orders;

alter table postmates_orders
modify order_timestamp_utc datetime;

/*
How many customers placed an order and what is the average order amount?
*/
select
	customer_id
    ,round(avg(amount), 2) average_order_amount
from postmates_orders
group by customer_id;

-- this question is to ask all orders in general
select
	count(distinct customer_id)
    ,round(avg(amount), 2)
from postmates_orders;

/*
Which hour has the highest average order volume per day?
Your output should have the hour which satisfies that condition, and average order volume.
*/
with cte as (
	select
		`hour`
		,cast(avg(orders) as unsigned) avg_orders
	from (
		select
			hour(order_timestamp_utc) `hour`
			,date(order_timestamp_utc) # this needs to be date
			,count(id) orders
		from postmates_orders
		group by 1, 2
		) t
	group by 1
    )
select *
from cte
where avg_orders = (select max(avg_orders) from cte);

-- use ranking and cte
with cte as (
	select
		`hour`
		,cast(avg(orders) as unsigned) avg_orders
        ,dense_rank() over (order by avg(orders) desc) dr
	from (
		select
			hour(order_timestamp_utc) `hour`
			,date(order_timestamp_utc) # this needs to be date
			,count(id) orders
		from postmates_orders
		group by 1, 2
		) t
	group by 1
    )
select
	`hour`
    ,avg_orders
from cte
where dr = 1;

/*
What cities recorded the largest growth and biggest drop in order amount between March 11, 2019, and April 11, 2019.
Just compare order amounts on those two dates.
Your output should include the names of the cities and the amount of growth/drop.
*/
create table postmates_markets (
	id int primary key
    ,`name` varchar(10)
    ,timezone varchar(3)
);

insert into postmates_markets values
(43, 'Boston', 'EST'),
(44, 'Seattle', 'PST'),
(47, 'Denver', 'MST'),
(49, 'Chicago', 'CST');

select * from postmates_markets;

with cte as (
	select
		city_id
		,date(order_timestamp_utc) order_date
		,sum(amount) monthly_total
        ,sum(amount) - lag(sum(amount)) over (partition by city_id order by date(order_timestamp_utc)) amount
	from postmates_orders
	group by 1, 2
	order by 1, 2
    )
select
	`name`
    ,amount
from cte
join postmates_markets p on p.id = cte.city_id 
where amount in ((select max(amount) from cte), (select min(amount) from cte));

/*
Which partners have ‘pizza’ in their name and are located in Boston?
And what is the average order amount? Output the partner name and the average order amount.
*/
create table postmates_partners (
	id int primary key
    ,name varchar(20)
    ,category varchar(10)
);

insert into postmates_partners values
(71, "Papa John's", 'Pizza'),
(75, "Domino's Pizza", 'Pizza'),
(77, 'Pizza Hut', 'Pizza'),
(79, "Papa Murphy's", 'Pizza');

select
	p.name
    ,round(avg(amount), 2) average_amount
from postmates_orders o
join postmates_partners p on p.id = o.seller_id and p.name like '%pizza%'
join postmates_markets m on m.id = o.city_id and m.name = 'Boston'
group by seller_id;
	