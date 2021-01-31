-----наиболее популярное направление: по кол-ву запланированных рейсов зимой
select a_to.city, model, count(distinct flight_id)
from dst_project.flights f
join dst_project.airports a_from on a_from.airport_code= f.departure_airport
join dst_project.airports a_to on a_to.airport_code= f.arrival_airport
join dst_project.aircrafts s on s.aircraft_code=f.aircraft_code
join dst_project.seats se on s.aircraft_code=se.aircraft_code
where a_from.city = 'Anapa' and 
scheduled_departure >= '2016-12-01'
and scheduled_departure< '2017-03-01' --- такой же запрос по фактическому отправлению actual_departure>= '2016-12-01' and actual_departure< '2017-03-01'
group by 1,2
---вывод: в Белгород и Москву летает по 90 рейсов, в Новокузнецк только 13, в Новокузнецк летает только Boeing 737-300
---из Анапы летает только две модели самолетов: Boeing 737-300, Sukhoi Superjet-100


---по кол-ву чел-к, наименее популярные модели рейсов
select a_to.city, model, count(*)
from dst_project.flights f
join dst_project.airports a_from on a_from.airport_code= f.departure_airport
join dst_project.airports a_to on a_to.airport_code= f.arrival_airport
join dst_project.aircrafts s on s.aircraft_code=f.aircraft_code
join dst_project.seats se on s.aircraft_code=se.aircraft_code
where a_from.city = 'Anapa' and actual_departure>= '2016-12-01' and actual_departure< '2017-03-01'
group by 1,2
-----Максимальная загрузка самолетов: Москва 11700 человек, Белгород - 8730, Новокузнецк - 1690.

----фактическая загрузка самолетов
select  a_to.city, f.arrival_airport, count(tf.flight_id)
from dst_project.flights f
join dst_project.aircrafts s on s.aircraft_code=f.aircraft_code
join dst_project.airports a_from on a_from.airport_code= f.departure_airport
join dst_project.airports a_to on a_to.airport_code= f.arrival_airport
join dst_project.ticket_flights tf on tf.flight_id = f.flight_id
where f.departure_airport = 'AAQ' and f.actual_departure>= '2016-12-01' and f.actual_departure< '2017-03-01'
group by 1,2
---
/*
итоги:
Belgorod | EGO | 8141
Moscow   |SVO  |10210

Ни один человек не летаел зимой в Новокузнецк
*/
----но все самолеты из Анапы вылетели в Новокузнецк, не было отмененных рейсов
select distinct status
from dst_project.flights f
join dst_project.airports a_from on a_from.airport_code= f.departure_airport
join dst_project.airports a_to on a_to.airport_code= f.arrival_airport
join dst_project.aircrafts s on s.aircraft_code=f.aircraft_code
join dst_project.seats se on s.aircraft_code=se.aircraft_code
where a_from.city = 'Anapa' and a_to.city = 'Novokuznetsk'
and scheduled_departure >= '2016-12-01'
and scheduled_departure< '2017-03-01'

----наиболее частые перелеты
select date_trunc('month',actual_departure), extract(hour from scheduled_departure),  a_to.city,count(flight_id)
from dst_project.flights f
join dst_project.airports a_from on a_from.airport_code= f.departure_airport
join dst_project.airports a_to on a_to.airport_code= f.arrival_airport
join dst_project.aircrafts s on s.aircraft_code=f.aircraft_code
where a_from.city = 'Anapa' and actual_departure>= '2016-12-01' and actual_departure< '2017-03-01'
group by 1,2,3
----вывод: в мск и белгород самолеты летают каждый день, в Новокузнецк только раз в неделю в 6 утра. В Мск и Белгород в 9-10 утра

----в Новокузнецк летают только по вторникам в 6 утра (хотела использовать dateweek функцию, но она не работает в metabase)
select scheduled_departure, extract(hour from scheduled_departure), a_to.city,count(flight_id)
from dst_project.flights f
join dst_project.airports a_from on a_from.airport_code= f.departure_airport
join dst_project.airports a_to on a_to.airport_code= f.arrival_airport
join dst_project.aircrafts s on s.aircraft_code=f.aircraft_code
where a_from.city = 'Anapa' and actual_departure>= '2016-12-01' 
and actual_departure< '2017-03-01'
and a_to.city not in ('Moscow', 'Belgorod')
group by 1,2,3

-----прибыльность рейсов: кол-во билетов/ размер топлива
/* средний расход топлива в зависимости от модели:
Bombardier CRJ-200: 1 200 кг/час : 1200/60 = 20 кг/мин
Boeing 767-300: 4 500 кг/час
Cessna 208 Caravan: 1257 кг/час
Boeing 737-300:  2400 кг/час : 2400/60 = 40 кг/мин
Airbus A321-200: 3 200 кг/час
Sukhoi Superjet-100: 1700 кг/час : 1700/60 = 28,3 кг/мин

Цена топлива в Анапе в 2017 году в январе:41 435 руб за тонну; в феврале: 39 553 руб за тонну; в декабре 2016: 38 867 руб за тонну, 
среднее значение:  39,952 за кг
*/


-----время перелета (хотела использовать datediff или timediff но ее нет в metabase)
select  distinct a_to.city, scheduled_arrival- scheduled_departure
from dst_project.flights f
join dst_project.airports a_from on a_from.airport_code= f.departure_airport
join dst_project.airports a_to on a_to.airport_code= f.arrival_airport
join dst_project.aircrafts s on s.aircraft_code=f.aircraft_code
where a_from.city = 'Anapa' and actual_departure>= '2016-12-01' and actual_departure< '2017-03-01'

/*
Belgorod 0 years 0 mons 0 days 0 hours 50 mins 0.00 secs
Moscow 0 years 0 mons 0 days 1 hours 40 mins 0.00 secs
Novokuznetsk 0 years 0 mons 0 days 5 hours 5 mins 0.00 secs
*/
----все перелеты в Мск и Белгород прибыльные. При чем прибыль в 8-9 раз больше расходов
select city, 
       model,
       flight_id, 
       profit - costs as pnl,  
       profit/costs as margin
from (select  a_to.city,
        s.model, 
        f.flight_id,
        case when model = 'Sukhoi Superjet-100'and a_to.city = 'Belgorod' 
                  then 39.952*28.3*50
                  when  model = 'Boeing 737-300' and a_to.city = 'Moscow' 
                  then 39.952*40*100
                  end as costs,
         sum(amount)  as profit
from dst_project.flights f
join dst_project.aircrafts s on s.aircraft_code=f.aircraft_code
join dst_project.airports a_from on a_from.airport_code= f.departure_airport
join dst_project.airports a_to on a_to.airport_code= f.arrival_airport
join dst_project.ticket_flights tf on tf.flight_id = f.flight_id
where f.departure_airport = 'AAQ' and f.actual_departure>= '2016-12-01' and f.actual_departure< '2017-03-01'
group by 1,2,3,4
) a
order by 4  


-----убыточны 4 рейса в Новокузнецк никто не летает, т.е расходы составляют: 487,414.4 руб за один перелет
select model, flight_id, 39.952*40*305 as cost ---39 цена на 1 кг топлива, 305 минут лететь, 40 кг за минуту перелета
from dst_project.flights f
join dst_project.airports a_from on a_from.airport_code= f.departure_airport
join dst_project.airports a_to on a_to.airport_code= f.arrival_airport
join dst_project.aircrafts s on s.aircraft_code=f.aircraft_code
where a_from.city = 'Anapa' 
      and a_to.city = 'Novokuznetsk'
      and actual_departure >= '2016-12-01'
      and actual_departure< '2017-03-01' 
      
      
 /*т.е нужно убрать вылеты в Новокузнецк: рейсы c flight_id:
136511
136513
136514
136518
136523
136533
136534
136540
136544
136546
136560
136564
136567
    */

