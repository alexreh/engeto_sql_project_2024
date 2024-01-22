/*
 * SQL project Engeto: question 4 - Alexandra Rehusova
 */

--  Otázka 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

SELECT
	`year`,
	ROUND(AVG(pct_change_price), 2) AS pct_change_prices,
	ROUND(AVG(pct_change_salary), 2) AS pct_change_salaries,
	CASE
		WHEN ABS(ROUND(AVG(pct_change_price), 2) - ROUND(AVG(pct_change_salary), 2)) > 10 THEN 'yes'
		ELSE 'no'
	END AS diff_higher_10_percent
FROM t_alexandra_rehusova_project_sql_primary_final pf
GROUP BY `year`
HAVING `year` BETWEEN 2007 AND 2018
;