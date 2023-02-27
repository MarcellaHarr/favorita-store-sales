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
from storesWithTrans
order by max_trans desc;

--== Sorted table with 54 records ==--
--== Stores in Pichincha & Tungurahua state are top 10 ==--



-- 6.) view stores and train table

--==        qst#2: Which stores had the most on-promotions?
;with storePromos_cte
as
(
    select store_nbr,
            family,
            sum(onpromotion) as tot_promos
    from dbo.train
    group by store_nbr, family
),
storeDetails as 
(
    select sp.store_nbr,
            sp.family,
            sto.city,
            sto.[state],
            sp.tot_promos
    from dbo.stores sto
    inner join storePromos_cte sp
        on sto.store_nbr = sp.store_nbr
)
select *
from storeDetails
order by tot_promos desc;

--== 1782 records total ==--
--== stores in Manabi, Pichincha, and Tungurahua state are the top 10 ==--
--== store 53 has the most on promotions ==--



-- 7.) view train, stores, and holidays and events table

--==        qst#Three: Were promotions in relation to the holidays and events?
--==        select average(onpromotion) from cte where type = "Transfer"
;with storeDeets
as
(
    select t.store_nbr,
            t.family,
            t.onpromotion,
            t.[date],
            avg((t.onpromotion)) as avg_promos,
            cast((avg(t.onpromotion) - lag (avg(t.onpromotion)) 
                 over( order by t.[date] asc
                     ))/ lag(avg(t.onpromotion)) 
                 over ( order by t.[date] asc)*100 as float) as promo_growth
    from dbo.train t 
    join dbo.stores sto on t.store_nbr = sto.store_nbr
    where sto.store_nbr = t.store_nbr and
            t.onpromotion <> 0
    group by t.store_nbr, t.family,
             t.onpromotion, t.[date]
)
,storeHolidays as
(
    select st.store_nbr,
            he.locale_name,
            st.family,
            he.[type],
            he.transferred,
            he.[date],
            st.avg_promos,
            st.promo_growth
    from dbo.holidays_events he
    join storeDeets st on he.[date] = st.[date]
    where st.[date] = he.[date]
    group by st.store_nbr, he.locale_name, st.family,
            he.[type], he.transferred, he.[date],
            st.onpromotion, st.avg_promos, st.promo_growth
)
select *
from storeHolidays
where [type] = 'Transfer'
order by promo_growth desc;

--== 6312 records ==--

--== DATA NOTES: A transferred day is more like a normal day than a holiday. To find 
--==            the day that it was actually celebrated, look for the corresponding 
--==            row where type is Transfer. ==--

--==    Type transfer has Transferred as false, assuming that the dates are the actual dates
--==    the holiday or event fell on but wasn't move to another date by the government.
--==    I see that the promoted items of a store were promoted higher than the items that
--==    were being promoted.




-- .8) view stores and train table

--==        qst#Four: Which stores had the most sales?
;with storeMostSales
as 
(
    select t.store_nbr,
            sto.city,
            sto.[state],
            sum(t.sales) as tot_sales
    from dbo.train t
    join dbo.stores sto on sto.store_nbr = t.store_nbr
    where sto.store_nbr = t.store_nbr
    group by t.store_nbr, sto.city, sto.[state]
)
select *
from storeMostSales sms
order by tot_sales desc;



-- .) 

--==        qst#: Which stores had the most sales by family/day?


-- .)

--==        qst#: How much did sales suffer from the earthquake in Ecuador on 2016-04-16?


-- .) view trains and transactions table

--==        qst#: How are sales impacted by bi-weekly pay periods of the 15th & last day of each month?


-- .) view train and stores table

--==        qst#: How many transactions happened 2-wks before and 2-wks after the earthquake in Ecuador on 2016-04-16?
