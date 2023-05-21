create table airports (
	id bigserial primary key,
	ident varchar(20),
	type varchar(50),
	name text,
	latitude_deg float8,
	longitude_deg float8,
	elevation_ft int8,
	continent varchar(10),
	iso_country varchar(2),
	iso_region varchar(10),
	municipality varchar(50),
	scheduled_service varchar(5),
	gps_code varchar(5),
	iata_code varchar(10),
	local_code varchar(10),
	home_link varchar(500),
	wikipedia_link varchar(500),
	keywords varchar(300)
);
select count(*) from airports;	
select * from flights_data limit 5;

create table airports_data as (
	select * from airports
	where type in ('small_airport', 'medium-airport', 'large_airport') 
);
select * from airports_data limit 5;

create table flights_data as (
	select * from flights f 
	where f.origin != f.destination
)
;


