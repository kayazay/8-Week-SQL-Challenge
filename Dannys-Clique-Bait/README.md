# 🍜 Case Study #6 - Danny's Clique Bait
<p align="center">

<img src="https://user-images.githubusercontent.com/60517587/178071018-52ea8ede-5b74-48c5-89c3-6341f85721be.png" width=40% height=40% />


## 📕 Table Of Contents
* ### 🛠️ [Problem Statement](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Clique-Bait#%EF%B8%8F-problem-statement)
* ### 📂 [Dataset](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Clique-Bait#-dataset)
* ### ❓ [Case Study Questions](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Clique-Bait#question%EF%B8%8F-case-study-questions)
  * #### 🖥️ [DIGITAL ANALYSIS](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Clique-Bait#-digital-analysis)
  * #### 🍱 [PRODUCT FUNNEL ANALYSIS](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Data-Mart#-product-funnel-analysis)
  * #### 📢 [CAMPAIGNS ANALYSIS](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Data-Mart#-campaigns-analysis)

<br/>

## 🛠️ Problem Statement

> Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry! In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

 <br /> 


## 📂 Dataset
Danny has shared with you 5 datasets for this case study:

### **```users```**

<details>
<summary>
View table
</summary>

Customers who visit the Clique Bait website are tagged via their `cookie_id`.

| user_id | cookie_id | start_date     |
|---------|-----------|----------------|
| 397     | 3759ff    | 3/30/2020 |
| 215     | 863329    | 1/26/2020 |
| 191     | eefca9    | 3/15/2020 |
| 89      | 764796    | 1/7/2020  |
| 127     | 17ccc5    | 1/22/2020 |
| 81      | b0b666    | 3/1/2020  |
| 260     | a4f236    | 1/8/2020  |
| 203     | d1182f    | 4/18/2020 |
| 23      | 12dbc8    | 1/18/2020 |
| 375     | f61d69    | 1/3/2020  |


</details>



### **`events`**

<details>
<summary>
View table
</summary>

Customer visits are logged at a `cookie_id level` and the `event_type` and `page_id` values can be used to join onto relevant tables to obtain further information about each event.

The `sequence_number` is used to order the events within each visit.

| visit_id | cookie_id | page_id | event_type | sequence_number | event_time                 |
|----------|-----------|---------|------------|-----------------|----------------------------|
| 719fd3   | 3d83d3    | 5       | 1          | 4               | 2020-03-02 00:29:09.975502 |
| fb1eb1   | c5ff25    | 5       | 2          | 8               | 2020-01-22 07:59:16.761931 |
| 23fe81   | 1e8c2d    | 10      | 1          | 9               | 2020-03-21 13:14:11.745667 |
| ad91aa   | 648115    | 6       | 1          | 3               | 2020-04-27 16:28:09.824606 |
| 5576d7   | ac418c    | 6       | 1          | 4               | 2020-01-18 04:55:10.149236 |
| 48308b   | c686c1    | 8       | 1          | 5               | 2020-01-29 06:10:38.702163 |
| 46b17d   | 78f9b3    | 7       | 1          | 12              | 2020-02-16 09:45:31.926407 |
| 9fd196   | ccf057    | 4       | 1          | 5               | 2020-02-14 08:29:12.922164 |
| edf853   | f85454    | 1       | 1          | 1               | 2020-02-22 12:59:07.652207 |
| 3c6716   | 02e74f    | 3       | 2          | 5               | 2020-01-31 17:56:20.777383 |


</details>


### **`event_identifier`**

<details>
<summary>
View table
</summary>

This table shows the types of events which are captured by Clique Bait’s digital data systems.

| event_type | event_name    |
|------------|---------------|
| 1          | Page View     |
| 2          | Add to Cart   |
| 3          | Purchase      |
| 4          | Ad Impression |
| 5          | Ad Click      |


</details>

### **`campaign_identifier`**

<details>
<summary>
View table
</summary>

This table shows information for the 3 campaigns that Clique Bait has ran on their website so far in 2020.

| campaign_id | products | campaign_name                     | start_date          | end_date            |
|-------------|----------|-----------------------------------|---------------------|---------------------|
| 1           | 1-3      | BOGOF - Fishing For Compliments   | 2020-01-01 00:00:00 | 2020-01-14 00:00:00 |
| 2           | 4-5      | 25% Off - Living The Lux Life     | 2020-01-15 00:00:00 | 2020-01-28 00:00:00 |
| 3           | 6-8      | Half Off - Treat Your Shellf(ish) | 2020-02-01 00:00:00 | 2020-03-31 00:00:00 |


</details>


### **`page_hierarchy`**

<details>
<summary>
View table
</summary>

This table lists all of the pages on the Clique Bait website which are tagged and have data passing through from user interaction events.

| page_id | page_name      | product_category | product_id |
|---------|----------------|------------------|------------|
| 1       | Home Page      | null             | null       |
| 2       | All Products   | null             | null       |
| 3       | Salmon         | Fish             | 1          |
| 4       | Kingfish       | Fish             | 2          |
| 5       | Tuna           | Fish             | 3          |
| 6       | Russian Caviar | Luxury           | 4          |
| 7       | Black Truffle  | Luxury           | 5          |
| 8       | Abalone        | Shellfish        | 6          |
| 9       | Lobster        | Shellfish        | 7          |
| 10      | Crab           | Shellfish        | 8          |
| 11      | Oyster         | Shellfish        | 9          |
| 12      | Checkout       | null             | null       |
| 13      | Confirmation   | null             | null       |


</details>


### **E.R.D**
<details>

<summary>
View diagram
</summary>
<img src="https://user-images.githubusercontent.com/60517587/178071015-0d00a49d-d22d-47af-bb12-5ec7d9527649.png" width=60% height=50%>

</details>

<br/>

## ❓ Case Study Question

This case study has a LOT of questions - they are divided into 3 sections which are:
+ **Digital Analysis**,  
+ **Product Funnel Analysis**,
+ **Campaigns Analysis**.

 <p align="center">
<img src="https://user-images.githubusercontent.com/60517587/178070968-d324b2ed-5391-46e0-b9d6-4610d3cd19e5.gif" width=50% height=50%>

</br>

### 🖥️ DIGITAL ANALYSIS
#### **Q1. How many `users` are there?**

```SQL
SELECT
  COUNT (DISTINCT user_id) AS num_customers
FROM
  clique_bait.users;
```

| num_customers |
|---------------|
| 500           |

---

#### **Q2. How many cookies does each user have on average?**

```SQL
WITH count_of_cookies AS (
    SELECT
      user_id,
      COUNT(DISTINCT cookie_id) AS _count
    FROM
      clique_bait.users
    GROUP BY
      1
  )
SELECT
  ROUND(AVG(_count), 2) AS avg_cookies_per_user
FROM
  count_of_cookies;
```

| avg_cookies_per_user |
|----------------------|
| 3.56                 |

---

#### **Q3. What is the unique number of visits by all `users` per month?**

```SQL
SELECT
  DATE_TRUNC('month', event_time) AS start_month,
  COUNT(DISTINCT visit_id) AS number_of_visits
FROM
  clique_bait.events
GROUP BY
  1
ORDER BY
  1;
```

| start_month              | number_of_visits |
|--------------------------|------------------|
| 2020-01-01 | 876              |
| 2020-02-01 | 1488             |
| 2020-03-01 | 916              |
| 2020-04-01 | 248              |
| 2020-05-01 | 36               |

---

#### **Q4. What is the number of events for each event type?**

```SQL
SELECT
  event_name,
  COUNT(*) frequency_of_occurence
FROM
  clique_bait.events
  LEFT JOIN clique_bait.event_identifier ON event_identifier.event_type = events.event_type
GROUP BY
  1
ORDER BY
  2 DESC;
```

| event_name    | frequency_of_occurence |
|---------------|------------------------|
| Page View     | 20928                  |
| Add to Cart   | 8451                   |
| Purchase      | 1777                   |
| Ad Impression | 876                    |
| Ad Click      | 702                    |

---

#### **Q5. What is the percentage of visits which have a purchase event?**

```SQL
WITH purchase_cte AS (
    SELECT
      visit_id,
      MAX(
        CASE
          WHEN event_type = 3 THEN 3
          ELSE 0
        END
      ) AS flaga
    FROM
      clique_bait.events
    GROUP BY
      visit_id
    ORDER BY
      1
  )
SELECT
  SUM(
    CASE
      WHEN flaga = 3 THEN 1
      ELSE 0
    END
  ) AS visits_that_turned_to_purchase,
  ROUND(
    100 * SUM(
      CASE
        WHEN flaga = 3 THEN 1
        ELSE 0
      END
    ) :: NUMERIC / COUNT(*),
    2
  ) AS percent_of_total
FROM
  purchase_cte;
```

| visits_that_turned_to_purchase | percent_of_total |
|--------------------------------|------------------|
| 1777                           | 49.86            |

---

#### **Q6. What is the percentage of visits which view the checkout page but do not have a purchase event?**

```SQL
WITH boolean_bought AS (
    SELECT
      visit_id,
      MAX(
        CASE
          WHEN event_type = 1
          AND page_id = 12 THEN 5
          ELSE 0
        END
      ) AS view_checkout_page,
      MAX(
        CASE
          WHEN event_type = 3 THEN 7
          ELSE 0
        END
      ) AS purchased
    FROM
      clique_bait.events
    GROUP BY
      visit_id
  )
SELECT
  SUM(
    CASE
      WHEN purchased = 7 THEN 0
      ELSE 1
    END
  ) AS view_checkout_page_but_no_purchase,
  ROUND(
    100 * SUM(
      CASE
        WHEN purchased = 7 THEN 0
        ELSE 1
      END
    ) :: NUMERIC / COUNT(*),
    2
  ) AS percent_total
FROM
  boolean_bought
WHERE
  view_checkout_page = 5;
```

| view_checkout_page_but_no_purchase | percent_total |
|------------------------------------|---------------|
| 326                                | 15.5          |  

---

#### **Q7. What are the top 3 pages by number of views?**

```SQL
SELECT
  page_name,
  COUNT(visit_id) AS number_of_views
FROM
  clique_bait.events
  LEFT JOIN clique_bait.page_hierarchy ON page_hierarchy.page_id = events.page_id
WHERE
  event_type = 1
GROUP BY
  1
ORDER BY
  2 DESC;
```

| page_name      | number_of_views |
|----------------|-----------------|
| All Products   | 3174            |
| Checkout       | 2103            |
| Home Page      | 1782            |
| Oyster         | 1568            |
| Crab           | 1564            |
| Russian Caviar | 1563            |
| Kingfish       | 1559            |
| Salmon         | 1559            |
| Lobster        | 1547            |
| Abalone        | 1525            |
| Tuna           | 1515            |
| Black Truffle  | 1469            |

---

#### **Q8. What is the number of views and cart adds for each `product_category`?**

```SQL
SELECT
  product_category,
  SUM(
    CASE
      WHEN event_type = 2 THEN 1
      ELSE 0
    END
  ) AS num_cart_adds,
  SUM(
    CASE
      WHEN event_type = 1 THEN 1
      ELSE 0
    END
  ) AS num_views
FROM
  clique_bait.events
  INNER JOIN clique_bait.page_hierarchy ON page_hierarchy.page_id = events.page_id
WHERE
  product_category IS NOT null
GROUP BY
  1;
```

| product_category | num_cart_adds | num_views |
|------------------|---------------|-----------|
| Luxury           | 1870          | 3032      |
| Shellfish        | 3792          | 6204      |
| Fish             | 2789          | 4633      |

---

#### **Q9. What are the top 3 products by purchases?**

```SQL
WITH filtered_cte AS (
    SELECT
      visit_id,
      cookie_id,
      event_type,
      page_id
    FROM
      clique_bait.events t1
    WHERE
      EXISTS (
        SELECT
          'BOMBOCLAAT'
        FROM
          clique_bait.events t2
        WHERE
          event_type = 3
          AND t1.visit_id = t2.visit_id
          AND t1.cookie_id = t2.cookie_id
      )
  )
SELECT
  page_name,
  SUM(
    CASE
      WHEN event_type = 2 THEN 1
      ELSE 0
    END
  ) AS num_times_purchase_item
FROM
  filtered_cte
  INNER JOIN (
    SELECT
      *
    FROM
      clique_bait.page_hierarchy
    WHERE
      page_id NOT IN (1, 2, 12, 13)
  ) page_hierarchy ON page_hierarchy.page_id = filtered_cte.page_id
GROUP BY
  1
ORDER BY
  2 DESC;
```

| page_name      | num_times_purchase_item |
|----------------|-------------------------|
| Lobster        | 754                     |
| Oyster         | 726                     |
| Crab           | 719                     |
| Salmon         | 711                     |
| Kingfish       | 707                     |
| Black Truffle  | 707                     |
| Abalone        | 699                     |
| Russian Caviar | 697                     |
| Tuna           | 697                     |

---

</br>

### 🍱 PRODUCT FUNNEL ANALYSIS

**Using a single SQL query - create a new output table which has the following details:**

+ How many times was each product viewed?
+ How many times was each product added to cart?
+ How many times was each product added to a cart but not purchased (abandoned)?
+ How many times was each product purchased?
+ How many times was each product viewed?
+ How many times was each product added to cart?
+ How many times was each product added to a cart but not purchased (abandoned)?
+ How many times was each product purchased?

#### Q1. Output table aggregated on page name - products.

```sql
DROP TABLE IF EXISTS page_name_table;
CREATE TEMP TABLE page_name_table AS (
  WITH actual_df AS (
    SELECT
      visit_id,
      cookie_id,
      events.page_id,
      event_type,
      page_name,
      product_category
    FROM
      clique_bait.events
      LEFT JOIN clique_bait.page_hierarchy ON page_hierarchy.page_id = events.page_id
  ),
  view_cart_buy AS (
    SELECT
      visit_id,
      page_id,
      page_name,
      product_category,
      SUM(
        CASE
          WHEN event_type = 1 THEN 1
          ELSE 0
        END
      ) AS num_views,
      SUM(
        CASE
          WHEN event_type = 2 THEN 1
          ELSE 0
        END
      ) AS cart_adds,
      MAX(
        CASE
          WHEN page_id = 13 THEN 1
          ELSE 0
        END
      ) OVER(PARTITION BY visit_id) AS purchased
    FROM
      actual_df
    GROUP BY
      1,
      2,
      3,
      4
  ),
  todo_groupby AS (
    SELECT
      visit_id,
      page_name,
      product_category,
      num_views,
      cart_adds,
      CASE
        WHEN purchased = 1
        AND cart_adds = 0 THEN 0
        ELSE purchased
      END AS purchased
    FROM
      view_cart_buy
    WHERE
      page_id NOT IN (1, 2, 12, 13)
  )
  SELECT
    page_name,
    SUM(num_views) AS total_views,
    SUM(cart_adds) AS added_to_cart,
    SUM(
      CASE
        WHEN cart_adds = 1
        AND purchased = 0 THEN 1
        ELSE 0
      END
    ) AS cart_but_abandoned,
    SUM(purchased) AS purchased
  FROM
    todo_groupby
  GROUP BY
    1
);
SELECT
  *
FROM
  page_name_table;
```

| page_name      | total_views | added_to_cart | cart_but_abandoned | purchased |
|----------------|-------------|---------------|--------------------|-----------|
| Abalone        | 1525        | 932           | 233                | 699       |
| Oyster         | 1568        | 943           | 217                | 726       |
| Salmon         | 1559        | 938           | 227                | 711       |
| Crab           | 1564        | 949           | 230                | 719       |
| Tuna           | 1515        | 931           | 234                | 697       |
| Lobster        | 1547        | 968           | 214                | 754       |
| Kingfish       | 1559        | 920           | 213                | 707       |
| Russian Caviar | 1563        | 946           | 249                | 697       |
| Black Truffle  | 1469        | 924           | 217                | 707       |

---

#### Q2. Output table aggregated on product_category.

```sql
DROP TABLE IF EXISTS product_category_table;
CREATE TEMP TABLE product_category_table AS (
    WITH actual_df AS (
      SELECT
        visit_id,
        cookie_id,
        events.page_id,
        event_type,
        page_name,
        product_category
      FROM
        clique_bait.events
        LEFT JOIN clique_bait.page_hierarchy ON page_hierarchy.page_id = events.page_id
    ),
    view_cart_buy AS (
      SELECT
        visit_id,
        page_id,
        page_name,
        product_category,
        SUM(
          CASE
            WHEN event_type = 1 THEN 1
            ELSE 0
          END
        ) AS num_views,
        SUM(
          CASE
            WHEN event_type = 2 THEN 1
            ELSE 0
          END
        ) AS cart_adds,
        MAX(
          CASE
            WHEN page_id = 13 THEN 1
            ELSE 0
          END
        ) OVER(PARTITION BY visit_id) AS purchased
      FROM
        actual_df
      GROUP BY
        1,
        2,
        3,
        4
    ),
    todo_groupby AS (
      SELECT
        visit_id,
        page_name,
        product_category,
        num_views,
        cart_adds,
        CASE
          WHEN purchased = 1
          AND cart_adds = 0 THEN 0
          ELSE purchased
        END AS purchased
      FROM
        view_cart_buy
      WHERE
        page_id NOT IN (1, 2, 12, 13)
    )
    SELECT
      product_category,
      SUM(num_views) AS total_views,
      SUM(cart_adds) AS added_to_cart,
      SUM(
        CASE
          WHEN cart_adds = 1
          AND purchased = 0 THEN 1
          ELSE 0
        END
      ) AS cart_but_abandoned,
      SUM(purchased) AS purchased
    FROM
      todo_groupby
    GROUP BY
      1
  );
SELECT
  *
FROM
  product_category_table;
```

| product_category | total_views | added_to_cart | cart_but_abandoned | purchased |
|------------------|-------------|---------------|--------------------|-----------|
| Luxury           | 3032        | 1870          | 466                | 1404      |
| Shellfish        | 6204        | 3792          | 894                | 2898      |
| Fish             | 4633        | 2789          | 674                | 2115      |

---

</br>

### 📢 CAMPAIGNS ANALYSIS

> **Generate a table that has 1 single row for every unique `visit_id` record and has the following columns:**

+ `user_id`
+ `visit_id`
+ `visit_start_time`: the earliest event_time for each visit
+ `page_views`: count of page views for each visit
+ `cart_adds`: count of product cart add events for each visit
+ `purchase`: 1/0 flag if a purchase event exists for each visit
+ `campaign_name`: map the visit to a campaign if the `visit_start_time` falls between the `start_date` and `end_date`
+ `impression`: count of ad impressions for each visit
+ `click`: count of ad clicks for each visit
+ `cart_products` (Optional column): a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the `sequence_number`)


```SQL
DROP TABLE IF EXISTS info_user;
CREATE TEMP TABLE info_user AS (
  WITH order_items_cart AS (
    SELECT
      visit_id,
      STRING_AGG(page_name, ', ') OVER(
        PARTITION BY visit_id
        ORDER BY
          sequence_number
      ) AS cart_products,
      ROW_NUMBER() OVER(
        PARTITION BY visit_id
        ORDER BY
          sequence_number DESC
      ) AS flag
    FROM
      clique_bait.events
      LEFT JOIN clique_bait.page_hierarchy ON page_hierarchy.page_id = events.page_id
    WHERE
      event_type = 2
  ),
  other_fields AS (
    SELECT
      visit_id,
      cookie_id,
      MIN(event_time :: TIMESTAMP) AS visit_start_time,
      SUM(
        CASE
          WHEN event_type = 1 THEN 1
          ELSE 0
        END
      ) AS page_views,
      SUM(
        CASE
          WHEN event_type = 2 THEN 1
          ELSE 0
        END
      ) AS cart_adds,
      MAX(
        CASE
          WHEN event_type = 3
          AND page_id = 13 THEN 'yes'
          ELSE 'no'
        END
      ) AS purchase,
      SUM(
        CASE
          WHEN event_type = 4 THEN 1
          ELSE 0
        END
      ) AS impressions,
      SUM(
        CASE
          WHEN event_type = 5 THEN 1
          ELSE 0
        END
      ) AS clicks
    FROM
      clique_bait.events
    GROUP BY
      1,
      2
  )
  SELECT
    user_id,
    other_fields.visit_id,
    visit_start_time,
    page_views,
    cart_adds,
    purchase,
    campaign_name,
    impressions,
    clicks,
    COALESCE(cart_products, '') AS cart_products
  FROM
    other_fields
    LEFT JOIN clique_bait.campaign_identifier ON other_fields.visit_start_time BETWEEN campaign_identifier.start_date
    AND campaign_identifier.end_date
    LEFT JOIN clique_bait.users ON users.cookie_id = other_fields.cookie_id
    LEFT JOIN (
      SELECT
        *
      FROM
        order_items_cart
      WHERE
        flag = 1
    ) otc ON otc.visit_id = other_fields.visit_id
  ORDER BY
    user_id,
    visit_id
);
SELECT
  *
FROM
  info_user
LIMIT
  10;
```

| user_id | visit_id | visit_start_time         | page_views | cart_adds | purchase | campaign_name                     | impressions | clicks | cart_products                                                                 |
|---------|----------|--------------------------|------------|-----------|----------|-----------------------------------|-------------|--------|-------------------------------------------------------------------------------|
| 1       | 02a5d5   | 2020-02-26T16:57:26.261Z | 4          | 0         | no       | Half Off - Treat Your Shellf(ish) | 0           | 0      |                                                                               |
| 1       | 0826dc   | 2020-02-26T05:58:37.919Z | 1          | 0         | no       | Half Off - Treat Your Shellf(ish) | 0           | 0      |                                                                               |
| 1       | 0fc437   | 2020-02-04T17:49:49.603Z | 10         | 6         | yes      | Half Off - Treat Your Shellf(ish) | 1           | 1      | Tuna, Russian Caviar, Black Truffle, Abalone, Crab, Oyster                    |
| 1       | 30b94d   | 2020-03-15T13:12:54.024Z | 9          | 7         | yes      | Half Off - Treat Your Shellf(ish) | 1           | 1      | Salmon, Kingfish, Tuna, Russian Caviar, Abalone, Lobster, Crab                |
| 1       | 41355d   | 2020-03-25T00:11:17.861Z | 6          | 1         | no       | Half Off - Treat Your Shellf(ish) | 0           | 0      | Lobster                                                                       |
| 1       | ccf365   | 2020-02-04T19:16:09.183Z | 7          | 3         | yes      | Half Off - Treat Your Shellf(ish) | 0           | 0      | Lobster, Crab, Oyster                                                         |
| 1       | eaffde   | 2020-03-25T20:06:32.343Z | 10         | 8         | yes      | Half Off - Treat Your Shellf(ish) | 1           | 1      | Salmon, Tuna, Russian Caviar, Black Truffle, Abalone, Lobster, Crab,   Oyster |
| 1       | f7c798   | 2020-03-15T02:23:26.313Z | 9          | 3         | yes      | Half Off - Treat Your Shellf(ish) | 0           | 0      | Russian Caviar, Crab, Oyster                                                  |
| 2       | 0635fb   | 2020-02-16T06:42:42.736Z | 9          | 4         | yes      | Half Off - Treat Your Shellf(ish) | 0           | 0      | Salmon, Kingfish, Abalone, Crab                                               |
| 2       | 1f1198   | 2020-02-01T21:51:55.079Z | 1          | 0         | no       | Half Off - Treat Your Shellf(ish) | 0           | 0      |                                                                               |

---

<p>&copy; 2022 Kingsley Izima</p>
