CREATE DATABASE HR_project;

use HR_project;

select * from hr;

-- Data Cleaning &  Preprocessing--

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

describe hr;
SET sql_safe_updates = 0;

-- changing data format & data type of birthdate Column--
UPDATE hr
SET birthdate = CASE
WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
Else NULL 
END;

ALTER TABLE hr
MODIFY column birthdate DATE;

-- changing data format & data type of hire_date Column--

UPDATE hr
SET hire_date = CASE
WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
Else NULL 
END;

ALTER TABLE hr
MODIFY column hire_date DATE;

-- changing data format & data type of termdate Column--
UPDATE hr
SET termdate = date (str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

UPDATE hr
SET termdate = NULL
WHERE termdate = '';

-- creating an age column--
ALTER TABLE hr
ADD Column age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, curdate());
select min(age), max(age)
from hr;

-- 1. what is the gender breakdown of employees in the company --

SELECT gender , count(*) AS COUNT
from hr
WHERE termdate IS NULL
group by 1;


-- 2. what is the race breakdown of employees in the company --

SELECT race , count(*) AS COUNT
from hr
WHERE termdate IS NULL
group by 1;


-- 3. what is the age distribution of employees in the company --

select 
case 
 when age >= 18 and age <= 24 then '18-24'
 when age >= 25 and age <= 34 then '25-34'
 when age >= 35 and age <= 44 then '35-44'
 when age >= 45 and age <= 54 then '45-54'
 when age >= 55 and age <= 64 then '55-64'
 else '65+'
END AS age_group,
count(*) as count
from hr
where termdate is null
group by age_group
order by age_group;

-- 4. how many employees work in HQ VS Remote --
select location, count(*) as count
from hr
where termdate is null
group by 1;

-- 5. what the average length of emplyement for terminated staff--
 select round(avg(year(termdate) - year(hire_date)),0) as length_of_emp
 from hr
 where termdate is not null and termdate <= curdate();
 
-- 6. how does the gender distribution vary acros dept and job titles--
select department, jobtitle, gender, count(*) as count 
from hr
where termdate is null
group by 1,2,3
order by 1,2,3;

select department, gender, count(*) as count
from hr
where termdate is null
group by 1,2
order by 1,2;

-- 7. what is the distribution of job titles across the company--

select jobtitle, count(*) as count
from hr
where termdate is null
 group by 1;
 
 -- 8. which department has the highest turnover rate--
 
 select department, 
 count(*) as total_count,
count(case when termdate is not null and termdate <= curdate() then 1 End) AS terminated_count,
round((count(case when termdate is not null and termdate <= curdate() then 1 End)/count(*))*100, 2) as turnover_rate
 from hr
 group by 1
 order by turnover_rate desc;
 
 -- 9. what is the distribution of employees across location_state / city--
 
 select location_state, count(*) as count
 from hr
 where termdate is null
 group by 1;
 
  select location_city, count(*) as count
 from hr
 where termdate is null
 group by 1;
 
 -- 10. how has the company's employee count changed over time based on hire and termination date --
 select * from hr;
 
 select year, hires, terminations, hires-terminations as net_change,
 (terminations/hires)*100 as change_percent
 from (
 select year(hire_date) as year,
 count(*) as hires,
 sum(case
       when termdate IS NOT NULL AND termdate <= curdate() then 1 
	end) as terminations
       from hr
       group by year(hire_date)) as sub
       
group by year
order by year;       
 
-- 11 what is the tenure distribution for each department --
select department,round(avg(datediff(termdate, hire_date)/365),0) as avg_tenure
from hr
where termdate is not null and termdate <= curdate()
group by 1;
 
 
 -- 12. department wise distribution --
select department, count(*) as count
from hr
where termdate is null
group by 1
order by 1;

-- 13. termination and hire breakdown gender wise --

select
 gender, 
 total_hires,
 total_terminations, 
 ROUND((total_terminations/total_hires)*100,2) AS termination_rate
FROM(
     select gender, 
     COUNT(*) AS total_hires,
     COUNT( CASE
            WHEN termdate is not null and termdate <= curdate() THEN 1 END)
            AS total_terminations
     from hr
     GROUP by gender) as sub1
GROUP BY 1;

-- age --
select
 age, 
 total_hires,
 total_terminations, 
 ROUND((total_terminations/total_hires)*100,2) AS termination_rate
FROM(
     select age, 
     COUNT(*) AS total_hires,
     COUNT( CASE
            WHEN termdate is not null and termdate <= curdate() THEN 1 END)
            AS total_terminations
     from hr
     GROUP by age) as sub1
GROUP BY 1   
order by 1;

-- dept --
select
 department, 
 total_hires,
 total_terminations, 
 ROUND((total_terminations/total_hires)*100,2) AS termination_rate
FROM(
     select department, 
     COUNT(*) AS total_hires,
     COUNT( CASE
            WHEN termdate is not null and termdate <= curdate() THEN 1 END)
            AS total_terminations
     from hr
     GROUP by 1) as sub1
GROUP BY 1   
order by 1; 

 -- Race --
 
 select
 race, 
 total_hires,
 total_terminations, 
 ROUND((total_terminations/total_hires)*100,2) AS termination_rate
FROM(
     select race, 
     COUNT(*) AS total_hires,
     COUNT( CASE
            WHEN termdate is not null and termdate <= curdate() THEN 1 END)
            AS total_terminations
     from hr
     GROUP by 1) as sub1
GROUP BY 1   
order by 1;

-- year --
select
 year, 
 total_hires,
 total_terminations, 
 ROUND((total_terminations/total_hires)*100,2) AS termination_rate
FROM(
     select YEAR(hire_date) as year,
     COUNT(*) AS total_hires,
     COUNT( CASE
            WHEN termdate is not null and termdate <= curdate() THEN 1 END)
            AS total_terminations
     from hr
     GROUP by 1) as sub1
GROUP BY 1   
order by 1;
