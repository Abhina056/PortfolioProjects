/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT * 
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;


--Select specific data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;




-- Looking at Total Cases vs Total Deaths
-- Shows probability of death if contracted with covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths::decimal /total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location like '%India%'
WHERE continent IS NOT NULL
ORDER BY 1, 2;



-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid infected

SELECT location, date, population, total_cases, (total_cases::decimal/population)*100 as Population_Effected_Percentage
FROM coviddeaths
WHERE location like '%India%'
WHERE continent IS NOT NULL
ORDER BY 1, 2;



-- Looking at countries with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases::decimal /population))*100 as Population_EffectedPercentage
FROM coviddeaths
--WHERE location like '%India%'
WHERE continent IS NOT NULL
GROUP BY location, population 
ORDER BY Population_EffectedPercentage DESC;


-- Showing countries with Highest Death count per population

SELECT location, MAX(CAST(total_deaths as int)) as HighestdeathCount
FROM coviddeaths
--WHERE location like '%India%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestdeathCount DESC;



-- BREAKING THINGS DOWN BY CONTINENT
-- Showing continents with Highest Death Counts 

SELECT continent, MAX(CAST(total_deaths as int)) as HighestdeathCount
FROM coviddeaths
--WHERE location like '%India%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestdeathCount DESC;


-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
--WHERE location like '%India%' 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;



--Looking at Total Population vs Vaccination
-- Shows Percentage of population that has received atleast one covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS Percentpopulationvaccinated;
CREATE TABLE Percentpopulationvaccinated
(
continent varchar(100),
	location varchar(100),
	date date,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
;

INSERT INTO Percentpopulationvaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM Percentpopulationvaccinated;



-- Creating view to store data for later visualizations

CREATE VIEW Percentagepopulationvaccinated1 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

SELECT *
FROM Percentagepopulationvaccinated1;
