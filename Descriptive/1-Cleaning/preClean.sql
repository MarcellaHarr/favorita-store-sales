-- go into DB --
select favorita_store_salesDB;

-- select DB --
use favorita_store_salesDB;


--== Create tables ==--

-- 1.) train.csv --
drop table if exists dbo.train;
create table train 
(
	id varchar(20),
	date varchar(10),
	store_nbr int,
	family varchar(255),
    sales float,
    onpromotion int,
	primary key (id)
);

bulk insert train
from 'D:\repos\github\favorita-store-sales\data\train.csv'
with
(
	format = 'CSV',
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '0x0a'
);

-- 2.) stores.csv --
drop table if exists dbo.stores;
create table stores 
(
	store_nbr int,
	city varchar(60),
    state varchar(60),
    type varchar(2),
    cluster int
);

bulk insert stores
from 'D:\repos\github\favorita-store-sales\data\stores.csv'
with
(
	format = 'CSV',
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '0x0a'
);

-- 3.) transaction.csv --
drop table if exists dbo.transactions;
create table transactions 
(
	date varchar(10),
	store_nbr int,
    transactions int
);

bulk insert transactions
from 'D:\repos\github\favorita-store-sales\data\transactions.csv'
with
(
	format = 'CSV',
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '0x0a'
);

-- 4.) oil.csv --
drop table if exists dbo.oil;
create table oil
(
	date varchar(10),
	dcoilwtico float
);

bulk insert oil
from 'D:\repos\github\favorita-store-sales\data\oil.csv'
with
(
	format = 'CSV',
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '0x0a'
);


-- 5.) holidays_events.csv --
drop table if exists dbo.holidays_events;
create table holidays_events
(
	date varchar(10),
	type varchar(15),
	locale varchar(15),
	locale_name varchar(30),
	description varchar(50),
	transferred varchar(10)
);

bulk insert holidays_events
from 'D:\repos\github\favorita-store-sales\data\holidays_events.csv'
with
(
	format = 'CSV',
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '0x0a'
);



-- 6.) test.csv --
drop table if exists dbo.test;
create table test 
(
	id varchar(20),
	date varchar(10),
	store_nbr int,
	family varchar(255),
    onpromotion int,
	primary key (id)
);

bulk insert test
from 'D:\repos\github\favorita-store-sales\data\test.csv'
with
(
	format = 'CSV',
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '0x0a'
);