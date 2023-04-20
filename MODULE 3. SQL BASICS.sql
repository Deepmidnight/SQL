--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO dvd_rental;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.


select first_name ,last_name , a.address,city.city, country.country 
FROM customer c
join address a on a.address_id=c.address_id 
join city on city.city_id=a.city_id 
join country on country.country_id=city.country_id 

--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

select s.store_id, count(c.customer_id) quantity_customers
from store s 
join customer c  on c.store_id = s.store_id 
group by s.store_id 


--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

select store.store_id, count(c.customer_id) quantity_customers
from store 
join customer c  on c.store_id = store.store_id 
group by store.store_id 
having count(c.customer_id)>300



-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

select staff.first_name||' '||staff.last_name as ФИО,
count(customer.customer_id) quantity_customers,
address.address,
city.city
from city
join address on city.city_id  =address.city_id 
join store on store.address_id  =address.address_id 
join staff on store.store_id = staff.store_id 
join customer on store.store_id  = customer.store_id  
group by "ФИО",address.address,city.city
having count(customer.customer_id)>300

--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов

select  customer.first_name||' '||customer.last_name as ФИО,count(rental.customer_id)
from rental
join customer on customer.customer_id = rental.customer_id 
group by customer.customer_id
order by count(rental.customer_id) desc
limit 5

--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
select  customer.first_name||' '||customer.last_name as ФИО,
count(rental.customer_id),
round(sum(payment.amount)) as "sum",
min(payment.amount),
max(payment.amount)
from rental
join customer on customer.customer_id = rental.customer_id 
join payment on payment.rental_id = rental.rental_id
group by rental.customer_id,customer.first_name,customer.last_name
order by count(rental.customer_id) desc


--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
 
--без одинаковых названий городов
select c1.city, c2.city
from city c1, city c2 
where c1.city!=c2.city

--без зеркальных названий городов
select c1.city, c2.city
from city c1, city c2 
where c1.city>c2.city

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 
select customer_id, avg(date_part('day', age(return_date::date, rental_date::date)))
from rental 
group by customer_id
order by customer_id 

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.

select film.film_id,
title,
count(film.film_id),
sum (amount)
from rental 
join payment on rental.rental_id = payment.rental_id 
join inventory on inventory.inventory_id = rental.inventory_id 
join film on film.film_id = inventory.film_id 
group by film.film_id
order by film.film_id 


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.

select film.film_id,
title,
amount
from rental 
join payment on rental.rental_id = payment.rental_id 
join inventory on inventory.inventory_id = rental.inventory_id 
full join film on film.film_id = inventory.film_id 
where amount is null 
group by film.film_id, amount
order by film.film_id 

--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".


select staff.first_name||' '||staff.last_name as ФИО,
count(payment.payment_id),
	case 
		when count(staff.staff_id)>7300 then'Да'
		when count(staff.staff_id)<=7300 then'Нет'
	end as "Премия"
from staff
join payment on payment.staff_id = staff.staff_id
group by staff.staff_id
