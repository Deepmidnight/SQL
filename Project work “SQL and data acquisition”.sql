--=============== Проектная работа по модулю “SQL и получение данных”=======================================

SET search_path TO bookings;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Какие самолеты имеют более 50 посадочных мест?

select a.aircraft_code , a.model ,count(s.seat_no) as "Количество мест"
from aircrafts a 
join seats s on s.aircraft_code = a.aircraft_code 
group by a.aircraft_code 
having count(s.seat_no)>50


--ЗАДАНИЕ №2
--В каких аэропортах есть рейсы, в рамках которых можно добраться бизнес - классом дешевле, 
--чем эконом - классом?

with c1 as (
	select flight_id, fare_conditions, amount бизнес
	from ticket_flights 
	where fare_conditions='Business'
	group by flight_id,fare_conditions,amount),
c2 as (
select flight_id, fare_conditions, amount эконом
	from ticket_flights 
	where fare_conditions='Economy'
	group by flight_id,fare_conditions,amount)
select f.departure_airport , c1.бизнес, c2.эконом
from c1
join c2 on c2.flight_id =c1.flight_id
join flights f ON f.flight_id =c2.flight_id
where c1.бизнес<c2.эконом
group by f.departure_airport , c1.бизнес, c2.эконом


--ЗАДАНИЕ №3
--Есть ли самолеты, не имеющие бизнес - класса?

select a.aircraft_code ,a.model ,array_agg(s.fare_conditions) 
from aircrafts a 
join seats s on s.aircraft_code = a.aircraft_code 
group by a.aircraft_code 
having not 'Business' = any (array_agg(s.fare_conditions))


--ЗАДАНИЕ №4
--Найдите количество занятых мест для каждого рейса, процентное отношение количества занятых мест 
--к общему количеству мест в самолете, добавьте накопительный итог вывезенных пассажиров 
--по каждому аэропорту на каждый день.

select t.flight_id,
t."Количество посадочных талонов", 
round(cast (t."Количество посадочных талонов" as numeric) *100/ cast(seat."Количество мест" as numeric), 2) as "доля занятых мест",
t.departure_airport, 
t.actual_departure::date,
sum(t."Количество посадочных талонов") over (partition by t.departure_airport ,t.actual_departure::date order by t.actual_departure) as "пассажиров в день"
from (select distinct tf.flight_id ,
	bn."Количество посадочных талонов",
	f.departure_airport ,
	f.actual_departure, 
	f.aircraft_code 
	from ticket_flights tf 
	join (select bp.flight_id ,
		count(bp.boarding_no) as "Количество посадочных талонов"	
		from boarding_passes bp
		group by bp.flight_id ) bn on bn.flight_id = tf.flight_id 
	join flights f on tf.flight_id =f.flight_id ) t
join aircrafts a on a.aircraft_code =t.aircraft_code
join (select a.aircraft_code, 
	a.model ,
	count(s.seat_no) as "Количество мест"
	from aircrafts a 
	join seats s on s.aircraft_code = a.aircraft_code 
	group by a.aircraft_code) seat on seat.aircraft_code = a.aircraft_code

	
--ЗАДАНИЕ №5
--Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов. 
--Выведите в результат названия аэропортов и процентное отношение


select a1.airport_name as "аэропорт вылета" ,a2.airport_name as "аэропорт прилёта",
round(count(f.flight_id)*100.0/sum(count(f.flight_id)) over (), 3) as "процентное отношение"
from flights f
join airports a1 on a1.airport_code =f.departure_airport 
join airports a2 on a2.airport_code =f.arrival_airport  
group by a1.airport_name ,a2.airport_name
order by a1.airport_name,a2.airport_name
	
	
--ЗАДАНИЕ №6
--Выведите количество пассажиров по каждому коду сотового оператора, если учесть, 
--что код оператора - это три символа после +7


select count(t.ticket_no ) as "количество пассажиров", right(left(t.contact_data->>'phone', 5), 3) as код
from tickets t 
group by "код"


--ЗАДАНИЕ №7
--Между какими городами не существует перелетов?


select a1.city,a2.city
from airports a1, airports a2 
where a1.city>a2.city
except 
select a.city ,a3.city 
from flights f 
join airports a on a.airport_code =f.departure_airport 
join airports a3 on a3.airport_code =f.arrival_airport 


--ЗАДАНИЕ №8
--Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
--До 50 млн - low
--От 50 млн включительно до 150 млн - middle
--От 150 млн включительно - high
--Выведите в результат количество маршрутов в каждом классе.

select t."класс",
count(t."класс")
from (
	select f.departure_airport,f.arrival_airport,
	case 
		when sum(tf.amount)<50000000 then'low'
		when sum(tf.amount)>=50000000 and sum(tf.amount)<150000000 then'middle'
		when sum(tf.amount)>=150000000 then'high'
	end as класс
	from flights f 
	join ticket_flights tf on tf.flight_id =f.flight_id 
	group by f.departure_airport,f.arrival_airport
	order by sum(tf.amount) desc) t
group by t."класс"


--ЗАДАНИЕ №9
-- Выведите пары городов между которыми расстояние более 5000 км

