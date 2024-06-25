select *
from PortfolioProject..CovidDeaths
where continent is not null

--select data that we're going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

-- total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%somalia%' and
where continent is not null

--looking at total cases vs population
-- shows what percent of population got covid

select location, date, population, total_cases, (total_cases/population) * 100 as PercentOfPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%somalia%'
and where continent is not null

-- Looking at countries with the highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentOfPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%somalia%'
where continent is not null
group by location, population
order by PercentOfPopulationInfected desc


-- showing countries with the highest death count per population


select continent, location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%somalia%'
where continent is not null
group by continent, location, population
order by TotalDeathCount desc

--LET'S BREAK things down by continent
-- showing the continents with the highest death count
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%somalia%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers


select date, sum(new_cases) as NewReportedCases, sum(cast(new_deaths as int)) as NewReportedDeaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%somalia%' and
where continent is not null
group by date
order by 1, 2

-- global number just total cases and deaths also percentage

select sum(new_cases) as TotalReportedCases, sum(cast(new_deaths as int)) as TotalReportedDeaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%somalia%' and
where continent is not null
--group by date
order by 1, 2

-- join the tables (covid deaths, covid vaccination)
--then
-- total population vs vaccination 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccination_By_Country
, (Total_Vaccination_By_Country/population)* 100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- USE CTE to make Total_Vaccination_By_Country alias work

with PopvsVac (continent, location, date, population, new_vaccination, Total_Vaccination_By_Country)
	as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccination_By_Country
--, (Total_Vaccination_By_Country/population)* 100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
 --order by 2, 3

)

select *, (Total_Vaccination_By_Country/population)* 100 
from PopvsVac


-- Temp table instead of CTE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
Date datetime,
Population numeric,
new_vaccination numeric,
Total_Vaccination_By_Country numeric

)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccination_By_Country
--, (Total_Vaccination_By_Country/population)* 100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
 --order by 2, 3

 select *, (Total_Vaccination_By_Country/population)* 100 
from #PercentPopulationVaccinated

-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccination_By_Country
--, (Total_Vaccination_By_Country/population)* 100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
 --order by 2, 3

 select * 
 from PercentPopulationVaccinated