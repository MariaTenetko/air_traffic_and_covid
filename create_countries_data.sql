-- создание таблицу countries_data
create table countries_data as (
	select id,
	to_char(date_trunc('year', fd.day), 'YYYY') as year,
	to_char(date_trunc('month', fd.day), 'MM') as month
	from flights_data fd 
);

--создание индекса по id
create index countries_data_id on countries_data (id);
--создание первичного ключа у flights_data
alter table flights_data 
	add constraint flights_data_pkey primary key (id);
-- создание вторичного ключа по id
alter table countries_data 
	add constraint countries_data_fk foreign key (id)
	references flights_data (id);

--создать колонку is_domestic
alter table countries_data add column is_domestic boolean;

-- заполнить домашними перелетами, выставив значения true
update countries_data 
set is_domestic = true from (select df.id from domestic_flights df) df
where df.id = countries_data.id;

--вставить международные перелеты
update countries_data 
set is_domestic = false from (select if.id from international_flights if) if
where if.id = countries_data.id;

-- вставить поля названий стран и их кодов и заполнить данными
alter table countries_data add column name varchar(100), add column code varchar(5);

create index country_flights_id on country_flights (id);


update countries_data set name = cf.name from (select cf.id, cf.name from country_flights cf) cf where cf.id = countries_data.id;

update countries_data set code = cf
.iso_country from (select cf.id, cf.iso_country from country_flig
hts cf) cf where cf.id = countries_data.id;

--- создать столбец с пометкой дальности полетов s m l
alter table countries_data add column range varchar(5);

-- заполнить строки близкими перелетами
update countries_data set range = 's' from (select dd.id from distance_data dd where distance <= 2500) dd where dd.id = countries_data.id;
update countries_data set range = 'm' from (select dd.id from distance_data dd where distance > 2500 and distance < 6000) dd where dd.id = countries_data.id;
update countries_data set rang
e = 'l' from (select dd.id from distance_data dd where distance > 6000) dd where dd.id = countries_data.id;

--вставить регион
alter table countries_data add column region varchar(5);

update countries_data set region = c.continent from (select c.continent, c.code from countries c) c where c.code = countries_data.code;
select * from countries_data limit 5;

--создать колонку с размерами аэропорта;
alter table countries_data add column airport_type varchar(80);

-- заполнить строки из колонки по типу аэропорта
update countries_data 
set airport_type = fd_ad.type from (
									select fd.id, 
								           ad.ident, 
								           ad.type, 
								           fd.origin 
								          from airports_data ad 
								          left join flights_data fd 
								          on fd.origin = ad.ident
								       	) as fd_ad 
								      where fd_ad.id = countries_data.id;

