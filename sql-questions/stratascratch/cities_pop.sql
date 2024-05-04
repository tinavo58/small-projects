use stratascratch;

rename table cities_poppulation to cities_population;

describe cities_population;

-- explain
select * from cities_population;

-- You are working on a data analysis project at Deloitte where you need to analyze a dataset containing information
-- about various cities. Your task is to calculate the population density of these cities, 
-- rounded to the nearest integer, and identify the cities with the minimum and maximum densities.
-- The population density should be calculated as (Population / Area).
-- The output should contain 'city', 'country', 'density'.
select
	city
    ,country
    ,round(population/area) density
    ,case
		when round(population/area) = (select min(round(population/area)) from cities_population) then 'min_density'
        when round(population/area) = (select max(round(population/area)) from cities_population) then 'max_density'
	end desities_ranking
from cities_population;