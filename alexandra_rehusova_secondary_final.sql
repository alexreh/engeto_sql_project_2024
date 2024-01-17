/*
 * SQL project Engeto: secondary final table - Alexandra Rehusova
 */

CREATE OR REPLACE TABLE t_alexandra_rehusova_project_sql_secondary_final AS
SELECT 
	e.`year` ,
	c.country,
	round(e.GDP) AS GDP,
	e.gini,
	round(e.taxes, 1) AS taxes,
	e.population 
FROM countries c
JOIN economies e
	ON c.country = e.country
		AND e.`year` BETWEEN 2006 AND 2018
WHERE c.continent = 'Europe'
ORDER BY `year`, country
;

SELECT 
	*
FROM t_alexandra_rehusova_project_sql_secondary_final
;