-- PARTE 1:

-- Ejercicio 4: Crear una tabla continent.
USE world;

DROP TABLE IF EXISTS continent;

CREATE TABLE continent (
	Name char(52) NOT NULL,
	Area int NOT NULL,
	PercentTotalMass decimal(5,2) NOT NULL,
	MostPopulatedCity int NOT NULL,
	PRIMARY KEY (Name),
	FOREIGN KEY (MostPopulatedCity) REFERENCES city (ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Ejercicio 5: Agregar valores a continent.

SELECT ID FROM city WHERE Name = 'Mexico';

INSERT INTO continent VALUES
    ('Africa', 30370000, 20.4, 608),
    ('Antartica', 14000000, 9.2, 4082),
    ('Asia', 44579000, 29.5, 1024),
    ('Europe', 10180000, 6.8, 3357),
    ('North America', 24709000, 16.5, 864),
    ('Oceania', 8600000, '5.9', 130),
    ('South America', 17840000, '12.0', 206);

-- PARTE 2:

-- Ejercicio 1:
-- Devuelva una lista de los nombres y las regiones a las que 
-- pertenece cada país ordenada alfabéticamente.
   
SELECT Name, Region 
FROM country 
ORDER BY Name ASC;

-- Ejercicio 2:
-- Liste el nombre y la población de las 10 ciudades más pobladas del mundo.

SELECT Name, Population 
FROM city 
ORDER BY Population DESC 
LIMIT 10;

-- Ejercicio 3:
-- Liste el nombre, región, superficie y forma de gobierno de los 
-- 10 países con menor superficie.

SELECT Name, Region, SurfaceArea, GovernmentForm
FROM country
ORDER BY SurfaceArea ASC
LIMIT 10;

-- Ejercicio 4:
-- Liste todos los países que no tienen independencia.

SELECT Name
FROM country
WHERE IndepYear IS NULL; 

-- Ejercicio 5:
-- Liste el nombre y el porcentaje de hablantes que tienen todos los 
-- idiomas declarados oficiales.

SELECT Language, Percentage
FROM countrylanguage
WHERE IsOfficial = 'T';