
select *
from PORTFOLIOPROJECT..CovidDeaths$
where continent is not null
order by 3, 4
;
--select *
--from PORTFOLIOPROJECT..CovidVaccinations$
--order by 3, 4
--;



-- looking at total cases vs totaal deaths
-- shows likelihood of death if you contact the disease
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PORTFOLIOPROJECT..CovidDeaths$
where location like '%kenya%'
where continent is not null
order by 1,2
;


-- looking at the total cases vs the population
-- shows the percentage of population got covid

select location, date,  population, total_cases, (total_cases/population)*100 as populationinfectedpercentage
from PORTFOLIOPROJECT..CovidDeaths$
where location like '%kenya%'
where continent is not null
order by 1,2
;

-- looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as mostinfected, MAX(total_cases/population)*100 as percentpopulationinfected
from PORTFOLIOPROJECT..CovidDeaths$
where continent is not null
group by location, population
order by percentpopulationinfected desc
;

-- showing countries with the highest death count per population

select location, MAX(cast(total_deaths as int)) as Deathcount 
from PORTFOLIOPROJECT..CovidDeaths$
where continent is not null
group by location
order by Deathcount desc
;



--showing the continent with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as Deathcount 
from PORTFOLIOPROJECT..CovidDeaths$
where continent is not null
group by continent
order by Deathcount desc
;


-- GLOBAL NUMBERS

select date, SUM(total_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths,
SUM(cast(new_deaths as int))/SUM(total_cases)*100 as deathpercentage
from PORTFOLIOPROJECT..CovidDeaths$
--where location like '%kenya%'
where continent is not null
group by date
order by 1,2
;

select SUM(total_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths,
SUM(cast(new_deaths as int))/SUM(total_cases)*100 as deathpercentage
from PORTFOLIOPROJECT..CovidDeaths$
where continent is not null
order by 1,2
;

-- looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER(Partition by dea.location order by 
dea.location,dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PORTFOLIOPROJECT..CovidDeaths$ dea
join PORTFOLIOPROJECT..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
;

--CTE
with populationvaccinated (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER(Partition by dea.location order by 
dea.location,dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PORTFOLIOPROJECT..CovidDeaths$ dea
join PORTFOLIOPROJECT..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from populationvaccinated
;

--TEMP TABLE

DROP table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER(Partition by dea.location order by 
dea.location,dea.date) as rollingpeoplevaccinated
from PORTFOLIOPROJECT..CovidDeaths$ dea
join PORTFOLIOPROJECT..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated
;

-- creating view to store data for later visualization

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER(Partition by dea.location order by 
dea.location,dea.date) as rollingpeoplevaccinated
from PORTFOLIOPROJECT..CovidDeaths$ dea
join PORTFOLIOPROJECT..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from percentpopulationvaccinated








