/*
 * SQL project Engeto: question 2 - Alexandra Rehusova
 */

-- Otázka 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

SELECT
	`year`,
	category,
	industry,
	ROUND(avg_salary / avg_price) AS affordable_units
FROM t_alexandra_rehusova_project_sql_primary_final pf
WHERE `year`  IN (2006, 2018)
	AND industry IS NOT NULL
	AND category IN (
		SELECT category 
		FROM t_alexandra_rehusova_project_sql_primary_final pf 
		WHERE category LIKE '%Mléko%' OR category LIKE '%Chléb%')
ORDER BY industry, category, `year`
;