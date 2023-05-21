/**8) Посмотреть динамику по отдельным странам
 
 -в разбивке все/только как поменялось в сравнении с такими же месяцами (+среднее и средневзвешенное за 12 месяце) в не кризисный год+
 
 -внутрннре/только: как поменялось в сравнении с такими же месяцами (+среднее и средневзвешенное за 12 месяце) в не кризисный год

 -Выбрать правильно периоды в зависимости от спадов (в старые должны быть "хорошие" цифры) 
9) вывести динамику по месяцам (либо относительное изменения месяц к месяцу прошлого года, либо, если применимо, накопленным итогом)

9,5) Посмотреть другие статистики (минимум, максимум и т.п.)

10) leaderboard по странам/аэропортам/ригеонам, кто больше и кто меньше все поменял. Выделить группы стран (например покрасить по регионам)
*/
-- подсчет количество вылетов по аэропортам

select * from countries_data cd limit 10;
select year, month, name, count(*) from countries_data cd 
group by year, month, is_domestic, name
having is_domestic is true 
order by 1;

select year, month, name, count(*) from countries_data cd 
group by year, month, is_domestic, name
having is_domestic is false 
order by 1;

select name, diff(max(count(*)),min(count(*))) as diff from countries_data cd 
group by name, diff
order by diff desc;

--расчет максимальной величины полетов по годам;
with a as(
	select year, name, count(*) as sum_flights from countries_data
	group by year, name)
select a.year, a.name, max(a.sum_flights) as maximum from a
group by a.year, a.name;
