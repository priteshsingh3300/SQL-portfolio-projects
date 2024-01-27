
select * 
from Portfolio_project_covid.dbo.CovidDeaths
order by 3,4

--select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from CovidDeaths
where location like '%states'
order by 1,2


--Looking at Total Cases vs Population

select location, date, total_cases, population, (total_cases/population)*100 as cases_percentage
from CovidDeaths
where location like '%states'
order by 1,2

 
 --Looking at country's highest infection as compared to population

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population)*100) as highest_cases_percentage
from CovidDeaths
group by location, population
order by highest_cases_percentage desc


--Showing countries with highest death count per population
--some continent rows are null so we are not counting those rows

select location, population, max(cast(total_deaths as int)) as highest_death_count
from CovidDeaths
where continent is not null
group by location, population
order by highest_death_count desc


--Breaking the data down as per continent

select location, max(cast(total_deaths as int)) as highest_death_count
from CovidDeaths
where continent is not null
group by location
order by highest_death_count desc


-- Global number

select date, sum(new_cases) as daily_cases, sum(cast(new_deaths as int)) as daily_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as daily_deathVSnewCases_count
from CovidDeaths
where continent is not null
group by date
order by 1,2


-- Join CovidDeaths and CovidVaccination together to get the data

select * 
from Portfolio_project_covid.dbo.CovidDeaths CD
inner join Portfolio_project_covid.dbo.CovidVaccinations CV
on CD.location = CV.location


-- Looking at total vaccinations and total population

select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 

-- we want to get the total new vaccinations in particular country
	sum(cast(CV.new_vaccinations as Int)) 
	over(partition by CD.location -- order by CD.location, CV.new_vaccinations) --> order  by is not possible because max byte limit is 900
	)as total_new_vacc,

-- we want to get percentage population got vaccinated recently as compare to population

--(total_new_vacc/CD.population)*100 --> alias can't be used as coloumn immediately after it made so we will use CTE

--please see next query to get an idea

from Portfolio_project_covid.dbo.CovidDeaths CD
inner join Portfolio_project_covid.dbo.CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
order by 1,2,3

-- CTE 

with NewVacvsPop (continent, location, date, population, new_vaccinations, total_new_vacc)
as
(
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
	sum(cast(CV.new_vaccinations as Int)) 
	over(partition by CD.location 
	)as total_new_vacc
from Portfolio_project_covid.dbo.CovidDeaths CD
inner join Portfolio_project_covid.dbo.CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
-- order by 1,2,3 --> order by clause can't be used inside CTE
)

select *, (total_new_vacc/population)*100 as vacc_percentWpop --> now we are able to create coloumn from alias we made
from NewVacvsPop


-- we can use Temp table as well instead of CTE

drop table #NewVacvsPop --> "There is already an object named '#NewVacvsPop' in the database" error will occur 
-- if we run same program multiple time so we need drop table query
create Table #NewVacvsPop 
(
continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric, --> data type INT can't be used here as number will go into many decimal places
new_vaccinations numeric, --> data type INT can't be used here as number will go into many decimal places 
total_new_vacc numeric --> data type INT can't be used here as number will go into many decimal places
)
insert into #NewVacvsPop
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
	sum(cast(CV.new_vaccinations as Int)) 
	over(partition by CD.location 
	)as total_new_vacc
from Portfolio_project_covid.dbo.CovidDeaths CD
inner join Portfolio_project_covid.dbo.CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
order by 1,2,3 


select *, (total_new_vacc/population)*100 as vacc_percentWpop
from #NewVacvsPop


-- create view for later visualisation purpose

create view view_NewVacvsPop
as
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
	sum(cast(CV.new_vaccinations as Int)) 
	over(partition by CD.location 
	)as total_new_vacc
from Portfolio_project_covid.dbo.CovidDeaths CD
inner join Portfolio_project_covid.dbo.CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
-- order by 1,2,3 --> order by clause is not valid in view

select * from view_NewVacvsPop









