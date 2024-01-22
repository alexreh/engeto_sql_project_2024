/*
 * SQL project Engeto: question 1 - Alexandra Rehusova
 */

-- Otázka 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

CREATE OR REPLACE VIEW v_ar_salaries_trend AS
SELECT 
	`year`,
	industry,
	pct_change_salary,
	CASE
		WHEN pct_change_salary > 0 THEN 'increase'
		WHEN pct_change_salary < 0 THEN 'decrease'
			ELSE 'no change'
	END AS salary_trend
FROM t_alexandra_rehusova_project_sql_primary_final pf
WHERE industry IS NOT NULL
GROUP BY `year`, industry
; 


SELECT
	industry,
	`year`,
	pct_change_salary
FROM v_ar_salaries_trend st 
WHERE salary_trend = 'decrease'
ORDER BY industry, `year`
;

SELECT 
	`year`,
	COUNT(1) AS industries_declined
FROM v_ar_salaries_trend st
WHERE salary_trend = 'decrease'
GROUP BY `year`
;

SELECT 
	`year`,
	industry,
	pct_change_salary 
FROM v_ar_salaries_trend st 
WHERE salary_trend = 'decrease'
ORDER BY pct_change_salary, `year` 
LIMIT 5
;