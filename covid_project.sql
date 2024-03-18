select covid_deaths.location, covid_deaths.population, sum(covid_deaths.total_cases) as total cases
from covid_deaths

group by location, population
order by 1

select * from covid_deaths where continent is not null and new_cases > 0 order by date asc

select sum(covid_deaths.population) as total_pop, sum(convert(Int,covid_deaths.total_cases)) from covid_deaths

select continent, location, population, max(covid_deaths.total_cases) as total_cases, (max(covid_deaths.total_cases)/population)*100 as covid_rate 
from covid_deaths
--where location = 'Pakistan'
group by location, population, continent
order by covid_rate desc

select continent, location, population, max(covid_deaths.total_deaths) as total_deaths, (max(covid_deaths.total_deaths)/population)*100 as death_rate 
from covid_deaths
where location = 'Pakistan'
--where continent is not null
group by location, population, continent
order by location desc

select location, max(covid_deaths.total_deaths) as total_deaths 
from covid_deaths
--where location = 'Qatar'
where continent is not null
group by location
order by total_deaths desc


alter table covid_deaths alter column population bigint

select column_name, data_type
from INFORMATION_SCHEMA.COLUMNS
where table_name = 'covid_deaths'

select sum(distinct(a.population)) world_pop, sum(a.new_cases) inf_rate, sum(a.new_deaths) death_rate
from covid_deaths a
where continent is not null

select distinct(b.location), b.population, sum(b.new_cases) as total_cases, sum(b.new_deaths) as total_deaths
from covid_deaths b
where b.continent is not null
and b.location = 'Qatar'
group by b.location, b.population
order by 1

select sum(distinct(c.population)) as world_pop
from covid_deaths c
where continent is not null


select * from covid_deaths where date = (select max(date) from covid_deaths) 

---BOTH TABLES JOIN DEATHS AND VACCINATIONS

alter table covid_vaccinations alter column new_vaccinations bigint

select column_name, data_type
from INFORMATION_SCHEMA.COLUMNS
where table_name = 'covid_vaccinations'


select vacc.date, format(dea.population, '#,000') pop, 
format(cast(vacc.total_vaccinations as int), '#,0') total_vacc, 
format(cast(vacc.new_vaccinations as int), '#,0') new_vacc
from covid_project..covid_deaths dea
join covid_project..covid_vaccinations vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
and vacc.location = 'Pakistan' --and vacc.new_vaccinations > 0
--group by dea.population
order by vacc.date desc

select vacc.location, format(dea.population, '#,000') pop, 
format(max(vacc.total_vaccinations), '#,0') total_vacc, 
format(sum(vacc.new_vaccinations), '#,0') new_vacc,
(sum(vacc.new_vaccinations)/cast(dea.population as float))*100 vacc_new_rate
from covid_project..covid_deaths dea
join covid_project..covid_vaccinations vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
and vacc.location = 'Qatar'
group by vacc.location, dea.population
order by 5 desc

----CTE

With PopvsVacc (continet, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, --total_vaccinations, 
sum(vacc.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_project..covid_deaths dea
join covid_project..covid_vaccinations vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
and vacc.location = 'Qatar'
--order by 2,3,4)
)
select *, (RollingPeopleVaccinated/cast(population as float))*100 as new_vacc_rate from PopvsVacc


----TEMP TABLE
DROP TABLE If exists #PopVaccinated
Create Table #PopVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PopVaccinated

select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, --total_vaccinations, 
sum(vacc.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_project..covid_deaths dea
join covid_project..covid_vaccinations vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
--and vacc.location = 'Qatar'
order by 2,3,4

select *, (RollingPeopleVaccinated/cast(population as float))*100 as new_vacc_rate from #PopVaccinated

----CREATE VIEW TO STORE DATA FOR LATER VISUALIZATION
Create View PopVaccRate as
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, --total_vaccinations, 
sum(vacc.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_project..covid_deaths dea
join covid_project..covid_vaccinations vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
--and vacc.location = 'Qatar'

 select * from PopVaccRate

