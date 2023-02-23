/* 
DESCRIPTIVE ANALYSIS

1. Cleaning table Oil in SQL Server
*/


-- 1.) select DB
use [favorita_store_salesDB];

-- count rows
select count(*)
    from dbo.oil;

--== 1218 records ==--

-- 2.) view Train Table
select top 10 *
from dbo.oil;


-- 3.) nulls
select *
from dbo.oil
where dcoilwtico is null or dcoilwtico = ' ';

select count(*) as NULL_counts
from dbo.oil
    where dcoilwtico is null or dcoilwtico = ' ';

--== There are 43 nulls all in `dcoilwtico` col ==--


-- 4.) view data types
select table_name,
       column_name, 
       data_type
from information_schema.columns
where table_name = 'oil';

--== date = varchar | dcoilwtico = float ==--



-- 5.) view & replace null vals 
select [date], 
       dcoilwtico,
       coalesce(dcoilwtico, 0) as NULLdcoil
from dbo.oil;

update dbo.oil
set dcoilwtico = coalesce(dcoilwtico, 0);

--== replaced NULLS with 0 ==--


-- 6.) convert to date
alter table dbo.oil 
add oil_date date;

update dbo.oil 
set oil_date = convert(Date, date);

select top 10 * 
from dbo.oil;

--== converted the date col and duplicated it under a new col ==--


-- 7.) Drop date col
alter table oil 
drop column date;

select top 10 *
from dbo.oil;

-- 8.) rename date col
sp_rename 'oil.oil_date', 'date', 'COLUMN';


--== oil_date --> date ==--