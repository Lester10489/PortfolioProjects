
SELECT * 
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying if you contract covid in Singapore
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%singapore%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Percentage of population that got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%singapore%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing Continent with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global numbers
SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2


-- Looking at Total Population vs Vaccination
-- Partition By
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ AS Dea
JOIN PortfolioProject..CovidVaccinations$ AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2, 3

-- Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS 
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ AS Dea
JOIN PortfolioProject..CovidVaccinations$ AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentVaccinated
From PopvsVac


-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ AS Dea
JOIN PortfolioProject..CovidVaccinations$ AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingVaccinationRate
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ AS Dea
JOIN PortfolioProject..CovidVaccinations$ AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date


