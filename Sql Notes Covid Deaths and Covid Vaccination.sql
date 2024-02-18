  Select *
  From Portfolio_project.dbo.CovidDeaths
  Order by 3,4

  Select *
  From Portfolio_project.dbo.CovidVaccinations 
  Order by 3,4

  --Select Data that we are going to be using 

  Select Location, date, total_cases, new_cases, total_deaths, population
  From Portfolio_project.dbo.CovidDeaths
  Order By 1,2 

  --Looking at Total cases vs Total Deaths
  --Shows the likelihood of dying if you contract covid in your country 

  Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage 
  From Portfolio_project.dbo.CovidDeaths
  Where location like '%Nigeria%'
  Order by 1,2 
  


  --looking at the total cases vs the population 
  --shows what percentage of population got Covid

  Select Location, date, population, total_cases, (total_deaths/population)*100 as percentpopulationinfected  
  From Portfolio_project.dbo.CovidDeaths
  Where location like '%Nigeria%'
  Order by 1,2


  --looking at countries with highest infection rate compared to population

   Select Location, Population, MAX(total_cases) as Highestinfectioncount, Max((total_cases/population))*100 as percentpopulationinfected
  From Portfolio_project.dbo.CovidDeaths
  --Where location like '%Nigeria%'
  Group by Location, Population
  Order by percentpopulationinfected desc
  

  --This is to order th population  desc with the highest infection count .. my  query
  Select Location, Population, Max (Total_cases) as highestinfectioncount 
  From Portfolio_project.dbo.CovidDeaths
  Group by population, location
  Order by 2,1 asc 
 

 --showing the countries with the highest death count per population
 --Cast will show the total death count as an integer
 
  Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
  From Portfolio_project.dbo.CovidDeaths
  --Where location like '%Nigeria%'
  Where continent is not NULL 
  Group by Location
  Order by TotalDeathCount desc

 
 --LETS'S BREAK THINGS DOWN BY CONTINENT 

  Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
  From Portfolio_project.dbo.CovidDeaths
  --Where location like '%Nigeria%'
  Where continent is  NULL 
  Group by Location
  Order by TotalDeathCount desc


   --showing the continent with the highest death count per population

  Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
  From Portfolio_project.dbo.CovidDeaths
  --Where location like '%Nigeria%'
  Where continent is  NULL 
  Group by Continent
  Order by TotalDeathCount desc


  --	Global Numbers 
  --AS helps to give the column a name or how you want something to be in your query
  --This query gives the number of people affected around the world accordiing to dates . 

  Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(Cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
  From Portfolio_project.dbo.CovidDeaths
  --Where location like '%Nigeria%'
  WHERE continent is not NULL
  Group by Date
  Order by 1,2 

  --This will give us the total cases,total deathas and death percentage 

  Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(Cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
  From Portfolio_project.dbo.CovidDeaths
  --Where location like '%Nigeria%'
  WHERE continent is not NULL
  --Group by Date
  Order by 1,2 


  --looking at Total population vs vaccination 

  Select *
  From Portfolio_project.dbo.CovidDeaths  dea
  JOIN Portfolio_project.dbo.CovidVaccinations vac
  ON dea.Location = vac.location
  AND dea.date = vac.date


    With PopvsVac(Continent,location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
	as
	(
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
       ,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	   dea.Date) as Rollingpeoplevaccinated 
	   --,(Rollingpeoplevaccinated/population)*100
  From Portfolio_project.dbo.CovidDeaths  dea
  JOIN Portfolio_project.dbo.CovidVaccinations vac
           ON dea.Location = vac.location
           AND dea.date = vac.date
  where dea.continent is not null
 -- Order by 2,3 
  )
  Select *, (RollingPeopleVaccinated/Population)*100
   From PopvsVac

  
  --Temp Table 

  DROP Table if exists #PercentPopulationVaccinated
  Create Table #PercentPopulationVaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

   Insert Into #PercentPopulationVaccinated
   Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	   dea.Date) as Rollingpeoplevaccinated 
	   --,(Rollingpeoplevaccinated/population)*100
  From Portfolio_project..CovidDeaths  dea
  JOIN Portfolio_project..CovidVaccinations vac
           ON dea.Location = vac.location
           AND dea.date = vac.date
  --where dea.continent is not null
 -- Order by 2,3 

  Select *, (RollingPeopleVaccinated/Population)*100
   From #PercentPopulationVaccinated

   

   --CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

   Create View PercentPopulationVaccinated as 
   Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	   dea.Date) as Rollingpeoplevaccinated 
	   --,(Rollingpeoplevaccinated/population)*100
  From Portfolio_project..CovidDeaths  dea
  JOIN Portfolio_project..CovidVaccinations vac
           ON dea.Location = vac.location
           AND dea.date = vac.date
  where dea.continent is not null
  --Order by 2,3 
                           