/*
 * SQL project Engeto: question 5 - Alexandra Rehusova
 */

--  Otázka 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

CREATE OR REPLACE VIEW v_ar_gdp_comparison AS
SELECT
	`year`,
	GDP,
	round((GDP - lag(GDP) OVER (ORDER BY `year`)) / lag(GDP) OVER (ORDER BY `year`) * 100, 2) AS pct_change_gdp
FROM t_alexandra_rehusova_project_sql_secondary_final sf
WHERE country = 'Czech Republic' 
;


CREATE OR REPLACE VIEW v_ar_prices_comparison_aggreg AS
SELECT
	`year`,
	round(avg(pct_change_price), 2) AS pct_change_price
FROM v_ar_prices_comparison pc
GROUP BY `year`;


CREATE OR REPLACE VIEW v_ar_salaries_comparison_aggreg AS
SELECT
	payroll_year,
	round(avg(pct_change_salary), 2) AS pct_change_salary
FROM v_ar_salaries_comparison sc
GROUP BY payroll_year
;


CREATE OR REPLACE TABLE t_ar_changes_same_yr AS
SELECT 
	pca.`year`,
	pca.pct_change_price AS pct_change_price_yr0,
	sca.pct_change_salary AS pct_change_salary_yr0,
	gc.pct_change_gdp AS pct_change_gdp_yr0 
FROM v_ar_prices_comparison_aggreg pca
JOIN v_ar_salaries_comparison_aggreg sca
	ON pca.`year` = sca.payroll_year
		AND pca.`year` BETWEEN 2007 AND 2018
JOIN v_ar_gdp_comparison gc
	ON pca.`year` = gc.`year` 
;



CREATE OR REPLACE TABLE t_ar_changes_next_yr AS
SELECT 
	gc.`year`,
	pca.pct_change_price AS pct_change_price_yr1,
	sca.pct_change_salary AS pct_change_salary_yr1,
	gc.pct_change_gdp AS pct_change_gdp_yr0
FROM v_ar_prices_comparison_aggreg pca
JOIN v_ar_salaries_comparison_aggreg sca
	ON pca.`year` = sca.payroll_year		
JOIN v_ar_gdp_comparison gc
	ON pca.`year` - 1 = gc.`year`
		AND gc.`year` BETWEEN 2007 AND 2018
;


-- Regression GDP/price changes within same year:
	
	
CREATE OR REPLACE VIEW v_ar_regress_prices_same_yr AS
SELECT 
	count(1) AS n,
	avg(pct_change_gdp_yr0) AS x_mean,
	sum(pct_change_gdp_yr0) AS x_sum,
	sum(pct_change_gdp_yr0 * pct_change_gdp_yr0) AS xx_sum,
	avg(pct_change_price_yr0) AS y_mean,
	sum(pct_change_price_yr0) AS y_sum,
	sum(pct_change_price_yr0 * pct_change_price_yr0) AS yy_sum,
	sum(pct_change_gdp_yr0 * pct_change_price_yr0) AS xy_sum
FROM t_ar_changes_same_yr csy; 


CREATE OR REPLACE VIEW v_ar_correl_prices_same_yr AS
SELECT 
	'same year' AS effect,
	'GDP/price' AS coefficient,
	(n * xy_sum - x_sum * y_sum) / SQRT((n * xx_sum - x_sum * x_sum) * (n * yy_sum - Y_sum * Y_sum)) AS value,
	power((n * xy_sum - x_sum * y_sum) / SQRT((n * xx_sum - x_sum * x_sum) * (n * yy_sum - Y_sum * Y_sum)), 2) AS value_squared
FROM v_ar_regress_prices_same_yr;

 
-- Regression GDP/price changes following year:

CREATE OR REPLACE VIEW v_ar_regress_prices_next_yr AS
SELECT 
	count(1) AS n,
	avg(pct_change_gdp_yr0) AS x_mean,
	sum(pct_change_gdp_yr0) AS x_sum,
	sum(pct_change_gdp_yr0 * pct_change_gdp_yr0) AS xx_sum,
	avg(pct_change_price_yr1) AS y_mean,
	sum(pct_change_price_yr1) AS y_sum,
	sum(pct_change_price_yr1 * pct_change_price_yr1) AS yy_sum,
	sum(pct_change_gdp_yr0 * pct_change_price_yr1) AS xy_sum
FROM t_ar_changes_next_yr csy; 


CREATE OR REPLACE VIEW v_ar_correl_prices_next_yr AS
SELECT 
	'next year' AS effect,
	'GDP/price' AS coefficient,
	(n * xy_sum - x_sum * y_sum) / SQRT((n * xx_sum - x_sum * x_sum) * (n * yy_sum - Y_sum * Y_sum)) AS value,
	power((n * xy_sum - x_sum * y_sum) / SQRT((n * xx_sum - x_sum * x_sum) * (n * yy_sum - Y_sum * Y_sum)), 2) AS value_squared
FROM v_ar_regress_prices_next_yr;



-- Regression GDP/salaries changes within same year:
	
	
CREATE OR REPLACE VIEW v_ar_regress_salaries_same_yr AS
SELECT 
	count(pct_change_salary_yr0) AS n,
	avg(pct_change_gdp_yr0) AS x_mean,
	sum(pct_change_gdp_yr0) AS x_sum,
	sum(pct_change_gdp_yr0 * pct_change_gdp_yr0) AS xx_sum,
	avg(pct_change_salary_yr0) AS y_mean,
	sum(pct_change_salary_yr0) AS y_sum,
	sum(pct_change_salary_yr0 * pct_change_salary_yr0) AS yy_sum,
	sum(pct_change_gdp_yr0 * pct_change_salary_yr0) AS xy_sum
FROM t_ar_changes_same_yr csy; 


CREATE OR REPLACE VIEW v_ar_correl_salaries_same_yr AS
SELECT 
	'same year' AS effect,
	'GDP/salary' AS coefficient,
	(n * xy_sum - x_sum * y_sum) / SQRT((n * xx_sum - x_sum * x_sum) * (n * yy_sum - Y_sum * Y_sum)) AS value,
	power((n * xy_sum - x_sum * y_sum) / SQRT((n * xx_sum - x_sum * x_sum) * (n * yy_sum - Y_sum * Y_sum)), 2) AS value_squared
FROM v_ar_regress_salaries_same_yr;


-- Regression GDP/salaries changes within same year:

CREATE OR REPLACE VIEW v_ar_regress_salaries_next_yr AS
SELECT 
	count(pct_change_salary_yr1) AS n,
	avg(pct_change_gdp_yr0) AS x_mean,
	sum(pct_change_gdp_yr0) AS x_sum,
	sum(pct_change_gdp_yr0 * pct_change_gdp_yr0) AS xx_sum,
	avg(pct_change_salary_yr1) AS y_mean,
	sum(pct_change_salary_yr1) AS y_sum,
	sum(pct_change_salary_yr1 * pct_change_salary_yr1) AS yy_sum,
	sum(pct_change_gdp_yr0 * pct_change_salary_yr1) AS xy_sum
FROM t_ar_changes_next_yr csy; 


CREATE OR REPLACE VIEW v_ar_correl_salaries_next_yr AS
SELECT 
	'next year' AS effect,
	'GDP/salary' AS coefficient,
	(n * xy_sum - x_sum * y_sum) / SQRT((n * xx_sum - x_sum * x_sum) * (n * yy_sum - Y_sum * Y_sum)) AS value,
	power((n * xy_sum - x_sum * y_sum) / SQRT((n * xx_sum - x_sum * x_sum) * (n * yy_sum - Y_sum * Y_sum)), 2) AS value_squared
FROM v_ar_regress_salaries_next_yr;

-- Result:

SELECT *
FROM v_ar_correl_prices_same_yr cpsy 
UNION ALL
SELECT *
FROM v_ar_correl_prices_next_yr cpny
UNION ALL
SELECT *
FROM v_ar_correl_salaries_same_yr cssy
UNION ALL
SELECT *
FROM v_ar_correl_salaries_next_yr csny;