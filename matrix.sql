
create table flights_origin_postcovid as(
with flights_data_origin as (
select id, origin, day from flights_data_postcovid
)
select fdo.id, 
	fdo.origin,
	cd.name as country_origin,
	fdo.day 
from flights_data_origin fdo
left join countries_data cd using (id));


create table flights_destination_postcovid as (
with flights_data_destination as (
select id, destination from flights_data_postcovid 
)
select fdd.id, 
	fdd.destination,
	c.name as country_destination
from flights_data_destination fdd
left join airports_data ad on ad.ident = fdd.destination
left join countries c on c.code = ad.iso_country);




create table flights_matrix_postcovid as (
select fop.id,
	fop.country_origin,
	fop.origin,
	fdp.destination,
	fdp.country_destination,
	fop.day
from flights_origin_postcovid fop
left join flights_destination_postcovid fdp using (id));

select count(distinct country_origin) from flights_matrix_postcovid;
delete from flights_matrix_postcovid 
where country_origin not in (select name_x from stat_covid_flights);

create index flights_matrix_precovid_id on flights_matrix_precovid (id); 

with matrix_month_postcovid as (
select 
	id, 
	country_origin, 
	country_destination, 
	(to_char(date_trunc('month', day), 'YYYY-MM')) as month_postcovid
from flights_matrix_postcovid 
)
select 
	count(id),
	month_postcovid,
	country_origin, 
	country_destination
from matrix_month_postcovid
group by  2, 3, 4
order by 2
;

create table matrix_postcovid as(
with matrix_month_postcovid as (
select 
	id, 
	country_origin, 
	country_destination, 
	to_char(date_trunc('month', day), 'YYYY-MM') as postcovid_month
from flights_matrix_postcovid 
)
select 
	count(id) as count_postcovid,
	(substring(postcovid_month from '..$')) as postcovid_month,
	to_date(postcovid_month, 'YYYY-MM') as postcovid_date,
	country_origin, 
	country_destination
from matrix_month_postcovid
group by  2, 3, 4, 5
order by 2
);



create table matrix_percent as (
select 
	mp19.count_precovid as count_precovid, 
	mp20.count_postcovid as count_postcovid,
	percent_total_matrix(mp19.count_precovid, mp20.count_postcovid) as percent,
	mp19.country_origin,
	mp19.country_destination,
	precovid_date,
	postcovid_date	
from matrix_precovid mp19
left join matrix_postcovid mp20
on mp19.country_origin = mp20.country_origin
and mp19.country_destination = mp20.country_destination
and  mp19.precovid_month = mp20.postcovid_month);

update matrix_percent set count_postcovid = 0 where count_postcovid is null;
update matrix_percent set percent = 1 where count_postcovid = 0; 
select * from matrix_percent;
where percent > 1;

drop function percent_total_matrix;

CREATE FUNCTION percent_total_matrix(denominator numeric, divider numeric)
 RETURNS numeric
 LANGUAGE sql
AS $function$
select round(
		(case when denominator <> 0 then (1 - (divider/denominator))
		   	when divider = 0 then 1
			else null 
			end), 2)
$function$
;
select * from matrix_percent;