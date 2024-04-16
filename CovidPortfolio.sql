SELECT *
FROM CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM CovidVaccinations
--order by 3,4

-- Select Data that im going to use

Select Location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
from Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as [Death Percentage]
from Portfolio_Project..CovidDeaths
where location like '%Brazil%' and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population)*100 as [Percentage of Population Infected]
from Portfolio_Project..CovidDeaths
--where location like '%Brazil%' and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, 
	MAX(total_cases) as [Highest Infection Count], 
	MAX((total_cases/population))*100 as [Percentage of Population Infected]
from Portfolio_Project..CovidDeaths
--where location like '%Brazil%' and continent is not null
group by Location, population
order by [Percentage of Population Infected] desc

-- Showing Countries with Highest Death Count per Population
Select Location, 
	MAX(cast(total_deaths as int)) as [Total Death Count]
from Portfolio_Project..CovidDeaths
where continent is not null
group by Location
order by [Total Death Count] desc

-- Showing continents with the highest death count per population
Select continent,
	MAX(cast(total_deaths as int)) as [Total Death Count]
from Portfolio_Project..CovidDeaths
where continent is not null
group by continent
order by [Total Death Count] desc

-- Global numbers

Select  
	SUM(new_cases) as [Total Cases], 
	SUM(cast(new_deaths as int)) as [Total Deaths], 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as [Death Percentage]
from Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, [Vaccination Day by Day])
as
(
Select dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as [Vaccination Day by Day]
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, ([Vaccination Day by Day]/Population)*100
From PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
[Vaccination Day by Day] numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as [Vaccination Day by Day]
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, ([Vaccination Day by Day]/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later viualization

Create View PercentPopulationVaccinated as
Select dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as [Vaccination Day by Day]
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-------------------------------------------------------------------------------------------------------------------------------------------

-- Global numbers
Create View GlobalNumbers as
Select  
	SUM(new_cases) as [Total Cases], 
	SUM(cast(new_deaths as int)) as [Total Deaths], 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as [Death Percentage]
from Portfolio_Project..CovidDeaths
where continent is not null

---------------------------------------------------------------------------------------


Create View HighestDeathCountries as
Select Location, 
	MAX(cast(total_deaths as int)) as [Total Death Count]
from Portfolio_Project..CovidDeaths
where continent is not null
group by Location

-----------------------------------------------------------------------------------------


Create View HighestDeathContinents as
Select continent,
	MAX(cast(total_deaths as int)) as [Total Death Count]
from Portfolio_Project..CovidDeaths
where continent is not null
group by continent