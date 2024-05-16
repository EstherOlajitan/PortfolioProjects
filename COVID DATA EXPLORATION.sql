Select * 
From PORTFOLIO1..CovidDeaths
Where continent is not null
order by 3,4

--Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
from PORTFOLIO1..CovidDeaths
order by 1,2



--Looking at Total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in Nigeria as 30-04-2021
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PORTFOLIO1..CovidDeaths
where location = 'Nigeria'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population got Covid 
Select Location, date, total_cases, population, (NULLIF(CONVERT(float, total_cases), 0) / (CONVERT(float, population))) * 100 AS PercentPopulationInfected
from PORTFOLIO1..CovidDeaths
--where location = 'Nigeria'
Where continent is not null
order by 1,2


--Looking at Country with Highest Infection Rate compared to Population
Select Location,population, MAX(total_cases) AS HIGHESTINFECTIONCOUNT, ((MAX(NULLIF(CONVERT(float, total_cases), 0))) / (CONVERT(float, population))) * 100 AS PercentPopulationInfected
from PORTFOLIO1..CovidDeaths
--where location = 'Nigeria'
Where continent is not null
group by location, population
order by PercentPopulationInfected desc



-- Showing Countries with Highest Death Count per population
Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PORTFOLIO1..CovidDeaths
--where location = 'Nigeria'
Where continent is not null
group by location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PORTFOLIO1..CovidDeaths
--where location = 'Nigeria'
Where continent is not null
group by continent
order by TotalDeathCount desc

Select continent, SUM(CAST(new_deaths AS INT)) AS NEWDeathCount
from PORTFOLIO1..CovidDeaths
--where location = 'Nigeria'
Where continent is  not null
group by continent
order by NEWDeathCount desc



-- Showing continents with the highest death count per population


Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PORTFOLIO1..CovidDeaths
--where location = 'Nigeria'
Where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select sum(cast(new_cases as float)) as sum_newcases, sum(cast(new_deaths as float))as sum_newdeaths, nullif(sum(cast(new_deaths as int)), 0) / nullif(sum(cast(new_cases as int)), 0)*100 as deathper ---, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PORTFOLIO1..CovidDeaths
--where location = 'Nigeria'
where continent is null
--group by date, new_cases,	new_deaths
order by 1,2 

--ori
Select SUM(CAST(new_cases AS FLOAT)) AS sum_newcases, SUM(CAST(new_deaths AS FLOAT)) AS sum_newdeaths, SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT)) * 100 AS daeth_percentage
From PORTFOLIO1..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
--,(RollingPeopleVac/population)*100
from PORTFOLIO1..CovidDeaths dea 
join PORTFOLIO1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = dea.date
where dea.continent is not null 
order by 2, 3

--USE CTE

With PopvsVac  (continent, location, date, population,new_vaccinactions, RollingPeopleVac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
--,(RollingPeopleVac/population)*100
from PORTFOLIO1..CovidDeaths dea 
join PORTFOLIO1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3
)
select * , (RollingPeopleVac/population) * 100
from PopvsVac


-- TEMP TABLE
DroP TABLE IF  exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVacc numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
--,(RollingPeopleVac/population)*100
from PORTFOLIO1..CovidDeaths dea 
join PORTFOLIO1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2, 3

select * , (RollingPeopleVacc/population) * 100
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
--,(RollingPeopleVac/population)*100
from PORTFOLIO1..CovidDeaths dea 
join PORTFOLIO1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3



select * From PercentPopulationVaccinated