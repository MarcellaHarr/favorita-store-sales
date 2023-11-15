# Corporación Favorita Analysis

![](/src/images/corporacion-la-favorita.jpg) source: https://marcasecuador.club/corporacion-favorita/

<br />

# Introduction
The purpose of this repository is to showcase a time-series forecasting model that predicts store sales of a major supermarket corporation based in South America. This Kaggle "Getting Started" competition runs indefinitely with a rolling leaderboard. My goal is to build a model that more accurately predicts the unit sales for thousands of products sold at various Favorita stores. I am also looking to gain a deeper understanding of the data and the corporation through a full statistical analysis. This will give me the opportunity to practice my machine-learning skills, enter my first competition on Kaggle, and gain real-world experience.

<br />

# Data

As an individual participating in this competition, I will need to predict sales for the thousands of product families sold at Favorita stores located in Ecuador. The training dataset includes information on the dates, stores, and products sold, whether a product was being promoted, and the sales numbers. Additionally, there are supplementary files that may be useful in building my models. __These are the datasets used:__

<details><summary>1. train.csv dataset:</summary>

| Column Name | Description |
|-------------|-------------|
| **store_nbr** | Identifies the store at which the products are sold |
| **family** | Identifies the type of product sold |
| **sales** | Provides the total sales for a product family at a particular store on a given date. Note that fractional values are possible since products can be sold in fractional units (e.g., 1.5 kg of cheese) |
| **onpromotion** | Indicates the total number of items in a product family that were being promoted at a store on a given date |

</details>

<br />

***
***

<details><summary>2. test.csv dataset:</summary>

| Column name | Description |
|-------------|-------------|
| id          | Unique ID for the row |
| date        | Date of the sales forecast |
| store_nbr   | Identifies the store at which the products are sold |
| family      | Identifies the type of product sold |
| onpromotion | Total number of items in a product family that were being promoted at a store on a given date |

</details>
<br />

***
***

<details><summary>3. sample_submission.csv dataset:</summary>

| Column name | Description |
|-------------|-------------|
| id          | Unique ID for the row |
| sales       | Predicted sales for the corresponding id in test.csv |

</details>
<br />

***
***

<details><summary>4. stores.csv dataset:</summary>

| Column name | Description |
|-------------|-------------|
| store_nbr   | Identifies the store |
| city        | City where the store is located |
| state       | State where the store is located |
| type        | Type of store (A, B, or C) |
| cluster     | Grouping of similar stores |

</details>
<br />

***
***

<details><summary>5. oil.csv dataset:</summary>

| Column name | Description |
|-------------|-------------|
| date        | Date of the oil price |
| dcoilwtico  | Daily oil prices (West Texas Intermediate) |

</details>
<br />

***
***

<details><summary>6. holidays_events.csv dataset:</summary>

| Column name | Description |
|-------------|-------------|
| date        | Date of the holiday/event |
| type        | Type of holiday/event (Holiday, Additional, Bridge, or Transfer) |
| locale      | Locale of the holiday/event (National, Regional, or Local) |
| locale_name | Name of the holiday/event locale |
| description | Description of the holiday/event |
| transferred | Indicates whether a holiday was officially transferred to another date by the government |

</details>





 <br />

> *Citation* &nbsp;&nbsp;&nbsp; Alexis Cook, DanB, inversion, Ryan Holbrook. (2021). Store Sales - Time Series Forecasting. [Kaggle][1].

[1]: (https://kaggle.com/competitions/store-sales-time-series-forecasting)

<br />