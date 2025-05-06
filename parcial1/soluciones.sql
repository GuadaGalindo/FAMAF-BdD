-- PARCIAL 1:

-- Ejercicio 1:
SELECT p.name, COUNT(*) as review 
FROM reviews r
INNER JOIN properties p
ON r.property_id = p.id
WHERE YEAR(r.created_at) = 2024
GROUP BY p.name 
LIMIT 7;

-- Ejercicio 2:
WITH rent_properties AS (
	SELECT b.property_id, DATEDIFF(b.check_out, b.check_in) * p.price_per_night as income
	FROM bookings b
	INNER JOIN properties p ON (p.id = b.property_id)
)
SELECT property_id, SUM(income) AS total_income
FROM rent_properties
GROUP BY property_id;

-- Ejercicio 3:
WITH users_payments AS (
	SELECT u.name, p.amount
	FROM payments p
	INNER JOIN users u ON (p.user_id = u.id)
)
SELECT name, SUM(amount) AS total_amount
FROM users_payments
GROUP BY name
ORDER BY total_amount DESC
LIMIT 10;

-- Ejercicio 4:

-- Verifiqué que funcione lo que se encuntra entre begin y end. Sin embargo, por algún
-- motivo me toma mal los DELIMITER.

DROP TRIGGER IF EXISTS notify_host_after_booking;

DELIMITER //

CREATE TRIGGER notify_host_after_booking AFTER INSERT ON booking 
FOR EACH ROW
BEGIN
	INSERT INTO messages (sender_id, receiver_id, property_id)
    SELECT b.user_id, p.owner_id, b.property_id, 'A reservation has been made'
    FROM bookings b
    INNER JOIN properties p
    ON b.property_id = p.id;
END //

DELIMITER ;

-- Ejercicio 5:

-- No se me ocurrio como verificar que la propiedad este disponible en laa fechas dadas.
-- Mismo prblema de los DELIMITER que el ejercicio anterior.

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS add_new_booking (IN propertyID INT
												IN userID INT
												IN checkIN DATE
												IN checkOUT DATE)
BEGIN
    INSERT INTO bookings (property_id, user_id, check_in, check_out, total_price, status)
    VALUES (propertyID, userID, checkIN, checkOUT, 0, 'confirmed') 
END//

DELIMITER ;
CALL add_new_booking();


-- Ejercicio 6:

CREATE ROLE 'admin';
GRANT CREATE ON properties TO 'admin';
GRANT UPDATE (status) ON property_availability TO 'admin';

-- Ejercicio 7:

-- Esto no contradice la propiedad de Durabilidad de ACID, la cual nos dice que una vez confirmados los efectos 
-- de la transacción son permanentes persistiendo incluso a través de fallos del sistema; ya que al utilizar commit
-- se completa con éxito la transacción, haciendo que los cambios sean permanentes.








