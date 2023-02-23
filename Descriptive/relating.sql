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


-- 5.) view stores, transactions

--==          qst#1: What stores have the maximum transactions? ==--
;with storeTrans_cte
as
(
    select store_nbr,
            max(transactions) as max_trans
    from dbo.transactions
    group by store_nbr
),
storesWithTrans as
(
    select sto.store_nbr,
        sto.city,
        sto.[state],
        st.max_trans
    from dbo.stores sto
    inner join storeTrans_cte st 
        on sto.store_nbr = st.store_nbr
)
select * 
into ##qst1
from storesWithTrans;

--
select * 
from ##qst1
order by max_trans desc;

--== Sorted table with 54 records ==--
--== Stores in Pichincha & Tungurahua state are top 10 ==--



-- .) view stores and train table

--==        qst#Two: Which stores had the most on promotions?
;with storePromos_cte
as
(
    select store_nbr,
            sum(onpromotion) as tot_promos
    from dbo.train
    group by store_nbr
),
storeDetails as 
(
    select sto.store_nbr,
            sto.city,
            sto.[state],
            sp.tot_promos
    from dbo.stores sto
    inner join storePromos_cte sp
        on sto.store_nbr = sp.store_nbr
)
select *
into ##qst2
from storeDetails;

--
select * 
from ##qst2
order by tot_promos desc;

--== 54 records total ==--
--== Stores in Manabi, Pichincha, and Tungurahua state are the top 10 ==--



-- .) view train, stores, and holidays and events table

--==        qst#: Were promotions in relation to the holidays and events?
--==        select average(onpromotion) from cte where type = "Transfer"
;with storeAvgPromos_cte
as
(
    select store_nbr,
            [date],
            family,
            avg(onpromotion) as avg_promos
    from dbo.train
    group by store_nbr, [date], family
),
storeWithAvgPromos as 
(
    select sto.store_nbr,
            sto.city,
            sto.[state],
            sap.[date],
            sap.family,
            sap.avg_promos
    from dbo.stores sto 
    inner join storeAvgPromos_cte sap
        on sto.store_nbr = sap.store_nbr
),
storeAvgPromoHoldayEvents as 
(
    select swap.store_nbr,
            swap.family,
            swap.city,
            swap.[state],
            swap.[date],
            he.[type],
            he.locale_name,
            he.[description],
            he.transferred,
            swap.avg_promos
    from dbo.holidays_events he
    inner join storeWithAvgPromos swap
        on he.[date] = swap.[date]
)
select * 
into ##qst3Table
from storeAvgPromoHoldayEvents;

--
select *
from ##qst3Table;

--== 502524 records ==--

--== A transferred day is more like a normal day than a holiday. To find the day that it 
--== was actually celebrated, look for the corresponding row where type is Transfer. ==--
select *
into ##qst3Transfer
from ##qst3Table
where [type] = 'Transfer';

-- 
select *
from ##qst3Transfer
order by avg_promos desc;

--== 16038 records ==--



-- .) view stores and train table

--==        qst#Three: Which stores had the most sales?


-- .)

--==        qst#: How much did sales suffer from the earthquake in Ecuador on 2016-04-16?


-- .) view trains and transactions table

--==        qst#: How are sales impacted by bi-weekly pay periods of the 15th & last day of each month?


-- .) view train and stores table

--==        qst#: How many transactions happened 2-wks before and 2-wks after the earthquake in Ecuador on 2016-04-16?
