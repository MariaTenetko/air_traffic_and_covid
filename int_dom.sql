
create table international_flights as (
 SELECT fd.id,
    fd.callsign,
    fd.number,
    fd.typecode,
    fd.origin,
    fd.destination,
    fd.firstseen,
    fd.lastseen
   FROM ((flights_data fd
     LEFT JOIN airports_data ao ON (((fd.origin)::text = (ao.ident)::text)))
     LEFT JOIN airports_data ad ON (((fd.destination)::text = (ad.ident)::text)))
  WHERE ((ao.iso_country)::text <> (ad.iso_country)::text));	
 create index international_flights_id on international_flights (id);
 
select ident, iso_country from airports_data ad 
where ident is null or iso_country is null;


create table domestic_flights as (
 SELECT fd.id,
    fd.callsign,
    fd.number,
    fd.typecode,
    fd.origin,
    fd.destination,
    fd.firstseen,
    fd.lastseen
   FROM ((flights_data fd
     LEFT JOIN airports_data ao ON (((fd.origin)::text = (ao.ident)::text)))
     LEFT JOIN airports_data ad ON (((fd.destination)::text = (ad.ident)::text)))
  WHERE ((ao.iso_country)::text = (ad.iso_country)::text));	
  create index domestic_flights_id on domestic_flights (id);
 