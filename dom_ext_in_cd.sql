
-- создаем материализованное представление, где мы выводим все перелеты внутри страны
create materialized view domestic_data as (
	select fd.id as dd_id,
			fd.origin,
			fd.destination,
			fd.firstseen,
			fd.day,
			is_domestic 
	from flights_data fd
	left join airports_data ao
	on fd.origin = ao.ident
	left join airports_data ad
	on fd.destination = ad.ident
	where ao.iso_country = ad.iso_country 
);

-- на основе вьюшки создаем таблицу домашних перелетов
create table domestic as (
	select dd_id as id,
			is_domestic from domestic_data
);

-- заполняем поле is_domestic  значением true
update domestic set is_domestic = true;

-- смотрим что получилось
select * from domestic where is_domestic limit 50;
select count(*) from domestic;
select count(*) from domestic d where is_domestic ;

--- добавляем столбец is_domestic в countries_data;
alter table countries_data add column is_domestic boolean;

-- заполняем некоторые строки в поле is_domestic  в countries_data, если есть совпадения по айди у таблиц flights_data - domestic 
update countries_data 
set is_domestic = true
from 
	(select d.id, d.is_domestic from domestic d) d 
where d.id = countries_data.id;

select count(*) from countries_data where is_domestic; -- 37 648 612

-- теперь мы заполняем false там где у нас is null

select  count(*) from countries_data cd where is_domestic is false; -- 15 481 980
update countries_data 
set is_domestic = false where is_domestic is null;






