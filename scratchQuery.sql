-- Brian Dewhirst, 2023-11-16
-- Miscelaneous review with a local T-SQL server


Create DATABASE newDb;

select * from INFORMATION_SCHEMA.TABLES;

use newDB;

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
from t