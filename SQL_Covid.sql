-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Select *
From portfolioprojectcovid.coviddeathsdosDos
Where continent is not null 
order by 3,4;


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From portfolioprojectcovid.coviddeathsdos
Where continent is not null 
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolioprojectcovid.coviddeathsdos
Where location like '%states%'
and continent is not null 
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From portfolioprojectcovid.coviddeathsdos
-- Where location like '%states%'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolioprojectcovid.coviddeathsdos
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From portfolioprojectcovid.coviddeathsdos
-- Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
From portfolioprojectcovid.coviddeathsdos
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From  portfolioprojectcovid.coviddeathsdos
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

With PopvsVac (continent, location, date, population, `new vaccinations`, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.`new vaccinations`
, SUM(vac.`new vaccinations`) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From  portfolioprojectcovid.coviddeathsdos dea
Join  portfolioprojectcovid.covidvaccinationsdos vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Temp Table


-- Drop the temporary table if it exists
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

-- Create the temporary table
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime, 
    Population numeric, 
    New_Vaccinations numeric,
    RollingPeopleVaccinated numeric
);

-- Insert data into the temporary table
INSERT INTO PercentPopulationVaccinated (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.`new vaccinations`, 
    SUM(vac.`new vaccinations`) OVER (PARTITION BY dea.location ORDER BY dea.Date) as RollingPeopleVaccinated
FROM 
    portfolioprojectcovid.coviddeathsdos dea
JOIN 
    portfolioprojectcovid.covidvaccinationsdos vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date;

-- Select from the temporary table and calculate percentage
SELECT 
    *, 
    (RollingPeopleVaccinated / Population) * 100 AS PercentVaccinated
FROM 
    PercentPopulationVaccinated;
    
    
    
    
    
    



