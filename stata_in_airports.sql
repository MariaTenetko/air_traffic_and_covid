/**8) Посмотреть динамику по отдельным аэропортам/странам/регионам + 
 
 в разбивке все/только 
 внутрннре/только: как поменялось в сравнии с такими же месяцами (+среднее и средневзвешенное за 12 месяце) в не кризисный год

Выбрать правильно периоды в зависимости от спадов (в старые должны быть "хорошие" цифры) 
9) вывести динамику по месяцам (либо относительное изменения месяц к месяцу прошлого года, либо, если применимо, накопленным итогом)

9,5) Посмотреть другие статистики (минимум, максимум и т.п.)

10) leaderboard по странам/аэропортам/ригеонам, кто больше и кто меньше все поменял. Выделить группы стран (например покрасить по регионам)
*/
select * from countries_data cd limit 10;

create table stata_airports as (
	select cd.id as id,
	cd.year,
	cd.month,
	ad.name,
	ad.type,
	ad.ident,
	cd.range
	from countries_data cd 
	left join flights_data fd using(id)
	left join airports_data ad on fd.origin = ad.ident
) ;

update countries_data 
set airport_type = fd_ad.type from 
	(select fd.id, 
	ad.ident, 
	ad.type, 
	fd.origin 
	from airports_data ad 
	left join flights_data fd 
	on fd.origin = ad.ident) as fd_ad 
	where fd_ad.id = countries_data.id;
	
select * from stata_airports sa limit 20;

select year, month, name, count(*) from stata_airports sa 
group by year, month, name;

create materialized view best_airports as (
select sa.year, sa.month, sa.name, ad.iso_country, count(*) as count from stata_airports sa
left join airports_data ad using(name) 
group by  sa.year, sa.month, ad.iso_country, sa.name 
order by 1);

with best_airports as (
	select sa.year, sa.month, sa.name, ad.iso_country as country, count(*) as count from stata_airports sa
	left join airports_data ad using(name) 
	group by  sa.year, sa.month, ad.iso_country, sa.name 
	order by 1
)
select sa.year, sa.month, sa.name, ad.iso_country, max(ba.count)
from stata_airports sa
left join airports_data ad using(name)
left join best_airports as ba on ba.country = ad.iso_country
group by sa.year, sa.month, sa.name, ad.iso_country 
order by 1 desc;
-- product_id как count
