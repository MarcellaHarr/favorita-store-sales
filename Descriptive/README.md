# Summary

Delving into the datasets, I've uncovered intriguing trends in Ecuadorian supermarket transactions, zooming in on specific stores, departments, and the various factors influencing supermarket activities. Notably, stores in **Quito, Pichincha**, take the lead in maximum `transactions`, emphasizing their significance in the dataset. However, **Store number 53** in **Manta, Manabi**, stands out for its highest number of `on-promotions`, showcasing a proactive approach to promotional activities.

At the department level, `family`, distinctive performances came to light. **Manta and El Carmen**, **Store 53 and 54** in the Grocery 1 and Cleaning family, and Store 53 in the Beverages and Produce family, exhibited the highest on-promotion growth with the *"Transfer"* status under `type`. These insights provide valuable information for potential strategic planning, especially related to holidays. Similarly, in **Quito, Pichincha**, **Store 49** in the Produce family, categorized under the *Holiday* store type, demonstrated substantial on-promotion growth on three separate occasions coinciding with actual holidays.

Moving to the transaction and oil tables, they did yield insightful observations, too. The Daily oil prices, `dcoilwtico`, resulted in a wide range of records, with the lowest at 26.19 (West Texas Intermediate) and the highest at 110.62 (WTI). On *August 15, 2017*, multiple stores maintained a consistent oil price of 47.57 (WTI), indicating stability across various locations. Conversely, changes in daily oil prices are observed, starting on *January 3, 2013*, in **Quito, Pichincha**, with a value of 92.16 (WTI) and concluding on *August 15, 2017*, in **El Carmen**, at 47.57 (WTI), reflected fluctuations in oil prices over time and across different locations.

Further analysis of the `earthquake` on *April 16th, 2016*, revealed significant changes in average unit sales and transaction volumes. Notably, **Store 44** in **Quito, Pichincha**, consistently led in `transaction` rates both before and after the earthquake, showcasing its remarkable resilience. Despite having the highest number of transactions in the dataset, Store 44 experienced a substantial 74% impact on its transactions, highlighting the challenges posed by the earthquake. These initial findings provide a glimpse into the nuanced dynamics of supermarket transactions, laying the groundwork for a more comprehensive understanding. While informative, the need for different approaches and further analysis to draw more conclusive and refined conclusions for informed decision-making will be explored.
<br>
<br>
<br>
<br>


## Features
There are a total of six data sets but only four were analyzed for this process. I will focus on specific features/columns from the different data sets, __which are as follows:__

    - 1. Store number
    - 2. Family
    - 3. Sales
    - 4. On promotions
    - 5. State
    - 6. Type
    - 7. Date
    - 8. Daily oil prices
    - 9. Transactions
    - 10. Transferred
<br>
<br>

## Tables

### Train table
<table><tr><th>Store_Amount</th><th>Department_Amount</th><th>Sales_Amount</th><th>Sales_Total</th><th>On_Promotion_Amount</th><th>On_Promotion_Total</th><th>Earliest_Date</th><th>Latest_Date</th><tr><tr><td>54</td><td>33</td><td>379610</td><td>1073644952.20309</td><td>362</td><td>7810622</td><td>2013-01-01</td><td>2017-08-15</td></tr></table>
<br>

### Transactions' table
<table><tr><th>Store_Amount</th><th>Transactions_Amount</th><th>Transactions_Total</th><th>Earliest_Date</th><th>Latest_Date</th><tr><tr><td>54</td><td>4993</td><td>141478945</td><td>2013-01-01</td><td>2017-08-15</td></tr></table>
<br>

### Stores' tables
<table><tr><th>Store_Amount</th><th>City_Amount</th><th>State_Amount</th><th>Type_Amount</th><th>Cluster_Amount</th><th>Cluster_Total</th><tr><tr><td>54</td><td>22</td><td>16</td><td>5</td><td>17</td><td>458</td></tr></table>
<br>

### Oil tables
<table><tr><th>Oil_Amount</th><th>Oil_Total</th><th>Earliest_Date</th><th>Latest_Date</th><tr><tr><td>999</td><td>79564.3800000001</td><td>2013-01-01</td><td>2017-08-31</td></tr></table>
<br>

### Holidays_Events' table
<table><tr><th>Type_Amount</th><th>Locale_Amount</th><th>Locale_Name_Amount</th><th>Description_Amount</th><th>Transferred_Amount</th><th>Earliest_Date</th><th>Latest_Date</th><tr><tr><td>6</td><td>3</td><td>24</td><td>103</td><td>2</td><td>2012-03-02</td><td>2017-12-26</td></tr></table>
<br>


<style>
    cite {
        font-style: normal;
        text-decoration: underline;
    }
</style>