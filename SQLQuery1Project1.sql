SELECT * from Portfolio..CovidDeaths
where continent is not null
order by 3,4

--SELECT * from Portfolio..CovidVaccs
--order by 3,4 

--Data to be used
 SELECT location,date,total_cases,new_cases,total_deaths,population 
 from Portfolio..CovidDeaths
 where continent is not null
 order by 1,2

 -- Total Cases vs Total Deaths
 SELECT location,date,total_cases,total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercent
 from Portfolio..CovidDeaths
 where continent is not null
 order by 1,2 

 --COVID in my country
 SELECT location,date,total_cases,total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercent
 from Portfolio..CovidDeaths 
 where location like '%India%' and continent is not null
 order by 1,2 

 --Total Cases vs Population
 SELECT location,date,total_cases,population, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as TotalCasesPercent
 from Portfolio..CovidDeaths 
 --where location like '%India%'
 where continent is not null
 order by 1,2  

 --Countries with highest infection rate that is total cases/population
 SELECT location,population,MAX(total_cases) as HighestCaseCount, MAX((CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100) as MAXRATE
 from Portfolio..CovidDeaths 
 where continent is not null
 Group by location,population
 order by 4 DESC 

 --Countries with highest death cases +
 SELECT location,population,MAX(total_deaths) as HighestDeathCaseCount, MAX((CONVERT(float,total_deaths)/NULLIF(CONVERT(float,population),0))*100) as MAXDEATHRATE
 from Portfolio..CovidDeaths
 where continent is not null
 Group by location,population
 order by 4 DESC 

 --Dates of all the countries when the total deaths was maximum
 SELECT distinct(location),MAX(cast(total_deaths as int)) as HighestDeathCasesCount
 from Portfolio..CovidDeaths 
 where continent is not null
 Group by location
 order by 2 DESC

 --BY Continent wise query1
 --SELECT continent,MAX(cast(total_deaths as int)) as HighestDeathCasesCount
 --from Portfolio..CovidDeaths 
 --where continent is not null 
 --Group by continent
 --order by 2 DESC


 --BY continent wise query2 (by this method numbers are more accurate
  SELECT location,MAX(cast(total_deaths as int)) as HighestDeathCasesCount
 from Portfolio..CovidDeaths 
 where continent is null and location not like'%income%'
 Group by location
 order by 2 DESC

 --Global numbers
 Select count(distinct location) as Total_Countries,SUM(new_cases) as Total_Infected, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(new_cases) *100 as DeathPercentage
 from Portfolio..CovidDeaths
 where continent is not null
 order by 1,2

 --Population vs vaccinations  
 SELECT dea.continent,dea.location,dea.date,dea.population,vacs.new_vaccinations,
 sum(cast(vacs.new_vaccinations as bigint)) over (partition by dea.location  order by dea.location, dea.date) as total_vaccinations
 FROM Portfolio..CovidDeaths dea
 join Portfolio..CovidVaccs vacs
 on dea.location=vacs.location and dea.date=vacs.date
 where dea.continent is not null 
 order by 2,3


 --Using CTE to define the percentage of vacciantions vs population
 With PopnVacs(continent,location,date,population,vaccinations,total_vaccinations)
 as
 (
 SELECT dea.continent,dea.location,dea.date,dea.population,vacs.new_vaccinations,
 sum(cast(vacs.new_vaccinations as bigint)) over (partition by dea.location  order by dea.location, dea.date) as total_vaccinations
 FROM Portfolio..CovidDeaths dea
 join Portfolio..CovidVaccs vacs
 on dea.location=vacs.location and dea.date=vacs.date
 where dea.continent is not null 
 --order by 2,3
 )
 Select *,(total_vaccinations/population)*100 as PercentageofVaccinations 
 From PopnVacs


 --Using Temp Tables 

 DROP TABLE if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 total_vaccinations numeric
 )
 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent,dea.location,dea.date,dea.population,vacs.new_vaccinations,
 sum(cast(vacs.new_vaccinations as bigint)) over (partition by dea.location  order by dea.location, dea.date) as total_vaccinations
 FROM Portfolio..CovidDeaths dea
 join Portfolio..CovidVaccs vacs
 on dea.location=vacs.location and dea.date=vacs.date
 where dea.continent is not null 
 order by 2,3
 Select *,(total_vaccinations/population)*100 as PercentageofVaccinations 
 From #PercentPopulationVaccinated
 

--Creating the view to store date for tablaue
Create view PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vacs.new_vaccinations,
 sum(cast(vacs.new_vaccinations as bigint)) over (partition by dea.location  order by dea.location, dea.date) as total_vaccinations
 FROM Portfolio..CovidDeaths dea
 join Portfolio..CovidVaccs vacs
 on dea.location=vacs.location and dea.date=vacs.date
 where dea.continent is not null 


Select * from PercentPopulationVaccinated
 