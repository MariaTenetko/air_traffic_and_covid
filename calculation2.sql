/*Какая глубина данных (минимальная и максимальная дата полётов)
**/
select min(firstseen), max(firstseen) from flights_data;

select max(firstseen) from flights_data;

select extract(day from (max(firstseen) - min(firstseen))) from flights;


/*
1,5) Сгруппировать данные в sql и выгрузить в эксель
2) Очистить данные (в конце, если не 
3) сгруппировать по месяцам
*/
select to_char(date_trunc('month', firstseen), 'YYYY-MM'), count(*) from flights_data 
group by 1
order by 1
;
/*
 
4) среднее/общее количество полётов на аэропорт полетов
*/

select ad.name, f.origin, count(origin) from flights_data f 
left join airports_data as ad on f.origin = ad.ident
group by origin, ad.name
order by 3 desc;

/*среднее количество полетов на аэропорт по месяцам*/
select to_char(date_trunc('month', firstseen), 'YYYY-MM') as month, ad.name, f.origin, count(f.origin)
from flights f 
left join airports_data as ad on f.origin = ad.ident
where f.origin != f.destination 
group by month, ad.name, f.origin
order by 2, 1;

with af as (
select to_char(date_trunc('month', firstseen), 'YYYY-MM') as month, ad.name, f.origin, count(f.origin)
from flights_data f 
left join airports_data as ad on f.origin = ad.ident
where f.origin != f.destination 
group by month, ad.name, f.origin
order by 4 desc
)
select month, name, round(avg(count),0) from af
group by name
order by avg(count) desc;
select distinct count(name) from airports_data ad ;
select * from airports_data ad limit 10;

select * from flights_data fd limit 5;
/*

 
5) Построить графики

6) поделить полёты на внутренние/внешние + близкие/дальние + большие/малые аэропорты
**непонятно как делить полеты на близкие или дальные, если нет возможности измерить расстояние. Если взять расстояние между аэропортами
*
магистральные ближние с дальностью от 1000 до 2500 км
магистральные среднее с дальностью от 2500 до 6000 км
магистральные дальние с дальностью полёта свыше 6000 км

7) проверить сезоность (сравнить с динамикой прошлого года), сравнить кривые +
Для 8го задания сделать таблицу
Страна, 
среднее за 2019, 
среднее за 2020, 
ср за 21, 
ср за 22



8) сделать табличку с полями
- страна
- год
- месяц
- внутренний/внешний
- количество рейсов

- дальний/ближний
- размер аэропорта (маленкий/большой)

- регион

8) Посмотреть динамику по отдельным аэропортам/странам/регионам + в разбивке все/только внутрннре/только: как поменялось в сравнии с такими же месяцами (+среднее и средневзвешенное за 12 месяце) в не кризисный год
Выбрать правильно периоды в зависимости от спадов (в старые должны быть "хорошие" цифры) 
9) вывести динамику по месяцам (либо относительное изменения месяц к месяцу прошлого года, либо, если применимо, накопленным итогом)
9,5) Посмотреть другие статистики (минимум, максимум и т.п.)
10) leaderboard по странам/аэропортам/ригеонам, кто больше и кто меньше все поменял. Выделить группы стран (например покрасить по регионам)
 */