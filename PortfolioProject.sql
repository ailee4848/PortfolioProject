--Data that we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at Total Cases VS Total Deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what % of population got Covid
select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at countries with Highest Infection compared to Population

select location,population,Max(total_cases) as HighestInfectionCount,Max(total_cases/population)*100 
as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
group by location,population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
 select location,max(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths$
 where continent is not null
 group by location
 order by TotalDeathCount desc
 
 --Break things down by continent
 select continent,max(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths$
 where continent is not null
 group by continent
 order by TotalDeathCount desc

 --Showing continent with highest death count per population

 select continent,max(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths$
 where continent is not null
 group by continent
 order by TotalDeathCount desc

 --Global Numbers

 Select sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths$
 Where continent is not null
 order by 1,2
 
 --Looking at Total Population vs Vaccination
 select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollinPeopleVaccinated
 ,(RollinPeopleVaccinated/population)*100
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 1,2,3

 --use CTE
 With PopVsVac (continent,location,date,population,New_Vaccinations,RollingPeopleVaccinated)
 as
 (
 select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 1,2,3
 )
 Select *,(RollingPeopleVaccinated/population)*100
 From PopVsVac
  
  --Temparary table
  drop table if exists #PercentPopulationVaccinated
  create table #PercentPopulationVaccinated
  (
  Continent nvarchar(255),
  location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

  insert into #PercentPopulationVaccinated
 select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 1,2,3

 Select *,(RollingPeopleVaccinated/population)*100
 From #PercentPopulationVaccinated
--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

