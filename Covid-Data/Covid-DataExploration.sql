Select * 
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at Total cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%argen%'
order by 1,2

--Show what percetage of population got covid
Select Location, date, Population, total_cases, (total_cases / population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
order by 1,2

--Looking at countries with highest infection rTE COMPARED TO POPULATION

Select Location,Population, MAX(total_cases)AS HighestInfectionCount, MAX((total_cases / population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Sowing Countries with highest Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathsCount desc

--Break things Down By Continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is  null
Group by location
order by TotalDeathsCount desc

--Showing the contienes with the highest deaths count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathsCount desc

--GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage--,total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%argen%'
where continent is not null
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


