/* 
DESCRIPTIVE ANALYSIS

1. Cleaning the dataset in SQL
*/


-- select DB
use [favorita_store_salesDB];

-- count rows
select count(*)
    from dbo.train;

select count(*) from 
    dbo.stores;

select count(*) from 
    dbo.oil;

select count(*) from 
    dbo.transactions;

select count(*) from 
    dbo.holidays_events;

select count(*) from 
    dbo.test;


-- view Train Table
select top 10 *
from dbo.train;


-- nulls
select id
from dbo.train
    where id is null and id = ' ';

select date
from dbo.train
    where date is null and date = ' ';

select store_nbr
from dbo.train
    where store_nbr is null and store_nbr = ' ';

select family
from dbo.train
    where family is null and family = ' ';

select sales 
from dbo.train 
    where sales is null and sales = ' ';

select onpromotion
from dbo.train
    where onpromotion is null and onpromotion = ' ';


-- convert to date

alter table dbo.train 
add train_date date;

update dbo.train 
set train_date = convert(Date, date);

select top 10 train_date 
from dbo.train;