select *
from Portofolio_project..Covid_death 
order by 3,4

--select *
--from Portofolio_project..Covid_vaccination
--order by 3,4

--Data selection 

select Location, date, total_cases, new_cases, total_deaths, population
from Portofolio_project..Covid_death 
order by 1,2 

--Total cases vs Total deaths 

--Data Type convertion...
alter table Portofolio_project..Covid_death alter column total_cases FLOAT
alter table Portofolio_project..Covid_death alter column total_deaths FLOAT

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from Portofolio_project..Covid_death 
where location='Cameroon'
order by 1,2 

--Total cases vs Population 

select Location, date, population, total_cases, (total_deaths/population)*100 as InfectionPercentage 
from Portofolio_project..Covid_death 
where location='Cameroon'
order by 1,2 


--Highest infection rate with respect to each country
select Location, population, max(total_cases) as HighestInfectionCount, max((total_deaths/population)*100) as HighestInfectionRate 
from Portofolio_project..Covid_death 
--where location='Cameroon'
group by Location, population
order by HighestInfectionRate  desc 

--Highest death rate with respect to pop 

select Location,  max(total_deaths) as HighestDeathCount
from Portofolio_project..Covid_death 
--where location='Cameroon'
group by Location
order by HighestDeathCount  desc 

-- By continent 
-- showing continents with the highest death count per population 

select continent,  max(total_deaths) as HighestDeathCount
from Portofolio_project..Covid_death 
where continent is not null
group by continent
order by HighestDeathCount  desc 

-- GLOBAL NUMBERS 

--select date, sum(new_cases) as GlobalCasesNumber, sum(cast(new_deaths as int)) as GlobalDeathsNumber 
--(sum(new_cases)/sum(cast(new_deaths as int)))*100 as GlobalDeathsPercentage 
--from Portofolio_project..Covid_death 
--where new_deaths is not null and continent is not null
----where continent is not null  
--group by date 
--order by 2,3 

select date, GlobalCasesNumber, GlobalDeathsNumber, (GlobalDeathsNumber/GlobalCasesNumber)*100 as GlobalDeathsPercentage 
from ( 
select date, sum(new_cases) as GlobalCasesNumber, sum(cast(new_deaths as int)) as GlobalDeathsNumber 
from Portofolio_project..Covid_death 
--where new_deaths is not null and continent is not null
where continent is not null  
group by date 
 ) as TempTable
where GlobalCasesNumber is not null
--order by GlobalDeathsPercentage desc


alter table Portofolio_project..Covid_vaccination alter column new_vaccinations FLOAT
-- Total population vs Vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RolliingPeopleVaccinated 
from Portofolio_project..Covid_death as dea
join Portofolio_project..Covid_vaccination as vac 
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent  is not null 
order by 2,3 

--USE CTE 
with PopvsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated  )

as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from Portofolio_project..Covid_death as dea
join Portofolio_project..Covid_vaccination as vac 
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent  is not null 
--order by 2,3 
)
select * , (RollingPeopleVaccinated/Population)*100 
from PopvsVac


-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations  numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from Portofolio_project..Covid_death as dea
join Portofolio_project..Covid_vaccination as vac 
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent  is not null 
--order by 2,3 

select  * , (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated


-- View creation for later usage 

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from Portofolio_project..Covid_death as dea
join Portofolio_project..Covid_vaccination as vac 
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent  is not null 
--order by 2,3 

select * 
from PercentPopulationVaccinated

