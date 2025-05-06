USE world;

-- Ejercicio 1:
-- Listar el nombre de la ciudad y el nombre del país de todas las ciudades 
-- que pertenezcan a países con una población menor a 10000 habitantes.

SELECT c1.Name AS CityName, c2.Name AS CountryName
FROM city c1
JOIN country c2 ON c1.CountryCode = c2.Code
WHERE c2.Population IN (SELECT Population FROM country WHERE Population < 10000);

-- Ejercicio 2:
-- Listar todas aquellas ciudades cuya población sea mayor que la población 
-- promedio entre todas las ciudades.

SELECT Name, Population
FROM city
WHERE Population > (SELECT AVG(Population) FROM city);

-- Ejercicio 3: Forma 1
-- Listar todas aquellas ciudades no asiáticas cuya población sea igual o 
-- mayor a la población total de algún país de Asia.

SELECT c1.Name
FROM city c1
WHERE c1.CountryCode NOT IN (
	SELECT c2.Code
	FROM country c2
	WHERE c2.Continent = 'Asia' 
)
AND c1.Population >= SOME (
	SELECT Population 
	FROM country
	WHERE Continent = 'Asia'
);

-- Ejercicio 3: Forma 2
SELECT c1.Name
FROM city c1
INNER JOIN country c2
ON c1.CountryCode = c2.Code 
WHERE c2.Continent != 'Asia'
AND c1.Population >= SOME (
	SELECT Population 
	FROM country
	WHERE Continent = 'Asia'
)

-- Ejercicio 4:
-- Listar aquellos países junto a sus idiomas no oficiales, que superen en 
-- porcentaje de hablantes a cada uno de los idiomas oficiales del país.

SELECT c1.Name, c2.Language 
FROM country c1
LEFT JOIN countrylanguage c2
ON c1.Code = c2.CountryCode
WHERE c2.IsOfficial = 'F'
AND c2.Percentage > ALL (
	SELECT Percentage
	FROM countrylanguage c3
	WHERE c3.CountryCode = c1.Code 
	AND c3.IsOfficial = 'T'
);

-- Ejercicio 5: Sin subquery
-- Listar (sin duplicados) aquellas regiones que tengan países con una superficie menor 
-- a 1000 km2 y exista (en el país) al menos una ciudad con más de 100000 habitantes.  

SELECT c1.Region
FROM country c1
INNER JOIN city c2
ON c1.Code = c2.CountryCode
WHERE c2.Population > 100000
AND c1.SurfaceArea < 1000
GROUP BY c1.Region;

-- Ejercicio 5: Con subquery
SELECT c1.Region
FROM country c1
WHERE c1.SurfaceArea < 1000
AND c1.Code IN (
	SELECT c2.CountryCode
	FROM city c2
	WHERE c2.Population > 100000
)
GROUP BY c1.Region;

-- Ejercicio 6: Con subquery
-- Listar el nombre de cada país con la cantidad de habitantes de su ciudad más poblada.

SELECT c1.Name as Country,
	(SELECT MAX(c2.Population)
	FROM city c2
	WHERE c2.CountryCode = c1.Code) AS Population 
FROM country c1;

-- Ejercicio 6: Con agrupaciones

SELECT c1.Name as Country, MAX(c2.Population)
FROM country c1
INNER JOIN city c2
ON c1.Code = c2.CountryCode
GROUP BY c1.Name;

-- Ejercicio 7:
-- Listar aquellos países y sus lenguajes no oficiales cuyo porcentaje de 
-- hablantes sea mayor al promedio de hablantes de los lenguajes oficiales.

SELECT c1.Name, c2.Language 
FROM country c1
INNER JOIN countrylanguage c2
ON c1.Code = c2.CountryCode
WHERE c2.IsOfficial = 'F'
AND c2.Percentage > (
	SELECT AVG(c3.Percentage) 
	FROM countrylanguage c3
	WHERE c3.CountryCode = c1.Code
	AND c3.IsOfficial = 'T'
);

-- Ejercicio 8:
-- Listar la cantidad de habitantes por continente ordenado en forma descendente.
SELECT Continent, SUM(Population) AS TotalPopulation
FROM country c 
GROUP BY Continent
ORDER BY TotalPopulation DESC;

-- Ejercicio 9:
-- Listar el promedio de esperanza de vida (LifeExpectancy) por 
-- continente con una esperanza de vida entre 40 y 70 años.
SELECT Continent, AVG(LifeExpectancy) AS LifeExpectancyAVG
FROM country
WHERE LifeExpectancy BETWEEN 40 AND 70
GROUP BY Continent

-- Ejercicio 10:
-- Listar la cantidad máxima, mínima, promedio y suma de habitantes por continente.
SELECT Continent, MAX(Population), MIN(Population), AVG(Population), SUM(Population) 
FROM country
GROUP BY Continent


















