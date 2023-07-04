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

--==        qst#3: Were promotions in relation to the holidays and events?
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

--==        qst#4a: Which stores had the most unit sales?
;with storeMostSales
as 
(
    select t.store_nbr,
            sto.city,
            sto.[state],
            sum(t.sales) as unit_sales
    from dbo.train t
    join dbo.stores sto on sto.store_nbr = t.store_nbr
    where sto.store_nbr = t.store_nbr
    group by t.store_nbr, sto.city, sto.[state]
)
select *
from storeMostSales sms
order by unit_sales desc;

--== 54 records ==--
--== Store number 44 had the most unit sales ==--



-- .9) view stores and train

--==        qst#4b: Which stores had the most unit sales by family/day?
;with storesWithSalesFamilyDate
as 
(
    select t.store_nbr,
            t.family,
            sto.city,
            sto.[state],
            t.[date],
            sum(t.sales) as unit_sales
    from dbo.train t
    join dbo.stores sto on sto.store_nbr = t.store_nbr
    group by t.store_nbr, t.family, sto.city,
            sto.[state], t.[date]
)
select *
from storesWithSalesFamilyDate
order by unit_sales desc;

--== 3000888 records ==--
--== 00:00:35.277 to run ==--
--== Store number 2 had the most unit sales under the Grocery l on the date
--== of 2016-05-02 ==--



-- .10) view stores and train

--==        qst#4c: What were the averages and growth rate of sales by family/date?
-- ;with storesWithAveragesGrowth
-- as 
-- (
--     select t.store_nbr,
--             t.family,
--             sto.[state],
--             t.[date],
--             avg(t.sales) as avg_sales,
--             lag(t.sales) over (order by t.[date]) as daily_sales,
--             t.sales - lag(t.sales) over (order by t.[date]) as sales_difference
--     from dbo.train t
--     join dbo.stores sto on sto.store_nbr = t.store_nbr
--     group by t.store_nbr, t.family, sto.city,
--             sto.[state], t.[date], t.sales
-- )
-- select *
-- from storesWithAveragesGrowth;


;with storesWithAveragesGrowth
as 
(
    select t.store_nbr,
            t.family,
            sto.[state],
            t.[date],
            avg(t.sales) as avg_unit_sales,
            lag(t.sales) over (order by t.[date]) as daily_unit_sales
    from dbo.train t
    join dbo.stores sto on sto.store_nbr = t.store_nbr
    group by t.store_nbr, t.family, sto.city,
            sto.[state], t.[date], t.sales
)
select *,
        format(
                (avg_unit_sales - lag(avg_unit_sales) over (order by [date])), 'P'
        ) as sales_difference
from storesWithAveragesGrowth;




-- .11) view stores and train

--==        **qst#4d: What were the sales difference by family/YR/MTH?
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


-- 12.)

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



-- 13.) view trains and transactions table

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





-- 14.) view train and stores table

--==        qst#7: How many transactions happened 2-wks before and 2-wks after the earthquake in Ecuador on 2016-04-16?



-- 15.) view features table: 
--              store_nbr, family, date, state, type, transferred, 
--              transactions, onpromotion, dcoilwtico, sales

--==        qst#8: What is the measure of the mean & median?
;with storeFeatsTendency
as 
(
        select tr.store_nbr,
                tr.family,
                sto.[state],
                he.[type],
                he.transferred,
                tr.[date],
                avg(tr.sales + tr.onpromotion + trns.transactions + ol.dcoilwtico) / 4.0 as store_unit_mean,
                percentile_cont(0.5) 
                        within group (order by (tr.sales + tr.onpromotion + 
                                                trns.transactions + ol.dcoilwtico))
                        over (partition by tr.store_nbr) as store_unit_median
        from dbo.train tr 
        join dbo.stores sto on sto.store_nbr = tr.store_nbr
        join dbo.transactions trns on trns.store_nbr = sto.store_nbr and trns.[date] = tr.[date]
        join dbo.holidays_events he on he.[date] = tr.[date]
        join dbo.oil ol on ol.[date] = tr.[date]
        group by tr.store_nbr, tr.family, sto.[state],
                 he.[type], he.transferred, tr.[date],
                 tr.sales, tr.onpromotion, trns.transactions,
                 ol.dcoilwtico
)
select *
from storeFeatsTendency
order by store_nbr;


--== 304260 records ==--
--== 00:00:05.140 to run ==--



-- 16.) view features table: 
--              store_nbr, family, date, state, type, transferred, 
--              transactions, onpromotion, dcoilwtico, sales
--==        qst#9: What is the measure of the mean / median/ mode?

;with stoFeatCentralTendency
as 
(
        select tr.store_nbr,
                tr.family,
                sto.[state],
                he.[type],
                he.transferred,
                tr.[date],
                count(trns.transactions) as store_frequency,
                avg(tr.sales + tr.onpromotion + trns.transactions + ol.dcoilwtico) / 4.0 as store_unit_mean,
                percentile_cont(0.5) 
                        within group (order by (tr.sales + tr.onpromotion + trns.transactions + ol.dcoilwtico))
                        over (partition by tr.store_nbr) as store_unit_median,
                rank() over (partition by tr.store_nbr order by count(trns.transactions) desc) as store_rank
        from dbo.train tr 
        join dbo.stores sto on sto.store_nbr = tr.store_nbr
        join dbo.transactions trns on trns.store_nbr = sto.store_nbr and trns.[date] = tr.[date]
        join dbo.holidays_events he on he.[date] = tr.[date]
        join dbo.oil ol on ol.[date] = tr.[date]
        group by tr.store_nbr, tr.family, sto.[state],
                 he.[type], he.transferred, tr.[date],
                 tr.sales, tr.onpromotion, trns.transactions,
                 ol.dcoilwtico
)
select *
from stoFeatCentralTendency
where store_rank = 1
order by store_unit_median desc;

--== 4983 records ==--
--== 00:00:03.502 to run ==--
--== This query removed the years 2016 and 2017 ==--




-- 17.) view features table: 
--              store_nbr, family, date, state, type, transferred, 
--              transactions, onpromotion, dcoilwtico, sales
--==        qst#10: What is the measure of the mean / median/ mode?

;with storeWithCentralTendency
as 
(
        select tr.store_nbr,
                count(trns.transactions) as store_frequency,
                avg(tr.sales + tr.onpromotion + trns.transactions + ol.dcoilwtico) / 4.0 as store_unit_mean,
                percentile_cont(0.5) 
                        within group (order by (tr.sales + tr.onpromotion + trns.transactions + ol.dcoilwtico))
                        over (partition by tr.store_nbr) as store_unit_median,
                rank() over (partition by tr.store_nbr order by count(trns.transactions) desc) as store_rank
        from dbo.train tr 
        join dbo.stores sto on sto.store_nbr = tr.store_nbr
        join dbo.transactions trns on trns.store_nbr = sto.store_nbr and trns.[date] = tr.[date]
        join dbo.holidays_events he on he.[date] = tr.[date]
        join dbo.oil ol on ol.[date] = tr.[date]
        group by tr.store_nbr, tr.sales, tr.onpromotion, 
                trns.transactions, ol.dcoilwtico
)
select distinct *
from storeWithCentralTendency
where store_rank = 1
order by store_unit_median desc;

--== 58 records ==--
--== 00:00:03.603 to run ==--
--== Noticed that store number 52 duplicates two times ==--