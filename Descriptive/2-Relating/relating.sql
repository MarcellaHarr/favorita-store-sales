/* 
DESCRIPTIVE ANALYSIS

2. Relating: SQLite | open db CTRL + SHIFT + P | run query SHIFT + R
*/

-- 1.) view all table information

pragma table_info(holidays_events);
pragma table_info(oil);
pragma table_info(stores);
pragma table_info(test);
pragma table_info(train);
pragma table_info(transactions);


-- 2.) view stores & transactions

select * 
from train
limit 10;

select *
from transactions
limit 10;

select *
from stores
limit 10;

select * 
from oil
limit 10;

select * 
from holidays_events
limit 10;


-- 3.) view all tables of counts and sums

select count(distinct store_nbr) Store_Amount,
        count(distinct family) Department_Amount,
        count(distinct sales) Sales_Amount,
        sum(sales) Sales_Total,
        count(distinct onpromotion) On_Promotion_Amount,
        sum(onpromotion) On_Promotion_Total,
        min([date]) Earliest_Date,
        max([date]) Latest_Date
from train;

select count(distinct store_nbr)Store_Amount,
        count(distinct transactions) Transactions_Amount,
        sum(transactions) Transactions_Total,
        min([date]) Earliest_Date,
        max([date]) Latest_Date
from transactions;

select count(distinct store_nbr) Store_Amount,
        count(distinct city) City_Amount,
        count(distinct [state]) State_Amount,
        count(distinct [type]) Type_Amount,
        count(distinct cluster) Cluster_Amount,
        sum(cluster) Cluster_Total
from stores;

select count(distinct dcoilwtico) Oil_Amount,
        sum(dcoilwtico) Oil_Total,
        min([date]) Earliest_Date,
        max([date]) Latest_Date
from oil;

select count(distinct [type]) Type_Amount,
        count(distinct locale) Locale_Amount,
        count(distinct locale_name) Locale_Name_Amount,
        count(distinct [description]) Description_Amount,
        count(distinct transferred) Transferred_Amount,
        min([date]) Earliest_Date,
        max([date]) Latest_Date
from holidays_events;



-- 4.) view stores and transactions tables

--==          qst#1: What stores have the maximum transactions? ==--

with storeTrans_cte
as
(
    select store_nbr,
            max(transactions) as Max_Transactions
    from transactions
    group by store_nbr
),
storesWithTrans as
(
    select sto.store_nbr Store,
        sto.city City,
        sto.[state] State_Name,
        st.Max_Transactions,
        (case when st.Max_Transactions > 50000 then 'Top-range'
                when st.Max_Transactions > 30000 then 'Mid-range'
                else 'Low-range'
        end) Maximum_Range
    from stores sto
    inner join storeTrans_cte st 
        on sto.store_nbr = st.store_nbr
)
select * 
from storesWithTrans
order by Store;
--== Sorted table with 54 records ==--
--== 00:00:00.054 runtime ==--
--== Stores in Quito & Guayaquil are the top 2 ==--



-- 5.) view stores and train tables

--==        qst#2: Which store(s) had the most on-promotions?

with storePromos_cte
as
(
    select store_nbr,
            family,
            sum(onpromotion) as Promos_Total
    from train
    group by store_nbr, family
),
storeDetails as 
(
    select distinct sp.store_nbr Store,
        sp.family Department,
        sp.Promos_Total,
        (case when sp.Promos_Total > 50000 then 'Top-range'
                when sp.Promos_Total > 30000 then 'Mid-range'
                else 'Low-range'
        end) Level_Range
    from stores sto
    inner join storePromos_cte sp on sto.store_nbr = sp.store_nbr
)
select *
from storeDetails
order by Promos_Total desc;
--== 1782 records total ==--
--== 00:00:01.048 runtime ==--
--== store 53 has the most on promotions ==--



-- 6.) view train, stores, and holidays and events tables

--==        qst#3: Were promotions in relation to the holidays and events' table?
--==        select average(onpromotion) from cte where type = "Transfer"

create table if not exists qst3_DF (
        Store INTEGER,
        Department VARCHAR(75),
        Store_Type TEXT(10),
        Dates DATE,
        Promotions INTEGER,
        Promo_Growth INTEGER,
        Promo_Percent_Growth INTEGER
);
insert into qst3_DF
with promotionData as
(
        select sto.store_nbr as Store,
                tr.family as Department,
                he.[type] as Store_Type,
                he.[date] as Dates,
                tr.onpromotion as Promotions,
                tr.onpromotion - lag(tr.onpromotion) over (order by he.[date]) as Promo_Growth,
                ((tr.onpromotion - lag(tr.onpromotion) over (order by he.[date])) / lag(tr.onpromotion) over (order by he.[date])) * 100.0 as Promo_Percent_Growth
        from train tr
                join stores sto on tr.store_nbr = sto.store_nbr
                join holidays_events he on tr.[date] = he.[date]
        where he.[type] = 'Transfer'
)
select *
from promotionData
group by Store, Department, Store_Type, Dates, Promotions;

select *
from qst3_DF
order by Promo_Percent_Growth desc;
--== 6312 records ==--
--== 00:00:00.255 runtime ==--
--== Store 54 in the Beverages department under the Transfer store type
--== had the most on-promotions on 2016-05-27 ==--


create table if not exists qst3b_DF (
        Store_ INTEGER,
        Department_ VARCHAR(75),
        Store_Type_ TEXT(10),
        Dates_ DATE,
        Promotions_ INTEGER,
        Promo_Growth_ INTEGER,
        Promo_Percent_Growth_ INTEGER
);
insert into qst3b_DF
with promotionData as
(
        select sto.store_nbr as Store,
                tr.family as Department,
                he.[type] as Store_Type,
                he.[date] as Dates,
                tr.onpromotion as Promotions,
                tr.onpromotion - lag(tr.onpromotion) over (order by he.[date]) as Promo_Growth,
                ((tr.onpromotion - lag(tr.onpromotion) over (order by he.[date])) / lag(tr.onpromotion) over (order by he.[date])) * 100.0 as Promo_Percent_Growth
        from train tr
                join stores sto on tr.store_nbr = sto.store_nbr
                join holidays_events he on tr.[date] = he.[date]
        where he.[type] != 'Transfer'
)
select *
from promotionData
group by Store, Department, Store_Type, Dates, Promotions;

select *
from qst3b_DF
where Store_Type_ = 'Holiday'
order by Promo_Percent_Growth_ desc;
--== Store 49 in the Produce department under the Holiday store type 
--== had the most on-promotions on three occurrences 2016-09-28, 2016-11-02, and 2017-04-12 ==--

--== DATA NOTES: A transferred day is more like a normal day than a holiday. To find 
--==            the day that it was actually celebrated, look for the corresponding 
--==            row where type is Transfer. ==--




-- .7) view stores and train tables

--==        qst#4a: Which store(s) had the most unit sales?

with storeMostSales
as 
(
    select t.store_nbr Store,
            sto.city City_,
            sto.[state] State_,
            sum(t.sales) as Unit_Sales_Total
    from train t
    join stores sto on sto.store_nbr = t.store_nbr
    where sto.store_nbr = t.store_nbr
    group by t.store_nbr, sto.city, sto.[state]
)
select *
from storeMostSales sms
order by Unit_Sales_Total desc;
--== 54 records ==--
--== Store number 44 had the most unit sales ==--



-- 8.) view stores and train tables

--==            qst#4b: What elements for store #44 generates their top unit sales?

select distinct tr.store_nbr Store,
        sto.city City_,
        sto.[state] State_,
        tr.family Department,
        round(sum(tr.sales), 2) Unit_Sales_Total
from train tr 
        join stores sto on tr.store_nbr = sto.store_nbr
where tr.store_nbr = 44
group by tr.family, tr.store_nbr, sto.[state], sto.city
order by Unit_Sales_Total desc;
--== 33 records ==--
--== 00:00:00.330 runtime ==--
--== Store 44's Grocery I department generates the most unit sales ==--



-- .9) view stores and train tables

--==        qst#4c: Which store(s) had the most unit sales by family/date?

select distinct tr.store_nbr Store,
        sto.city City_,
        sto.[state] State_,
        tr.family Department,
        tr.[date] Date_,
        round(sum(tr.sales), 2) Unit_Sales_Total
from dbo.train tr 
        join dbo.stores sto on tr.store_nbr = sto.store_nbr
group by tr.[date], tr.family, tr.store_nbr, sto.[state], sto.city
order by Unit_Sales_Total desc;
--== 3000888 records==--
--== 00:00:25.544 runtime ==--
--== Store 2 has the most unit sales in Grocerry I on May 2nd, 2016 ==--
--== Store 39 is second runner up in the Meat's department on December 7th, 2016 ==--
--== had the most unit sales ==--



-- .10) view stores and train tables

--==        qst#4d: What were the averages and growth rate of sales by family/date?

create table if not exists qst4d_DF (
    Store INTEGER,
    Department VARCHAR(75),
    State_ VARCHAR(255),
    Date_ DATE,
    Unit_Sales_Average REAL,
    Unit_Sales_Daily REAL,
    Difference_ REAL
);
insert into qst4d_DF
with storesWithAveragesGrowth
        as
        (
                select t.store_nbr Store,
                        t.family Department,
                        sto.[state] State_,
                        t.[date] Date_,
                        avg(t.sales) Unit_Sales_Average,
                        lag(avg(t.sales)) over (order by t.[date]) Unit_Sales_Daily
                from train t
                        join stores sto on sto.store_nbr = t.store_nbr
                group by t.store_nbr, t.family, sto.city,
            sto.[state], t.[date], t.sales
        )
select *,
        format(
                100 * (Unit_Sales_Average - lag(Unit_Sales_Average) over (order by Date_)) / lag(Unit_Sales_Average) over (order by Date_), 'P'
        ) as Difference_
from storesWithAveragesGrowth
where Unit_Sales_Average <> 0 and Unit_Sales_Daily <> 0;

select *
from qst4d_DF
order by Unit_Sales_Average, Difference_ desc;
--== Store 39 in the Seafood department had the most Unit_Sales_Average and Difference_ rates on 2015-09-15 ==--




-- .11) view stores and train tables

--==        **qst#4e: What were the sales difference by family/YR/MTH?
drop table qst4e_DF;
create table if not exists qst4e_DF (
        Store INTEGER,
        Department VARCHAR(75),
        State_ VARCHAR(255),
        Current_Year DATE,
        Current_Month DATE,
        Current_Month_Unit_Sales REAL,
        Previous_Year DATE,
        Comparable_Month DATE,
        Prev_12_Months REAL,
        Month_2_Month_Diff REAL
);
insert into qst4e_DF
with storeSalesWithMonthlyMetrics as 
(
    select t.store_nbr,
            t.family,
            sto.[state],
            strftime('%Y', t.[date]) as yr,
            strftime('%m', t.[date]) as mth,
            sum(t.sales) as unit_revenue
    from train t 
    join stores sto on sto.store_nbr = t.store_nbr
    where t.store_nbr = sto.store_nbr
    group by t.store_nbr, t.family, sto.[state], strftime('%Y', t.[date]), strftime('%m', t.[date])
),
earliestYear as (
    select min(yr) as min_year
    from storeSalesWithMonthlyMetrics
)
select ssmm.store_nbr as Store,
        ssmm.family as Department,
        ssmm.[state] as State_,
        ssmm.yr as Current_Year,
        ssmm.mth as Current_Month,
        ssmm.unit_revenue as Current_Month_Unit_Sales,
        case
            when ssmm.yr = (select min_year from earliestYear) then cast('' as text)
            else (ssmm.yr - 1)  -- Subtract 1 to get the previous year
        end as Previous_Year,
        lag(ssmm.mth, 12) over (order by ssmm.yr, ssmm.mth) as Comp_Month,
        lag(ssmm.unit_revenue, 12) over (order by ssmm.yr, ssmm.mth) as Prev_12_Months,
        ssmm.unit_revenue - lag(ssmm.unit_revenue, 12) over (order by ssmm.yr, ssmm.mth) as Month_2_Month_Diff
from storeSalesWithMonthlyMetrics ssmm
order by Current_Year, Current_Month;

select *
from qst4e_DF;

select Department, 
        ceiling(sum(Current_Month_Unit_Sales)) as Current_Month_Unit_Sales,
        round((avg(Current_Month_Unit_Sales) / (select avg(Current_Month_Unit_Sales) from qst4e_DF)) * 100, 1) as pct
from qst4e_DF
group by 1;

select *
from qst4e_DF
where Prev_12_Months < (
    select max(Prev_12_Months)
    from qst4e_DF df2
    where df2.Store = qst4e_DF.Store
);
--== 99792 records ==--
--== 00:00:21.194 to run ==--
--== Earlies date 2013-01-01 to latest date 2017-08-15 ==--




-- 12.) view train table

--==        **qst#4f: How/If did unit sales fluctuate yearly on April 15th and April 16th?

select
    count(sales) AS Total_Unit_Sales,
    count(case when strftime('%m-%d', date) in ('04-15', '04-16', '04-17') then sales end) as April_15th_to_17th_Unit_Sales,
    cast(count(case when strftime('%m-%d', date) in ('04-15', '04-16', '04-17') then sales end) as REAL) / count(sales) * 100.0 as Fluctuations,
    case
        when (
            select count(sales) 
            from train 
            where strftime('%m-%d', date) in ('04-15', '04-16', '04-17')
        ) / (
            select count(sales)
            from train
        ) then 'Inside Levels Total Unit Sales (April 15th to 17th)'
        else 'Total Unit Sales Influenced by Outside Levels'
    end as 'Fluctuation Metrics'
from train;
--== 26730 sales ==--
--== Total_Unit_Sales 3000888 ==--
--== Fluctuations 0.890736342042755 ==--

create table qst4f_DF (
        Store INTEGER,
        Department VARCHAR(75),
        Year_ DATE,
        Month_n_Day DATE,
        Total_Unit_Sales REAL,
        Average_Unit_Sales FLOAT,
        Sales_Fluctuation VARCHAR(75)
);
insert into qst4f_DF
with aprilSales as (
    select distinct 
        store_nbr as Store,
        family as Department,
        strftime('%Y', [date]) as Year,
        strftime('%m-%d', [date]) as Month_n_Day,
        ceiling(avg(sales)) as Average_Unit_Sales
    from train
    where strftime('%m-%d', [date]) in ('04-15', '04-16', '04-17')
    group by Year, Month_n_Day
),
fluctuationsOverYears as (
    select
        a.Store,
        a.Department,
        strftime('%Y', t.[date]) as Year,
        strftime('%m-%d', t.[date]) as Month_n_Day,
        t.sales as Total_Unit_Sales,
        a.Average_Unit_Sales,
        case
            when t.sales < a.Average_Unit_Sales * 0.890736342042755 then 'Unit Sales Decreased (Possible Fluctuation)'
            else 'No Significant Fluctuation'
        end as Sales_Fluctuation
    from train t
    join aprilSales a on strftime('%Y', t.[date]) = a.Year and strftime('%m-%d', t.[date]) = a.Month_n_Day
    where strftime('%m-%d', t.[date]) in ('04-15', '04-16', '04-17')
)
select
    t.Store,
    t.Department,
    t.Year,
    t.Month_n_Day,
    t.Total_Unit_Sales,
    t.Average_Unit_Sales,
    t.Sales_Fluctuation
from fluctuationsOverYears t
order by t.Year, t.Month_n_Day;

select *
from qst4f_DF
limit 20;
--== 26,730 records ==--
--== Average unit sales are about 191 units purchased in April 15th, 2013 ==--
--== Average unit sales are about 188 units purchased in April 16th, 2013 ==--
--== Average unit sales are about 205 units purchased in April 15th, 2014 ==--
--== Average unit sales are about 231 units purchased in April 16th, 2014 ==--
--== Average unit sales are about 224 units purchased in April 17th, 2014 ==--
--== Average unit sales are about 246 units purchased in April 15th, 2015 ==--
--== Average unit sales are about 235 units purchased in April 15th, 2015 ==--
--== Average unit sales are about 257 units purchased in April 17th, 2015 ==--
--== Average unit sales are about 375 units purchased in April 15th, 2016 ==--
--== Average unit sales are about 484 units purchased in April 16th, 2016 ==--
--== Average unit sales are about 714 units purchased in April 17th, 2016 ==--
--== Average unit sales are about 505 units purchased in April 15th, 2017 ==--
--== Average unit sales are about 554 units purchased in April 16th, 2017 ==--
--== Average unit sales are about 436 units purchased in April 17th, 2017 ==--



-- 13.) view train table

--==        qst#5: How much did sales suffer from the earthquake in Ecuador on 2016-04-16?

create table qst5_DF (
        Store INTEGER,
        Department VARCHAR(75),
        Date_ DATE,
        Unit_Revenue REAL,
        Unit_Sale_Before REAL,
        Earthquake_Impact NVARCHAR(55)
);
insert into qst5_DF
with storeEarthquakeSales as (
    select distinct
        t.store_nbr as Store,
        t.family as Department,
        t.[date] as Date,
        sum(t.sales) as Unit_Revenue,
        lag(sum(t.sales), 1) over (
            partition by t.store_nbr, t.family
            order by t.[date]
        ) as Unit_Sale_Before
    from train t
    where t.[date] in ('2013-04-16', '2014-04-16', '2015-04-16', '2016-04-16', '2017-04-16')
    group by
        t.store_nbr,
        t.family,
        t.[date]
)
select *,
    case
        when [date] = '2016-04-16' then
            case
                when (
                    select sum(sales)
                    from train
                ) < (
                    select Unit_Sale_Before
                    from storeEarthquakeSales
                    where [date] in ('2013-04-16', '2014-04-16', '2015-04-16')
                ) * 0.890736342042755 then (
                    select sum(sales)
                    from train
                ) - (
                    select Unit_Sale_Before
                    from storeEarthquakeSales
                    where [date] in ('2013-04-16', '2014-04-16', '2015-04-16')
                ) * 0.890736342042755
                else 0
            end
        else
            case
                when Unit_Sale_Before is null then 'Not Evaluated'
                else 
                    cast(round(((Unit_Revenue - Unit_Sale_Before) * 1.0 / Unit_Sale_Before), 2) as NVARCHAR(6)) || '%'
            end
    end as Earthquake_Impact
from storeEarthquakeSales;

select *
from qst5_DF
where Earthquake_Impact != 'Not Evaluated'
order by Earthquake_Impact desc;
--== 8910 records ==--
--== 5038 records w/o 'Not Evaluated' ==--



-- 14.) view transaction table

--==        qst#6: How many transactions happened 2-wks before and 2-wks after the earthquake in Ecuador on 2016-04-16?

create table qst6_DF (
        Store INTEGER,
        Two_Weeks_B4_Earthquake DATE,
        Total_Transaction_B4 INTEGER,
        Two_Weeks_After_Earthquake DATE,
        Total_Transaction_After INTEGER,
        Earthquake_Impact NVARCHAR(10)
);
insert into qst6_DF
with transactionBefore as (
    select 
        store_nbr as store_number1,
        date('2016-04-16', '-14 days') as two_weeks_before_earthquake,
        sum(transactions) as transaction_before
    from transactions
    where [date] = date('2016-04-16', '-14 days')
    group by store_nbr, two_weeks_before_earthquake
), transactionAfter as (
    select 
        store_nbr as store_number1,
        date('2016-04-16', '+14 days') as two_weeks_after_earthquake,
        sum(transactions) as transaction_after
    from transactions
    where [date] = date('2016-04-16', '+14 days')
    group by store_nbr, two_weeks_after_earthquake
), transactionBeforeAfter as (
    select 
        tb.store_number1,
        tb.two_weeks_before_earthquake,
        tb.transaction_before,
        ta.two_weeks_after_earthquake,
        ta.transaction_after,
        cast(round(((tb.transaction_before - ta.transaction_after) * 1.0 / 2), 2) as NVARCHAR(6)) || '%' as earthquake_impact_percentage
    from transactionBefore tb
    left join transactionAfter ta on tb.store_number1 = ta.store_number1
)
select *
from transactionBeforeAfter;

select *,
        max(Total_Transaction_B4),
        max(Total_Transaction_After)
FROM qst6_DF
order by Earthquake_Impact desc;
--== 53 records ==--
--== Store number 44 w/highest before and after transactions w/earthquake impact of 74% ==--



-- 15.) view features table: 
--              store_nbr, unit, transactions
--              mean is normal distributions
--              median is skewed distributions

--==        qst#7: What is the measure of the mean & median (central tendency)?

with storeTrans as
(
    select
        trns.store_nbr as Store,
        sum(trns.transactions) as Transactions,
        cast(round(avg(trns.transactions), 2) as decimal(10, 2)) as transMean
    from transactions trns
    group by trns.store_nbr
),
storeUnits as
(
    select
        tr.store_nbr as Store,
        round(sum(tr.sales), 2) as Units,
        cast(round(avg(tr.sales), 2) as decimal(10, 2)) as unitsMean
    from train tr
    group by tr.store_nbr
),
storeMeanMedian as
(
    select
        sT.Store,
        sT.Transactions,
        sU.Units,
        round((sT.transMean + sU.unitsMean), 2) as Mean,
        sT.transMean,
        sU.unitsMean,
        (select
            round((sU.Units + sT.Transactions) / 2.0, 2)
         from storeTrans sT2, storeUnits sU2
         where sT2.Store = sT.Store and sU2.Store = sT.Store) as Median
    from storeTrans sT
    join storeUnits sU on sT.Store = sU.Store
)
select
    sMM.Store,
    sMM.Transactions,
    sMM.Units,
    sMM.Mean,
    sMM.Median
from storeMeanMedian sMM;
--== 54 records ==--



-- 16.) view features table: 
--              store_nbr, unit, transactions
--              mean is normal distributions
--              median is skewed distributions
--              mode is most frequently occurring value

--==        qst#8: What is the measure of the mean / median/ mode (central tendency)?

create table centralTendency (
        Store INTEGER,
        Transactions_ INTEGER,
        Units REAL,
        Mean_ FLOAT,
        Median_ REAL,
        Mode_ VARCHAR(75)
);
insert into centralTendency
with storeTrans as
(
    select
        trns.store_nbr as Store,
        sum(trns.transactions) as Transactions,
        cast(round(avg(trns.transactions), 2) as decimal(10, 2)) as transMean
    from transactions trns
    group by trns.store_nbr
),
storeUnits as
(
    select
        tr.store_nbr as Store,
        round(sum(tr.sales), 2) as Units,
        cast(round(avg(tr.sales), 2) as decimal(10, 2)) as unitsMean
    from train tr
    group by tr.store_nbr
),
storeMeanMedian as
(
    select
        sT.Store,
        sT.Transactions,
        sU.Units,
        round((sT.transMean + sU.unitsMean), 2) as Mean,
        sT.transMean,
        sU.unitsMean,
        (
            select round((sU.Units + sT.Transactions) / 2.0, 2)
            from storeTrans sT2, storeUnits sU2
            where sT2.Store = sT.Store and sU2.Store = sT.Store
        ) as Median
    from storeTrans sT
    join storeUnits sU on sT.Store = sU.Store
),
storeMode as
(
    select
        s.Store as Store,
        (
            select family
            from train t
            where t.store_nbr = s.Store
            group by family
            order by count(*) desc
            LIMIT 1
        ) as Mode
    from storeTrans s
)
select
    sMM.Store,
    sMM.Transactions,
    sMM.Units,
    sMM.Mean,
    sMM.Median,
    sm.Mode
from storeMeanMedian sMM
join storeMode sm on sMM.Store = sm.Store;

select *
from centralTendency;
--== 54 records ==--



-- 17.) view features table:
--              store_nbr, date, transactions
--              date, dcoilwtico
--              right join b/c the oil data is what I want matched to

select trn.store_nbr Store_,
        trn.[date] Date_,
        o.dcoilwtico Daily_Oil_Prices_WTI
from transactions trn 
    right join oil o on o.[date] = trn.[date];
--== 59667 records ==--


create table oilDataTable (
    Store_ INTEGER,
    City_ VARCHAR(255),
    Date_ DATE,
    Daily_Oil_Prices_WTI FLOAT
);
insert into oilDataTable
with tablesTransAndOil as (
    select trn.store_nbr Store_,
        sto.city City_,
        trn.[date] Date_,
        o.dcoilwtico Daily_Oil_Prices_WTI
from transactions trn 
        join stores sto on sto.store_nbr = trn.store_nbr
        right join oil o on o.[date] = trn.[date]
)
select *
from tablesTransAndOil;

select *
from oilDataTable;
--== 59667 records ==--



-- 18.) view features table:
--              oilDataTable

--==        qst#9a: What were the lowest and highest oil prices?

select * 
from oilDataTable 
    order by Daily_Oil_Prices_WTI asc;
--== 59667 records ==--
--== The lowest daily oil price was 26.19 (West Texas Intermediate) ==--


select *
from oilDataTable 
    order by Daily_Oil_Prices_WTI desc;
--== 59667 records ==--
--== The highest daily oil price was 110.62 (West Texas Intermediate) ==--



-- 19.) view features table:
--              oilDataTable

--==        qst#9b: What are the dates and stores with the first change of oil prices occured?

select Store_,
    City_,
    Date_,
    Daily_Oil_Prices_WTI
from (
    select odt.*,
        lead(Daily_Oil_Prices_WTI) over 
            (partition by Store_ order by Date_) as Lead_Price
    from oilDataTable odt
) as odt
where Lead_Price is null;
--== 55 records ==--

create table noOilPriceChanges (
    Store_ INTEGER,
    City_ VARCHAR(255),
    Date_ DATE,
    Daily_Oil_Prices_WTI FLOAT
);
insert into noOilPriceChanges (
    Store_,
    City_,
    Date_,
    Daily_Oil_Prices_WTI
)
select Store_,
    City_,
    Date_,
    Daily_Oil_Prices_WTI
from (
    select odt.*,
        lead(Daily_Oil_Prices_WTI) over 
            (partition by Store_ order by Date_) as Lead_Price
    from oilDataTable odt
) as odt
where Lead_Price is null;

select *
from noOilPriceChanges;
--== Shows no change in the daily oil prices for multiple stores
--== on 2017-08-15 at 47.57 (West Texas Intermediate) ==--



select Store_,
    City_,
    Date_,
    Daily_Oil_Prices_WTI
from (
    select odt.*,
        lag(Daily_Oil_Prices_WTI) over 
            (partition by Store_ order by Date_) as LAG_Price 
    from oilDataTable odt
) odt
where LAG_Price is not null and LAG_Price <> Daily_Oil_Prices_WTI;
--== 59192 records ==--

create table oilPriceChanges (
    Store_ INTEGER,
    City_ VARCHAR(255),
    Date_ DATE,
    Daily_Oil_Prices_WTI FLOAT
);
insert into oilPriceChanges (
    Store_,
    City_,
    Date_,
    Daily_Oil_Prices_WTI
)
select Store_,
    City_,
    Date_,
    Daily_Oil_Prices_WTI
from (
    select odt.*,
        lag(Daily_Oil_Prices_WTI) over 
            (partition by Store_ order by Date_) as LAG_Price 
    from oilDataTable odt
) odt
where LAG_Price is not null and LAG_Price <> Daily_Oil_Prices_WTI;

select *
from oilPriceChanges;
--== Does show change in the daily oil prices and the first occurence of this is on
--== 2013-01-03 in Quito, Pinchincha in the amount of 92.16 (West Texas Intermediate) and the last
--== date is on 2017-08-15 in El Carmen in the amount of 47.57 (West Texas Intermediate) ==--