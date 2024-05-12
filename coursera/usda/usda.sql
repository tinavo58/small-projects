create database usda;
use usda;

drop table if exists honey_production;
drop table if exists cheese_production;
drop table if exists milk_production;
drop table if exists coffee_production;
drop table if exists egg_production;
drop table if exists yogurt_production;


CREATE TABLE honey_production (
    Year INTEGER,
    State_ANSI INTEGER,
    Commodity_ID INTEGER,
    Value INTEGER
);


CREATE TABLE cheese_production (
    Year INTEGER,
    Period TEXT,
    State_ANSI INTEGER,
    Commodity_ID INTEGER,
    Value bigint
);


CREATE TABLE milk_production (
    Year INTEGER,
    Period TEXT,
    State_ANSI INTEGER,
    Commodity_ID INTEGER,
    Value bigint
);


CREATE TABLE coffee_production (
    Year INTEGER,
    Period TEXT,
    State_ANSI INTEGER,
    Commodity_ID INTEGER,
    Value bigint
);


CREATE TABLE egg_production (
    Year int,
    Period TEXT,
    State_ANSI INTEGER,
    Commodity_ID INTEGER,
    Value BIGINT
);


CREATE TABLE state_lookup (
    State TEXT,
    State_ANSI INTEGER
);


CREATE TABLE yogurt_production (
    Year int,
    Period TEXT,
    State_ANSI int,
    Commodity_ID int,
    Value bigint
);


/*
usda practice final project
*/
-- transform data for analysis
select * from yogurt_production limit 10;
select distinct `    Domain` from milk_production;

alter table cheese_production
drop column `    Geo_Level`,
drop column `    Domain`;

describe cheese_production;

alter table cheese_production
rename column `    Year` to year_,
rename column `    Period` to period,
rename column `    State_ANSI` to state_ansi,
-- rename column `    State` to state;
rename column `    Commodity_ID` to commodity_id,
rename column `    Value` to value_;

/*
====================================================================================================
*/
-- analysis starts here
-- Find the total milk production for the year 2023.
select * from milk_production limit 10;
select
	-- state_ansi
    year_
	,sum(value_)
    ,count(*)
from milk_production
-- where year_ = 2023
group by 1 with rollup
order by 1 desc;

select
	period
	,sum(value_)
from milk_production
where year_ = 2023
group by 1 with rollup;

-- Show coffee production data for the year 2015.
select
	year_
	,period
	,sum(value_)
from coffee_production
group by 1, 2 with rollup;

SELECT * FROM coffee_production WHERE year_ = 2015;

-- Find the average honey production for the year 2022.
select
	avg(value_)
from honey_production
where year_ = 2022
and state_ansi <> 0;

select *
from honey_production
where state_ansi <> 0;

-- Get the state names with their corresponding ANSI codes from the state_lookup table.
-- What number is Iowa?
select
	state
    ,state_ansi
from state_lookup
where state = 'iowa';

select * from state_lookup;

-- Find the highest yogurt production value for the year 2022.
select 
	*
from yogurt_production
where value_ = (select max(value_) from yogurt_production where year_=2022);

-- Find states where both honey and milk were produced in 2022.
-- Did State_ANSI "35" produce both honey and milk in 2022?
with honey as (
	select
        state_ansi state_honey
        ,sum(value_) total_honey
	from honey_production
    where year_ = 2022
    group by 1
    ),
    milk as (
    select
        state_ansi state_milk
        ,sum(value_) total_milk
	from milk_production
    where year_ = 2022
    group by 1
    )
    
select
	state_honey
    ,state
    ,total_honey
    ,total_milk
from honey
join milk on state_honey = state_milk
join state_lookup on state_honey = state_ansi
where state_ansi = 35;

-- Find the total yogurt production for states that also produced cheese in 2022.
select * from cheese_production limit 10;
with cte as (
	select
		state_ansi
	from cheese_production
    where year_ = 2022
    group by state_ansi
    )
select
	sum(value_)
from yogurt_production
-- where year_ = 2022
where state_ansi in (select state_ansi from cte);

select
	state_ansi
from cheese_production
where year_ = 2022 and state_ansi <> 0
group by state_ansi;

-- Which states had cheese production greater than 100 million in April 2023?
-- The Cheese Department wants to focus their marketing efforts there. 
-- How many states are there?
select * from cheese_production limit 10;
select
	state_ansi
    ,sum(value_)
from cheese_production
where period = 'APR' and year_ = 2023
group by 1
having sum(value_) > 100000000;

-- What is the total value of coffee production for 2011?
select sum(value_)
from coffee_production
where year_ = 2011;

select * from coffee_production
where state_ansi = 0;

-- There's a meeting with the Honey Council next week.
-- Find the average honey production for 2022 so you're prepared.
select avg(value_)
from honey_production
where year_ = 2022;

-- What is the State_ANSI code for Florida?
describe state_lookup;
select *
from state_lookup
where state = 'Florida';

-- For a cross-commodity report, can you list all states with their cheese production values,
-- even if they didn't produce any cheese in April of 2023?
-- What is the total for NEW JERSEY?
select
	state
    ,state_ansi
    ,sum(value_)
from cheese_production
join state_lookup using (state_ansi)
group by 1, 2;

-- Can you find the total yogurt production for states in the year 2022
-- which also have cheese production data from 2023?
select
	sum(value_)
from yogurt_production
where year_ = 2022
and state_ansi in (select state_ansi from cheese_production where year_ = 2023 group by 1);

-- List all states from state_lookup that are missing from milk_production in 2023.
-- How many states are there?
select
	count(*)
from state_lookup
where state_ansi not in (select state_ansi from milk_production where year_ = 2023 group by 1);

-- List all states with their cheese production values, including states that didn't produce any cheese in April 2023.
-- Did Delaware produce any cheese in April 2023?
select
	state
    ,sum(value_)
from cheese_production
right join state_lookup using (state_ansi)
where period = 'APR' and year_ = 2023
group by 1
order by 1;

-- Find the average coffee production for all years where the honey production exceeded 1 million.
with cte as (
	select
		year_
	from honey_production
    group by year_
    having sum(value_) > 1000000
	)
select
	avg(value_)
from coffee_production
where year_ in (select year_ from cte);
