/*
 * SQL project Engeto: question 3 - Alexandra Rehusova
 */

-- Otázka 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

SELECT
	category,
	ROUND(AVG(pct_change_price), 2) AS 'pct_change_price'
FROM v_ar_prices_comparison pc 
WHERE pct_change_price IS NOT NULL
GROUP BY category
ORDER BY pct_change_price
;