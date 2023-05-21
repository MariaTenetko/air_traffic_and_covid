

select earth_distance(
	ll_to_earth(1.38, 104.03),
	ll_to_earth(33.9, -118.37)
) / 1000;

select * from flights_data fd limit 1;

create table distance_data as (
select id, 
		to_char(date_trunc('month', firstseen), 'YYYY-MM') as month,
		round(cast(earth_distance(
		ll_to_earth(latitude_1, longitude_1),
		ll_to_earth(latitude_2, longitude_2)
		)/1000 as numeric),2) as distance
		from flights_data
);

/*магистральные ближние с дальностью от 1000 до 2500 км
магистральные среднее с дальностью от 2500 до 6000 км
магистральные дальние с дальностью полёта свыше 6000 км.*/
create index distance_data_id on distance_data (id);

/* группировка по расстоянию*/
select month, sum(case when distance < 2500 then 1 else 0 end) as short,
sum(case when 2500 <= distance and distance < 6000 then 1 else 0 end) as middle,
sum(case when distance >= 6000 then 1 else 0 end) as long
from distance_data dd
group by month;

