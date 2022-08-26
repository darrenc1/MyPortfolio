USE Portfolio_1_Covid;

# Testing
SELECT
	*
FROM
	covid_vaccinations;
    
SELECT
	*
FROM
	covid_deaths;
    
SELECT
	location, date, total_cases, new_cases, total_deaths, population
FROM
	covid_deaths;

# Convert Date from TEXT to DATE
ALTER TABLE Portfolio_1_Covid.covid_deaths
CHANGE COLUMN date date DATE NULL DEFAULT NULL;

# Total Cases vs Total Deaths or Mortality Analysis -> (TD / TC) * 100%
SELECT
	location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS mortality_rate
FROM
	covid_deaths
WHERE
	location LIKE '%states'
ORDER BY
	date DESC; # Low percentage, but high volume of lives lost to COVID

# Infected rate 
SELECT
	location, date, total_cases, population, (total_cases / population) * 100 AS pop_contracted
FROM
	covid_deaths
WHERE
	location LIKE '%States'; # 26.82% of population has contracted COVID since 2022-23-07

# Cases as of 2022-23-07 for each country, ordered by highest infection rate
SELECT
	location, population, MAX(total_cases) AS highest_infection, MAX((total_cases / population) * 100) AS max_percentage
FROM
	covid_deaths
GROUP BY
	location, population
ORDER BY
	max_percentage DESC;

# Quite a low number, but unsurprising given China's strict 'Zero Covid' lockdown policy
SELECT
	location, population, MAX(total_cases) AS highest_infection, MAX((total_cases / population) * 100) AS max_percentage
FROM
	covid_deaths
GROUP BY
	location, population
HAVING location = 'China';

# Substantially higher than China; however, they are not enforcing the 'Zero Covid' policy
SELECT
	location, population, MAX(total_cases) AS highest_infection, MAX((total_cases / population) * 100) AS max_percentage
FROM
	covid_deaths
GROUP BY
	location, population
HAVING location = 'Taiwan';

# Death cases as of 2022-23-07 for each country, ordered by highest death rate
SELECT
	location, MAX(CAST(total_deaths AS UNSIGNED)) AS total_death_count #total_deaths is VARCHAR so CONVERT TO INT/UNSIGNED BEFORE APPLYING AN AGGREGATE FUNCTION
FROM
	covid_deaths
WHERE
	continent <> ''
GROUP BY
	location
ORDER BY
	total_death_count DESC;
 
# Death cases as of 2022-23-07 for each continent
SELECT
	continent, SUM(new_deaths) AS total_deaths
FROM
	covid_deaths
WHERE
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	total_deaths DESC;
   
# New data each day
SELECT
	date, 
    SUM(new_cases) AS new_cases, 
    SUM(CAST(new_deaths AS UNSIGNED)) AS new_deaths, 
    SUM(CAST(new_deaths AS UNSIGNED))/ SUM(new_cases) * 100 AS mortality_rate
FROM
	covid_deaths
WHERE
	continent IS NOT NULL
GROUP BY
	date
ORDER BY
	date DESC;
    
# Join covid_deaths and covid_vaccinations to compare vaccinations against total population
SELECT
	d.continent, d.location, d.date, population, v.new_vaccinations
FROM
	covid_deaths d
JOIN
	covid_vaccinations v ON d.location = v.location AND d.date = v.date
WHERE
	d.continent IS NOT NULL
ORDER BY
	d.location, date DESC;
    
# Join covid_deaths and covid_vaccinations to compare vaccinations against total population for China, Taiwan, & United States
SELECT
	d.continent, d.location, d.date, population, v.new_vaccinations
FROM
	covid_deaths d
JOIN
	covid_vaccinations v ON d.location = v.location AND d.date = v.date
WHERE
	d.location LIKE 'China' OR 
    d.location LIKE 'Taiwan' OR 
    d.location LIKE 'United States'
ORDER BY
	d.location, date DESC;

# Rolling statistic using Windows function
SELECT
	d.continent, d.location, d.date, population, v.new_vaccinations, 
    SUM(CAST(new_vaccinations AS UNSIGNED)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_total
FROM
	covid_deaths d
JOIN
	covid_vaccinations v ON d.location = v.location AND d.date = v.date
WHERE
	d.continent IS NOT NULL
ORDER BY
	d.location, date ASC;

# For China, Taiwan, & United States
SELECT
	d.continent, d.location, d.date, population, v.new_vaccinations, 
    SUM(CAST(new_vaccinations AS UNSIGNED)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_total
FROM
	covid_deaths d
JOIN
	covid_vaccinations v ON d.location = v.location AND d.date = v.date
WHERE
	d.location LIKE 'China' OR 
    d.location LIKE 'Taiwan' OR 
    d.location LIKE 'United States'
ORDER BY
	d.location, date ASC;
    
# CTE to validate new column, rolling_total
WITH pop_vac (continent, location, date, population, pop_doubled, new_vaccinations, rolling_total)
AS (SELECT
	d.continent, d.location, d.date, population, population * 2 AS pop_doubled, v.new_vaccinations, SUM(CAST(new_vaccinations AS UNSIGNED)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_total
FROM
	covid_deaths d
JOIN
	covid_vaccinations v ON d.location = v.location AND d.date = v.date
WHERE
	d.continent IS NOT NULL
)
SELECT
	*, (rolling_total / population) * 100 AS vac_rate 
FROM
	pop_vac
WHERE
	(rolling_total / population) * 100 < 100; # This assumes the country has given less doses than population

WITH pop_vac (continent, location, date, population, new_vaccinations, rolling_total)
AS (SELECT
	d.continent, d.location, d.date, population, v.new_vaccinations, SUM(CAST(new_vaccinations AS UNSIGNED)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_total
FROM
	covid_deaths d
JOIN
	covid_vaccinations v ON d.location = v.location AND d.date = v.date
WHERE
	d.location LIKE 'China' OR 
    d.location LIKE 'Taiwan' OR 
    d.location LIKE 'United States'
)
SELECT
	*
FROM
	pop_vac; #Doses are greater than population, thus we can assume some people are either double vaccinated and possibly boosted
    
SELECT
	location, MAX(date) AS date, MAX(people_fully_vaccinated) AS total
FROM
	covid_vaccinations
GROUP BY
	location;
    
SELECT
	location, MAX(people_fully_vaccinated) AS recent
FROM
	covid_vaccinations
GROUP BY
	location;
    





