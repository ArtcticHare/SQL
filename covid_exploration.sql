

-- Queries used to explore the data originally 
--exploring the structure of the data
-- Filtering out the null continent fields is a way of removing the locations that are assigned as continents.

select *
from `covid-project-342610.Covid_deaths.covid_deaths`
where continent is not null
order by 3,4

--Select the data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from `covid-project-342610.Covid_deaths.covid_deaths`
order by 1,2

--Looking at Total Cases VS Total Deaths
-- shows likelihood of dying if you contract covid in your country over time (used Australia as an example, as it made the data more relevant to myself)

select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
from `covid-project-342610.Covid_deaths.covid_deaths`
where location = 'Australia'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date, total_cases, population, ((total_cases/population)*100) as InfectionPercentage
from `covid-project-342610.Covid_deaths.covid_deaths`
where location = 'Australia'
order by 1,2

--Showing total deaths as of the date of my exploration
--cast total deaths to an integer as for most accurate results

select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from `covid-project-342610.Covid_deaths.covid_deaths`
where continent is null
Group by location
order by TotalDeathCount DESC

-- Looking at the percentage of the population infected compare to the population 

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentagePopulationInfected
from `covid-project-342610.Covid_deaths.covid_deaths`
Group by location, population
order by PercentagePopulationInfected DESC 


-- Lets's Break things down by continent
-- Showing the continents with the highest death count per population 

select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from `covid-project-342610.Covid_deaths.covid_deaths`
where continent is not null
Group by continent
order by TotalDeathCount DESC

-- Daily numbers for new cases, new deaths and DeathPercentage as a percentage of deaths compared to cases

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from `covid-project-342610.Covid_deaths.covid_deaths`
--where location like '%Australia%'
where continent is not null
group by date
order by 1,2

-- Looking at Total Population vs Vaccinations
-- Partitioned by the location to break it up correctly, as we wanted to look at rolling vaccination by location.

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from `covid-project-342610.Covid_deaths.covid_deaths` as dea
join `covid-project-342610.Covid_deaths.covid_vaccinations` as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 

-- Creating a View to store data for later visualizations

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