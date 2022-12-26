--- Skill used: Joins, CTE, Temp Table, Windows Functions, Aggregate Functions, Creating View, Converting Data Types

--- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--- CONTINENTS

SELECT continent, MAX(total_cases) as TotalCases
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalCases DESC

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

---COUNTRIES

SELECT location, total_cases, total_deaths, (total_deaths/total_cases)*100 AS InfectionPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_deaths/total_cases))*100 AS HighestInfectionPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestInfectionCount DESC

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--- CTE 

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

--- TEMP TABLE
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
