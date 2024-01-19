# engeto_sql_project_2024

SQL analýza dostupnosti potravin na základě průměrných příjmů za určité časové období
Projekt pro účely certifikace v Datové akademii Engeto

# Struktura projektu

- Dokumentace
- SQL soubory obsahující tabulky (alexandra_rehusova_primary_final.sql, alexandra_rehusova_secondary_final.sql)
- SQL soubory s odpovědi na výzkumné otázky (alexandra_rehusova_question_1.sql, alexandra_rehusova_question_2.sql, alexandra_rehusova_question_3.sql, alexandra_rehusova_question_4.sql, alexandra_rehusova_question_5.sql)
- Nejdříve je potřeba spustit skript alexandra_rehusova_primary_final.sql, následně alexandra_rehusova_secondary_final.sql a posléze skripty s odpovědi na otázky v sekvenčním pořadí

# Zadání

Na vašem analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jste se dohodli, že se pokusíte odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.

Potřebují k tomu od vás připravit robustní datové podklady, ve kterých bude možné vidět porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období.

Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.

Výstupem by měly být dvě tabulky v databázi, ze kterých se požadovaná data dají získat. Tabulky pojmenujte t_{jmeno}_{prijmeni}_project_SQL_primary_final (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky) a t_{jmeno}_{prijmeni}_project_SQL_secondary_final (pro dodatečná data o dalších evropských státech).

Dále připravte sadu SQL, které z vámi připravených tabulek získají datový podklad k odpovězení na vytyčené výzkumné otázky.

# Informace o práci na projektu

Zdrojová tabulka czechia_payroll obsahovala několik řádků za daný kvartál roku. V sloupci value byl k nalezení jednak průměrný hrubý měsíční příjem (samostatný řádek pro průměrný příjem vypočtenou na základě fyzického počtu zaměstnanců a další řádek na základě přepočteného počtu zaměstnanců) a  a jednak průměrný počet zaměstnanců. Řešením bylo aplikovat filtry value_type_code = 5958 (průměrný hrubý měsíční příjem) a calculation_code = 200 (přepočtený počet zaměstnanců, FTE aneb full-time equivalent). Hodnoty průměrného příjmu dle přepočteného počtu zaměstnanců jsou k analýze dostupnosti potravin vhodnější než hodnoty dle fyzického počtu, protože zohledňují různé typy pracovních úvazků (0.5 FTE, 0.8 FTE atd.).

Dalším problémem byly NULL hodnoty v tabulce czechia_payroll v sloupci industry_branch_code. Znamená to, že u některých záznamů nebyl vyplněn kód hospodářského odvětví, což jsem vyřešila pomocí WHERE industry_branch_code IS NOT NULL v otázkách 1 a 2, které byly zaměřeny na jednotlivá odvětví. 

Zdrojová tabulka czechia_price obsahovala sloupce Date_from a Date_to a tudíž jsem se ujistila, že rok je v oboch sloupcích vždy stejný pomocí kombinace funkcí MIN a YEAR (validace ve finálním skriptu k tabulce primary není zmíněna).

Date_from hodnoty v tabulce czechia_price bylo třeba převést na rok pomocí funkce YEAR. Použití funkce YEAR a následné agregace a propočty výrazně zpomalily vytvoření tabulky primary_final. Po různých pokusech optimalizovat výkon jsem se rozhodla vytvořit místo původně zamýšleného view v_ar_avg_prices tabulku t_ar_avg_prices, což výrazně zrychlilo vykonání příkazu. V případě, že budou do tabulky czechia_price přidány nové záznamy, bude nutné tabulku t_ar_avg_prices (ideálne automaticky) aktualizovat. Také použití WITH a odstranění nepotřebných sloupců pomohlo dotaz zrychlit.

Tabulka czechia_payroll obsahovala data za roky 2000-2021, tabulka czechia_price za období 2006-2018 a tabulka economies za 1960-2020. Tudíž srovnatelné období bylo 2006-2018. Z toho důvodu jsem při sestavování tabulky primary_final spojila view v_ar_prices_comparison s view v_ar_salaries_comparison pomocí INNER JOIN, abych nemusela odfiltrovat data mimo roky 2006-2018.

V otázce 5 jsem vypočetla korelační koeficienty a koeficienty determinace a SELECT na sumarizaci výsledků trval příliš dlouho (obsahoval několik JOINů a výpočet koeficientu determinace r^2. Pro zrychlení jsem se rozhodla vytvořit tabulky t_ar_changes_same_yr (obsahující % meziroční změny HDP, cen a mezd ve stejném roce) a t_ar_changes_next_yr (obsahující % meziroční změny HDP v daném roce a % meziroční změny cen a příjmů v následujícím roce). Taky jsem k zobrazení výsledných koeficientů použila UNION ALL místo JOIN. Časové období pro analýzu byly roky 2007-2018 v otázce 5, poněvadž % změny cen za rok 2006 neexistovaly.

# Popis dat

## Tabulka primary_final

- year integer(4)
- avg_price double (2 desetinné místa)
- category varchar(50) 
- pct_change_price double (2 desetinné místa)
- avg_salary decimal (2 desetinné místa)
- industry varchar(255)
- pct_change_salary decimal (2 desetinné místa)

## Tabulka secondary_final

- year integer(11)
- country text
- GDP double (0 desetinných míst)
- gini double (1 desetinné místo)
- taxes double (1 desetinné místo)
- population double (0 desetinných míst)

# Odpovědi na otázky

## Otázka 1 - Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? 

Ano, mzdy poklesly během let v několika odvětvích (sloupec pct_change_salary má negativní hodnotu) celkem 24 krát. Těžba figurovala na seznamu odvětví, které zaznamenaly meziroční pokles mezd nejčastěji, následována energetikou. V roce 2013 klesly mzdy v 11 odvětvích (sloupec industry_declined), v roce 2009 ve 4, v 2010 ve 3 v 2011 taky ve 3. Největší poklesy (top 5) zaznamenaly peněžnictví a pojišťovnictví, dále výroba a rozvod energií, těžba a vzdělávání, technologie a věda. 

View v_ar_salaries_trend je přehledem odvětví (sloupec industry), percentuální změny mezd (pct_change_salary) a trendu (sloupec salary_trend, increase reprezentuje meziroční % nárůst mezd a decrease pokles) v jednotlivých letech (year). Následující SELECT ukazuje seznam odvětví (industry), které zaznamenaly pokles a jak velký byl (pct_change_salary). Další SELECT ukazuje počet odvětví (industries_declined), ve kterých mzdy poklesly v jednotlivých letech. Poslední SELECT ukazuje top 5 poklesů mezd (pct_change_salary) za dané odvětví (industry).

## Otázka 2 - Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

Výsledky jsou vidět v SELECTU, sloupci affordable_units (počet litrů mléka nebo kilogramů chleba, které je možné si koupit). Sloupec category ukazuje, zda-li se jedná o mléko nebo chléb a výsledky jsou rozděleny dle odvětví (industry) a roku.

## Otázka 3 - Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

Výsledek ukazuje celkové % změny cen (pct_change_price) potravin. Potraviny jsou vyjmenovány v sloupci category. Krystalový cukr zdražuje nejpomaleji (negativní průměrná % změna cen potravin).

## Otázka 4 - Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

Ne, neexistuje. Odpověď je patrná v sloupci diff_higher_10_percent, kde vidíme ne (no) pro kazdý rok ve sledovaném období.

## Otázka 5 -  Otazka 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

Odpověd je ano. Výsledek lze vyčíst z tabulky t_ar_changes_same_yr, kde vidíme percentuální změny cen, mezd a HDP v jednotlivých letech. Pomocí jednofaktorové (každé Y zvlášť) lineární regrese medzi HDP (nezávislá proměnná X) a cenami potravin (závislá proměnná Y) a mzdami (závislá proměnná Y) byly vypočtené hodnoty korelačního koeficientu r (value) a je koeficient determinace r^2 (value-squared). Z dat plyne silnější vliv HDP na zmeny mezd (vyšší korelační koeficienty než u cen potravin), přičemž výslední efekt je výraznější v následujícím roce (next year). Nutno podotknout, ze koeficient determinace je docela nízký, což znamená, že modely nejsou velmi věrohodné. K nižší věrohodnosti přispívá skutečnost, že na změny cen a mezd má vliv velké množství faktorů (produktivita práce, inflace, nabídka, poptávka atd).Vhodnější by byla multifaktorová regrese pomocí jazyka R nebo Pythonu, případne statistických programů (Minitab apod.). 

Tabulka t_ar_changes_same_yr je přehledem % změn cen potravin (pct_change_price_yr0), mezd (pct_change_salary_yr0) a HDP (pct_change_gdp_yr0). Yr0 znamená, že se jedná o % změny zaznamenané ve stejném roce. Tabulka t_ar_changes_next_yr ukazuje % změn cen potravin (pct_change_price_yr1), mezd (pct_change_salary_yr1) a HDP (pct_change_gdp_yr0). Změny HDP jsou ve sledovaném roce (yr0) a změny cen a mezd v následujícím roku (yr1).

Zavěrečný SELECT je sumarizací korelačních (value = r) a determinačních koeficientů (value-squared = r^2). Sloupec effect obsahuje informaci, zda-li se jedná o vliv HDP v daném roce (same year) nebo v roce následujícím (next year). Sloupec coefficient ukazuje, k čemu se vážou koeficienty. Buďto k vztahu HDP a cen potravin (GDP price) nebo HDP a příjmů (GDP salary). 
