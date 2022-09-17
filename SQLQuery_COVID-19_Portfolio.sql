
SELECT *
FROM [Portfolio project]..COVIDDeaths
where continent is not null AND location not like '%income%'
ORDER BY 3,4

SELECT *
FROM [Portfolio project]..COVIDVaccinations
ORDER BY 3,4

SELECT Location,date,total_cases,new_cases,total_deaths,total_tests,population
FROM [Portfolio project]..COVIDDeaths
where continent is not null AND location not like '%income%'
ORDER BY 1,2

SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio project]..COVIDDeaths
where continent is not null AND location not like '%income%'
ORDER BY 1,2

SELECT Location,date,total_cases,population, (total_cases/population)*100 as CasesPercentage
FROM [Portfolio project]..COVIDDeaths
where continent is not null AND location not like '%income%'
ORDER BY 1,2

--SELECT Location,population, MAX(total_cases) MAX_CASES, Max((total_cases/population))*100 Max_case_percentage
--FROM [Portfolio project]..COVIDDeaths
--where continent is not null AND location not like '%income%'
--GROUP BY location, population
--ORDER BY Max_case_percentage DESC

SELECT Location,population, Max((total_cases/population))*100 Max_case_percentage
FROM [Portfolio project]..COVIDDeaths
where continent is not null AND location not like '%income%'
GROUP BY location, population
ORDER BY Max_case_percentage DESC

--All Country level analysis

SELECT Location, MAX(cast(total_deaths as int)) TotalDeathCountCty, MAX(cast(total_cases as int)) TotalCasesCountCty
FROM [Portfolio project]..COVIDDeaths
where continent is not null AND location not like '%income%'
GROUP BY location
ORDER BY TotalDeathCountCty DESC

SELECT Location, MAX(cast(total_vaccinations as bigint)) TotalVaccinationCountCty, MAX(cast(total_boosters as int)) TotalBoostersCountCty
FROM [Portfolio project]..COVIDVaccinations
where continent is not null AND location not like '%income%'
GROUP BY location
ORDER BY TotalVaccinationCountCty DESC

----EU4+UK,US level analysis

--SELECT Location, MAX(cast(total_deaths as int)) TotalDeathCountSpc, MAX(cast(total_cases as int)) TotalCasesCountSpc
--FROM [Portfolio project]..COVIDDeaths
--where location = 'Germany' OR location = 'France' OR location = 'Italy' OR location = 'Spain' OR location = 'United Kingdom'
--OR location = 'United States'
--GROUP BY location
--ORDER BY TotalDeathCountSpc DESC

--SELECT Location, MAX(cast(total_vaccinations as bigint)) TotalVaccinationCountCty, MAX(cast(total_boosters as int)) TotalBoostersCountCty
--FROM [Portfolio project]..COVIDVaccinations
--where (location = 'Germany' OR location = 'France' OR location = 'Italy' OR location = 'Spain' OR location = 'United Kingdom'
----OR location = 'United States'
--GROUP BY location
--ORDER BY TotalVaccinationCountCty DESC


--Continent level analysis

SELECT continent, MAX(cast(total_deaths as int)) TotalDeathCount, MAX(cast(total_cases as int)) TotalCasesCountCont
FROM [Portfolio project]..COVIDDeaths
where continent is not null AND location not like '%income%'
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(cast(total_vaccinations as bigint)) TotalVaccinationCountCont, MAX(cast(total_boosters as int)) TotalBoostersCountCont
FROM [Portfolio project]..COVIDVaccinations
where continent is not null AND location not like '%income%'
GROUP BY continent
ORDER BY TotalVaccinationCountCont DESC

SELECT date, sum(new_cases) cases_global, sum(cast(new_deaths as int)) deaths_global, SUM(cast(New_deaths as int))/sum(new_cases)*100 deathpercentageglobal
FROM [Portfolio project]..COVIDDeaths
where continent is not null AND location not like '%income%'
GROUP BY date
ORDER BY 1,2

SELECT sum(new_cases) cases_global, sum(cast(new_deaths as int)) deaths_global, SUM(cast(New_deaths as int))/sum(new_cases)*100 deathpercentageglobal
FROM [Portfolio project]..COVIDDeaths
where continent is not null AND location not like '%income%' AND new_cases is not null AND new_deaths is not null
ORDER BY 1,2

SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM (CONVERT(bigint,vacc.new_vaccinations)) OVER (Partition By death.location)
FROM [Portfolio project]..COVIDDeaths death
Join [Portfolio project]..COVIDVaccinations vacc
     On death.location = vacc.location 
	 AND death.date = vacc.date
where death.continent is not null AND death.location not like '%income%'
Order by 2,3

----Approach using LTE

--With PopvsVac (Continent,Location,Date,Population, new_vaccinations,Rollingpeoplevaccinated)
--as
--(
--Select death.continent, death.location, death.date, death.population, new_vaccinations
--, SUM (CONVERT(bigint,vacc.new_vaccinations)) OVER (Partition By death.location ORDER BY death.location,
-- death.date) as Rollingpeoplevaccinated
--FROM [Portfolio project]..COVIDDeaths death
--Join [Portfolio project]..COVIDVaccinations vacc
--     On death.location = vacc.location 
--	 AND death.date = vacc.date
--where death.continent is not null AND death.location not like '%income%'
--)
--Select *,
--From PopvsVac

DROP TABLE IF EXISTS #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
Select death.continent, death.location, death.date, death.population, new_vaccinations
, SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (Partition By death.location ORDER BY death.location,
 death.date) as Rollingpeoplevaccinated
FROM [Portfolio project]..COVIDDeaths death
Join [Portfolio project]..COVIDVaccinations vacc
     On death.location = vacc.location 
	 AND death.date = vacc.date
where death.continent is not null AND death.location not like '%income%'

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #percentpopulationvaccinated


Create View percentpopulationvaccinated as
Select death.continent, death.location, death.date, death.population, new_vaccinations
, SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (Partition By death.location ORDER BY death.location,
 death.date) as Rollingpeoplevaccinated
FROM [Portfolio project]..COVIDDeaths death
Join [Portfolio project]..COVIDVaccinations vacc
     On death.location = vacc.location 
	 AND death.date = vacc.date
where death.continent is not null AND death.location not like '%income%'

SELECT continent,location
FROM [Portfolio project]..COVIDDeaths
where continent is not null AND location not like '%income%'
GROUP BY CONTINENT,location
ORDER BY 1