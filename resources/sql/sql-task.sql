-- 1)Вывести к каждому самолету класс обслуживания и количество мест этого класса
SELECT a.model,
       s.fare_conditions,
       count(*)
FROM aircrafts a
         LEFT JOIN seats s ON a.aircraft_code = s.aircraft_code
GROUP BY a.model,
         s.fare_conditions
ORDER BY a.model,
         s.fare_conditions;

-- 2)Найти 3 самых вместительных самолета(модель + кол-во мест)
SELECT a.model,
       count(*) seats
FROM aircrafts a
         LEFT JOIN seats s ON a.aircraft_code = s.aircraft_code
GROUP BY a.model
ORDER BY seats DESC
LIMIT 3;

-- 3)Вывести код, модель самолета и места не эконом класса для самолета "Аэробус А321-200" с сортировкой по местам
SELECT s.aircraft_code,
       a.model,
       s.seat_no
FROM seats s
         LEFT JOIN aircrafts a ON s.aircraft_code = a.aircraft_code
WHERE a.model = 'Аэробус A320-200'
  AND s.fare_conditions != 'Economy'
ORDER BY s.seat_no;

-- 4)Вывести города в которых больше 1 аэропорта(код аэропорта, аэропорт, город)
SELECT a.airport_code,
       a.airport_name,
       a.city
FROM airports a
WHERE a.city in
      (SELECT city
       FROM airports
       GROUP BY city
       HAVING count(*) > 1)
ORDER BY a.city,
         a.airport_name;

-- 5)Найти ближайший вылетающий рейс из ЕКБ в Москву, на который еще не завершивлась регистрация
SELECT f.flight_id,
       f.scheduled_departure
FROM flights f
         LEFT JOIN airports AS dep_airport ON f.departure_airport = dep_airport.airport_code
         LEFT JOIN airports AS arr_airport ON f.arrival_airport = arr_airport.airport_code
         LEFT JOIN aircrafts ON f.aircraft_code = aircrafts.aircraft_code
         LEFT JOIN ticket_flights tf ON f.flight_id = tf.flight_id
         LEFT JOIN tickets ON tf.ticket_no = tickets.ticket_no
         LEFT JOIN boarding_passes bpass ON tf.ticket_no = bpass.ticket_no
    AND tf.flight_id = bpass.flight_id
WHERE dep_airport.city = 'Екатеринбург'
  AND arr_airport.city = 'Москва'
  AND f.scheduled_departure > bookings.now()
  AND bpass.boarding_no IS NULL
ORDER BY f.scheduled_departure
LIMIT 1;

-- 6)Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)
SELECT min(tf.amount) AS min_price,
       max(tf.amount) AS max_price
FROM tickets t
         LEFT JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no;

-- 7)Написать DDL таблицы Customers, должны быть поля id , firstName, lastName, email , phone.
-- Добавить ограничения на поля (constraints).
CREATE TABLE customers (
	id BIGSERIAL PRIMARY KEY,
	firstName VARCHAR(64) NOT NULL,
	lastName VARCHAR(64) NOT NULL,
	email VARCHAR(256) NOT NULL,
	phone VARCHAR(16) NOT NULL,
	CONSTRAINT uc_customers_email UNIQUE (email),
	CONSTRAINT ck_customers_phone CHECK (phone ~ '^\+?[1-9][0-9]{7,14}$')
);

-- 8)Написать DDL таблицы Orders, должен быть id, customerId, quantity.
-- Должен быть внешний ключ на таблицу customers + ограничения
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    customerId BIGSERIAL NOT NULL,
    quantity INT NOT NULL,
    CONSTRAINT fk_customerId FOREIGN KEY (customerId) REFERENCES customers(id),
    CONSTRAINT check_quantity CHECK (quantity > 0)
);

-- 9)Написать 5 insert в эти таблицы
INSERT INTO customers (id, firstName, lastName, email, phone)
VALUES (1,'Andrei', 'Yuryeu', 'andrei.yuryeu1@gmail.com', '+375257168240'),
       (2,'Yaroslav', 'Vasilevski', 'yarosvas2003@mail.ru', '+375336587429'),
       (3,'Alexander', 'Kuprijanenko', 'alexkupr55@tut.by', '+375447838436'),
       (4,'Oleg', 'Potapenko', 'aliehpotapka228@gmail.com', '+375291116779'),
       (5,'Anastasija', 'Yurkova', 'nst.yrk0@mail.ru', '+37525555825');

INSERT INTO orders (id, customerId, quantity)
VALUES (1, 1, 2),
       (2, 1, 1),
       (3, 2, 3),
       (4, 3, 1),
       (5, 5, 2);

-- 10)Удалить таблицы
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

-- 11)Написать свой кастомный запрос (rus + sql)
-- Найти кол-во перелётов каждого из клиентов (сортировка по убыванию)
SELECT t.passenger_name,
       COUNT(tf.flight_id) AS flights_count
FROM ticket_flights tf
         LEFT JOIN
     (
         SELECT tickets.ticket_no, tickets.passenger_name AS passenger_name
         FROM tickets
     ) t ON tf.ticket_no = t.ticket_no
GROUP BY t.passenger_name
ORDER BY flights_count DESC;