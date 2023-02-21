/* 
DESCRIPTIVE ANALYSIS

1. Cleaning table Holidays_Events in SQL Server
*/


-- 1.) select DB
use [favorita_store_salesDB];

-- count rows
select count(*) as NULL_counts
    from dbo.holidays_events;

--== 350 records ==--

-- 2.) view Train Table
select top 10 *
from dbo.holidays_events;


-- 3.) nulls
select count(*)
from dbo.holidays_events
    where [date] is null or [date] = ' ';

--== Zero nulls ==--



-- 4.) view data types
select table_name,
       column_name, 
       data_type
from information_schema.columns
where table_name = 'holidays_events';

--== date = varchar | type = varchar | locale = varchar ==--
--== locale_name = varchar | description = varchar | transferred = varchar ==--



-- 5.) convert to date
alter table dbo.holidays_events 
add hol_date date;

update dbo.holidays_events 
set hol_date = convert(Date, date);

select top 10 * 
from dbo.holidays_events;

--== converted the date col and duplicated it under a new col ==--

