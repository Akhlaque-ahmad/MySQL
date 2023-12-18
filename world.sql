show databases;

use world;
show tables;


select *from city;
select *from country;
select *from countrylanguage;







select name,population from city;
select name,population ,population+1 as newpop from city;

--- can we do maths with cols ? yes

select name,population ,population /2  as halfpopulation from city;

-- filtering records using where

select *from city where id=74;
select *from city where population < 700;


select *from city where countrycode='IND';


select *from city where district='Punjab';

-- using logical operatore AND, OR, NOT:

select *from city where district='Punjab' and countrycode='IND';

select *from city where id=5 or id = 15 or id=55;

# select all city whose id is bwteen 2-999

select *from city where  (id>=2 and id<=999);

--- obs the diff

select *from city where not (id>=2 and id<=999);

# sql best practises use 'between' to capture data in range

select *from city where id between 2 and 9;
select *from city where id not between 2 and 9;

# id matches either with 7,17,77
-- in keyword : single cols with multiple attributes

select *from city where id in(7,17,77);

# except from ind , china and autralia

select *from city where countrycode not in('ind','chn','aus');

-- distinct use to eliminate duplicate

select continent from country;
select distinct continent from country;

# sorting using order by
# to get population in desc (order by colm )

select *from city order by population desc;

select *from city order by population desc limit 5;


# ------aggregates fns (max,min,sum,avg,count)-statistical facts from data

select max(population),min(population),avg(population),sum(population),count(population) from city;

# count exclude null values


# to get null values

select name , indepyear from country;
select *from country where indepyear is null;    # using is keyword and '=' will reuturn 0 rows,so when compare cols use 'is' keyword

select count(*) from country where indepyear is null;    # to get total count of null values

-- filling null with NA with if null()

select name ,ifnull(indepyear,'Not Available') as 'newindepyear' from country;
select *from countrylanguage;









-- Pattern based search using like key

select *from city where name like 'mo%';    # % after word means start with
select *from city where name like '%nagar'; # %before word mean end with

select *from city where name like '%ing%';  # contains ing in between

select *from city where name like '____';  # city name exactly 4 characters,here 1 '_' means 1 character

select *from city where name like '_o___';  # city name with 4 ch where 2nd ch is 'o'


# find langdetails spoken by 80-90% of people and is official lang

select *from countrylanguage;

select * from countrylanguage  where isOfficial='T' and percentage between 80 and 90;


-- Proper case

select pname,
concat(upper(substring(pname,1,1))  , substring(pname,2))from stock;  
 # extract 1 ch from pname and convert it into upper and leave all ch in small






# ----Grouping

select name,continent from country;

select distinct continent from country;   # to get unique records use distinct

# find the count of contries in each continent

select count(name) as countrycount from country group by continent; 

select  continent , count(name) as 'countryCount' from country
	group by continent;

select continent, surfacearea from country;

select sum(surfacearea) as totalsurfacearea, continent from country group by continent order by totalsurfacearea desc;

-- Nested query

 # find the details of most populated city in the world
select max(population) from city;

select *from city where population =10500000;

--	OR

select *from city where population =(select max(population) from city); 

-- you are asked to the name of countries that speak ‘hindi’ as one of their language

select name from country where CODE in 
(select countrycode from countrylanguage where language ='hindi');









--- Joins

use restaurants_db;

show tables;


select *from online_customers;
select *from walkin_customers;

select 
wc.customername as 'walkinCustomer',
oc.customername as 'onlineCustomer',
wc.phoneno as 'walkinContact',
oc.phoneno as 'onlineContact',
ratings
from
walkin_customers as wc inner join online_customers as oc
on 
wc.phoneno = oc.phoneno;



select 
wc.customername as 'walkinCustomer',
oc.customername as 'onlineCustomer',
wc.phoneno as 'walkinContact',
oc.phoneno as 'onlineContact',
ratings
from
walkin_customers as wc left join online_customers as oc
on 
wc.phoneno = oc.phoneno;


select 
wc.customername as 'walkinCustomer',
oc.customername as 'onlineCustomer',
wc.phoneno as 'walkinContact',
oc.phoneno as 'onlineContact',
ratings
from
walkin_customers as wc right join online_customers as oc
on 
wc.phoneno = oc.phoneno;




select 
wc.customername as 'walkinCustomer',
oc.customername as 'onlineCustomer',
wc.phoneno as 'walkinContact',
oc.phoneno as 'onlineContact',
ratings
from
walkin_customers as wc left join online_customers as oc
on 
wc.phoneno = oc.phoneno

union

select 
wc.customername as 'walkinCustomer',
oc.customername as 'onlineCustomer',
wc.phoneno as 'walkinContact',
oc.phoneno as 'onlineContact',
ratings
from
walkin_customers as wc right join online_customers as oc
on 
wc.phoneno = oc.phoneno;

