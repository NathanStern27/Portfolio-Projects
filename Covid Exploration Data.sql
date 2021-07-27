select *
from [Portfolio Projects]..['Covid Deaths$']

select *
from [Portfolio Projects]..['Covid Vaccinations$']

--- Data Exploration ---

--- Query 1 : Looking at Total Cases vs Total Deaths In Israel ---
--- Indicates Rate of death from total Cases

select location, date, total_cases, total_deaths, concat((round(((total_deaths/total_cases)*100),1)),'%') as Death_rateVCases
from [Portfolio Projects]..['Covid Deaths$']
where location like '%Israel%'
order by 1,2

--- Query 2 : Looking at Total Cases vs Population in Israel---
--- Indicates percentage of population that has Covid

select location, date, total_cases, population, concat((round(((total_cases/population)*100),1)),'%') as Infection_rateVPop
from [Portfolio Projects]..['Covid Deaths$']
where location like '%Israel%'
and total_cases is not null
order by 1,2

---Query 3 : Which country has the highest infection rate

select location, max(cast(total_cases as int)) as highestInfectionCount, population, Max(total_cases/population)*100 as Infection_rateVPop
from [Portfolio Projects]..['Covid Deaths$']
group by location, population
order by Infection_rateVPop desc

---Quert 4 : Showing Countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeath_count
from [Portfolio Projects]..['Covid Deaths$']
where continent is not null
group by location
order by TotalDeath_count desc

--- TIME TO ANALYSE BY CONINENT (highest death count per population)

select continent, max(cast(total_deaths as int)) as TotalDeath_count
from [Portfolio Projects]..['Covid Deaths$']
where continent is not null
group by continent
order by TotalDeath_count desc

--- Global Numbers ---
--- PER DAY ---
select date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from [Portfolio Projects]..['Covid Deaths$']
where continent is not null
and total_cases is not null
group by date
order by 1,2

-- Total count --
select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, concat((round((SUM(cast(new_deaths as int))/Sum(new_cases)*100),1)),'%') as DeathPercentage
from [Portfolio Projects]..['Covid Deaths$']
where continent is not null
and total_cases is not null
order by 1,2

--- JOINING Death and Vaccine Table

Select *
from [Portfolio Projects]..['Covid Deaths$'] Dea
JOIN [Portfolio Projects]..['Covid Vaccinations$'] Vac
on dea.location = vac.location
and dea.date = vac.date

---Looking at Total Population Vs Vaccinations with Rolling Count of Vaccinations with CTE due to having to analyse a created aggregarted column

With popvsVac (continent, location, date, population, new_vaccinations, Rolling_pplvac) -- Make sure number of columns here is equal to sub-query
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,sum(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as Rolling_pplvac
from [Portfolio Projects]..['Covid Deaths$'] Dea
JOIN [Portfolio Projects]..['Covid Vaccinations$'] Vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)
Select * ,Round((Rolling_pplvac/population)*100,1) as RateofNewVacs
From popvsVac

--- Temp Table

Drop Table if exists #PercentPopulationsVaccinated --- needed when altering Temp Table
Create Table #PercentPopulationsVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_pplvac numeric,
)
Insert into #PercentPopulationsVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,sum(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as Rolling_pplvac
from [Portfolio Projects]..['Covid Deaths$'] Dea
JOIN [Portfolio Projects]..['Covid Vaccinations$'] Vac
on dea.location = vac.location
and dea.date = vac.date

Select *, Round((Rolling_pplvac/population)*100,1) as RateofNewVacs
From #PercentPopulationsVaccinated

--- Creating View to store data for later visualizations, E.G Tableau

Create view PercentPopulationsVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,sum(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as Rolling_pplvac
from [Portfolio Projects]..['Covid Deaths$'] Dea
JOIN [Portfolio Projects]..['Covid Vaccinations$'] Vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null




