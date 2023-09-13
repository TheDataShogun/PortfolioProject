Select *
from PortfolioProject..CovidDeaths
order by 2,3,4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 2,3,4

-- Select Data that we're going to be using 

Select location, date, total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2


--looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%Niger%'
order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of popuation got Covid
Select location, date, population,total_cases, (total_deaths/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
Where location like '%Senegal%' 
and  continent is not null

order by 1,2



--Looking at countries with Highest Infection Rate compared to Population
Select location, population,Max(total_cases) HighestInfectionCount,
Max((total_cases/population))*100 as InfectionRate
from PortfolioProject..CovidDeaths
 Where continent is not null

--Where location like '%Senegal%' 
Group by location, population 
order by InfectionRate desc

--Looking at countries with Highest Infection Rate & DeathPercentage compared to Population
Select location, population,Max(total_cases) HighestInfectionCount,
Max((total_cases/population))*100 as InfectionRate, 
Max((total_deaths/total_cases))*100 DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%Niger%'
 Where continent is not null

Group by location, population 
order by 4 desc

--showing Countries with Highest Death count per Population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%Niger%' 
 Where continent is not null
Group by continent
order by TotalDeathCount 

 --Let's break it Down By Continents


 --Showing continents with the Highest death Count per population

 Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%mauritania%' 
--and  Where continent is null
Group by location 
order by TotalDeathCount desc


-- GLOBAL NUMBERS 

Select  sum(new_cases) TotalCases,Sum(cast(new_deaths as int)) TotalDeaths, Sum(cast(new_deaths as int))/Sum
(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2

-- GLOBAL NUMBERS BY DATE

Select date, sum(new_cases) TotalCases,Sum(cast(new_deaths as int)) TotalDeaths, Sum(cast(new_deaths as int))/Sum
(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2


--- LET's have a glance at CovideVaccination Data

Select *
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date= vac.date

	-- Looking at the Total Population Vs 	Vaccinations
	/* we're gonna calculated the probability of people getting vaccinated*/
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,

--Count(cast(vac.new_vaccinations as int))
/* methods N°1 of converting a column as an int*/
--sum(Cast(vac.new_vaccinations as int)) Over (partition by dea.location)
/* Method N°2 of converting a collumn as an int*/
sum(convert(int,vac.new_vaccinations)) Over (partition by dea.location Order by dea.location 
,dea.date) as RollingeopleVaccnated

from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date= vac.date
Where dea.continent is not null
--Group by dea.continent, dea.location, dea.population, vac.new_vaccinations
order by 1,2,3



--	USE CTE

with PopvsVac (Continent, Location, Date,population,new_vaccinations , RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,

--Count(cast(vac.new_vaccinations as int))
/* methods N°1 of converting a column as an int*/
--sum(Cast(vac.new_vaccinations as int)) Over (partition by dea.location)
/* Method N°2 of converting a collumn as an int*/
sum(convert(int,vac.new_vaccinations)) Over (partition by dea.location Order by dea.location 
,dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date= vac.date
Where dea.continent is not null
--Group by dea.continent, dea.location, dea.population, vac.new_vaccinations
--order by 1,2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Use Temp 
Drop Table if exists #PercentPopulationVaccineted
Create Table #PercentPopulationVaccineted
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated  numeric
)
Insert into #PercentPopulationVaccineted
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,

--Count(cast(vac.new_vaccinations as int))
/* methods N°1 of converting a column as an int*/
--sum(Cast(vac.new_vaccinations as int)) Over (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
/* Method N°2 of converting a collumn as an int*/
sum(convert(int,vac.new_vaccinations)) Over (partition by dea.location Order by dea.location 
,dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date= vac.date
Where dea.continent is not null
--Group by dea.continent, dea.location, dea.population, vac.new_vaccinations
--order by 1,2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccineted

-- Creating View to store data for later visualization
Drop view PercentPopulationVaccineted
Create  view PercentPopulationVaccineted as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,

--Count(cast(vac.new_vaccinations as int))
/* methods N°1 of converting a column as an int*/
sum(convert(int,vac.new_vaccinations)) Over (partition by dea.location Order by dea.location 
,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date= vac.date
Where dea.continent is not null

Select *
from PercentPopulationVaccineted

select Object_ID ('PercentPopulationVaccineted') As ObjectID;
