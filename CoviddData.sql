-- Select count(*)
-- From coviddeaths;
-- -- -- where continent= ''
-- -- order by 3,4;

-- Select count(*)
-- From covidvaccination
-- where location like '%Canada%';


-- select the data we are going to be using

select location,date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent <> ''
order by 1,2;

-- looking at Total cases vs Total deaths
-- shows the likelihood of dying if you contract covid in your country

select location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location like '%Canada%'
order by 1,2;

-- looking at Total Cases vs Population
-- what percentage of population got Covid
select location,date,population ,total_cases, (total_cases/population)*100 as CovidPercentage
from coviddeaths
where location like '%states%'
order by 1,2;

-- what country has the highest infection rate compared to population?
select location,population,MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentPopulationInfected
from coviddeaths
-- where location like '%states%'
group by Location, population
order by 4 desc;

-- This is showing the countires with the highest death count per population

select location,MAX(CAST(total_deaths AS SIGNED)) as TotalDeathCount
from coviddeaths
-- where location like '%states%'
where continent <> ''
group by Location
order by TotalDeathCount desc;


-- let's break things down by continent

select continent,MAX(CAST(total_deaths AS SIGNED)) as TotalDeathCount
from coviddeaths
-- where location like '%states%'
where continent <> ''
group by continent
order by TotalDeathCount desc;


-- showing the continents with the highest deathcounts

select continent,MAX(CAST(total_deaths AS SIGNED)) as TotalDeathCount
from coviddeaths
-- where location like '%states%'
where continent <> ''
group by continent
order by TotalDeathCount desc;

-- Global Numbers per day
select date, sum(new_cases) as total_cases , sum(new_deaths) as total_deaths,(sum(new_deaths)/sum(new_cases))*100 as DeathPercentageGlobal
from coviddeaths
-- where location like '%states%'
where continent <> ''
group by date
order by 1,2;

-- Global numbers in total

select sum(new_cases) as total_cases , sum(new_deaths) as total_deaths,(sum(new_deaths)/sum(new_cases))*100 as DeathPercentageGlobal
from coviddeaths
-- where location like '%states%'
where continent <> ''
-- group by date
order by 1,2;


select *
from coviddeaths dea
join covidvaccinations vac
on dea.location=vac.location and dea.date=vac.date;

-- looking at total population vs vaccination

-- Use CTE

with PopvsVac (Continent, Location,Date,Population,new_vaccinations,RollingPeopleVaccinated) as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated

From coviddeaths dea
Join covidvaccinations vac
on dea.date=vac.date and dea.location=vac.location  
-- where dea.location like '%states%'
where dea.continent <> ''
-- order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100
from PopvsVac;




-- Temp Table
drop table if exists PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated (
  Continent VARCHAR(255),
  Location  VARCHAR(255),
  `Date`    DATE,
  Population BIGINT NULL,
  new_vaccinations BIGINT NULL,
  RollingPeopleVaccinated BIGINT NULL
);

INSERT INTO PercentPopulationVaccinated
SELECT
  NULLIF(TRIM(dea.continent), '') AS continent,
  dea.location,
  dea.date,
  CAST(NULLIF(TRIM(dea.population), '') AS UNSIGNED) AS population,
  CAST(NULLIF(TRIM(vac.new_vaccinations), '') AS UNSIGNED) AS new_vaccinations,
  SUM(CAST(NULLIF(TRIM(vac.new_vaccinations), '') AS UNSIGNED))
    OVER (PARTITION BY dea.location ORDER BY dea.date)
    AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE NULLIF(TRIM(dea.continent), '') IS NOT NULL;

select * , (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated;



-- creating view to store data for later visualization

create view PopulationVaccinatedPercent as
 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From coviddeaths dea
Join covidvaccinations vac
on dea.date=vac.date and dea.location=vac.location  
-- where dea.location like '%states%'
where dea.continent <> '';
-- order by 2,3
Select *
from PopulationVaccinatedPercent






