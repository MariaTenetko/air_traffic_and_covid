

create index distance_data_long on distance_data (distance)
where distance >= 6000;

create index distance_data_id on distance_data (id);
create index countries_data_id on countries_data (id);
create index domestic_id on domestic (id);
create index domestic_is_domestic_true on domestic (is_domestic)
where is_domestic is true;
create index domestic_is_domestic_false on domestic (is_domestic)
where is_domestic is false;
/*Страна / короткие / средние /длинные / внутренние / международные / все

Россия / - 10% / - 20% / - 50% / - 43% / - 20% / - 38%*/


-- создание таблицы для вычисления процентных соотношений между доковидным и посковидным годом
create table percent_stat_flights as (
select cd.name, 
		cd.year,
		cd.month,
		sum(case when dd.distance < 2500 then 1 else 0 end) as short,
		sum(case when 2500 <= dd.distance and dd.distance < 6000 then 1 else 0 end) as middle,
		sum(case when dd.distance >= 6000 then 1 else 0 end) as long,
		count(df.id) as domestic,
		count(if.id) as international
from distance_data dd 
left join countries_data cd using (id)
left join international_flights if using (id)
left join domestic_flights df using (id)
group by cd.year, cd.month, cd.name)
;
select CONCAT(year,month) from percent_stat_flights psf 
where psf.year < '2020';

create table precovid_time as (
	select name,
		(substring(date from '..$')) as precovid_month,
		to_date(date, 'YYYY-MM') as precovid_date,
		short as pre_short,
		middle as pre_middle,
		long as pre_long, 
		domestic as pre_domestic,
		international as pre_international
from percent_stat_flights psf 
where date between '2019-03' and '2020-02');

create table postcovid_time as (
	select name,
		(substring(date from '..$')) as postcovid_month,
		to_date(date, 'YYYY-MM') as postcovid_date,
		short as post_short,
		middle as post_middle,
		long as post_long, 
		domestic as post_domestic,
		international as post_international
from percent_stat_flights psf 
where date between '2020-03' and '2021-02');


create table percent_stat_covid as (
select prt.name as name_x,
		prt.precovid_date,
		prt.pre_short as short_x,
		prt.pre_middle as middle_x,
		prt.pre_long as long_x,
		prt.pre_domestic as domestic_x,
		prt.pre_international as international_x,
		pst.name as name_y,
		pst.postcovid_date,
		pst.post_short as short_y,
		pst.post_middle as middle_y,
		pst.post_long as long_y,
		pst.post_domestic as domestic_y,
		pst.post_international as international_y
from precovid_time prt 
left join postcovid_time pst on prt.precovid_month = pst.postcovid_month and prt.name = pst.name);

select * from percent_stat_covid;

delete from percent_stat_covid
where name_x in (select name 
				from countries_data cd 
				where year = '2019'
				group by name, cd.year
				having count(id) < 6852);


select * from percent_stat_covid psc;


update precovid_time set date = substring(date from '..$'); 
ALTER TABLE precovid_time RENAME COLUMN date TO precovid_month;
update postcovid_time set date = substring(date from '..$'); 
ALTER TABLE postcovid_time RENAME COLUMN date TO postcovid_month;


create table to_percent_flights as (
select name_x as country, 
		precovid_date,
		postcovid_date,
		percent_total(short_x, short_y) as percent_short,
		percent_total(middle_x, middle_y) as percent_middle,
		percent_total(long_x, long_y) as percent_long,
		percent_total(domestic_x, domestic_y) as percent_domestic,
		percent_total(international_x, international_y) as percent_international
from percent_stat_covid
)

;
create table stat_covid_flights as (
select * from percent_stat_covid psc 
where name_x in (select name 
				from countries_data cd 
				where year = '2019'
				group by name, cd.year
				having count(id) > 6851)
);

select * from stat_covid_flights scf 
order by 1, 2;
select * from to_percent_flights 
order by 1, 2
;

create function percent_total (denominator numeric, divider numeric) returns numeric as 
$$
select round(
		(case when denominator <> 0 then (1 - (divider/denominator))
		   	when divider = 0 and denominator = 0 then null
			when divider = 0 then 1		   	
			else null 
			end), 2)
$$language sql
;

-- создание двух вьюшек
create view precovid_year as (
select name,
		to_char(date_trunc('month', date), 'YYYY-MM') as precovid_month,
		short,
		middle,
		long
from percent_stat_flights
where date between '2019-03-01' and '2020-03-01');

create view postcovid_year as (
select name,
		to_char(date_trunc('month', date), 'YYYY-MM') as postcovid_month,
		short,
		middle,
		long
from percent_stat_flights
where date between '2020-03-01' and '2021-03-01');

delete from to_percent_flights 
where country	 in (select name 
				from countries_data cd 
				where year = '2019'
				group by name, cd.year
				having count(id) < 6852);


create table precovid_year as(
	select name,
		date,
		to_char(date_trunc('month', date), 'MM') as precovid_month,
		short,
		middle,
		long
from percent_stat_flights
where date between '2019-03-01' and '2020-03-01')
;
			
create view absolute_ratio as (
	select (short_y - short_x) as short_ar,
		(middle_y - middle_x) as middle_ar,
		(long_y - long_x) as long_ar,
		(domestic_y - domestic_x) as domestic_ar,
		(international_y - international_x) as international_ar
	from stat_covid_flights scf );

select * from absolute_ratio
where short_ar is not null;
)