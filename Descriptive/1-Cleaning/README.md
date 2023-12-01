# <span style="color: #8893A2;">Data</span> <span style="color: #627186;">Cleaning</span> <span style="color: #455870;">Process</span>

I began the data preprocessing by creating tables in SQL Server, utilizing the bulk insert function to import CSV files obtained from Kaggle. To handle line feed (LF) row terminators, I employed hexadecimal notation (\n). The initial step involved cleaning the Holidays_Events table, which contained 350 records with no null values. I converted the date column from varchar to date data type and renamed the hol_date column to date. Moving on to the Oil table with 1218 records, I addressed 43 nulls in the dcoilwtico column by replacing them with zeros. I converted the date column to the date data type and renamed the oil_date column to date.
<br>
<br>

![](./src/images/../../../../src/images/lightsaber-collection-HrqAOiTFVH4-unsplash.jpg)<br> source: Photo by <a href="https://unsplash.com/@lightsabercollection?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Lightsaber Collection</a> on <a href="https://unsplash.com/photos/a-green-and-white-machine-sitting-on-top-of-a-table-HrqAOiTFVH4?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a>
  

## Detailed Table Cleaning Breakdown

### <span style="color: #EDF2F9">Holidays_Events Table:</span>
<ul>
    <li>Records | 350</li>
    <li>Nulls | 0</li>
    <li>Data Types | VarChar (6 columns)</li>
    <li>Transformation | Converted date column to date data type, renamed <mark style="color: #E8F8F4; background-color: #388C77; border-radius: 5px;">hol_date</mark> to <mark style="color: #E8F8F4; background-color: #388C77; border-radius: 5px;">date</mark></li>
</ul>

### <span style="color: #C7D5E6">Oil Table:</span>
<ul>
    <li>Records | 1218</li>
    <li>Nulls | 43 (dcoilwtico column)</li>
    <li>Data Types | VarChar (1 column) -- Float (1 columns)</li>
    <li>Transformation | Replaced null values with zeros, converted date column to date data type, renamed <mark style="color: #E8F8F4; background-color: #388C77; border-radius: 5px;">oil_date</mark> to <mark style="color: #E8F8F4; background-color: #388C77; border-radius: 5px;">date</mark></li>
</ul>

### <span style="color: #98AFCB">Stores' Table:</span>
<ul>
    <li>Records | 54</li>
    <li>Nulls | 0</li>
    <li>Data Types | Int (2 columns) -- VarChar (3 columns)</li>
    <li>Transformation | No nulls, data types intact</li>
</ul>

### <span style="color: #6984A8">Train Table:</span>
<ul>
    <li>Records | 3,000,888</li>
    <li>Nulls | 0</li>
    <li>Data Types | VarChar (3 columns) -- Float (1 column) -- Int (2 columns)</li>
    <li>Transformation | Converted date column to date data type, renamed <mark style="color: #E8F8F4; background-color: #388C77; border-radius: 5px;">train_date</mark> to <mark style="color: #E8F8F4; background-color: #388C77; border-radius: 5px;">date</mark></li>
</ul>

### <span style="color: #43638D">Transactions' Table:</span>
<ul>
    <li>Records | 83,488</li>
    <li>Nulls | 0</li>
    <li>Data Types | VarChar (1 column) -- Int (1 columns)</li>
    <li>Transformation | Converted date column to date data type, renamed <mark style="color: #E8F8F4; background-color: #388C77; border-radius: 5px;">trn_date</mark> to <mark style="color: #E8F8F4; background-color: #388C77; border-radius: 5px;">date</mark></li>
</ul>
<br>
<br>

These thorough cleaning steps ensure a consistent and well-prepared dataset for subsequent analysis and modeling tasks, highlighting the essential need for precision in the process.