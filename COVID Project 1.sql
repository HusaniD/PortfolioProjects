Select *
from CovidDeaths
order by 3,4 

--Select *
--from CovidVaccinations
--order by 3,4 

--Select Location, date, total_cases, new_cases, total_deaths, population
--From CovidDeaths
--order by 1,2	

-- Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
order by 1,2

-- Total cases vs Population

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location like '%states%'
order by 1,2

-- Countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with the highest death count per population

Select Location, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- The continents with the highest death count

Select continent, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers

Select date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2


Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2


-- Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3



-- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as Rolling_People_Vaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
----Order by 2, 3
)
Select *, (Rolling_People_Vaccinated/Population)*100 as Rolling_Vac_Percentage
From PopvsVac


-- TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as Rolling_People_Vaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2, 3

Select *, (Rolling_People_Vaccinated/Population)*100 as Rolling_Vac_Percentage
From #PercentPopulationVaccinated


-- Creating view for visualizations

Create view	PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as Rolling_People_Vaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

Select *
From PercentPopulationVaccinated


