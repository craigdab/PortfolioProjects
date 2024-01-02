SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

/* SELECT *
FROM CovidVaccinations
ORDER BY 3,4 */

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the possibility of dying if you contract Covid in your country.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Australia'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows the percentage of population who have contracted Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Australia'
ORDER BY 1,2

-- Looking at countries with highest infection rates compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing countries with the highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing the continents with the highest death count
-- correct data

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- use for visualisations

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers
-- my version

SELECT MAX(total_cases), MAX(total_deaths), (MAX(total_deaths)/MAX(total_cases))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'World'
ORDER BY 1,2

-- his version

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date)
    AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.[location] = vac.[location]
AND dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- use CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date)
    AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.[location] = vac.[location]
AND dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

-- TEMP TABLE

DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    continent NVARCHAR(255),
    Location NVARCHAR(255),
    DATE datetime,
    population NUMERIC,
    new_vaccination NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date)
    AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.[location] = vac.[location]
AND dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store later for visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date)
    AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.[location] = vac.[location]
AND dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
