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
-----в Москву летает 11700 человек, Белгород - 8730, Новокузнецк - 1690. 

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
Bombardier CRJ-200: 1 200 кг/час
Boeing 767-300: 4 500 кг/час
Cessna 208 Caravan: 1257 кг/час
Boeing 737-300:  2400 кг/час
Airbus A321-200: 3 200 кг/час
Sukhoi Superjet-100: 1700 кг/час

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
