/*
 * SQL project Engeto: primary final table - Alexandra Rehusova
 */

CREATE OR REPLACE TABLE t_ar_avg_prices AS
SELECT 
	YEAR(date_from) AS price_year,
	avg(value) AS avg_price,
	category_code
FROM czechia_price cpr 
GROUP BY price_year, category_code;		


CREATE OR REPLACE VIEW v_ar_prices_comparison AS
SELECT 
	ap.price_year AS `year`,
	round(ap.avg_price, 2) AS avg_price,
	cpc.name AS category,
	round((ap.avg_price - lag(ap.avg_price) OVER (PARTITION BY ap.category_code ORDER BY ap.price_year)) / lag(ap.avg_price) OVER (PARTITION BY ap.category_code ORDER BY ap.price_year) * 100, 2) AS pct_change_price
FROM t_ar_avg_prices ap
JOIN czechia_price_category cpc 
	ON ap.category_code = cpc.code
ORDER BY ap.price_year, category
;


CREATE OR REPLACE VIEW v_ar_salaries_comparison AS
WITH avg_salaries AS (
	SELECT
		payroll_year, 
		avg(value) AS avg_salary,
		industry_branch_code
	FROM czechia_payroll cp 
	WHERE cp.value_type_code = 5958 -- average gross salary 
		AND cp.calculation_code = 200 -- FTE (full-time equivalent)
	GROUP BY payroll_year, industry_branch_code
)
SELECT
	asa.payroll_year,
	round(asa.avg_salary, 2) AS avg_salary,
	cpib.name AS industry,
	round((asa.avg_salary - lag(asa.avg_salary) OVER (PARTITION BY asa.industry_branch_code ORDER BY asa.payroll_year)) / lag(asa.avg_salary) OVER (PARTITION BY asa.industry_branch_code ORDER BY asa.payroll_year) * 100, 2) AS pct_change_salary
FROM avg_salaries asa
LEFT JOIN czechia_payroll_industry_branch cpib
	ON asa.industry_branch_code = cpib.code 
ORDER BY asa.payroll_year, industry
;

CREATE OR REPLACE TABLE t_alexandra_rehusova_project_SQL_primary_final AS
SELECT 
	pc.*,
	sc.avg_salary,
	sc.industry,
	sc.pct_change_salary
FROM v_ar_prices_comparison pc
JOIN v_ar_salaries_comparison sc 
	ON pc.year = sc.payroll_year 
ORDER BY year, category, industry
; 

SELECT 
	* 
FROM t_alexandra_rehusova_project_sql_primary_final
;