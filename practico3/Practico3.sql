USE world;

-- Ejercicio 1:
-- Lista el nombre de la ciudad, nombre del país, región y 
-- forma de gobierno de las 10 ciudades más pobladas del mundo.

SELECT 	ci.Name as CityName, co.Name as CountryName, co.Region, co.GovernmentForm, ci.Population 
FROM city ci
INNER JOIN country co
ON ci.CountryCode = co.Code 
ORDER BY ci.Population DESC 
LIMIT 10;

 
-- Ejercicio 2:
-- Listar los 10 países con menor población del mundo, junto a sus ciudades capitales.

SELECT co.Name as CountryName, ci.Name as CapitalName, co.Population 
FROM country co
LEFT JOIN city ci
ON co.Capital = ci.ID 
ORDER BY co.Population ASC
LIMIT 10;

-- Ejercicio 3:
-- Listar el nombre, continente y todos los lenguajes oficiales de cada país.

SELECT co.Name, co.Continent, lang.Language
FROM country co
INNER JOIN countrylanguage lang
ON lang.CountryCode = co.Code
WHERE lang.IsOfficial ='T'
ORDER BY lang.Language DESC;

-- Ejercicio 4:
-- Listar el nombre del país y nombre de capital, de los 20 países con mayor superficie del mundo.

SELECT co.Name as CountryName, ci.Name as CityName, co.Population
FROM country co
LEFT JOIN city ci
ON ci.ID = co.Capital
ORDER BY co.SurfaceArea DESC 
LIMIT 20;

-- Ejercicio 5:
-- Listar las ciudades junto a sus idiomas oficiales 
-- (ordenado por la población de la ciudad) y el porcentaje de hablantes del idioma.

SELECT ci.Name as CityName, lang.`Language` as CityLanguage, lang.Percentage
FROM city ci
INNER JOIN countrylanguage lang
ON lang.CountryCode = ci.CountryCode 
WHERE lang.IsOfficial = 'T'
ORDER BY ci.Population DESC ;

-- Ejercicio 6:
-- Listar los 10 países con mayor población y los 10 países con menor población 
-- (que tengan al menos 100 habitantes) en la misma consulta.

(
SELECT Name as CountryName, Population
FROM country
WHERE Population >= 100
ORDER BY Population DESC
LIMIT 10
)
UNION ALL
(
SELECT Name as CountryName, Population
FROM country
WHERE Population >= 100
ORDER BY Population ASC 
LIMIT 10
);

-- Ejercicio 7:
-- Listar aquellos países cuyos lenguajes oficiales son el Inglés y el Francés.

(
SELECT c1.Name
FROM country c1
INNER JOIN countrylanguage c2
ON c1.Code = c2.CountryCode
WHERE c2.Language = 'French' AND c2.IsOfficial ='T'
)
INTERSECT ALL
(
SELECT c1.Name
FROM country c1
INNER JOIN countrylanguage c2
ON c1.Code = c2.CountryCode
WHERE c2.Language = 'English' AND c2.IsOfficial ='T'
);

-- Ejercicio 8:
-- Listar aquellos países que tengan hablantes del Inglés pero no del Español en su población.

(
SELECT co.Name
FROM country co
INNER JOIN countrylanguage lang
ON lang.CountryCode = co.Code 
WHERE lang.`Language` IN ('English')
)
EXCEPT ALL 
(
SELECT co.Name
FROM country co
INNER JOIN countrylanguage lang
ON lang.CountryCode = co.Code 
WHERE lang.`Language` IN ('Spanish')
);

