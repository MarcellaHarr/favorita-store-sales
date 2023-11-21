/* 
DESCRIPTIVE ANALYSIS

1. Cleaning table Train in SQL
*/


-- 1.) select DB
use [favorita_store_salesDB];


-- 2.) count rows
select count(*)
    from dbo.train;

--== 3,000,888 records ==--


-- 3.) view Train Table
select top 10 *
from dbo.train;


-- 4.) nulls
select *
from dbo.train
    where id is null or id = ' ';

--== Zero nulls ==--


-- 5.) view data types
select table_name,
       column_name, 
       data_type
from information_schema.columns
where table_name = 'train';

--== id = varchar | date = varchar | store_nbr = int ==--
--== family = varchar | sales = float | onpromotion = int ==--


-- 6.) convert to date
alter table dbo.train 
add train_date date;

update dbo.train 
set train_date = convert(Date, date);

select top 10
from dbo.train;


--== converted date col ==--


-- 7.) Drop date col
alter table train 
drop column date;

select top 10 *
from dbo.train;

-- 8.) rename date col
sp_rename 'train.train_date', 'date', 'COLUMN';


--== train_date --> date ==--