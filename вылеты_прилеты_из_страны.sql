/*Каждая строка имеет такие столбцы:
- страна
- год
- месяц
- длина (short/medium/long) -- все-таки думаю внутренние и международные
- вылет (1 - если вылет из этой страны, 0 - иначе)
- прилёт (1 - если прилетел в эту страну, 0 - иначе)
- количество рейсов
*/
create table country_origin_deatination_year as (
select c.name as Страна,
	  (to_char(date_trunc('year', day), 'YYYY')) as Период,
	  count(df.id) as Внутренние_перелёты,
	  count(if.id) as Международные_перелёты,
	  count(fd.origin) as Вылеты,
	  count(fd.destination) as Прилеты,
	  count(fd.id) as Количество_рейсов
from flights_data fd 
left join domestic_flights df using (id)
left join international_flights if using(id)
left join airports_data ad on fd.origin = ad.ident
left join countries c on c.code = ad.iso_country 
group by c.name, Период
order by c.name, Период
);

select * from country_origin_deatination_year; 



--Рассчитаем нагрузку аэропортов до и после ковида
create table passenger_traffic_in_airport_precovid as (
select
	ad.name as Аэропорт,
	c.name as Страна,
	(to_char(date_trunc('month', fd.day), 'YYYY-MM')) as precovid_month,
	(to_char(date_trunc('month', fd.day),'MM')) as Месяц,
	count(df.id) as Внутренние_перелёты,
	count(if.id) as Международные_перелёты,
	count(fd.origin) as Вылеты,
	count(fd.destination) as Прилеты,
	count(fd.id) as Количество_рейсов
from flights_data fd 
left join domestic_flights df using (id)
left join international_flights if using(id)
left join airports_data ad on fd.origin = ad.ident
left join countries c on c.code = ad.iso_country 
group by ad.name, c.name, fd.day
having fd.day > '2019-03-01' and fd.day < '2020-03-01'
order by precovid_month
);


create table passenger_traffic_in_airport_precovid as (
with step_1 as (
select
	ad.name as Аэропорт,
	c.name as Страна,
	(to_char(date_trunc('month', fd.day), 'MM')) as precovid_month,
	(to_char(date_trunc('month', fd.day), 'YYYY-MM')) as precovid_date,
	count(df.id) as Внутренние_перелёты,
	count(if.id) as Международные_перелёты,
	count(fd.origin) as Вылеты,
	count(fd.destination) as Прилеты,
	count(fd.id) as Количество_рейсов
from flights_data fd 
left join domestic_flights df using (id)
left join international_flights if using(id)
left join airports_data ad on fd.origin = ad.ident
left join countries c on c.code = ad.iso_country 
where fd.day between '2019-03-01' and '2020-03-01'
group by ad.name, c.name, fd.day
)
select 
	Аэропорт, 
	Страна, 
	precovid_month, 
	to_date(precovid_date, 'YYYY-MM') as precovid_date, 
	sum(Внутренние_перелёты) as domestic, 
	sum(Международные_перелёты) as international,
	sum(Вылеты) as origin,
	sum(Прилеты) as destination,
	sum(Количество_рейсов) as count_flights
from step_1
group by 1, 2, 3, 4
order by 1, 2
);

create table passenger_traffic_in_airport_postcovid as (
with step_1 as (
select
	ad.name as Аэропорт,
	c.name as Страна,
	(to_char(date_trunc('month', fd.day), 'MM')) as postcovid_month,
	(to_char(date_trunc('month', fd.day), 'YYYY-MM')) as postcovid_date,
	count(df.id) as Внутренние_перелёты,
	count(if.id) as Международные_перелёты,
	count(fd.origin) as Вылеты,
	count(fd.destination) as Прилеты,
	count(fd.id) as Количество_рейсов
from flights_data fd 
left join domestic_flights df using (id)
left join international_flights if using(id)
left join airports_data ad on fd.origin = ad.ident
left join countries c on c.code = ad.iso_country 
where fd.day between '2020-03-01' and '2021-03-01'
group by ad.name, c.name, fd.day
)
select 
	Аэропорт, 
	Страна, 
	postcovid_month, 
	to_date(postcovid_date, 'YYYY-MM') as postcovid_date, 
	sum(Внутренние_перелёты) as domestic, 
	sum(Международные_перелёты) as international,
	sum(Вылеты) as origin,
	sum(Прилеты) as destination,
	sum(Количество_рейсов) as count_flights
from step_1
group by 1, 2, 3, 4
order by 1, 2
);

-- создание таблицы с трафиком полетов в аэропорта постковидного периода


create table to_percent_traffic_in_airport as (
select 
	pr.Аэропорт as airport,
	pr."Страна" as country,
	precovid_date,
	postcovid_date,
	percent_total(pr.domestic, pt.domestic) as domestic_per,
	percent_total(pr.international, pt.international) as international_per,
	percent_total(pr.origin, pt.origin) as origin_per,
	percent_total(pr.destination, pt.destination) as destination_per,
	percent_total(pr.count_flights, pt.count_flights) as flights_per
from passenger_traffic_in_airport_precovid pr
left join passenger_traffic_in_airport_postcovid pt 
on pr.Аэропорт = pt.Аэропорт and pr.precovid_month = pt.postcovid_month
order by 1, 2)
;
select * from to_percent_traffic_in_airport;

---рассчитаем нагрузку аэропортов по годам
delete from passenger_traffic_in_airport_precovid
where count_flights < 200	;  
delete from passenger_traffic_in_airport_postcovid 
where Аэропорт not in (select Аэропорт from passenger_traffic_in_airport_precovid);

select * from passenger_traffic_in_airport_precovid;
ALTER TABLE passenger_traffic_in_airport_precovid RENAME TO passenger_traffic_in_airport_postcovid;
--абсолютные значения полетов
create table absolute_ratio_airports as (
select 
	pr.Аэропорт, 
	pr.Страна, 
	precovid_date
	postcovid_date, 
	pr.domestic as domestic_x, 
	pr.international as international_x,
	pr.origin as origin_x,
	pr.destination as destination_x,
	pr.count_flights as count_flights_x,
	ps.domestic as domestic_y, 
	ps.international as international_y,
	ps.origin as origin_y,
	ps.destination as destination_y,
	ps.count_flights as count_destination_y,
	(pr.domestic - ps.domestic) as domestic_ar, 
	(pr.international - ps.international) as international_ar,
	(pr.origin - ps.origin) as origin_ar,
	(pr.destination - ps.destination) as destination_ar,
	(pr.count_flights - ps.count_flights) as count_flights_ar
from passenger_traffic_in_airport_precovid pr
left join passenger_traffic_in_airport_postcovid ps 
on ps.Аэропорт = pr.Аэропорт and ps.postcovid_month = pr.precovid_month 
);

select * from absolute_ratio_airports
order by 1, 3;

create table flights_data_part as(
select	id,
	origin, 
	destination,
	day
from flights_data
where day between '2019-03-01' and '201'
)

;

create table flights_data_precovid as(
select	id,
	origin,
	destination,
	day
from flights_data fd
where day between '2019-03-01'::timestamptz and '2020-03-01'::timestamptz);

create table flights_data_postcovid as(
select	id,
	origin,
	destination,
	day
from flights_data fd
where day between '2020-03-01'::timestamptz and '2021-03-01'::timestamptz);

create table flights_origin_precovid as(
with flights_data_origin as (
select id, origin, day from flights_data_precovid fdp 
)
select fdo.id, 
	fdo.origin,
	cd.name as country_origin,
	fdo.day 
from flights_data_origin fdo
left join countries_data cd using (id));


create table flights_destination_precovid as (
with flights_data_destination as (
select id, destination from flights_data_precovid fdp 
)
select fdd.id, 
	fdd.destination,
	c.name as country_destination
from flights_data_destination fdd
left join airports_data ad on ad.ident = fdd.destination
left join countries c on c.code = ad.iso_country);

select * from countries_data cd limit 5;

select * from flights_destination_precovid 
;
select * from flights_origin_precovid fop ;
where id = 11566468;


create table flights_matrix_precovid as (
select fop.id,
	fop.country_origin,
	fop.origin,
	fdp.destination,
	fdp.country_destination,
	fop.day
from flights_origin_precovid fop
left join flights_destination_precovid fdp using (id));
create index flights_matrix_precovid_id on flights_matrix_precovid (id); 


(substring(date from '..$')) as postcovid_month,
		to_date(date, 'YYYY-MM') as postcovid_date,


create table matrix_precovid as (
with matrix_month_precovid as (
select 
	id, 
	country_origin, 
	country_destination, 
	to_char(date_trunc('month', day), 'YYYY-MM') as precovid_month
from flights_matrix_precovid 
)
select 
	count(id) as count_precovid,
	(substring(precovid_month from '..$')) as precovid_month,
	to_date(precovid_month, 'YYYY-MM') as precovid_date,
	country_origin, 
	country_destination
from matrix_month_precovid
group by  2, 3, 4, 5
order by 2
);
(to_char(date_trunc('month', day), 'YYYY-MM')) as month_precovid,


delete from flights_matrix_precovid 
where country_origin not in (select name_x from stat_covid_flights);

select * from flights_matrix_precovid;
where id = 21840560;
select * from flights_destination_precovid
where id = 21840560;
where country_origin <> country_destination;
select * from international_flights if2
where id = 21840560;
select * from airports_data where ident like 'CNF9';
create view country_origin as (
select fd.id, cd.name as country_origin, fd.origin
from flights_data fd 
left join airports_data ad on ad.ident = fd.origin 
left join countries_data cd on cd.code = ad.iso_country);
	
create table matrix_flights as (
select 
	id, 
	country_origin,
	origin,
	country_destination,
	destination
from country_origin
left join country_destination using (id));
select count(distinct name_x) from stat_covid_flights scf ;