# 🍜 Case Study #5 - Danny's Data Mart
<p align="center">

<img src="https://user-images.githubusercontent.com/60517587/177965312-1650ace9-6d96-4765-9c3e-b40364efa349.png" width=40% height=40% />

</br>

## 📕 Table Of Contents
* ### 🛠️ [Problem Statement](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Data-Mart#%EF%B8%8F-problem-statement)
* ### 📂 [Dataset](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Data-Mart#-dataset)
* ### ❓ [Case Study Questions](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Data-Mart#question%EF%B8%8F-case-study-questions)
  * #### 🧼 [DATA CLEANSING STEPS](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Data-Mart#a-data-cleansing-steps)
  * #### 🔎 [DATA EXPLORATION](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Data-Mart#b-data-exploration)
  * #### ⌛ [BEFORE & AFTER ANALYSIS](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Data-Mart#c-before--after-analysis)

## 🛠️ Problem Statement

> Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specializes in fresh produce. Danny is asking for your support to analyze his sales performance. In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer. Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

 <br /> 


## 📂 Dataset
Danny has shared with you 1 dataset for this case study:

### **```weekly_sales```**

<details>
<summary>
View table
</summary>

+ Data Mart has international operations using a multi-`region` strategy. 

+ Data Mart has both, a retail and online `platform` in the form of a Shopify store front to serve their customers. 

+ Customer `segment` and `customer_type` data relates to personal age and demographics information that is shared with Data Mart.

+ `transactions` is the count of unique purchases made through Data Mart and `sales` is the actual dollar amount of purchases.


| week_date | region | platform | segment | customer_type | transactions | sales   |
|-----------|--------|----------|---------|---------------|--------------|---------|
| 27/4/20   | ASIA   | Retail   | F1      | Existing      | 98856        | 4710331 |
| 29/7/19   | EUROPE | Retail   | C4      | Existing      | 4763         | 265148  |
| 24/8/20   | AFRICA | Retail   | F3      | New           | 69461        | 2470906 |
| 1/4/2019  | AFRICA | Shopify  | null    | Existing      | 181          | 34961   |
| 19/8/19   | CANADA | Shopify  | null    | Existing      | 58           | 10825   |
| 2/7/2018  | CANADA | Shopify  | C1      | New           | 49           | 7681    |
| 12/8/2019 | CANADA | Shopify  | null    | New           | 107          | 18923   |
| 30/3/20   | CANADA | Retail   | F2      | New           | 17260        | 620714  |
| 19/8/19   | USA    | Shopify  | F1      | New           | 143          | 21077   |
| 22/4/19   | ASIA   | Shopify  | C3      | New           | 216          | 34180   |


 </details>


### **E.R.D**
<details>

<summary>
View diagram
</summary>
<img src="https://user-images.githubusercontent.com/60517587/177965308-298bc3fc-8096-4ae2-903f-78de6f1927f7.png" width=60% height=60%>
</details>

<br/>


## :question:️ Case Study Question

This case study has quite a NUMBER of questions - they are divided into 3 sections including:
+ **Data Cleansing Steps**,  
+ **Data Exploration**,
+ **Before & After Analysis**.

 <p align="center">
<img src="https://user-images.githubusercontent.com/60517587/177965293-16f618ab-f6f2-4647-b1e1-463af164493d.gif" width=60% height=50%>

### Just kidding, I do. I always do! 😎

---

### A. Data Cleansing Steps

In a single query, perform the following operations and generate a new table in the data_mart schema named `clean_weekly_sales`:
+ Convert the `week_date` to a DATE format.
+ Add a `week_number` as the second column for each `week_date` value. for example, any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc.
+ Add a `month_number` with the calendar month for each `week_date` value as the 3rd column.
+ Add a `calendar_year` column as the 4th column containing either 2018, 2019 or 2020 values.
+ Add a new column called `age_band` after the original `segment` column using the following mapping on the number inside the `segment` value.

| segment | age_band    |
|--------|--------------| 
| 1      | Young Adults |
| 2      | Middle Aged  |
| 3 or 4 | Retirees     |

+ Add a new `demographic` column using the following mapping for the first letter in the `segment` values:

| segment | demographic |
|--------|--------------| 
| C      | Couples      |
| F      | Families     |

+ Ensure all `null` string values with an "unknown" string value in the original `segment` column as well as the new `age_band` and `demographic` columns.
+ Generate a new `avg_transaction` column as the `sales` value divided by `transactions` rounded to 2 decimal places for each record.

</br>

#### NEW TABLE DDL

```sql
DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TEMP TABLE clean_weekly_sales AS (
  SELECT
    TO_DATE(week_date, 'DD/MM/YY') AS week_date,
    to_char(TO_DATE(week_date, 'DD/MM/YY'), 'WW') :: NUMERIC AS week_number,
    EXTRACT(
      'month'
      FROM
        TO_DATE(week_date, 'DD/MM/YY')
    ) AS month_number,
    EXTRACT(
      'year'
      FROM
        TO_DATE(week_date, 'DD/MM/YY')
    ) AS calendar_year,
    region,
    platform,
    CASE
      WHEN segment = 'null' THEN 'unknown'
      ELSE (
        CASE
          RIGHT(segment, 1) :: NUMERIC
          WHEN 1 THEN 'Young Adults'
          WHEN 2 THEN 'Middle Aged'
          WHEN 3 THEN 'Retirees'
          WHEN 4 THEN 'Retirees'
        END
      )
    END AS age_band,
    CASE
      WHEN segment = 'null' THEN 'unknown'
      ELSE (
        CASE
          LEFT(segment, 1)
          WHEN 'C' THEN 'Couples'
          WHEN 'F' THEN 'Families'
        END
      )
    END AS demographic,
    customer_type,
    transactions,
    sales,
    ROUND(sales :: NUMERIC / transactions, 2) AS avg_transaction
  FROM
    data_mart.weekly_sales
);
```

<details>
<summary>
View TABLE random rows

</summary>

| week_date                | week_number | month_number | calendar_year | region        | platform | age_band     | demographic | customer_type | transactions | sales    | avg_transaction |
|--------------------------|-------------|--------------|---------------|---------------|----------|--------------|-------------|---------------|--------------|----------|-----------------|
| 2018-07-09 | 28          | 7            | 2018          | USA           | Retail   | Retirees     | Families    | Existing      | 112436       | 7434676  | 66.12           |
| 2020-08-03 | 31          | 8            | 2020          | ASIA          | Shopify  | Middle Aged  | Couples     | Existing      | 2210         | 394490   | 178.5           |
| 2018-04-09 | 15          | 4            | 2018          | AFRICA        | Retail   | Middle Aged  | Families    | Existing      | 235769       | 13963081 | 59.22           |
| 2020-08-24 | 34          | 8            | 2020          | USA           | Shopify  | Retirees     | Couples     | New           | 160          | 26524    | 165.78          |
| 2020-08-10 | 32          | 8            | 2020          | ASIA          | Retail   | unknown      | unknown     | Guest         | 1887143      | 48068626 | 25.47           |
| 2020-03-30 | 13          | 3            | 2020          | OCEANIA       | Shopify  | unknown      | unknown     | Existing      | 595          | 115487   | 194.1           |
| 2019-08-12 | 32          | 8            | 2019          | CANADA        | Shopify  | Young Adults | Families    | Existing      | 653          | 117292   | 179.62          |
| 2020-04-13 | 15          | 4            | 2020          | SOUTH AMERICA | Shopify  | Middle Aged  | Families    | New           | 9            | 908      | 100.89          |
| 2020-08-17 | 33          | 8            | 2020          | SOUTH AMERICA | Retail   | Middle Aged  | Families    | New           | 408          | 14221    | 34.86           |
| 2018-06-11 | 24          | 6            | 2018          | OCEANIA       | Shopify  | Retirees     | Families    | New           | 155          | 26129    | 168.57          |

</details>

</br>

### B. Data Exploration

#### **Q1. What day of the week is used for each `week_date` value?**

```sql
SELECT
  to_char(week_date, 'Day') AS day_of_data_capture
FROM
  clean_weekly_sales
GROUP BY
  1;
```

| day_of_data_capture |
|---------------------|
| Monday              |

---

#### **Q2. What range of `week_number` are missing from the dataset?**

```sql
WITH to_string_agg AS (
  SELECT
    GENERATE_SERIES(1, 53, 1) months_missing
  EXCEPT
  SELECT
    DISTINCT week_number
  FROM
    clean_weekly_sales
  ORDER BY
    1
)
SELECT
  STRING_AGG(months_missing :: TEXT, ', ') AS month_missing
FROM
  to_string_agg;
```

| month_missing                                                                                         |
|-------------------------------------------------------------------------------------------------------|
| 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53 |
---

#### **Q3. How many total `transactions` were there for each year in the dataset?**

```sql
SELECT
  calendar_year,
  to_char(SUM(transactions), '9,999,999,999') AS sum_transactions
FROM
  clean_weekly_sales
GROUP BY
  1
ORDER BY
  1;
```

| calendar_year | sum_transactions |
|---------------|------------------|
| 2018          | 346,406,460      |
| 2019          | 365,639,285      |
| 2020          | 375,813,651      |

---

#### **Q4. What is the total `sales` for each `region` for each month?**

```sql
SELECT
  region,
  DATE_TRUNC('Month', week_date) AS start_month,
  SUM(sales)::MONEY AS sum_sales
FROM
  clean_weekly_sales
GROUP BY
  1,
  2
ORDER BY
  random()
LIMIT
  10;
```

| region        | start_month              | sum_sales       |
|---------------|--------------------------|-----------------|
| ASIA          | 2019-07-01 | $635,366,443.00 |
| USA           | 2019-05-01 | $220,370,520.00 |
| AFRICA        | 2019-05-01 | $553,828,220.00 |
| USA           | 2018-07-01 | $262,393,377.00 |
| CANADA        | 2018-03-01 | $33,815,571.00  |
| OCEANIA       | 2019-09-01 | $192,154,910.00 |
| AFRICA        | 2020-08-01 | $706,022,238.00 |
| SOUTH AMERICA | 2020-07-01 | $69,314,667.00  |
| AFRICA        | 2020-07-01 | $574,216,244.00 |
| USA           | 2019-04-01 | $277,108,603.00 |

---

#### **Q5. What is the total count of `transactions` for each `platform`.**

```sql
SELECT
  platform,
  to_char(SUM(transactions), '9,999,999,999') AS sum_transactions
FROM
  clean_weekly_sales
GROUP BY
  1;
```

| platform | sum_transactions |
|----------|------------------|
| Shopify  | 5,925,169        |
| Retail   | 1,081,934,227    |

---

#### **Q6. What is the percentage of `sales` for Retail vs Shopify for each month?**

```sql
WITH raw_sales AS (
    SELECT
      DATE_TRUNC('Month', week_date) AS start_month,
      platform,
      SUM(sales) AS sales
    FROM
      clean_weekly_sales
    GROUP BY
      1,
      2
  ),
  platform_segmented AS (
    SELECT
      t1.start_month,
      t1.sales AS shopify,
      t2.sales AS retail
    FROM
      raw_sales t1 FULL
      OUTER JOIN (
        SELECT
          start_month,
          sales
        FROM
          raw_sales
        WHERE
          platform = 'Retail'
      ) t2 ON t1.start_month = t2.start_month
    WHERE
      platform = 'Shopify'
  )
SELECT
  start_month,
  ROUND(100 * shopify :: NUMERIC / (retail + shopify)) || '%' AS shopify,
  ROUND(100 * retail :: NUMERIC / (retail + shopify)) || '%' AS retail
FROM
  platform_segmented
ORDER BY
  1;
```

| calendar_year | families | couples | unknown |
|---------------|----------|---------|---------|
| 2020          | 33%      | 29%     | 39%     |
| 2018          | 32%      | 26%     | 42%     |
| 2019          | 32%      | 27%     | 40%     |

---

#### **Q7. What is the percentage of `sales` by `demographic` for each year in the dataset?**

```sql
WITH raw_sales AS (
    SELECT
      calendar_year,
      demographic,
      SUM(sales) AS sales
    FROM
      clean_weekly_sales
    GROUP BY
      1,
      2
  ),
  demographic_year AS (
    SELECT
      t1.calendar_year,
      t1.sales AS families,
      t2.sales AS couples,
      t3.sales AS unknown
    FROM
      raw_sales t1 FULL
      OUTER JOIN (
        SELECT
          calendar_year,
          sales
        FROM
          raw_sales
        WHERE
          demographic = 'Couples'
      ) t2 ON t1.calendar_year = t2.calendar_year FULL
      OUTER JOIN (
        SELECT
          calendar_year,
          sales
        FROM
          raw_sales
        WHERE
          demographic = 'unknown'
      ) t3 ON t1.calendar_year = t3.calendar_year
    WHERE
      demographic = 'Families'
  )
SELECT
  calendar_year,
  ROUND(
    100 * families :: NUMERIC /(families + couples + unknown)
  ) || '%' AS families,
  ROUND(
    100 * couples :: NUMERIC /(families + couples + unknown)
  ) || '%' AS couples,
  ROUND(
    100 * unknown :: NUMERIC /(families + couples + unknown)
  ) || '%' AS unknown
FROM
  demographic_year;
```

| start_month              | shopify | retail |
|--------------------------|---------|--------|
| 2018-03-01 | 2%      | 98%    |
| 2018-04-01 | 2%      | 98%    |
| 2018-05-01 | 2%      | 98%    |
| 2018-06-01 | 2%      | 98%    |
| 2018-07-01 | 2%      | 98%    |
| 2018-08-01 | 2%      | 98%    |
| 2018-09-01 | 2%      | 98%    |
| 2019-03-01 | 2%      | 98%    |
| 2019-04-01 | 2%      | 98%    |
| 2019-05-01 | 2%      | 98%    |
| 2019-06-01 | 3%      | 97%    |
| 2019-07-01 | 3%      | 97%    |
| 2019-08-01 | 3%      | 97%    |
| 2019-09-01 | 3%      | 97%    |

---

#### **Q8. Which `age_band` and `demographic` values contribute the most to Retail `sales`?**

```sql
SELECT
  age_band,
  demographic,
  SUM(sales) :: MONEY AS sum_sales,
  ROUND(
    100 * SUM(sales) :: NUMERIC / SUM(SUM(sales)) OVER()
  ) || '%' AS percent
FROM
  clean_weekly_sales
WHERE
  platform = 'Retail'
  AND (
    demographic != 'unknown'
    OR demographic != 'unknown'
  )
GROUP BY
  1,
  2
ORDER BY
  3 DESC;
```

| age_band     | demographic | sum_sales         | percent |
|--------------|-------------|-------------------|---------|
| Retirees     | Families    | $6,634,686,916.00 | 28%     |
| Retirees     | Couples     | $6,370,580,014.00 | 27%     |
| Middle Aged  | Families    | $4,354,091,554.00 | 18%     |
| Young Adults | Couples     | $2,602,922,797.00 | 11%     |
| Middle Aged  | Couples     | $1,854,160,330.00 | 8%      |
| Young Adults | Families    | $1,770,889,293.00 | 8%      |

---

#### **Q9. Can we use the `avg_transaction` column to find the average `transaction` size for each year for Retail vs Shopify? If not - how would you calculate it instead?**

> #### You definitely can't. Reason - Math says so!
>
> #### Alternatively, you can solve it this way.

```SQL
WITH raw_transactions AS (
    SELECT
      calendar_year,
      platform,
      ROUND(AVG(transactions)) AS transactions
    FROM
      clean_weekly_sales
    GROUP BY
      1,
      2
  )
SELECT
  t1.calendar_year,
  to_char(t1.transactions, '9,999,999') AS retail,
  to_char(t2.transactions, '9,999,999') AS shopify
FROM
  raw_transactions t1 FULL
  OUTER JOIN (
    SELECT
      calendar_year,
      transactions
    FROM
      raw_transactions
    WHERE
      platform = 'Shopify'
  ) t2 ON t1.calendar_year = t2.calendar_year
WHERE
  platform = 'Retail';
```
  
| calendar_year | retail  | shopify |
|---------------|---------|---------|
| 2019          | 127,360 | 666     |
| 2018          | 120,770 | 523     |
| 2020          | 130,698 | 889     |

---

### C. BEFORE & AFTER ANALYSIS

#### **Q1. Comparison of 4 weeks period before and after change - '2020-06-15'.**

```SQL
WITH period_cte AS (
    SELECT
      to_char('2020-06-15' :: DATE, 'ww') :: NUMERIC AS week_of_change,
      4 AS period_length
  ),
  parameters AS (
    SELECT
      week_of_change,
      week_of_change + period_length AS right_date,
      week_of_change - period_length + 1 AS left_date
    FROM
      period_cte
  ),
  separate_cte AS (
    SELECT
      CASE
        WHEN week_number BETWEEN left_date
        AND week_of_change THEN '1. Before'
        WHEN week_number BETWEEN week_of_change + 1
        AND right_date THEN '2. After'
      END AS status,
      SUM(sales) AS total_sum
    FROM
      clean_weekly_sales,
      parameters
    WHERE
      calendar_year = 2020
      AND week_number BETWEEN left_date
      AND right_date
    GROUP BY
      1
  ),
  remove_nulls AS (
    SELECT
      (
        total_sum - LAG(total_sum) OVER(
          ORDER BY
            status
        )
      ) :: MONEY AS diff_sales,
      ROUND(
        100 * (
          total_sum - LAG(total_sum) OVER(
            ORDER BY
              status
          )
        ) :: NUMERIC / total_sum,
        2
      ) || '%' AS sales_change
    FROM
      separate_cte
  )
SELECT
  *
FROM
  remove_nulls
WHERE
  diff_sales IS NOT NULL;
```

| diff_sales    | sales_change |
|---------------|--------------|
| $4,009,608.00 | 0.17%        |

---

#### **Q2. Comparison of 12 weeks period before and after change - '2020-06-15'.**

```SQL
  WITH period_cte AS (
    SELECT
      to_char('2020-06-15' :: DATE, 'ww') :: NUMERIC AS week_of_change,
      12 AS period_length
  ),
  parameters AS (
    SELECT
      week_of_change,
      week_of_change + period_length AS right_date,
      week_of_change - period_length + 1 AS left_date
    FROM
      period_cte
  ),
  separate_cte AS (
    SELECT
      CASE
        WHEN week_number BETWEEN left_date
        AND week_of_change THEN '1. Before'
        WHEN week_number BETWEEN week_of_change + 1
        AND right_date THEN '2. After'
      END AS status,
      SUM(sales) AS total_sum
    FROM
      clean_weekly_sales,
      parameters
    WHERE
      calendar_year = 2020
      AND week_number BETWEEN left_date
      AND right_date
    GROUP BY
      1
  ),
  remove_nulls AS (
    SELECT
      (
        total_sum - LAG(total_sum) OVER(
          ORDER BY
            status
        )
      ) :: MONEY AS diff_sales,
      ROUND(
        100 * (
          total_sum - LAG(total_sum) OVER(
            ORDER BY
              status
          )
        ) :: NUMERIC / total_sum,
        2
      ) || '%' AS sales_change
    FROM
      separate_cte
  )
SELECT
  *
FROM
  remove_nulls
WHERE
  diff_sales IS NOT NULL;
```

| diff_sales        | sales_change |
|-------------------|--------------|
| $654,178,584.00 | -10.22%      |

---

#### **Q3. Comparison of 4 weeks period before and after change - '[x]-06-15' across all years.**

```SQL
WITH period_cte AS (
    SELECT
      24 AS week_of_change,
      4 AS period_length
  ),
  parameters AS (
    SELECT
      week_of_change,
      week_of_change + period_length AS right_date,
      week_of_change - period_length + 1 AS left_date
    FROM
      period_cte
  ),
  separate_cte AS (
    SELECT
      calendar_year,
      CASE
        WHEN week_number BETWEEN left_date
        AND week_of_change THEN '1. Before'
        WHEN week_number BETWEEN week_of_change + 1
        AND right_date THEN '2. After'
      END AS status,
      SUM(sales) AS total_sum
    FROM
      clean_weekly_sales,
      parameters
    WHERE
      week_number BETWEEN left_date
      AND right_date
    GROUP BY
      1,
      2
  ),
  remove_nulls AS (
    SELECT
      calendar_year,(
        total_sum - LAG(total_sum) OVER(
          PARTITION BY calendar_year
          ORDER BY
            status
        )
      ) :: MONEY AS diff_sales,
      ROUND(
        100 * (
          total_sum - LAG(total_sum) OVER(
            PARTITION BY calendar_year
            ORDER BY
              status
          )
        ) :: NUMERIC / total_sum,
        2
      ) || '%' AS sales_change
    FROM
      separate_cte
  )
SELECT
  *
FROM
  remove_nulls
WHERE
  diff_sales IS NOT NULL;
```

| calendar_year | diff_sales     | sales_change |
|---------------|----------------|--------------|
| 2018          | $4,102,105.00  | 0.19%        |
| 2019          | $16,519,108.00 | 0.73%        |
| 2020          | $4,009,608.00  | 0.17%        |

---

#### **Q4. Comparison of 12 weeks period before and after change - '[x]-06-15' across all years.**

```SQL
WITH period_cte AS (
    SELECT
      24 AS week_of_change,
      12 AS period_length
  ),
  parameters AS (
    SELECT
      week_of_change,
      week_of_change + period_length AS right_date,
      week_of_change - period_length + 1 AS left_date
    FROM
      period_cte
  ),
  separate_cte AS (
    SELECT
      calendar_year,
      CASE
        WHEN week_number BETWEEN left_date
        AND week_of_change THEN '1. Before'
        WHEN week_number BETWEEN week_of_change + 1
        AND right_date THEN '2. After'
      END AS status,
      SUM(sales) AS total_sum
    FROM
      clean_weekly_sales,
      parameters
    WHERE
      week_number BETWEEN left_date
      AND right_date
    GROUP BY
      1,
      2
  ),
  remove_nulls AS (
    SELECT
      calendar_year,(
        total_sum - LAG(total_sum) OVER(
          PARTITION BY calendar_year
          ORDER BY
            status
        )
      ) :: MONEY AS diff_sales,
      ROUND(
        100 * (
          total_sum - LAG(total_sum) OVER(
            PARTITION BY calendar_year
            ORDER BY
              status
          )
        ) :: NUMERIC / total_sum,
        2
      ) || '%' AS sales_change
    FROM
      separate_cte
  )
SELECT
  *
FROM
  remove_nulls
WHERE
  diff_sales IS NOT NULL;
```

| calendar_year | diff_sales        | sales_change |
|---------------|-------------------|--------------|
| 2018          | $104,256,193.00   | 1.60%        |
| 2019          | $557,600,876.00 | -8.85%       |
| 2020          | $654,178,584.00 | -10.22%      |

---

<p>&copy; 2022 Kingsley Izima</p>
