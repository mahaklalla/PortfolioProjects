
Select *
from PortfolioProjects..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from PortfolioProjects..CovidVaccinations
--order by 3,4

--Select data that is going to be used for visualization

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
where continent is not null
order by 1,2 

--Totals cases vs total deaths
Select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from PortfolioProjects..CovidDeaths
where location = 'canada'
and continent is not null
order by 1,2 

-- Total cases vs population

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPouplationInfected
from PortfolioProjects..CovidDeaths
--where location = 'canada'
order by 1,2 

-- Countries with highest infection rate compared to population
Select Location, Population, Max(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as PercentPouplationInfected
from PortfolioProjects..CovidDeaths
Group by location, population
Order by PercentPouplationInfected desc

--Countries with Highest Death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc


--Continents with Highest Death count per population

Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global numbers

Select date, sum(new_cases) as new_Cases, sum(cast(new_deaths as int)) as new_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercent
from PortfolioProjects..CovidDeaths
--where location = 'canada'
where continent is not null
Group by date
order by 1,2 

Select sum(new_cases) as total_Cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercent
from PortfolioProjects..CovidDeaths
--where location = 'canada'
where continent is not null
--Group by date
order by 1,2 


-- Looking at Total populattion Vs Vaccinations
Select dts.continent, dts.location,dts.date, dts.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as bigint)) 
 OVER (Partition by dts.location Order by dts.location, dts.Date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dts
JOIN PortfolioProjects..CovidVaccinations vax
	ON dts.location = vax.location
	and dts.date = vax.date
where dts.continent is not null
order by 2,3


--Use CTE

With PopVsVac (Continent, Location, Date, Population,New_vaccinations,RollingPeopleVaccinated)
AS 
(Select dts.continent, dts.location,dts.date, dts.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as bigint)) 
 OVER (Partition by dts.location Order by dts.location, dts.Date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dts
JOIN PortfolioProjects..CovidVaccinations vax
	ON dts.location = vax.location
	and dts.date = vax.date
where dts.continent is not null)

Select *, (RollingPeopleVaccinated/Population)*100 
From PopVsVac


-- Temp table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dts.continent, dts.location,dts.date, dts.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as bigint)) 
 OVER (Partition by dts.location Order by dts.location, dts.Date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dts
JOIN PortfolioProjects..CovidVaccinations vax
	ON dts.location = vax.location
	and dts.date = vax.date
--where dts.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated

--Creating views to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dts.continent, dts.location,dts.date, dts.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as bigint)) 
 OVER (Partition by dts.location Order by dts.location, dts.Date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dts
JOIN PortfolioProjects..CovidVaccinations vax
	ON dts.location = vax.location
	and dts.date = vax.date
where dts.continent is not null
--order by 2,3

Select * from PercentPopulationVaccinated