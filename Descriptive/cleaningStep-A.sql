/* 
DESCRIPTIVE ANALYSIS

1. Cleaning table Train in SQL
*/


-- select DB
use [favorita_store_salesDB];

-- count rows
select count(*)
    from dbo.train;

-- view Train Table
select top 10 *
from dbo.train;


-- nulls
select *
from dbo.train
    where id is null and id = ' ';


-- convert to date
-- alter table dbo.train 
-- add train_date date;

-- update dbo.train 
-- set train_date = convert(Date, date);

-- select top 10 train_date 
-- from dbo.train;

