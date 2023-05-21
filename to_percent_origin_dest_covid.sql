
create view origin_precovid as (
with step1 as(
	select 
		tpf.country as country_origin, 
		(date_trunc('month', fd.day))  as precovid_date, 
		to_char(date_trunc('month', fd.day), 'MM') as precovid_month,
		count(fd.origin) as count_origin
from flights_data fd 
left join countries_data cd using (id)
left join to_percent_flights tpf on tpf.country= cd.name
where fd.day between '2019-03-01' and '2020-03-01'
group by tpf.country, fd.day)
select 
	country_origin,
	precovid_month, 
	precovid_date,
	sum(count_origin) as sum_origin from step1
group by 1, 2, 3
order by 1, 2);

(substring(date from '..$')) as postcovid_month,
		to_date(date, 'YYYY-MM') as postcovid_date,;

--вьюшка с прековидным периодом прилетов
create view destination_precovid as (
with step1 as (
	select tpf.country as country_destination, 
	(to_char(date_trunc('month', fd.day), 'MM')) as precovid_month, 
	date(date_trunc('month', fd.day)) as precovid_date,
	count(fd.destination) as count_destination
from flights_data fd 
left join countries_data cd using (id)
left join to_percent_flights tpf on tpf.country = cd.name
where fd.day between '2019-03-01' and '2020-03-01'
group by tpf.country, fd.day)
select country_destination, precovid_date, precovid_month, sum(count_destination) from step1
group by 1, 2, 3
order by 1, 2);
select * from destination_precovid limit 5;


--создание вьюшки с постковидным периодом
create view origin_postkovid as (
with step1 as(
	select 
		tpf.country as country_origin, 
		(date_trunc('month', fd.day))  as postcovid_date, 
		to_char(date_trunc('month', fd.day), 'MM') as postcovid_month,
		count(fd.origin) as count_origin
from flights_data fd 
left join countries_data cd using (id)
left join to_percent_flights tpf on tpf.country= cd.name
where fd.day between '2020-03-01' and '2021-03-01'
group by tpf.country, fd.day)
select 
	country_origin,
	postcovid_month,
	postcovid_date,
	sum(count_origin) as sum_origin from step1
group by 1, 2, 3
order by 1, 2);

select * from origin_postkovid op limit 15;

create view destination_postkovid as (
with step1 as(
select tpf.country as country_destination, 
	(to_char(date_trunc('month', fd.day), 'MM')) as postcovid_month, 
	date(date_trunc('month', fd.day)) as postcovid_date,
	count(fd.destination) as count_destination
from flights_data fd 
left join countries_data cd using (id)
left join to_percent_flights tpf on tpf.country = cd.name
where fd.day between '2020-03-01' and '2021-03-01'
group by tpf.country, fd.day)
select country_destination, postcovid_date, postcovid_month, sum(count_destination) from step1
group by 1, 2, 3
order by 1, 2);


---вычисление процентного соотношения вылетов перед ковидом и после начала
create table origin_pre_postcovid as (
select 
	op.country_origin as country_x, 
    date(op.precovid_date) as precovid_month,
    date(op1.postcovid_date) as postcovid_month,
	op.sum_origin as sum_origin_x,
	op1.sum_origin as sum_origin_y,
	percent_total(op.sum_origin, op1.sum_origin)
from origin_precovid op
left join origin_postkovid op1 on op.country_origin = op1.country_origin and op.precovid_month = op1.postcovid_month
order by 1, 2
);
 select * from origin_pre_postcovid ;

select date(precovid_month) from origin_pre_postcovid opp ;

delete from destination_pre_postcovid
where country is null;

---вычисление процентного соотношения прилетов перед ковидом и после начала
create table destination_pre_postcovid as(
select 
	dp.country_destination as country, 
    date(dp.precovid_date) as precovid_month,
    date(dp1.postcovid_date) as postcovid_month,
	dp.sum as sum_x,
	dp1.sum as sum_y,
	percent_total(dp.sum, dp1.sum)
from destination_precovid dp
left join destination_postkovid dp1 on dp.country_destination = dp1.country_destination and dp.precovid_month = dp1.postcovid_month
order by 1, 2);

select * from destination_pre_postcovid;


select * from origin_pre_postcovid;

delete from origin_pre_postcovid
where country_x is null;


