/**сделать табличку с полями
- страна +
- год+
- месяц +
- внутренний/внешний +
- количество рейсов

- дальний/ближний+
- размер аэропорта (маленкий/большой)+

- регион+


**/
-- создать столбец с пометкой дальности полетов s m l
alter table countries_data add column range varchar(5);

-- заполнить строки близкими перелетами
update countries_data set range = 's' from (select dd.id from distance_data dd where distance <= 2500) dd where dd.id = countries_data.id;
update countries_data set range = 'm' from (select dd.id from distance_data dd where distance > 2500 and distance < 6000) dd where dd.id = countries_data.id;
update countries_data set range = 'l' from (select dd.id from distance_data dd where distance > 6000) dd where dd.id = countries_data.id;


create table distance_data as(
	select dk.id,
	distance from distance_km dk
);


alter table distance_data add column range numeric;


select * from distance_data dd where distance < 2500 limit 20;
select * from distance_km dk limit 20;
select count(*) from countries_data cd where range = 's' limit 10; --46 985 996
select count(*) from countries_data cd where range = 'm' limit 10;-- 4 412 271
select count(*) from countries_data cd where range = 'l' limit 10;-- 1 730 915
select * from countries_data cd limit 20;
