/* 
Table name: cva

columns: 
Province
Country/Region
Latitude
Longitude
Date
Confirmed
Deaths
Recovered*/

--Query the newly created table cva
select * from cva where rownum<10;

--Description of each attributes of cva table
desc cva;


--1. Check NULL values
select * from cva where Province IS NULL or	Country IS NULL or Latitude IS NULL or	Longitude IS NULL or	a_date IS NULL or	Confirmed IS NULL or	Deaths IS NULL or	Recovered IS NULL;

--No. of null values in each column
select count(*)-count(province) as province,count(*)-count(country) as Country,count(*)-count(Latitude) as Latitude, count(*)-count(Longitude) as Longitude,count(*)-count(a_date) as a_date, count(*)-count(Confirmed) as Confirmed, count(*)-count(Deaths) as Deaths, count(*)-count(Recovered) as Recovered from cva;

--2. Update Null values with zeros for all columns
update cva set Province=nvl(Province,'0'),Country=nvl(Country,'0'),Latitude=nvl(Latitude,0),Longitude=nvl(Longitude,0),a_date=nvl(a_date,to_date('2001-01-01','yyyy-mm-dd')),Confirmed=nvl(Confirmed,0),Deaths=nvl(Deaths,0),Recovered=nvl(Recovered,0);

--3. Check total number of rows
select count(*) from cva;

--4. Check the start_date and end_date
select min(a_date) as start_date,max(a_date) as end_date from cva;


--5. Number of months present in dataset
select count(distinct extract(month from a_date)) as no_of_months from cva;


--6. Monthly average for confirmed, deaths, recovered
select extract(month from a_date) as months,round(avg(Confirmed)) as Avg_confirmed_count,round(avg(Deaths)) as Avg_death_count,round(avg(Recovered)) as Avg_recovered_count from cva group by extract(month from a_date) order by extract(month from a_date);


--7. Most frequent value for confirmed, deaths, recovered each month
select extract(month from a_date) as months, max(confirmed) as Max_confirmed_cases,max(recovered) as Max_recovered_cases,max(deaths) as Max_death_cases from cva group by extract(month from a_date) order by months;


--8. Minimum values for confirmed, deaths, recovered per year
select extract(year from a_date) as years,min(Confirmed) as Min_confirmed_count,min(Deaths) as Min_death_count,min(Recovered) as Min_recovered_count from cva group by extract(year from a_date) order by extract(year from a_date);

--9. Maximum values of confirmed, deaths, recovered per year
select extract(year from a_date) as years,max(Confirmed) as Max_confirmed_count,max(Deaths) as Max_death_count,max(Recovered) as Max_recovered_count from cva group by extract(year from a_date) order by extract(year from a_date);

--10. Total number of case of confirmed, deaths, recovered each month
select extract(month from a_date) as Months,sum(Confirmed) as Confirmed_count,sum(Deaths) as Death_count,sum(Recovered) as Recovered_count from cva group by extract(month from a_date) order by extract(month from a_date);


--11. Check how corona virus spread out with respect to confirmed case Eg.: total confirmed cases, their average, variance & STDEV )
select sum(confirmed) as tot_confirmed_cases, round(avg(confirmed),2) as Avg_confirmed_cases,round(variance(confirmed),2) as var,round(STDDEV(confirmed),2) as std_dev from cva;


--12. Check how corona virus spread out with respect to death case per month (Eg.: total death cases, their average, variance & STDEV )
select sum(deaths) as tot_death_cases, round(avg(deaths),2) as Avg_death_cases,round(variance(deaths),2) as var,round(STDDEV(deaths),2) as std_dev from cva;

--13. Check how corona virus spread out with respect to recovered case (Eg.: total confirmed cases, their average, variance & STDEV )
select sum(recovered) as tot_recovered_cases, round(avg(recovered),2) as Avg_recovered_cases,round(variance(recovered),2) as var,round(STDDEV(recovered),2) as std_dev from cva;


--14. Country having highest number of the Confirmed case
select * from(select country,sum(confirmed) as Tot_confirmed_cases from cva group by country order by sum(confirmed) desc) where ROWNUM<2;

--15. Country having lowest number of the death case
select * from(select country,sum(deaths) as Tot_death_cases from cva group by country order by sum(deaths)) where ROWNUM<2;

--16. Top 5 countries having highest recovered case
select * from(select country,sum(recovered) as Tot_recovered_cases from cva group by country order by sum(recovered) desc) where ROWNUM<6;


--17. Countries where the first outbreak of the coronavirus occurred
create view outbreak_date as select country,min(a_date) as date_of_outbreak from (select * from cva where confirmed>=1) group by country order by min(a_date);

select * from outbreak_date where rownum<6;

--18. No.of days taken to spread to other countries since first outbreak
select country,DATE_OF_OUTBREAK-to_date('22-01-2020','DD-MM-YYYY') as no_of_days_from_firstoutbreak from OUTBREAK_DATE;

--19. Infection rate of asian countries per month
select t1.months,t1.country,round((c_rate/population)*100,4) as infection_rate from 
(select extract(month from A_DATE) as months,country as country,sum(CONFIRMED) as c_rate from cva 
group by extract(month from A_DATE),COUNTRY order by extract(month from A_DATE))t1 inner join asia_coun on asia_coun.COUNTRY=t1.country;


--20. Percentage of infection rates by provinces relative to the entire country.
select t1.sub_coun,t1.sub_prov,round((t1.sub_conf/sum(cva.confirmed))*100,6) as percent_of_contribution from
(SELECT distinct cva.country as sub_coun, cva.province as sub_prov,sum(cva.confirmed) as sub_conf FROM 
cva inner join (select country from cva group by country having count(distinct province)>1) 
t1 on t1.country=cva.country group by cva.country, cva.province)t1 inner join 
cva on cva.country=t1.sub_coun group by t1.sub_coun,t1.sub_prov,t1.sub_conf order by t1.sub_coun;



select country,sum(recovered), sum(confirmed),sum(deaths) from cva group by COUNTRY having country='Canada';

--21. Recovery rate of each country
select country,round((sum(recovered)/sum(confirmed))*100,4) as recovery_rate from cva group by COUNTRY order by recovery_rate desc;

--22. How long does corona infection last in various provinces
select province,
max(case when confirmed=0 then a_date end)-min(case when confirmed>0 then a_date end) as no_of_days
 from cva where province in (select PROVINCE from cva where a_date='13-06-2021' and confirmed=0) group by province order by no_of_days;
 

 
--23. Calculating the percentage of confirmed cases during the Christmas season relative to the total confirmed cases in the country.
create view festive_infection as select province,sum(c) as confirmed_cases from(select province,a_date,confirmed as c from cva where a_date>='01-12-2020' and a_date<='05-01-2021') group by province order by province;


select t1.province,round((t1.CONFIRMED_CASES/t2.t2_confirm)*100,2) as percent_of_total_cases from FESTIVE_INFECTION t1 inner join (select province,sum(confirmed) as t2_confirm from cva group by province)t2 on t1.PROVINCE=t2.province where round((t1.CONFIRMED_CASES/t2.t2_confirm)*100,2)>10.0;