/*
Covid Data Exploration
--- Skill used: Joins, CTE, Temp Table, Windows Functions, Aggregate Functions, Creating View, Converting Data Types
*/

--- Total cases vs Total Deaths
--- Shows likelihood of dying if you contract covid

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--- CONTINENTS

--- Showing continents with the highest number of COVID cases
SELECT continent, MAX(total_cases) as TotalCases
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalCases DESC

--- Showing continents with the highest death count
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

---COUNTRIES

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
ORDER BY 1,2

--- Total cases vs Total deaths
--- Showing the likelihood of dying if you contract covid in each country
SELECT location, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--- Showing countries with Highest Infection Count
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_deaths/total_cases))*100 AS HighestInfectionPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestInfectionCount DESC

--- Countries with Highest Death Count
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location,date,population, new_vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

---Create view

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
