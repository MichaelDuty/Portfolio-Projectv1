Select*
From PortfolioProject..CovidDeaths
order by 3,4

--select*
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, Population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at Total Cases vs Total Deaths
--shows likelihood of passing from Covid in your country

select location, date, total_cases, total_deaths, ( total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
Where Location like '%states%'
order by 1,2

--looking at the Total Cases vs Population
--shows what percentage of the population got Covid

select location, date, total_cases, Population, ( total_cases/population)*100 as PercentPopulationInfection
from PortfolioProject..CovidDeaths
--Where Location like '%states%'
order by 1,2


--Looking at Countries with the highest Infection Rate compared to Population

select location, Population, Max(total_Cases) as HighestInfectionCount, Max(( total_cases/population))*100 as PercentPopulationInfection
from PortfolioProject..CovidDeaths
--Where Location like '%states%'
Group by Location, population
order by PercentPopulationInfection desc

--Showing the countries with the Highest Fatalities per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where Location like '%states%'
where continent is not null
Group by Location, population
order by TotalDeathCount desc

--Now lets look at just continents

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where Location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where Location like '%states%'
where continent is not null
group by date 
order by 1,2

-- Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as ContinuedVaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Use CTE

with PopvsVac (Continent, location, date, Population, New_vaccinations, ContinuedVaccinationCount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as ContinuedVaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select*,(ContinuedVaccinationCount/Population)*100
from PopvsVac

--Temp Table

Create table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
ContinuedVaccinationCount numeric
)

Insert into #PercentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as ContinuedVaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select*,(ContinuedVaccinationCount/Population)*100
from #PercentpopulationVaccinated


--Creating View to store data for visualization later

create view PercentpopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as ContinuedVaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 