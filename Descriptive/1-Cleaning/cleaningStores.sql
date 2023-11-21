/* 
DESCRIPTIVE ANALYSIS

1. Cleaning table Stores in SQL Server
*/


-- 1.) select DB
use [favorita_store_salesDB];

-- count rows
select count(*)
    from dbo.stores;

--== 54 records ==--


-- 2.) view Train Table
select top 10 *
from dbo.stores;


-- 3.) view data types
select table_name,
       column_name, 
       data_type
from information_schema.columns
where table_name = 'stores';

--== store_nbr = int | city = varchar | state = varchar ==--
--== type = varchar | cluster = int ==--


-- 4.) nulls
select *
from dbo.stores
where store_nbr is null or store_nbr = ' ';

--== Zero NULLS ==--