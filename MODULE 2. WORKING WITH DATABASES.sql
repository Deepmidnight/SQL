--=============== МОДУЛЬ 2. РАБОТА С БАЗАМИ ДАННЫХ =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите уникальные названия городов из таблицы городов.
SELECT distinct city  FROM city


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города,
--названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.

SELECT distinct city 
from city
where city like 'L%a' 
and 
city not like '% %'


--ЗАДАНИЕ №3
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.

select amount, payment_date 
from payment p 
where amount > 1 
and payment_date::date between '17.06.2005' and '19.06.2005'
order by payment_date 


select pilot.first_name,
count(airplane_pilot.id)
--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.

select amount, payment_date 
from payment p 
order by payment_date desc 
limit 10


--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.

select first_name||' '||last_name as "ФИО", 
email Почта, 
LENGTH(email) as length,
date(last_update) as "Последнее обновление"
from customer c 


--ЗАДАНИЕ №6
--Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE.
--Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.

select lower(first_name)||' '||lower(last_name) фио, 
email Почта, 
date(last_update) as "Последнее обновление"
from customer c 
where (first_name ilike 'KELLY'
or first_name ilike 'WILLIE')
and active = 1

select *
from customer c 

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите одним запросом информацию о фильмах, у которых рейтинг "R" 
--и стоимость аренды указана от 0.00 до 3.00 включительно, 
--а также фильмы c рейтингом "PG-13" и стоимостью аренды больше или равной 4.00.

select title, 
rating,
rental_rate 
from film
where rating = 'R' and rental_rate between 0.00 and 3.00
or rating = 'PG-13' and rental_rate >= 4.00


--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.

select title , length(description) 
from film f 
order by length(description) desc 
limit 3


--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.

select concat(first_name, ' ', last_name),
email ,
SPLIT_PART(email, '@', 1) as name_customer, 
SPLIT_PART(email, '@', 2) as domain_mail
from customer c 


--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква должна быть заглавной, остальные строчными.

select first_name, last_name,
upper(left(email, 1)) || lower(right (SPLIT_PART(email, '@', 1), -1)),
upper(left(SPLIT_PART(email, '@', 2), 1)) || lower(right (SPLIT_PART(email, '@', 2), -1))
from customer c 
order by customer_id 
