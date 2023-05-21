create table stata_countries as (
select cd.name, cd.year, cd.month, count(cd.id) from countries_data as cd 
where cd.name in (select country from to_percent_flights tpf)
group by 1, 2, 3
order by 1, 2, 3);


delete from stata_countries 
where name not in (select country from to_percent_flights);

select count(distinct name) from stata_countries sc ;
where name like 'Australia';

select count(id) from flights;

---- создать таблицу с суммой по странам и по дальности за год

create view postcovid_year20 as (
	select name as country,
		sum(short) as post_short,
		sum(middle) as post_middle,
		sum(long) as post_long, 
		sum(domestic) as post_domestic,
		sum(international) as post_international
from percent_stat_flights psf 
where date between '2020-03' and '2021-02'
group by country);

create view precovid_year19 as (
	select name as country,
		sum(short) as pre_short,
		sum(middle) as pre_middle,
		sum(long) as pre_long, 
		sum(domestic) as pre_domestic,
		sum(international) as pre_international
from percent_stat_flights psf 
where date between '2019-03' and '2020-02'
group by country);

create table absolute_ratio_year as (
select  pry.country,
		(pry.pre_short - psy.post_short) as short_ar,
		(pry.pre_middle - psy.post_middle) as middle_ar,
		(pry.pre_long - psy.post_long) as long_ar,
		(pry.pre_domestic - psy.post_domestic) as domestic_ar,
		(pry.pre_international - psy.post_international) as international_ar		 
from precovid_year19 pry 
left join postcovid_year20 psy on pry.country = psy.country);

create table to_percent_flights_year as (
select pry.country, 
		percent_total(pre_short, post_short) as percent_short,
		percent_total(pre_middle, post_middle) as percent_middle,
		percent_total(pre_long, post_long) as percent_long,
		percent_total(pre_domestic, post_domestic) as percent_domestic,
		percent_total(pre_international, post_international) as percent_international
from precovid_year19 pry
left join postcovid_year20 using (country)
);

