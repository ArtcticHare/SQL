select *
from `covid-project-342610.Covid_deaths.covid_deaths`
where continent is not null
order by 3,4

##select * 
##From `covid-project-342610.Covid_deaths.covid_deaths`
##order by 3,4

#Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from `covid-project-342610.Covid_deaths.covid_deaths`
order by 1,2

## Looking at Total Cases VS Total Deaths
## shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
from `covid-project-342610.Covid_deaths.covid_deaths`
where location = 'Australia'
order by 1,2

## Looking at the Total Cases vs Population
## Shows what percentage of population got Covid

select location, date, total_cases, population, ((total_cases/population)*100) as DeathPercentage
from `covid-project-342610.Covid_deaths.covid_deaths`
where location = 'Australia'
order by 1,2

## Looking at countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentagePopulationInfected
from `covid-project-342610.Covid_deaths.covid_deaths`
##where location = 'Australia'
Group by location, population
order by PercentagePopulationInfected DESC 

## Showing countries with Highest Death Count per Population 

select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from `covid-project-342610.Covid_deaths.covid_deaths`
##where location = 'Australia'
where continent is not null
Group by location
order by TotalDeathCount DESC

##"correct way"

select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from `covid-project-342610.Covid_deaths.covid_deaths`
##where location = 'Australia'
where continent is null
Group by location
order by TotalDeathCount DESC

##Lets's Break things down by continent
##Showing the continents with the highest death count per population 

select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from `covid-project-342610.Covid_deaths.covid_deaths`
##where location = 'Australia'
where continent is not null
Group by continent
order by TotalDeathCount DESC

##Global Numbers

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from `covid-project-342610.Covid_deaths.covid_deaths`
--where location like '%Australia%'
where continent is not null
group by date
order by 1,2

##Total cases so far and the percentage of death

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from `covid-project-342610.Covid_deaths.covid_deaths`
--where location like '%Australia%'
where continent is not null
--group by date
order by 1,2


##Joining the tables together
## Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from `covid-project-342610.Covid_deaths.covid_deaths` as dea
join `covid-project-342610.Covid_deaths.covid_vaccinations` as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 



##Use CTE

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from `covid-project-342610.Covid_deaths.covid_deaths` as dea
join `covid-project-342610.Covid_deaths.covid_vaccinations` as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
## order by 2,3
)
select*, (RollingPeopleVaccinated/Population)*100
from popvsvac

##Teamp Table 

DROP TABLE IF EXISTS  covid-project-342610.Covid_deaths.PercentPopulationVaccinated
Create Table covid-project-342610.Covid_deaths.PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric,
)

INSERT INTO covid-project-342610.Covid_deaths.PercentPopulationVaccinated,
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from `covid-project-342610.Covid_deaths.covid_deaths` as dea
join `covid-project-342610.Covid_deaths.covid_vaccinations` as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
##order by 2,3

select *,((RollingPeopleVaccinated/ population)*100)
from PercentPopulationVaccinated

## Creating View to store data for later visualizations

create view covid-project-342610.Covid_deaths.PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from `covid-project-342610.Covid_deaths.covid_deaths` as dea
join `covid-project-342610.Covid_deaths.covid_vaccinations` as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
##order by 2,3