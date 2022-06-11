SELECT *
From PortfolioProjects..CovidDeaths$
Where continent is not null 
order by 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
From PortfolioProjects..CovidDeaths$
Where continent is not null 
order by 1,2

--Looking at Total cases vs Total deaths in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
Where location like '%India%'
order by 1,2

--Looking at Total cases vs Population
SELECT location,date,total_cases,population,(total_cases/population)*100 as CasePercentage
From PortfolioProjects..CovidDeaths$
Where location like '%India%'
order by 1,2

SELECT location,date,total_cases,population,(total_cases/population)*100 as CasePercentage
From PortfolioProjects..CovidDeaths$
--Where location like '%India%'
Where continent is not null 
order by 1,2

--Highest infection rate among all countries
SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as HighestPercentageCount
From PortfolioProjects..CovidDeaths$
Where continent is not null 
Group by location,population
order by HighestPercentageCount desc

--Countries with Highest death rate
SELECT location,population,MAX(total_deaths) as HighestDeathCount,MAX((total_deaths/population))*100 as HighestPercentageCount
From PortfolioProjects..CovidDeaths$
Where continent is not null 
Group by location,population
order by HighestPercentageCount desc

SELECT location, MAX(cast(total_deaths as int))as HighestDeathCount
From PortfolioProjects..CovidDeaths$
Where continent is not null 
Group by location
order by HighestDeathCount desc

--Among CONTINENTS
SELECT continent, MAX(cast(total_deaths as int))as HighestDeathCount
From PortfolioProjects..CovidDeaths$
Where continent is not null 
Group by continent
order by HighestDeathCount desc

SELECT location, MAX(cast(total_deaths as int))as HighestDeathCount
From PortfolioProjects..CovidDeaths$
Where continent is null 
Group by location
order by HighestDeathCount desc

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select *
From PortfolioProjects..CovidVaccinations$

Select*
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
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
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
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
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select*
From #PercentPopulationVaccinated