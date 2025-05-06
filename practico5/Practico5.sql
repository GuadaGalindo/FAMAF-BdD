USE Sakila;

-- Ejercicio 1:
-- Cree una tabla de `directors` con las columnas: Nombre, Apellido, Número de Películas.
DROP TABLE IF EXISTS directors;

CREATE TABLE directors (
	ID SMALLINT NOT NULL AUTO_INCREMENT,
	Name char(52) NOT NULL DEFAULT '',
	LastName char(52) NOT NULL DEFAULT '',
	NoOfFilms int NOT NULL DEFAULT 0,
 	PRIMARY KEY (ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Ejercicio 2:
-- El top 5 de actrices y actores de la tabla `actors` que tienen la mayor experiencia 
-- (i.e. el mayor número de películas filmadas) son también directores de las películas 
-- en las que participaron. Basados en esta información, inserten, utilizando una subquery 
-- los valores correspondientes en la tabla `directors`.

INSERT INTO directors (Name, LastName , NoOfFilms)
WITH most_experienced_performers AS (
	SELECT actor_id, COUNT(*) AS no_of_films 
	FROM film_actor 
	GROUP BY (actor_id) 
	ORDER BY no_of_films DESC 
	LIMIT 5
), most_experienced_performers_names AS (
	SELECT a1.first_name, a1.last_name, a2.no_of_films
	FROM actor a1 
		INNER JOIN most_experienced_performers a2
		ON a1.actor_id = a2.actor_id
) SELECT * FROM most_experienced_performers_names;

-- Ejercicio 2: Forma 2
INSERT INTO directors
SELECT actor.first_name, actor.last_name, COUNT(film_actor.film_id) AS num_files
FROM actor
INNER JOIN film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY actor.actor_id, actor.first_name, actor.last_name
ORDER BY num_files DESC
LIMIT 5

-- Ejercicio 3:
-- Agregue una columna `premium_customer` que tendrá un valor 'T' o 'F' de acuerdo a si 
-- el cliente es "premium" o no. Por defecto ningún cliente será premium.

ALTER TABLE customer
ADD COLUMN `premium_customer` enum('T','F') NOT NULL DEFAULT 'F';

-- Ejercicio 4:
-- Modifique la tabla customer. Marque con 'T' en la columna `premium_customer` de los 10 
-- clientes con mayor dinero gastado en la plataforma.

UPDATE customer SET customer.premium_customer = 'T'
WHERE customer.customer_id IN (
	SELECT premium.customer_id
	FROM (
		SELECT customer_id, SUM(amount) AS total_spent
		FROM payment
		GROUP BY customer_id 
		ORDER BY total_spent DESC
		LIMIT 10
	) AS premium
);

-- Ejercicio 5:
-- Listar, ordenados por cantidad de películas (de mayor a menor), los distintos ratings 
-- de las películas existentes.

SELECT rating, COUNT(*) AS amount
FROM film
GROUP BY rating
ORDER BY amount DESC;

-- Ejercicio 6:
-- ¿Cuáles fueron la primera y última fecha donde hubo pagos?
SELECT MIN(p.payment_date) AS first_date , MAX(p.payment_date) AS last_date
FROM payment p;

-- Ejercicio 7:
-- Calcule, por cada mes, el promedio de pagos.

SELECT MONTHNAME(payment_date) AS month_of_payments, AVG(amount) as avg_amount
FROM payment
GROUP BY month_of_payments;

-- Ejercicio 8:
-- Listar los 10 distritos que tuvieron mayor cantidad de alquileres 
-- (con la cantidad total de alquileres).

WITH rental_districts AS (
	SELECT r.rental_id, c.customer_id, a.district
	FROM rental r 
	INNER JOIN customer c ON (r.customer_id = c.customer_id)
	INNER JOIN address a ON (c.address_id = a.address_id)
)
SELECT district, COUNT(*) AS total_rentals
FROM rental_districts
GROUP BY district
ORDER BY total_rentals DESC
LIMIT 10;

-- Ejercicio 9:
-- Modifique la table `inventory_id` agregando una columna `stock` que sea un número entero 
-- y representa la cantidad de copias de una misma película que tiene determinada tienda. 
-- El número por defecto debería ser 5 copias.

ALTER TABLE inventory 
ADD COLUMN `stock` int NOT NULL DEFAULT '5';

-- Ejercicio 10:
-- Cree un trigger `update_stock` que, cada vez que se agregue un nuevo registro a la tabla rental,
-- haga un update en la tabla `inventory` restando una copia al stock de la película rentada.

DROP TRIGGER IF EXISTS update_stock;

DELIMITER //

CREATE TRIGGER update_stock 
AFTER INSERT ON rental 
FOR EACH ROW
BEGIN 
    UPDATE inventory AS i
    SET i.stock = i.stock - 1
    WHERE i.inventory_id = NEW.inventory_id
    AND i.stock > 0;
END //

DELIMITER ;

-- Ejercicio 11:
-- Cree una tabla `fines` que tenga dos campos: `rental_id` y `amount`. El primero es una clave foránea 
-- a la tabla rental y el segundo es un valor numérico con dos decimales.

DROP TABLE IF EXISTS fines;

CREATE TABLE fines (
	rental_id int NOT NULL,
	amount decimal(10,2) NOT NULL,
 	FOREIGN KEY (rental_id) REFERENCES rental (rental_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Ejercicio 12:
-- Cree un procedimiento `check_date_and_fine` que revise la tabla `rental` y cree un registro en la tabla 
-- `fines` por cada `rental` cuya devolución (return_date) haya tardado más de 3 días (comparación con rental_date). 
-- El valor de la multa será el número de días de retraso multiplicado por 1.5.

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS check_date_and_fine()
BEGIN
    INSERT INTO fines (rental_id, amount)
    SELECT rental.rental_id, DATEDIFF(rental.return_date, rental.rental_date) * 1.5 as amount
    FROM rental
    WHERE DATEDIFF(rental.return_date, rental.rental_date) > 3;
END//

DELIMITER ;
CALL check_date_and_fine();

-- Ejercicio 13:
-- Crear un rol `employee` que tenga acceso de inserción, eliminación y actualización a la tabla `rental`.

CREATE ROLE 'employee';
GRANT INSERT, DELETE, UPDATE ON rental TO 'employee';

-- Ejercicio 14:
-- Revocar el acceso de eliminación a `employee` y crear un rol `administrator` que tenga todos los 
-- privilegios sobre la BD `sakila`.

REVOKE DELETE ON rental FROM 'employee';
CREATE ROLE 'administrator';
GRANT ALL PRIVILEGES ON sakila.* TO 'administrator';

-- Ejercicio 15:
-- Crear dos roles de empleado. A uno asignarle los permisos de `employee` y al otro de `administrator`.

CREATE ROLE 'employee_role';
CREATE ROLE 'admin_role';
GRANT 'employee' TO 'employee_role';
GRANT 'administrator' TO 'admin_role';

-- EJEMPLO DE VISTA:
-- CREATE VIEW medals_summary AS
-- SELECT 
    -- c.country_name AS country,
    -- s.sport_name AS sport,
    -- SUM(CASE WHEN m.medal_type = 'Gold' THEN 1 ELSE 0 END) AS gold_medals,
    -- SUM(CASE WHEN m.medal_type = 'Silver' THEN 1 ELSE 0 END) AS silver_medals,
    -- SUM(CASE WHEN m.medal_type = 'Bronze' THEN 1 ELSE 0 END) AS bronze_medals,
    -- COUNT(*) - SUM(CASE WHEN m.medal_type IS NOT NULL THEN 1 ELSE 0 END) AS participations_without_medals
-- FROM 
    -- medals m
-- JOIN 
    -- countries c ON m.country_id = c.country_id
-- JOIN 
    -- sports s ON m.sport_id = s.sport_id
-- GROUP BY 
    -- c.country_name, s.sport_name;

-- EJEMPLO DE FUNCION:
-- DELIMITER //

-- CREATE PROCEDURE GetMedalCounts(IN country_name VARCHAR(50))
-- BEGIN
    -- SELECT 
        -- SUM(gold_medals) AS total_gold,
        -- SUM(silver_medals) AS total_silver,
        -- SUM(bronze_medals) AS total_bronze
    -- FROM 
        -- medals_summary
    -- WHERE 
        -- country = country_name;
-- END //

-- DELIMITER ;



