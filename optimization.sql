--создание индексов для оптимизации запросов
-- создание первичных ключей
create index airport_data_pkey on airports_data (id);
create index flights_data_pkey on flights_data (id);

--создание связей между таблицами
alter table airports_data add constraint airports_data_ident_pkey primary key (ident);
ALTER TABLE postgres_air.boarding_pass ADD CONSTRAINT booking_leg_id_fk FOREIGN KEY (booking_leg_id) REFERENCES postgres_air.booking_leg(booking_leg_id);
-- создание связи между таблицами с аэропортами и перелетами по аэропорту вылета
alter table flights_data add constraint airports_data_ident_fk foreign key (origin) references airports_data(ident);

select * from stata_airports sa limit 10;
select * from flights_data fd limit 5;
--создание индекса по аэропорта вылета в двух таблицах
create index flight_data_origin on flights_data (origin);
create index airport_data_ident on airports_data (ident);

-- создание индекса времени вылета и прилета
create index flight_data_firstseen on flights_data (firstseen);	
create index flight_data_lastseen on flights_data (lastseen);
