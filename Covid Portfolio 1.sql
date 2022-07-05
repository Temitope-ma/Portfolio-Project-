Select *
From Portfoliproject..CovidDeaths$
where continent is not null
order by 3,4 

--Select *
--From Portfoliproject..CovidVaccinations$
where continent is not null
--order by 3,4 

Select location, date,total_cases,new_cases,total_deaths,population
From Portfoliproject..CovidDeaths$
where continent is not null
order by 1,2 

--looking at Total cases vs Total deaths
--showing the likelihood of people that may die in the country if they contract covid 

Select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
From Portfoliproject..CovidDeaths$
where location like '%states%'
where continent is not null
order by 1,2 


--LOOKING AT THE TOTAL CASES VS POPULATION 
--SHOWS THE PERCENTAGE OF POPULATION THAT GOT COVID 

Select location, date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected 
From Portfoliproject..CovidDeaths$
--where location like '%states%'
where continent is not null
order by 1,2

--Looking at countries with the highest Infection rate compared to population 

Select location,population,MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected  
From Portfoliproject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by location,population
order by PercentPopulationInfected desc

--Showing countries with highest Death count by population 

Select location,MAX(cast(total_deaths as int)) as Totaldeathcount  
From Portfoliproject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by location
order by Totaldeathcount desc


--BREAKING THINGS DOWN BY CONTINENT
--Showing the continent with the highest death count by population 
Select continent, MAX(cast(total_deaths as int)) as Totaldeathcount  
From Portfoliproject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by Totaldeathcount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from Portfoliproject..CovidDeaths$
--where location like '%states%"
where continent is not null 
--Group by date 
order by 1,2

--looking at total population vs vaccination 
with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(CONVERT(INT,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from Portfoliproject..CovidDeaths$ dea
join Portfoliproject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null 
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE 

drop table if exists  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent  nvarchar(255),
Location nvarchar (255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
 INSERT INTO #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(CONVERT(INT,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from Portfoliproject..CovidDeaths$ dea
join Portfoliproject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null 
--ORDER BY 2,3
Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating views for data visualization 

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(CONVERT(INT,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from Portfoliproject..CovidDeaths$ dea
join Portfoliproject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null 
--ORDER BY 2,3

Create View GlobalNumbers as
select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from Portfoliproject..CovidDeaths$
--where location like '%states%"
where continent is not null 
--Group by date 
--order by 1,2