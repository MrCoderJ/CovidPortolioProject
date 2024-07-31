
-- Total Death vs Total cases

Select location, date, total_cases, total_deaths, CONVERT(float, (CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100) From CovidDeaths where location = 'Nigeria' order by 1, 2

-- Selecting the percentage of total_death vs total_cases based on location from Nigeria

SELECT location, date, total_cases, total_deaths, 
CONVERT(float, (CONVERT (float, total_deaths) / CONVERT(float, total_cases)) * 100) as DeathPercentage
FROM CovidDeaths WHERE location like '%Nigeria%' order by 2, 3


-- Looking at total case vs population
-- Shows what population percentage has got covid
SELECT location, date, total_cases, 
CONVERT(float, (CONVERT (float, total_cases) / CONVERT(float, population)) * 100) as PopulationPercentage
FROM CovidDeaths order by location

--Looking at country with Higher Infection rate vs Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float, CONVERT(float, total_cases) / CONVERT(float, population))*100) as PercentagePopulationInfected
FROM CovidDeaths WHERE location like  '%NIG%' GROUP BY location, population ORDER BY PercentagePopulationInfected desc

-- Creating view of country with HighInfectionRate vs Population 
Create View HighInfectionRatevsPopulation as
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float, CONVERT(float, total_cases) / CONVERT(float, population))*100) as PercentagePopulationInfected
FROM CovidDeaths WHERE location like  '%NIG%' GROUP BY location, population 


-- Showing Country with Highest Death count per Population
SELECT location, population, MAX(CONVERT(int, total_deaths)) as TotalDeathCount
FROM CovidDeaths  WHERE continent is not null GROUP BY location, population ORDER BY TotalDeathCount desc


-- Let break things into Continent
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths WHERE continent is not null GROUP by continent 
ORDER BY TotalDeathCount desc


--GLOBAL Numbers
SELECT date,  SUM(new_cases) as total_cases, SUM(CONVERT(int, new_deaths)) as total_deaths, SUM(CONVERT(float, new_deaths))/ SUM(New_cases)*100 AS DeathPercentage
from PortfolioProject.dbo.CovidDeaths WHERE continent is not null
GROUP by Date
Order by 1, 2

-- 9550464949

-- Total population vs total Vaccinated
WITH PopvsVac (Continent, Location, Date, Population, NewVacinated, RollingPeopleVacinated)
as
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as Rolling_people_vacinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
Select *, (RollingPeopleVacinated/Population) * 100 FROM PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVacinated
CREATE Table #PercentPopulationVacinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vacinations numeric,
	RollingPeopleVacinated numeric
)
INSERT INTO #PercentPopulationVacinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as Rolling_people_vacinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

Select *, (RollingPeopleVacinated/Population) * 100 FROM #PercentPopulationVacinated

-- Creating view to store data for later visualization 
Create View PercentPopulationVacinated as 
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as Rolling_people_vacinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent IS NOT NULL

