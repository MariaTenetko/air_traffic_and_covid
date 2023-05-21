select * from flights_data fd 
where destination is null ;/*0*/

select * from flights_data fd limit 1;

delete  from flights_data 
where firstseen < '2019-01-01 00:00:00.000 +0300';

select count(*)  from flights_data fd 
where left(callsign, 3) in ('FDX', 'DHL', 'UPS', 'SDK')

;
select count(*) from flights_data fd;

create table airports_data as  (
	select * from airports a
	where type in ('small_airport', 'medium_airport', 'large_airport')
	)
;

select count(*) from airports_data ad 
;


delete from flights_data fd
where fd.destination not in (select ad.ident from airports_data ad)  ;


select count(*) from airports_data ad 
where name like '%Air Base%';/*744*/

delete from airports_data ad
where name like '%Air Base%'; /**254193*/

delete from fl

select count(*) from flights_data fd ; /*55203481 строк. Это вылеты из маленьких, средних и больших аэропортов, и вылеты в которых 
не совпдают аэропорты вылета и прилета*/ 
/**Соотношение вылетов военных самолетов к обычным гражданским состовляет меньше одного процента 
 * 
*/

select count(*), iso_country from flights_data fd /*кол-во полетов на страну*/
left join airports_data ad 
on ad.ident = fd.origin 
group by iso_country
;

select fd.origin, fd.destination, ad.iso_country from flights_data fd
left join airports_data ad 
on ad.ident = fd.origin 
limit 20;

/*вьюшка с внутренними перелетами из общей таблицы перелетов*/
create view domestic_flights as (
	 select fd.id as fd_id,
			fd.callsign,
			fd.number,
			fd.typecode,
			fd.origin,
			fd.destination,
			fd.firstseen,
			fd.lastseen
	from flights_data fd
	left join airports_data ao
	on fd.origin = ao.ident
	left join airports_data ad
	on fd.destination = ad.ident
	where ao.iso_country = ad.iso_country 
);
select * from domestic_flights limit 1;
/*вьюшка с внешними перелетами*/
create view external_flights as (
	 select fd.id as fd_id,
			fd.callsign,
			fd.number,
			fd.typecode,
			fd.origin,
			fd.destination,
			fd.firstseen,
			fd.lastseen
	from flights_data fd
	left join airports_data ao
	on fd.origin = ao.ident
	left join airports_data ad
	on fd.destination = ad.ident
	where ao.iso_country != ad.iso_country 
);

select count(*) from external_flights
;
select * from domestic_flights limit 1;

select fd.origin, fd.destination, fd.typecode, (fd.lastseen - fd.firstseen) as time_flight from flights_data fd
order by 4 desc 
limit 50
;
select count(*) from flights_data fd 
where typecode = 'C5M';

delete from flights_data 
where typecode = 'C5M';

select ad.name, ad.ident from airports_data ad 
where ident in ('KFNL', 'CO53');


select * from flights_data fd limit 10;

select * from flights_data f
	left join airports_data ao
	on f.origin = ao.ident
	left join airports_data ad
	on f.destination = ad.ident
	where ao.iso_country = ad.iso_country ;


