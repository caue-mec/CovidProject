-- In this project i'm going to analyse the covid-19 data 

-- All data information was acquired in https://ourworldindata.org/covid-deaths

-- CHECK IF ALL DATA WAS IMPORTED CORRECTLY

select *

from COVIDDEATHS


order by 3


select *

from COVIDVACCINATIONS

order by 3





-- selecting data that i'm going to use 

select date,location, total_cases, new_cases, total_deaths, population

from COVIDDEATHS

order by 2




--looking total cases vs total deaths a death rate

select location, date, total_cases, total_deaths,

CASE 
     WHEN total_deaths = 0 OR total_cases = 0 THEN 0
     ELSE (total_deaths/total_cases)*100 
END AS deathrate

from COVIDDEATHS

order by 1




-- looking at total cases vs population to see what percentage of population got covid

select location, date,total_cases, population,(total_cases/population)*100 INFACTIONRATE

from COVIDDEATHS

order by 1 




-- looking the hightest infection rates per population 

select location,population, 
max(total_cases) maxinfections, 
max((total_cases/population)*100) maxinfactionrate 

from COVIDDEATHS

group by location,population

order by maxinfactionrate desc




--looking for the hights death rate per population in southamerica

SELECT location,population, 
max(total_deaths) maxdeaths, 
max((total_deaths/population)*100) maxdeathrate 

FROM COVIDDEATHS

GROUP BY location,population

ORDER BY maxdeathrate desc




-- NOW I WANTED TO SEE THE COUNTRIES WITH HIGHTEST DEATHS NUMBER IN THE WORLD

SELECT location,population, 
max(total_deaths) maxdeaths

FROM COVIDDEATHS

WHERE CONTINENT <> ''

GROUP BY location,population

ORDER BY maxdeaths desc




-- NOW I WANTED TO SEE THE CONTINENTS WITH HIGHTEST DEATHS NUMBER IN THE WORLD

SELECT location,population, 
max(total_deaths) maxdeaths,

FROM COVIDDEATHS

WHERE CONTINENT = ''

GROUP BY location,population

ORDER BY maxdeaths desc




-- GLOBAL NUMBERS BY DATES
-- the date column is set as a varchar so i need to cast it as a date


select cast(date as date), 
SUM(new_cases) casesarroundtheworld, 
SUM(new_deaths) deathsarroundtheworld,
CASE 
     WHEN SUM(new_cases) = 0 OR SUM(new_deaths) = 0 THEN 0
     ELSE (SUM(new_deaths)/SUM(new_cases))*100
END AS dealydeathrate

from COVIDDEATHS

where continent <> ''

group by date

order by 1 





--analyzing the accuracy of the table by the separate data and obtaining global values


select 
SUM(new_cases) casesarroundtheworld, 
SUM(new_deaths) deathsarroundtheworld,
CASE 
     WHEN SUM(new_cases) = 0 OR SUM(new_deaths) = 0 THEN 0
     ELSE (SUM(new_deaths)/SUM(new_cases))*100
END AS globaldeathrate

from COVIDDEATHS

where continent <> ''


order by 1 




-- joing the two tables

select *
from COVIDDEATHS dea
join COVIDVACCINATIONS vacc
	on dea.location = vacc.location 
	and dea.date = vacc.date


-- selecting data from the join

select dea.continent, dea.location,cast(dea.date as date), dea.population, vacc.new_vaccinations

from COVIDDEATHS dea
join COVIDVACCINATIONS vacc
	on dea.location = vacc.location 
	and dea.date = vacc.date

where dea.continent <> ''

group by dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations

order by 2,3




-- now i wanted to see how was the vaccination throughout the hole countries divided per dates 


select dea.continent, 
dea.location,
cast(dea.date as date), 
dea.population, 
vacc.new_vaccinations,
sum(vacc.new_vaccinations) over(partition by dea.location order by dea.location, 
								cast(dea.date as date) ) totalvaccinationperday

from COVIDDEATHS dea
join COVIDVACCINATIONS vacc
	on dea.location = vacc.location 
	and dea.date = vacc.date

where dea.continent <> ''

group by dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations

order by 2,3






-- now im using cte to easely use the data from the selection that we just created

with 
	vacc (continent, 
	location,
	date, 
	population, 
	new_vaccinations,
	totalvaccinationperday)
as
(
select dea.continent, 
dea.location,
cast(dea.date as date), 
dea.population, 
vacc.new_vaccinations,
sum(vacc.new_vaccinations) over(partition by dea.location order by dea.location, 
								cast(dea.date as date) ) totalvaccinationperday

from COVIDDEATHS dea
join COVIDVACCINATIONS vacc
	on dea.location = vacc.location 
	and dea.date = vacc.date

where dea.continent <> ''

group by dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations
)
select *, (totalvaccinationperday/population)*100
from vacc



-- using a temp table instead

--drop table if exists from #totalvaccination (if i need to make any alterations)
create table #totalvaccination
(
continent varchar(225), 
location varchar(225),
date datetime, 
population numeric, 
new_vaccinations numeric,
totalvaccinationperday numeric
)

insert into #totalvaccination
select dea.continent, 
dea.location,
cast(dea.date as date), 
dea.population, 
vacc.new_vaccinations,
sum(vacc.new_vaccinations) over(partition by dea.location order by dea.location, 
								cast(dea.date as date) ) totalvaccinationperday

from COVIDDEATHS dea
join COVIDVACCINATIONS vacc
	on dea.location = vacc.location 
	and dea.date = vacc.date

where dea.continent <> ''

group by dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations

order by 2,3

select *, (totalvaccinationperday/population)*100 peoplevaccinatedrate
from #totalvaccination




--creating view to use in future vilualizations

create view totalvaccination as

select dea.continent, 
dea.location,
cast(dea.date as date) date, 
dea.population, 
vacc.new_vaccinations,
sum(vacc.new_vaccinations) over(partition by dea.location order by dea.location, 
								cast(dea.date as date) ) totalvaccinationperday

from COVIDDEATHS dea
join COVIDVACCINATIONS vacc
	on dea.location = vacc.location 
	and dea.date = vacc.date

where dea.continent <> ''

group by dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations