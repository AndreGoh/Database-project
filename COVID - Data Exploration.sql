
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4


-- Select Data That we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY location, date

-- Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Australia%'
ORDER BY location, date


-- Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS infection_rate
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Australia%'
ORDER BY location, date

-- Countries with the highest infection rate relative to their population.

SELECT location, population, MAX(total_cases) AS peak_infection_count, MAX((total_cases/population))*100 AS infection_rate
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location like '%Australia%'
GROUP BY location, population
ORDER BY infection_rate DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths AS INT)) AS total_death_count
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location
ORDER BY total_death_count DESC

-- Continents with the highest death count per population
SELECT continent, MAX(cast(Total_deaths AS INT)) AS total_death_count
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location like '%Australia%'
WHERE CONTINENT IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases), SUM(new_deaths) --,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%Australia%'
WHERE continent IS NOT NULL
--GROUP by date
ORDER BY location, date

-- Total population vs Vaccinations  
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY DEA.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
-- Total population vs Vaccinations  
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (pARTITION BY DEA.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE if exists ##PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (pARTITION BY DEA.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (pARTITION BY DEA.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3  

SELECT *
FROM PercentPopulationVaccinated
