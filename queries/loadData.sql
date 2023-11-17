-- Brian Dewhirst, 2023-11-17
-- ref: https://blog.skyvia.com/3-easy-ways-to-import-csv-file-to-sql-server/
--
-- yes, whether you can do this in a 'real' database depends heavily on having access to the underlying server (AFAIK)
-- ... but if we're discussing loading data, that discussion would likely include specialized tools and Data Engineers/Data Engineering job orgs.
--
-- TLDR, the data is an official failed banks list.

use newDB;

drop table if exists banksStaging;
create table banksStaging (
  bankName varchar(127),
  cityName varchar(63),
  stateCode char(2),
  certNo int,
  acquringName varchar(127),
  closeDate date,
  fundNo int,
);

bulk insert banksStaging
from 'C:\Users\Brian\source\repos\T-SQL Review\data\banklist.csv'
with (
    format='CSV',
    FIELDTERMINATOR=',',
    FIRSTROW=2,
    ROWTERMINATOR = '\n'
);
select count(*) from banksStaging;
select top 10 * from banksStaging;

select * from banksStaging where stateCode='MA';

select stateCode, count(*) as countQ
from banksStaging
group by stateCode
order by stateCode;

-- "publish" this table and delete staging table.
drop table if exists banks;
select * 
into banks
from banksStaging;
drop table banksStaging;

drop table if exists stateAbbrs;
create table stateAbbrs (
  stateCode char(2),
  stateName varchar(63),
);
insert into stateAbbrs
values
('AL','	Alabama'),
('AK','	Alaska'),
('AZ','	Arizona'),
('AR','	Arkansas'),
('AS','	American Samoa'),
('CA','	California'),
('CO','	Colorado'),
('CT','	Connecticut'),
('DE','	Delaware'),
('DC','	District of Columbia'),
('FL','	Florida'),
('GA','	Georgia'),
('GU','	Guam'),
('HI','	Hawaii'),
('ID','	Idaho'),
('IL','	Illinois'),
('IN','	Indiana'),
('IA','	Iowa'),
('KS','	Kansas'),
('KY','	Kentucky'),
('LA','	Louisiana'),
('ME','	Maine'),
('MD','	Maryland'),
('MA','	Massachusetts'),
('MI','	Michigan'),
('MN','	Minnesota'),
('MS','	Mississippi'),
('MO','	Missouri'),
('MT','	Montana'),
('NE','	Nebraska'),
('NV','	Nevada'),
('NH','	New Hampshire'),
('NJ','	New Jersey'),
('NM','	New Mexico'),
('NY','	New York'),
('NC','	North Carolina'),
('ND','	North Dakota'),
('MP','	Northern Mariana Islands'),
('OH','	Ohio'),
('OK','	Oklahoma'),
('OR','	Oregon'),
('PA','	Pennsylvania'),
('PR','	Puerto Rico'),
('RI','	Rhode Island'),
('SC','	South Carolina'),
('SD','	South Dakota'),
('TN','	Tennessee'),
('TX','	Texas'),
('TT','	Trust Territories'),
('UT','	Utah'),
('VT','	Vermont'),
('VA','	Virginia'),
('VI','	Virgin Islands'),
('WA','	Washington'),
('WV','	West Virginia'),
('WI','	Wisconsin'),
('WY','	Wyoming');

-- not quite right:
select 
  stateAbbrs.stateCode, 
  stateAbbrs.stateName, 
  count(distinct coalesce(banks.bankName, '')) as banksQ
from stateAbbrs
left join banks on stateAbbrs.stateCode = banks.stateCode
where 1=1
  -- and certNo is not null
group by stateAbbrs.stateCode, stateAbbrs.stateName
order by count(distinct coalesce(bankName, '')) desc;


select 
  stateAbbrs.stateName, 
  count(distinct bankName) as banksQ
from banks
full outer join stateAbbrs on stateAbbrs.stateCode = banks.stateCode
where 1=1
  -- and certNo is not null
group by  stateAbbrs.stateName
order by count(distinct coalesce(bankName, '')) desc;


-- follow more of original intent, and set up for next query:
drop table if exists #failedBankByStatelike;
select 
  stateAbbrs.stateName, 
  count(distinct bankName) as banksQ
into #failedBankByStatelike
from banks
right join stateAbbrs on stateAbbrs.stateCode = banks.stateCode
where 1=1
group by  stateAbbrs.stateName
order by count(distinct coalesce(bankName, '')) desc;

select * from #failedBankByStatelike
where banksQ = 0;

-- or, as a left join, with max and min dates:
select 
  stateAbbrs.stateName, 
  count(distinct bankName) as banksQ,
  max(closeDate) as maxCloseDate,
  min(closeDate) as minCloseDate
from stateAbbrs 
left join banks on stateAbbrs.stateCode = banks.stateCode
where 1=1
group by  stateAbbrs.stateName
order by count(distinct coalesce(bankName, '')) desc;
