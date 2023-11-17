-- Brian Dewhirst, 2023-11-16
-- Miscelaneous review with a local T-SQL server
-- (the intent is to go from very-basic to more-interesting/ more complex-- this is all trivial stuff)
--
-- FWIW:  I agree tables, views, databases, columns, etc. should be given "good" (meaningful) names. 
--        (This is a pretty abstract exercise, though.)


Create DATABASE newDb;
Create DATABASE altDb;

select * from INFORMATION_SCHEMA.TABLES;

use newDB;

drop table if exists t;

create table t (
	arb_id int not null,
	field_name varchar(10),
);

select * from INFORMATION_SCHEMA.TABLES;

alter table t
  add constraint PK_arb_id primary key clustered (arb_id);

insert into t (arb_id, field_name)
  values (0, 'fnord'), (1, 'fizz'), (2, 'bin');

select top 3 * 
from t;

drop table if exists altDb.dbo.t;

select 
  arb_id as alt_id 
, field_name as alt_field_nm
into altDB.dbo.t 
from t;

alter table newDb.dbo.t
  add constraint PK_alt_id primary key clustered (alt_id);

-- select * from newDb.dbo.t;
-- select * from altDB.dbo.t;



-- local temp tables in T-SQL; global temps are the same, except "##t", etc.
drop table if exists #t;  -- not supported by all versions of T-SQL
select *
into #t
from newDb.dbo.t;

select * from #t;
drop table #t;

-- demonstrate simple joins
select *
from t as t1 
inner join altDb.dbo.t as t2 on t1.arb_id = t2.alt_id
where 1=1 
  and t1.arb_id > 0;

-- demonstrate something a little more interesting (yet still trivial)
/* explanation:
    this will look for records (with arb id in t1 greater than zero, and t1's id smaller than t2's) with mis-matched field names. 
	For each matching record (there's only one)
*/
select concat(field_name, '-', alt_field_nm) as arb_label
from t as t1 
inner join altDb.dbo.t as t2 on t1.field_name != t2.alt_field_nm
where 1=1 
  and t1.arb_id > 0
  and t2.alt_id > t1.arb_id;

-- demonstrate a meaningful outer join 
-- we'll need to add some more records first):

insert into t (arb_id, field_name)
  values (9, 'fnord2'), (10, 'fizz2'), (21, 'bin2');
insert into altDb.dbo.t (alt_id, alt_field_nm)
  values (99, 'fnord2'), (109, 'fizz2'), (219, 'bin2');

select * 
from t as t1 
full outer join altDb.dbo.t as t2 on t1.arb_id <= t2.alt_id  -- note the less-than-typical join logic, leading to 'spraying' results
where 1=1 
  and t1.arb_id > 0;

-- or the left join (i.e., a record must exist for t1, but there needn't be a matching record for t2)
select * 
from t as t1 
left join altDb.dbo.t as t2 on t1.arb_id = t2.alt_id
where 1=1 
  and t1.arb_id > 0;

-- demonstrate trivial self-join
select t1.*
from altDb.dbo.t as t1
inner join altDb.dbo.t as t2 on t1.alt_id = t2.alt_id
where 1=1
-- and ...

-- demonstrate joining on subqueries with aggregation (trivial)
select *
from t
inner join (
  select
    field_name,
    count(distinct left(field_name,3)) as field_q
  , sum(arb_id) as arb_sum
  from t
  where 1=1
  group by field_name
  ) as sq
  on t.arb_id = sq.field_q -- logically speaking, this is silly, but illustrates the point

