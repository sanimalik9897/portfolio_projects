select *
from PortfolioProjects..covid_deaths
order by 3,4


select *
from PortfolioProjects..covid_vaccination
order by 3,4

select location, date, total_deaths, new_cases,total_deaths, population
from PortfolioProjects..covid_deaths
order by 1,2


--looking at total cases vs total deaths
-- chances of death if you infected with covid
select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as death_perentage
from PortfolioProjects..covid_deaths
where location = 'india'
order by 1,2

--total_case vs populaton
--percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as death_perentage
from PortfolioProjects..covid_deaths
where location = 'india'
order by 1,2

-- countries with highest infection rate 

select location, population, MAX(total_cases) as highest_infection_rate, MAX(total_cases/population)*100 as population_infect_percentage
from PortfolioProjects..covid_deaths
group by location, population
order by population_infect_percentage desc


--countries with highest death rate

select location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProjects..covid_deaths
--where location = 'india'
where continent is not null
group by location
order by total_death_count desc


--continents with highest rate

select location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProjects..covid_deaths
--where location = 'india'
where continent is null
group by location
order by total_death_count desc

select continent, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProjects..covid_deaths
--where location = 'india'
where continent is not null
group by continent
order by total_death_count desc

--global_stats
select date, SUM(new_cases) as total_case, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from PortfolioProjects..covid_deaths
where continent is not null
group by date
order by 1,2

select SUM(new_cases) as total_case, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from PortfolioProjects..covid_deaths
where continent is not null
--group by date
order by 1,2


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccination
from PortfolioProjects..covid_deaths dea
join PortfolioProjects..covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


with popsVScont (continent, location, date, population, new_vaccination, rolling_people_vaccination)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccination
from PortfolioProjects..covid_deaths dea
join PortfolioProjects..covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select * , (rolling_people_vaccination/population)*100
from popsVScont

--creating view

create view population_vaccinated_percent as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccination
from PortfolioProjects..covid_deaths dea
join PortfolioProjects..covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from population_vaccinated_percent