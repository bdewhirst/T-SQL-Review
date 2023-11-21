-- Brian Dewhirst, 2023-11-21
--
-- sourced data is from data.bls.gov, sourced 2023-11-21 from https://data.bls.gov/projections/occupationProj)
--
-- given the data selected, this will likely involve some data cleanup first

-- Create table of data to analyze:

use newDB;

drop table if exists employmentProjection;
create table employmentProjection (
  occupationTitle varchar(600) not null
, occupationCode varchar(7) not null
, employment2022 DECIMAL
, employment2023 DECIMAL
, employmentChange2022_2032 DECIMAL
, employmentPercentChange2022_2032 DECIMAL
, occupationalOpeningsAnnualAverage2022_2032 DECIMAL
--, medianAnnualWage2022 DECIMAL -- missing values
, typicalEntryLevelEducation varchar(20)
, educationCode smallint
, workExperienceinaRelatedOccupation varchar(63)
, workexCode smallint
, typicalontheJobTraining varchar(63)
, trCode smallint
);

bulk insert employmentProjection
from 'C:\Users\Brian\source\repos\T-SQL Review\data\EmploymentProjections.tsv'  -- did some data cleaning
with (
    format='CSV',
    FIELDTERMINATOR='\t',
    FIRSTROW=2,
    ROWTERMINATOR = '\n',
    FIELDQUOTE = '"'  
);
select count(*) from employmentProjection;
select top 10 * from employmentProjection;

-- replace '-1' values with null


-- Create view of that table