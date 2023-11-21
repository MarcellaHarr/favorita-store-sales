/* 
DESCRIPTIVE ANALYSIS

1. Cleaning table Transactions in SQL Server
*/


-- 1.) select DB
use [favorita_store_salesDB];

-- count rows
select count(*)
    from dbo.transactions;

--== 83488 records ==--



-- 2.) view Train Table
select top 10 *
from dbo.transactions;



-- 3.) view data types
select table_name,
       column_name, 
       data_type
from information_schema.columns
where table_name = 'transactions';

--== date = varchar | store_nbr = int | transactions = int ==--


-- 4.) nulls
select *
from dbo.transactions
where store_nbr is null or store_nbr = ' ';

--== Zero nulls ==--


-- 5.) convert to date
alter table dbo.transactions 
add trn_date date;

update dbo.transactions 
set trn_date = convert(Date, date);

select top 10 * 
from dbo.transactions;

--== converted the date col and saved to new col ==--


-- 6.) Drop date col
alter table transactions 
drop column date;

select top 10 *
from dbo.transactions;

-- 7.) rename date col
sp_rename 'transactions.trn_date', 'date', 'COLUMN';


--== trn_date --> date ==--