-- Brian Dewhirst, 2023-11-21
-- (yes, this is trivial data-- not meant to be a data wrangling exercise)
-- see loadData for how the (failed) bank table dataset was generated

use newDB;

-- Create view of that table (run once, by itself)
--drop view vBanks;
--create view vBanks as
--  select
--    stateCode,
--    cast(count(*) as DECIMAL(7,2)) as failQ
--  from banks
--  group by stateCode;

select * from vBanks;  -- for offline manual checks, reference, etc.

-- mean
select 
  round(sum(failQ) / count(*),2) as mean_rounded,
  sum(failQ) / count(*) as mean
from vBanks;

-- percentile rank (not a measure of central tendency, but related)
select failQ, percent_rank() over(order by failQ) as decile
from vBanks;

-- median and IQR, etc.
select distinct
  min(failQ) over() as min_,
  percentile_cont(0.25) within group(order by failQ) over() as lower_quartile,
  percentile_cont(0.5) within group(order by failQ) over() as median,
  percentile_cont(0.75) within group(order by failQ) over() as upper_quartile,
  max(failQ) over() as max_,
  percentile_cont(0.75) within group(order by failQ) over() - percentile_cont(0.25) within group(order by failQ) over() as IQR
from vBanks;


-- it is often better to determine the mode by examining graphically-- let's assume past experience says it is 'okay' to measure it algorithmicly
-- ...
select
  failQ, 
  count(*) as instances
into #mode_tmp
from vBanks
group by failQ
order by instances desc;

select top 1 -- for multi-modal distributions, this would be top (N), however this is fragile without more logic (e.g. there are four and five-way ties for "2nd" and "3rd")
failQ as mode
from #mode_tmp;

drop table #mode_tmp;

-- aside: this is a skewed distribution, and there are measures of that we could probably include/implement

-- mean and standard deviation
select 
 avg(failQ) as mean,
-- STDEV  -- for samples
 STDEVP(failQ) as stddev_population
from vBanks;



-- trimmed mean

-- introduce ad-hoc "region" and take distribtions over that region; also review CTEs