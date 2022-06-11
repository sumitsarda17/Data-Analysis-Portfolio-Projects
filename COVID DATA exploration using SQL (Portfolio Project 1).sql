SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


/* SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4 */

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Looking at total cases vs total Deaths
-- shows the likelehood of dying if you contract covid in India
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2;

-- Looking at Total Cases Vs Population
-- shows what percentage of population got covid
SELECT location, date, Population,total_cases, (total_cases/population)*100 AS InfectedPrecentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2;


-- which country has the highest infection rate compared to population
SELECT location, Population, MAX(total_cases) AS HighestCase, MAX((total_cases/population))*100 AS InfectedPrecentage
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'India'
GROUP BY location, population
ORDER BY 4 desc;

-- showing the countries with the highest death count per population
-- here we are changing the datatype of total_deaths column which is varchar
-- so that it'll give us the right result of MAX function

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL	
GROUP BY location
ORDER BY TotalDeathCount desc;

/* here there is an issue we are not getting exact location it's grouping the continents like 
World or africa or south america let's go back in out data and explore

we got to know that for some record Location is Asia and continent is NUll and then for some record Continent is ASia
so it's confused between Location and Continent whici leads to wrong result*/

-- Let's break things down by continent

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL	
GROUP BY continent
ORDER BY TotalDeathCount desc;


-- Global Numbers Across the world
-- this will give us the total number of cases in entire world 

SELECT  date, SUM(new_cases) as TotalCase, SUM(cast(new_deaths as int)) as TotalDeath,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Deathrate

FROM PortfolioProject..CovidDeaths

WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- overall across the world death rate till now

SELECT  SUM(new_cases) as TotalCase, SUM(cast(new_deaths as int)) as TotalDeath,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Deathrate

FROM PortfolioProject..CovidDeaths

WHERE continent IS NOT NULL
ORDER BY 1,2;


-- looking at total population vs vaccinations
/* first let's add the no of vaccines for each day means suppose on 
day 1 there is 4 vaccines happesn then Total will be 4 then on Day 2 
vaccine count was 5 so tala vaccination happens till day2 will be 4 +5 = 9

so that we can get the record of particular date let's suppuse till 20th March 2020
how many total vaccinations happend in india we can achiveve this by 
using Partition By function */

SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY
 dea.location, dea.date) AS RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

/* now we have to find total population vs vaccination  but we cant
use RollingPeopleVaccinated column that we just creted to calculate precentage
 so what we need to do we need to create either CTE or TEMPTABLE */

 -- use CTE 

 WITH PopvsVac (continent, location, date, population ,new_vaccinations, RollingPeopleVaccinated)
 AS
 (
SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY
 dea.location, dea.date) AS RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- CREATING VIEW to store data for later visualizations



CREATE VIEW 
VaccinationRatePerPopulation AS
SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY
 dea.location, dea.date) AS RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT * 
FROM VaccinationRatePerPopulation