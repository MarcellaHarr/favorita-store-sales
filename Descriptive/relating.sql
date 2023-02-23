/* 
DESCRIPTIVE ANALYSIS

2. Relating: SQL Server
*/

-- 1.) select DB
use favorita_store_salesDB;


-- 2.) view all table information

select table_name,
       column_name,
       data_type
from information_schema.columns;


--== train - stores - transactions = STORE_NBR ==--
--== train - transactions - oil -  holidays_events = DATE ==--


-- 3.) create table indexes
create index trainNmbrSalesDate_idx
on train (store_nbr, sales, train_date);

create index storesNmbrCityState_idx
on stores (store_nbr, city, [state]);

create index transNmbrTransDate_idx
on transactions (store_nbr, transactions,trn_date);

create index oilPricesDate_idx
on oil (dcoilwtico, oil_date);

create index heNmeTrnferdDate_idx 
on holidays_events (locale_name, transferred, hol_date);


--== train indx took 00:01:10.989 ==--
--== stores indx took 0.223+ seconds ==--
--== transactions indx took 00:00:00.272 ==-- 
--== oil indx took 00:00:00.016 ==--
--== holidays_events took 00:00:02.657 ==--



-- 4.) view stores & transactions
select top 10 * 
from dbo.train;

select top 10 *
from dbo.transactions;

select top 10 *
from dbo.stores;

select top 10 * 
from dbo.oil;

select top 10 * 
from dbo.holidays_events;
