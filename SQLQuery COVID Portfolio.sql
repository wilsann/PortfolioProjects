Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Total Deaths vs Total Cases In My Country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where location like 'Indonesia' and continent is not null
Order by 1,2

-- Total Cases vs Population
Select location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
From PortfolioProject..CovidDeaths
-- Where location like 'Indonesia'
Where continent is not null
Order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCountry, MAX((total_cases/population))*100 as percent_population_infected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by percent_population_infected DESC

-- Countries with Highest Death Count per Population
Select location, MAX(CAST(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by 2 DESC

-- Break this down by Continent


-- Continent with Highest Death Count per Population
Select continent, MAX(CAST(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by 2 DESC

-- Global Number
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
-- Where location like 'Indonesia'
Where continent is not null
Order by 1,2

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
order by 2,3

-- With CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as rolling_percentage_vaccination
From PopvsVac

-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not NULL
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as rolling_percentage_vaccination
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3

Select *
From PercentPopulationVaccinated