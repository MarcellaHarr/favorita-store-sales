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
-- create index trainNmbrSalesDate_idx
-- on train (store_nbr, sales, train_date);

-- create index storesNmbrCityState_idx
-- on stores (store_nbr, city, [state]);

-- create index transNmbrTransDate_idx
-- on transactions (store_nbr, transactions, [date]);

-- create index oilPricesDate_idx
-- on oil (dcoilwtico, oil_date);

-- create index heNmeTrnferdDate_idx 
-- on holidays_events (locale_name, transferred, hol_date);


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



-- 5.) view all tables of counts and sums

select count(distinct store_nbr) Store_Amount,
        count(distinct family) Department_Amount,
        count(distinct sales) Sales_Amount,
        sum(sales) Sales_Total,
        count(distinct onpromotion) On_Promotion_Amount,
        sum(onpromotion) On_Promotion_Total,
        min([date]) Earliest_Date,
        max([date]) Latest_Date
from dbo.train;

select count(distinct store_nbr)Store_Amount,
        count(distinct transactions) Transactions_Amount,
        sum(transactions) Transactions_Total,
        min([date]) Earliest_Date,
        max([date]) Latest_Date
from dbo.transactions;

select count(distinct store_nbr) Store_Amount,
        count(distinct city) City_Amount,
        count(distinct [state]) State_Amount,
        count(distinct [type]) Type_Amount,
        count(distinct cluster) Cluster_Amount,
        sum(cluster) Cluster_Total
from dbo.stores;

select count(distinct dcoilwtico) Oil_Amount,
        sum(dcoilwtico) Oil_Total,
        min([date]) Earliest_Date,
        max([date]) Latest_Date
from dbo.oil;

select count(distinct [type]) Type_Amount,
        count(distinct locale) Locale_Amount,
        count(distinct locale_name) Locale_Name_Amount,
        count(distinct [description]) Description_Amount,
        count(distinct transferred) Transferred_Amount,
        min([date]) Earliest_Date,
        max([date]) Latest_Date
from dbo.holidays_events;


-- 6.) view stores, transactions

--==          qst#1: What stores have the maximum transactions? ==--
;with storeTrans_cte
as
(
    select store_nbr,
            max(transactions) as Max_Transactions
    from dbo.transactions
    group by store_nbr
),
storesWithTrans as
(
    select sto.store_nbr Store,
        sto.city City,
        sto.[state] State_Name,
        Max_Transactions,
        (case when Max_Transactions > 50000 then 'Top-range'
                when Max_Transactions > 30000 then 'Mid-range'
                else 'Low-range'
        end) Maximum_Range
    from dbo.stores sto
    inner join storeTrans_cte st 
        on sto.store_nbr = st.store_nbr
)
select * 
from storesWithTrans
order by Store;

--== Sorted table with 54 records ==--
--== 00:00:00.054 runtime ==--
--== Stores in Pichincha & Tungurahua state are top 10 ==--



-- 7.) view stores and train table

--==        qst#2: Which store(s) had the most on-promotions?
;with storePromos_cte
as
(
    select store_nbr,
            family,
            sum(onpromotion) as Promos_Total
    from dbo.train
    group by store_nbr, family
),
storeDetails as 
(
    select sp.store_nbr Store,
            sp.family Department,
            sto.city City,
            sto.[state] State_Name,
            Promos_Total,
            (case when Promos_Total > 50000 then 'Top-range'
                when Promos_Total > 30000 then 'Mid-range'
                else 'Low-range'
            end) Level_Range
    from dbo.stores sto
    inner join storePromos_cte sp
        on sto.store_nbr = sp.store_nbr
)
select *
from storeDetails
order by Promos_Total desc;

--== 1782 records total ==--
--== 00:00:01.048 runtime ==--
--== store 53 has the most on promotions ==--



-- 8.) view train, stores, and holidays and events table

--==        qst#3: Were promotions in relation to the holidays and events' table?
--==        select average(onpromotion) from cte where type = "Transfer"

select sto.store_nbr Store,
        tr.family Department,
        he.[type] Store_Type,
        he.[date] Dates,
        tr.onpromotion Promotions,
        tr.onpromotion - lag(tr.onpromotion) over (
                order by he.[date] 
        ) Promo_Growth,
        (tr.onpromotion - lag(tr.onpromotion) over (
                order by he.[date]
        ) / lag(tr.onpromotion) over (order by he.[date])*100) Promo_Perc_Growth
from dbo.train tr
        join dbo.stores sto on tr.store_nbr = sto.store_nbr
        join dbo.holidays_events he on tr.[date] = he.[date]
where tr.onpromotion <> 0 and he.[type] = 'Transfer'
group by sto.store_nbr, tr.family, he.[type],
        he.[date], tr.onpromotion, sto.[type];

--== 6312 records ==--
--== 00:00:00.255 runtime ==--

--== DATA NOTES: A transferred day is more like a normal day than a holiday. To find 
--==            the day that it was actually celebrated, look for the corresponding 
--==            row where type is Transfer. ==--




-- .9) view stores and train table

--==        qst#4a: Which store(s) had the most unit sales?
;with storeMostSales
as 
(
    select t.store_nbr Store,
            sto.city City_,
            sto.[state] State_,
            sum(t.sales) as Unit_Sales_Total
    from dbo.train t
    join dbo.stores sto on sto.store_nbr = t.store_nbr
    where sto.store_nbr = t.store_nbr
    group by t.store_nbr, sto.city, sto.[state]
)
select *
from storeMostSales sms
order by Unit_Sales_Total desc;

--== 54 records ==--
--== Store number 44 had the most unit sales ==--


-- 10.) view stores and train table

--==            qst#4b: What elements for store #44 generates their top unit sales?

select distinct tr.store_nbr Store,
        sto.city City_,
        sto.[state] State_,
        tr.family Department,
        round(sum(tr.sales), 2) Unit_Sales_Total
from dbo.train tr 
        join dbo.stores sto on tr.store_nbr = sto.store_nbr
where tr.store_nbr = 44
group by tr.family, tr.store_nbr, sto.[state], sto.city
order by Unit_Sales_Total desc;

--== 33 records ==--
--== 00:00:00.330 runtime ==--
--== Store 44's Grocery I department generates the most unit sales ==--



-- .11) view stores and train

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
--== 2016 had the most unit sales ==--



-- .12) view stores and train

--==        qst#4d: What were the averages and growth rate of sales by family/date?
;with storesWithAveragesGrowth
as 
(
    select t.store_nbr Store,
            t.family Department,
            sto.[state] State_,
            t.[date] Date_,
            avg(t.sales) Unit_Sales_Average,
            lag(avg(t.sales)) over (order by t.[date]) Unit_Sales_Daily
    from dbo.train t
        join dbo.stores sto on sto.store_nbr = t.store_nbr
    group by t.store_nbr, t.family, sto.city,
            sto.[state], t.[date], t.sales
)
select *,
        format(
                (Unit_Sales_Average - lag(Unit_Sales_Average) over (order by Date_)), 'P'
        ) as Difference_
from storesWithAveragesGrowth
where Unit_Sales_Average <> 0 and Unit_Sales_Daily <> 0;




-- .13) view stores and train

--==        **qst#43: What were the sales difference by family/YR/MTH?
;with storeSalesWithMonthlyMetrics
as 
(
    select t.store_nbr,
            t.family,
            sto.[state],
            format(t.[date], 'yyyy') as yr,
            format(t.[date], 'MM') as mth,
            sum(t.sales) as unit_revenue
    from dbo.train t 
    join dbo.stores sto on sto.store_nbr = t.store_nbr
    where t.store_nbr = sto.store_nbr
    group by t.store_nbr, t.family, sto.[state], t.[date]
)
select ssmm.store_nbr,
        ssmm.family,
        ssmm.[state],
        ssmm.yr as curr_yr,
        ssmm.mth as curr_mth,
        ssmm.unit_revenue as curr_mth_revenue,
        lag(ssmm.yr, 12) over (order by ssmm.yr, ssmm.mth) as prev_yr,
        lag(ssmm.mth, 12) over (order by ssmm.yr, ssmm.mth) as comp_mth,
        lag(ssmm.unit_revenue, 12) over (order by ssmm.yr, ssmm.mth) as prev_12_mths,
        ssmm.unit_revenue - lag(ssmm.unit_revenue, 12) over (order by ssmm.yr, ssmm.mth) as mth2mth_diff
from storeSalesWithMonthlyMetrics ssmm
order by curr_yr, curr_mth;

--== 3000888 records ==--
--== 00:00:21.194 to run ==--
--== Earlies date 2013-01-01 to latest date 2017-08-15 ==--


-- 14.)

--==        qst#5: How much did sales suffer from the earthquake in Ecuador on 2016-04-16?
;with storeEarthquakeSales
as 
(
        select distinct t.store_nbr as store,
                t.family as department,
                t.[date],
                sum(t.sales) as unit_revenue,
                lag(t.sales, 1) over (
                        partition by t.family
                        order by t.[date]
                ) as unit_sale_before
        from dbo.train t 
        group by t.store_nbr, t.family,
                t.[date], t.sales
)
select *,
        format((unit_revenue - unit_sale_before) / 2, 'P') as vs_15th_of_April
from storeEarthquakeSales
where [date] in ('2013-04-16', '2014-04-16', '2015-04-16', '2016-04-16', '2017-04-16');

--== 8910 records ==--
--== 00:00:06.973 to run ==--



-- 14.) view trains and transactions table

--==        qst#6: How are sales impacted by bi-weekly pay periods of the 15th & last day of each month?


-- select t.[date] as daily_date,
--         sum(t.sales) as sales
-- from dbo.train t
--         join dbo.transactions trns on trns.store_nbr = t.store_nbr
-- where year(t.[date]) in (2013, 2014, 2015, 2016, 2017)
-- group by t.[date];

--== ==--


select min(t.[date]) as earliest_date,
        max(t.[date]) as latest_date
from dbo.train t;

--== ealiest_date: 2013-01-01 | lastest_date: 2017-08-15 ==--


;with biWeeklySales
as
(
        select dateadd(day, 0, t.[date]) as paydate,
                dateadd(week, 2, t.[date]) as bi_weekly_date,
                sum(t.sales) as unit_sales
        from dbo.train t 
        join dbo.transactions trns on trns.store_nbr = t.store_nbr
        where t.store_nbr = trns.store_nbr
        group by t.[date]
)
select * from biWeeklySales
where day(paydate) = (15);

--== 56 records ==--
--== 00:00:23.123 to run ==--
--== Pay day date with bi-weekly dates and total sales ==--


;with biWeeklyLastDaySales
as
(
        select dateadd(day, 0, t.[date]) as paydate,
                dateadd(week, 2, t.[date]) as bi_weekly_date,
                eomonth(t.[date]) as month_last_day,
                sum(t.sales) as unit_sales
        from dbo.train t 
        join dbo.transactions trns on trns.store_nbr = t.store_nbr
        where t.store_nbr = trns.store_nbr
        group by t.[date]
)
select * from biWeeklyLastDaySales
where day(paydate) = (15);


--== 56 records ==--
--== 00:00:23.221 to run ==--
--== Paydate with bi-weekly dates & last day of the month, and total sales ==--




;with impactedDates
as
(
        select dateadd(day, 0, t.[date]) as paydate,
                dateadd(week, 2, t.[date]) as bi_weekly_date,
                eomonth(t.[date]) as month_last_day,
                sum(t.sales) as unit_sales
        from dbo.train t 
        join dbo.transactions trns on trns.store_nbr = t.store_nbr
        where day(dateadd(day, 0, t.[date])) = (15)
        group by t.[date], t.sales
)
, impactedSales as 
(
        select impD.paydate,
                impD.bi_weekly_date,
                impD.month_last_day,
                lag(impD.unit_sales) over (
                        order by impD.paydate
                ) as prev_sales,
                impD.unit_sales,
                impD.unit_sales - lag(impD.unit_sales) over (
                        order by impD.paydate
                ) as sales_diff
        from impactedDates impD
)
select * from impactedSales;

--== 37,627 records ==--
--== 00:00:39.599 to run ==--
--== Impacted sales table ==--





-- 15.) view transaction and stores table

--==        qst#7: How many transactions happened 2-wks before and 2-wks after the earthquake in Ecuador on 2016-04-16?


;with transactionBefore
as
(
        select store_nbr as store_number1,
                dateadd(week, -2, [date]) as two_weeks_before_earthquake,
                sum(transactions) as transaction_before
        from dbo.transactions
        where [date] = dateadd(week, -2, '2016-04-16')
        group by store_nbr, [date]
)
, transactionBeforeAfter
as
(
        select store_number1,
                two_weeks_before_earthquake,
                transaction_before,
                dateadd(week, 2, trns.[date]) as two_weeks_after_earthquake,
                sum(trns.transactions) as transaction_after
        from transactionBefore
        right join dbo.transactions trns on trns.store_nbr = transactionBefore.store_number1
        where trns.[date] = dateadd(week, 2, '2016-04-16')
        group by store_number1, two_weeks_before_earthquake, transaction_before, trns.[date], trns.transactions
)
select *
from transactionBeforeAfter;






-- 16.) view features table: 
--              store_nbr, family, date, state, type, transferred, 
--              transactions, onpromotion, dcoilwtico, sales
--              mean is normal distributions
--              median is skewed distributions

--==        qst#8: What is the measure of the mean & median (central tendency)?

select trns.store_nbr as Store,
        sum(trns.transactions) as Transactions,
        cast(round(avg(trns.transactions), 2) as decimal(10, 2)) as transMean
from dbo.transactions trns
group by trns.store_nbr
order by trns.store_nbr;

--== 54 records ==--



select tr.store_nbr as Store,
        sum(tr.sales) as Transactions,
        cast(round(avg(tr.sales), 2) as decimal(10, 2)) as unitsMean
from dbo.train tr
group by tr.store_nbr
order by tr.store_nbr;

--== 54 records ==--


;with storeTrans
as
(
        select trns.store_nbr as Store,
                sum(trns.transactions) as Transactions,
                cast(round(avg(trns.transactions), 2) as decimal(10, 2)) as transMean
        from dbo.transactions trns
        group by trns.store_nbr
)
, storeUnits
as
(
        select tr.store_nbr as Store,
                sum(tr.sales) as Units,
                cast(round(avg(tr.sales), 2) as decimal(10, 2)) as unitsMean
        from dbo.train tr
        group by tr.store_nbr
)
select sT.Store,
        sT.Transactions,
        sU.Units,
        sT.transMean,
        sU.unitsMean
into storeMean
from storeTrans sT
        join storeUnits sU on sT.Store = sU.Store;

--== 54 records ==--
--== 00:00:03.398 runtime ==--
--== Mean Dataframe CTE ==--


select *
from storeMean;

--== 54 records ==--
--== 00:00:00.004 runtime ==--


select Store,
        sum(transMean + unitsMean) / 2.0 Mean
from storeMean
group by Store
order by Store;

--== 54 records ==--
--== 00:00:00.160 runtime ==--
--== Mean Query ==--


;with meanQuery
as 
(
        select Store,
                sum(transMean + unitsMean) / 2.0 Mean
        from storeMean
        group by Store
)
select mQ.Store,
        sM.Transactions,
        sM.Units,
        mQ.Mean
into storeMeanDF
from meanQuery mQ
        join storeMean sM on mQ.Store = sM.Store;

--== 54 records ==--
--== 00:00:00.018 runtime ==--
--== Store Mean DF CTE ==--


select *
from storeMeanDF;

--== 54 records ==--
--== 00:00:00.013 runtime ==--


select Store,
        Transactions,
        Units,
        Mean,
        percentile_cont(0.5) within group (
                order by (Units + Transactions))
                over (partition by Store) as Median
from storeMeanDF;

--== 54 records ==--
--== 00:00:00.020 runtime ==--
--== Store Mean and Median ==--


;with storeMeanMedian
as 
(
        select Store,
                Transactions,
                Units,
                Mean,
                percentile_cont(0.5) within group (
                        order by (Units + Transactions))
                        over (partition by Store) as Median
        from storeMeanDF
)
select sMM.Store,
        sM.Transactions,
        sM.Units,
        sM.Mean,
        sMM.Median
into storeMeanMedianDF
from storeMeanMedian sMM
        join storeMeanDF sM on sMM.Store = sM.Store;

--== 54 records ==--
--== 00:00:02.877 runtime ==--
--== Store Mean & Median Dataframe CTE==--


select *
from storeMeanMedianDF;

--== 54 records ==--
--== 00:00:00.011 runtime ==--



-- 17.) view table: 
--              store mean median dataframe

--==        qst#9: What is the measure of the mean / median/ mode (central tendency)?

select store_nbr Store,
        string_agg(family, ' - ') within group (
                order by family
        ) Department_List
from dbo.train
group by store_nbr;


--==  ==--
--==  ==--
--==  ==--



-- .) view features table: 
--              store_nbr, family, date, state, type, transferred, 
--              transactions, onpromotion, dcoilwtico, sales