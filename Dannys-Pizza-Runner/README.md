# 🍕 Case Study #2 - Danny's Pizza Runner
<p align="center">

<img src="https://user-images.githubusercontent.com/60517587/176715403-26850b68-8cdf-4506-ab2e-35fb24fe4bca.png" width=50% height=40% />

## 📕 Table Of Contents
* ### 🛠️ [Problem Statement](https://github.com/kayazay/8-Week-SQL-Challenge/blob/main/Dannys-Pizza-Runner/README.md#%EF%B8%8F-problem-statement-1)
* ### 📂 [Dataset](https://github.com/kayazay/8-Week-SQL-Challenge/blob/main/Dannys-Pizza-Runner/README.md#-dataset-1)
* ### ❓  [Case Study Questions](https://github.com/kayazay/8-Week-SQL-Challenge/blob/main/Dannys-Pizza-Runner/README.md#question%EF%B8%8F-case-study-questions)
  * #### 📈 [PIZZA METRICS](https://github.com/kayazay/8-Week-SQL-Challenge/blob/main/Dannys-Pizza-Runner/README.md#-pizza-metrics-questions-and-solutions)
  * #### 🚚 [RUNNER AND CUSTOMER EXPERIENCE](https://github.com/kayazay/8-Week-SQL-Challenge/blob/main/Dannys-Pizza-Runner/README.md#-runner-and-customer-experience---questions-and-solutions)
  * #### 🌶️ [INGREDIENTS OPTIMIZATION](https://github.com/kayazay/8-Week-SQL-Challenge/blob/main/Dannys-Pizza-Runner/README.md#-ingredients-optimization---questions-and-solutions)
  * #### 💰 [PRICING AND RATINGS](https://github.com/kayazay/8-Week-SQL-Challenge/blob/main/Dannys-Pizza-Runner/README.md#-pricing-and-ratings---questions-and-solutions)


## 🛠️ Problem Statement

> Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!” Danny was sold on the idea, but he knew that he had one more genius idea to combine with his Pizza Empire - he was going to Uberize it - and so Pizza Runner was launched! Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters to customers. He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimize Pizza Runner’s operations.
 <br /> 


## 📂 Dataset
Danny has shared with you 6 datasets for this case study:

### **```runners```**

<details>
<summary>
View table
</summary>

The `runners` table shows the `registration_date` for each new runner.

| runner_id | registration_date        |
|-----------|--------------------------|
| 1         | 2021-01-01  |
| 2         | 2021-01-03  |
| 3         | 2021-01-08  |
| 4         | 2021-01-15  |

 </details>

### **`customer_orders`**

<details>
<summary>
View table
</summary>

Customer pizza orders are captured in the  `customer_orders` table with 1 row for each individual pizza that is part of the order. The `pizza_id` relates to the type of pizza which was ordered whilst the `exclusions` are the `topping_id` values which should be removed from the pizza and the `extras` are the `topping_id` values which need to be added to the pizza.

| order_id | customer_id | pizza_id | exclusions               | extras                   | order_time               |
|----------|-------------|----------|--------------------------|--------------------------|--------------------------|
| 1        | 101         | 1        |                         |                         |2021-01-01 18:05:02         |
| 2        | 101         | 1       |                          |                             | 2021-01-01 19:00:52  |
| 3        | 102         | 1        |                         |                            | 2021-01-02 23:51:23  |
| 3        | 102         | 2        |                        |                          | 2021-01-02 23:51:23    |
| 4        | 103         | 1        | 4                        |                      |   2021-01-04 13:23:46 |
| 4        | 103         | 1        | 4                        |                          |  2021-01-04 13:23:46|
| 4        | 103         | 2        | 4                        |                          |   2021-01-04 13:23:46|
| 5        | 104         | 1        | null                     | 1                        | 2021-01-08 21:00:29  |
| 6        | 101         | 2        | null                     | null                     | 2021-01-08 21:03:13  |
| 7        | 105         | 2        | null                     | 1                        | 2021-01-08 21:20:29  |
| 8        | 102         | 1        | null                     | null                     | 2021-01-09 23:54:33  |
| 9        | 103         | 1        | 4                        | 1, 5                     | 2021-01-10 11:22:59  |
| 10       | 104         | 1        | null                     | null                     | 2021-01-11 18:34:49  |
| 10       | 104         | 1        | 2, 6                     | 1, 4                     | 2021-01-11 18:34:49  |
  
There was need to clean this dataset because of data quality issues and a VIEW was created - `new_customer_order`, the DDL can be found in the general DDL script, and its rows are shown below. Also an extra column was added to track unique inidividual pizzas.
  
 | order_id | customer_id | pizza_id | pizza_name  | exclusions | extras | order_time               | rowcheck |
|----------|-------------|----------|-------------|------------|--------|--------------------------|----------|
| 1        | 101         | 1        | Meat Lovers |            |        | 2021-01-01T18:05:02.000Z | 7        |
| 2        | 101         | 1        | Meat Lovers |            |        | 2021-01-01T19:00:52.000Z | 2        |
| 3        | 102         | 1        | Meat Lovers |            |        | 2021-01-02T23:51:23.000Z | 3        |
| 3        | 102         | 2        | Vegetarian  |            |        | 2021-01-02T23:51:23.000Z | 11       |
| 4        | 103         | 2        | Vegetarian  | 4          |        | 2021-01-04T13:23:46.000Z | 14       |
| 4        | 103         | 1        | Meat Lovers | 4          |        | 2021-01-04T13:23:46.000Z | 8        |
| 4        | 103         | 1        | Meat Lovers | 4          |        | 2021-01-04T13:23:46.000Z | 9        |
| 5        | 104         | 1        | Meat Lovers |            | 1      | 2021-01-08T21:00:29.000Z | 10       |
| 6        | 101         | 2        | Vegetarian  |            |        | 2021-01-08T21:03:13.000Z | 13       |
| 7        | 105         | 2        | Vegetarian  |            | 1      | 2021-01-08T21:20:29.000Z | 12       |
| 8        | 102         | 1        | Meat Lovers |            |        | 2021-01-09T23:54:33.000Z | 4        |
| 9        | 103         | 1        | Meat Lovers | 4          | 1, 5   | 2021-01-10T11:22:59.000Z | 5        |
| 10       | 104         | 1        | Meat Lovers | 2, 6       | 1, 4   | 2021-01-11T18:34:49.000Z | 1        |
| 10       | 104         | 1        | Meat Lovers |            |        | 2021-01-11T18:34:49.000Z | 6        |
  

</details>

### **`runner_orders`**

<details>
<summary>
View table
</summary>

The `pickup_time` is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas. The `distance` and `duration` fields are related to how far and long the runner had to travel to deliver the order to the respective customer. 
**Note:-** Not all orders are fully completed and can be canceled by the restaurant or the customer, this information is found in the `cancellation` field.

| order_id | runner_id | pickup_time         | distance | duration   | cancellation            |
|----------|-----------|---------------------|----------|------------|-------------------------|
| 1        | 1         | 2021-01-01 18:15:34 | 20km     | 32 minutes |                         |
| 2        | 1         | 2021-01-01 19:10:54 | 20km     | 27 minutes |                         |
| 3        | 1         | 2021-01-03 00:12:37 | 13.4km   | 20 mins    |                         |
| 4        | 2         | 2021-01-04 13:53:03 | 23.4     | 40         |                         |
| 5        | 3         | 2021-01-08 21:10:57 | 10       | 15         |                         |
| 6        | 3         | null                | null     | null       | Restaurant Cancellation |
| 7        | 2         | 2021-01-08 21:30:45 | 25km     | 25mins     | null                    |
| 8        | 2         | 2021-01-10 00:15:02 | 23.4 km  | 15 minute  | null                    |
| 9        | 2         | null                | null     | null       | Customer Cancellation   |
| 10       | 1         | 2021-01-11 18:50:20 | 10km     | 10minutes  | null                    |

This dataset was inconsistent and had data quality issues also, so I had to create a VIEW - `new_runner_orders` to address these issues as well as join information from other tables.

  | order_id | runner_id | pickup_time         | distance | duration | cancellation            | registration_date        |
|----------|-----------|---------------------|----------|----------|-------------------------|--------------------------|
| 1        | 1         | 2021-01-01 18:15:34 | 20       | 20       |                         | 2021-01-01T00:00:00.000Z |
| 2        | 1         | 2021-01-01 19:10:54 | 20       | 20       |                         | 2021-01-01T00:00:00.000Z |
| 3        | 1         | 2021-01-03 00:12:37 | 13.4     | 13       |                         | 2021-01-01T00:00:00.000Z |
| 4        | 2         | 2021-01-04 13:53:03 | 23.4     | 23       |                         | 2021-01-03T00:00:00.000Z |
| 5        | 3         | 2021-01-08 21:10:57 | 10       | 10       |                         | 2021-01-08T00:00:00.000Z |
| 6        | 3         |                     |          |          | Restaurant Cancellation | 2021-01-08T00:00:00.000Z |
| 7        | 2         | 2021-01-08 21:30:45 | 25       | 25       |                         | 2021-01-03T00:00:00.000Z |
| 8        | 2         | 2021-01-10 00:15:02 | 23.4     | 23       |                         | 2021-01-03T00:00:00.000Z |
| 9        | 2         |                     |          |          | Customer Cancellation   | 2021-01-03T00:00:00.000Z |
| 10       | 1         | 2021-01-11 18:50:20 | 10       | 10       |                         | 2021-01-01T00:00:00.000Z |

 </details>

### **`pizza_names`**

<details>
<summary>
View table
</summary>
At the moment, Pizza Runner only has 2 pizzas available - the Meat Lovers or Vegetarian!

| pizza_id | pizza_name |
|----------|------------|
| 1        | Meatlovers |
| 2        | Vegetarian |

 </details>

 ### **`pizza_recipes`**

<details>
<summary>
View table
</summary>

Each `pizza_id` has a standard set of toppings which are used as part of the pizza recipe.


| pizza_id | toppings                |
|----------|-------------------------|
| 1        | 1, 2, 3, 4, 5, 6, 8, 10 |
| 2        | 4, 6, 7, 9, 11, 12      |

 </details>
 

### **`pizza_toppings`**

<details>
<summary>
View table
</summary>

This table contains all of the `topping_name` values with their corresponding `topping_id` value.

| topping_id | topping_name |
|------------|--------------|
| 1          | Bacon        |
| 2          | BBQ Sauce    |
| 3          | Beef         |
| 4          | Cheese       |
| 5          | Chicken      |
| 6          | Mushrooms    |
| 7          | Onions       |
| 8          | Pepperoni    |
| 9          | Peppers      |
| 10         | Salami       |
| 11         | Tomatoes     |
| 12         | Tomato Sauce |

 This table and the `pizza_recipes` table have obviuous connections and so I created this VIEW - `new_pizza_recipes` to join information from both tables and convey it in a more compact manner.

  | pizza_id | toppings                | toppings_indiv | topping_name |
|----------|-------------------------|----------------|--------------|
| 1        | 1, 2, 3, 4, 5, 6, 8, 10 | 1              | Bacon        |
| 1        | 1, 2, 3, 4, 5, 6, 8, 10 | 2              | BBQ Sauce    |
| 1        | 1, 2, 3, 4, 5, 6, 8, 10 | 3              | Beef         |
| 2        | 4, 6, 7, 9, 11, 12      | 4              | Cheese       |
| 1        | 1, 2, 3, 4, 5, 6, 8, 10 | 4              | Cheese       |
| 1        | 1, 2, 3, 4, 5, 6, 8, 10 | 5              | Chicken      |
| 1        | 1, 2, 3, 4, 5, 6, 8, 10 | 6              | Mushrooms    |
| 2        | 4, 6, 7, 9, 11, 12      | 6              | Mushrooms    |
| 2        | 4, 6, 7, 9, 11, 12      | 7              | Onions       |
| 1        | 1, 2, 3, 4, 5, 6, 8, 10 | 8              | Pepperoni    |
| 2        | 4, 6, 7, 9, 11, 12      | 9              | Peppers      |
| 1        | 1, 2, 3, 4, 5, 6, 8, 10 | 10             | Salami       |
| 2        | 4, 6, 7, 9, 11, 12      | 11             | Tomatoes     |
| 2        | 4, 6, 7, 9, 11, 12      | 12             | Tomato Sauce |
  
 </details>


### **E.R.D**
<details>

<summary>
View diagram
</summary>
<img src="https://user-images.githubusercontent.com/60517587/176715385-adf3edf3-c17a-4ed3-9d8e-c7948a93318c.png" width=80% height=50%>
</details>


<br/>

## ❓ Case Study Questions
<p align="center">
<img src="https://user-images.githubusercontent.com/60517587/176716805-463a8ae9-0ff8-4b98-93ef-ecf912f6f0c0.gif" width=60% height=50%>

This case study has LOTS of questions - they are broken up by 4 sections including: 
+ **Pizza Metrics**,  
+ **Runner and Customer Experience**,
+ **Ingredient Optimisation**, and
+ **Pricing and Ratings**. 

Feel free to explore whichever appeals to you the most, or all four (if you're like me and are obsessed with completion 😃)

<br/>

### 📈 PIZZA METRICS QUESTIONS AND SOLUTIONS
 
#### **Q1. How many pizzas were ordered?**

```sql
SELECT
  COUNT(DISTINCT rowcheck) AS num_pizzas_ordered
FROM
  joined_pizza;
```

| num_pizzas_ordered |
|--------------------|
| 14                 |

---

#### **Q2. How many unique customer orders were made?**

```sql
SELECT
  COUNT(DISTINCT order_id) AS num_unique_customers
FROM
  joined_pizza;
```

| num_unique_customers |
|----------------------|
| 10                   |

---

#### **Q3. How many successful orders were delivered by each runner?**

```sql
SELECT
  runner_id,
  COUNT(DISTINCT order_id) AS successful_runner_deliveries
FROM
  joined_pizza
WHERE
  cancellation IS NULL
GROUP BY
  1;
```

| runner_id | successful_runner_deliveries |
|-----------|------------------------------|
| 1         | 4                            |
| 2         | 3                            |
| 3         | 1                            |

---

#### **Q4. How many of each type of pizza was delivered?**

```sql
SELECT
  pizza_name,
  COUNT(DISTINCT rowcheck) AS successful_pizza_deliveries
FROM
  joined_pizza
WHERE
  cancellation IS NULL
GROUP BY
  1;
```

| pizza_name | successful_pizza_deliveries |
|------------|-----------------------------|
| Meatlovers | 9                           |
| Vegetarian | 3                           |

---

#### **Q5. How many Vegetarian and Meatlovers were ordered by each customer?**

```sql
  WITH ml AS (
    SELECT
      customer_id,
      pizza_name,
      COUNT(DISTINCT rowcheck) AS meatlovers
    FROM
      joined_pizza
    WHERE
      pizza_name = 'Meatlovers'
    GROUP BY
      1,
      2
  ),
  vg AS (
    SELECT
      customer_id,
      pizza_name,
      COUNT(DISTINCT rowcheck) AS vegetarian
    FROM
      joined_pizza
    WHERE
      pizza_name = 'Vegetarian'
    GROUP BY
      1,
      2
  )
SELECT
  DISTINCT joined_pizza.customer_id,
  COALESCE(ml.meatlovers, 0) AS meatlovers,
  COALESCE(vg.vegetarian, 0) AS vegetarian
FROM
  joined_pizza
  LEFT JOIN vg ON vg.customer_id = joined_pizza.customer_id
  LEFT JOIN ml ON ml.customer_id = joined_pizza.customer_id
ORDER BY
  1;
```

| customer_id | meatlovers | vegetarian |
|-------------|------------|------------|
| 101         | 2          | 1          |
| 102         | 2          | 1          |
| 103         | 3          | 1          |
| 104         | 3          | 0          |
| 105         | 0          | 1          |

---

#### **Q6. What was the maximum number of pizzas delivered in a single order?**
```sql
SELECT
  COUNT(DISTINCT rowcheck) AS num_pizza_by_time
FROM
  joined_pizza
GROUP BY
  order_time
ORDER BY
  1 DESC
LIMIT
  1;
```

| num_pizza_by_time |
|-------------------|
| 3                 |

---

#### **Q7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**

```sql
  WITH changes_cte AS (
    SELECT
      customer_id,
      rowcheck,
      COALESCE(
        ARRAY_LENGTH(STRING_TO_ARRAY(exclusions, ','), 1),
        0
      ) + COALESCE(ARRAY_LENGTH(STRING_TO_ARRAY(extras, ','), 1), 0) AS count_changes
    FROM
      joined_pizza
    WHERE
      cancellation IS NULL
    GROUP BY
      1,
      2,
      3
  ),
  no_changes AS (
    SELECT
      customer_id,
      COUNT(*) AS num_no_changes
    FROM
      changes_cte
    WHERE
      count_changes = 0
    GROUP BY
      1
  ),
  atleast_one_change AS (
    SELECT
      customer_id,
      COUNT(*) AS num_at_least_one_change
    FROM
      changes_cte
    WHERE
      count_changes >= 1
    GROUP BY
      1
  )
SELECT
  DISTINCT changes_cte.customer_id,
  COALESCE(num_at_least_one_change, 0) AS num_at_least_one_change,
  COALESCE(num_no_changes, 0) AS num_no_changes
FROM
  changes_cte
  LEFT JOIN no_changes ON no_changes.customer_id = changes_cte.customer_id
  LEFT JOIN atleast_one_change ON atleast_one_change.customer_id = changes_cte.customer_id
ORDER BY
  1;
```

| customer_id | num_at_least_one_change | num_no_changes |
|-------------|-------------------------|----------------|
| 101         | 0                       | 2              |
| 102         | 0                       | 3              |
| 103         | 3                       | 0              |
| 104         | 2                       | 1              |
| 105         | 1                       | 0              |

---

#### **Q8. How many pizzas were delivered that had both exclusions and extras?**
```sql
SELECT
  COUNT(DISTINCT rowcheck) AS both_excl_and_extr_pizzas
FROM
  joined_pizza
WHERE
  extras IS NOT NULL
  AND exclusions IS NOT NULL;
```

| both_excl_and_extr_pizzas |
|---------------------------|
| 2                         |

---

#### **Q9. What was the total volume of pizzas ordered for each hour of the day?**

```sql
SELECT
  EXTRACT(
    'hour'
    from
      order_time
  ) AS hour,
  COUNT(DISTINCT rowcheck) AS volume_pizzas_per_hour
FROM
  joined_pizza
GROUP BY
  1;
```

| hour | volume_pizzas_per_hour |
|------|------------------------|
| 11   | 1                      |
| 13   | 3                      |
| 18   | 3                      |
| 19   | 1                      |
| 21   | 3                      |
| 23   | 3                      |

---

#### **Q10. What was the volume of orders for each day of the week?**
```sql
SELECT
  TO_CHAR(order_time,'Day') AS day_of_week,
  COUNT(DISTINCT rowcheck) AS volume_pizzas_per_day
FROM
  joined_pizza
GROUP BY
  1;
```

| day_of_week | volume_pizzas_per_day |
|-------------|-----------------------|
| Friday      | 5                     |
| Monday      | 5                     |
| Saturday    | 3                     |
| Sunday      | 1                     |

<br /> 

### 🚚 RUNNER AND CUSTOMER EXPERIENCE - QUESTIONS AND SOLUTIONS

To solve the questions in this challenge, I used the MATERIALIZED VIEW - `joined_pizza` that was created in the DDL query.

#### **Q1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01).**

```sql
WITH t1 AS (
  SELECT
    DISTINCT runner_id,
    registration_date,
    DATE_TRUNC('week', registration_date) :: DATE + 4 AS week
  FROM
    pizza_runner.runners
)
SELECT
  week,
  COUNT(runner_id) AS num_runners
FROM
  t1
GROUP BY
  1
ORDER BY
  2 DESC;
```

| week | num_runners |
|---------|-------------|
| 2021-01-01 | 2  |
| 2021-01-08 | 1  |
| 2021-01-15 | 1  |

---

#### **Q2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
  
```sql
WITH t1 AS (
    SELECT
      runner_id,
      order_id,
      EXTRACT(
        'minutes'
        from
          AGE(
            pickup_time :: TIMESTAMP,
            order_time :: TIMESTAMP
          )
      ) AS arrival_time
    FROM
      joined_pizza
    WHERE
      pickup_time IS NOT NULL
    GROUP BY
      1,
      2,
      3
  )
SELECT
  runner_id,
  ROUND(AVG(arrival_time) :: NUMERIC, 1) || ' minutes' AS avg_arrival_time
FROM
  t1
GROUP BY
  1;
```

| runner_id | avg_arrival_time |
|-----------|------------------|
| 1         | 14.0 minutes     |
| 2         | 19.7 minutes     |
| 3         | 10.0 minutes     |

---

#### **Q3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**

```sql
WITH t1 AS (
    SELECT
      runner_id,
      order_id,
      rowcheck,
      EXTRACT(
        'minutes'
        from
          AGE(
            pickup_time :: TIMESTAMP,
            order_time :: TIMESTAMP
          )
      ) AS arrival_time
    FROM
      joined_pizza
    WHERE
      pickup_time IS NOT NULL
  )
SELECT
  arrival_time,
  COUNT(DISTINCT rowcheck)
FROM
  t1
GROUP BY
  1;
```

| arrival_time | count |
|--------------|-------|
| 10           | 4     |
| 15           | 2     |
| 20           | 1     |
| 21           | 2     |
| 29           | 3     |

---

#### **Q4. What was the average `distance` travelled for each customer?**
  
  ```sql
  WITH t1 AS (
    SELECT
      customer_id,
      distance
    FROM
      joined_pizza
    WHERE
      distance IS NOT NULL
    GROUP BY
      1,
      2
  )
SELECT
  customer_id,
  ROUND(AVG(distance), 1) AS avg_distance
FROM
  t1
GROUP BY
  1
ORDER BY
  1;
```

| customer_id | avg_distance |
|-------------|--------------|
| 101         | 20           |
| 102         | 18.4         |
| 103         | 23.4         |
| 104         | 10           |
| 105         | 25           |

---

#### **Q5. What was the difference between the longest and shortest delivery times for all orders?**
```sql
  WITH t1 AS (
    SELECT
      order_id,
      duration
    FROM
      joined_pizza
    WHERE
      pickup_time IS NOT NULL
    GROUP BY
      1,
      2
  )
SELECT
  MAX(duration) - MIN(duration) AS max_difference
FROM
  t1;
```

| max_difference |
|----------------|
| 15             |

---

#### **Q6. What was the average speed for each runner for each delivery and do you notice any trend for these values?**

```sql
WITH t1 AS (
    SELECT
      runner_id,
      distance / EXTRACT(
        'minutes'
        from
          AGE(
            pickup_time :: TIMESTAMP,
            order_time :: TIMESTAMP
          )
      ) :: NUMERIC AS delivery_speed,
      order_id,
      customer_id
    FROM
      joined_pizza
    WHERE
      pickup_time IS NOT NULL
    GROUP BY
      1,
      2,
      3,
      4
  )
SELECT
  runner_id,
  order_id,
  ROUND(AVG(delivery_speed), 2) || ' km/minute' AS delivery_speed
FROM
  t1
GROUP BY
  1,
  2
ORDER BY
  1,
  2;
```

| runner_id | order_id | delivery_speed |
|-----------|----------|----------------|
| 1         | 1        | 2.00 km/minute |
| 1         | 2        | 2.00 km/minute |
| 1         | 3        | 0.64 km/minute |
| 1         | 10       | 0.67 km/minute |
| 2         | 4        | 0.81 km/minute |
| 2         | 7        | 2.50 km/minute |
| 2         | 8        | 1.17 km/minute |
| 3         | 5        | 1.00 km/minute |

---

#### **Q7. What is the successful delivery percentage for each runner?**
```sql
  WITH t1 AS (
    SELECT
      runner_id,
      order_id,
      cancellation
    FROM
      joined_pizza
    GROUP BY
      1,
      2,
      3
  )
SELECT
  runner_id,
  ROUND(
    100 * SUM(
      CASE
        WHEN cancellation IS NULL THEN 1
        ELSE 0
      END
    ) / COUNT(runner_id)
  ) || '%' AS delivery_percent
FROM
  t1
GROUP BY
  1;
```

| runner_id | delivery_percent |
|-----------|------------------|
| 1         | 100%             |
| 2         | 75%              |
| 3         | 50%              |


<br /> 

### 🌶️ INGREDIENTS OPTIMIZATION - QUESTIONS AND SOLUTIONS

<details>
<summary>
To solve the questions in this challenge I created a VIEW (DDL contained within the dropdown)

The view - `ingredients_pizza` encompasses all fields required in the questions for this section C. 
</summary>

```sql
DROP VIEW IF EXISTS ingredients_pizza CASCADE;
CREATE VIEW ingredients_pizza AS (
    WITH todo_union AS (
      SELECT
        new_customer_orders.pizza_id,
        order_id,
        customer_id,
        exclusions,
        extras,
        rowcheck,
        new_pizza_recipe.toppings,
        toppings_indiv,
        topping_name,
        exclusions_indiv,
        extras_indiv,
        pizza_names.pizza_name --pizza_names table
      FROM
        new_customer_orders
        LEFT JOIN new_pizza_recipe ON new_customer_orders.pizza_id = new_pizza_recipe.pizza_id
        LEFT JOIN pizza_runner.pizza_names ON pizza_names.pizza_id = new_customer_orders.pizza_id
    )
    SELECT
      *,
      UNNEST(string_to_array(exclusions, ','))::NUMERIC AS exclusions_indiv,
      UNNEST(string_to_array(COALESCE(extras, ''), ','))::NUMERIC AS extras_indiv
    FROM
      todo_union
    WHERE
      exclusions IS NOT NULL
        OR extras IS NOT NULL
    UNION
    SELECT
      *,
      null,
      null
    FROM
      todo_union
    WHERE
      exclusions IS NULL
      AND extras IS NULL
  );
 ```
</details>

#### **Q1. What are the standard ingredients for each pizza?**
```sql
WITH t1 AS (
  SELECT
    pizza_name,
    topping_name
  FROM
    ingredients_pizza
  GROUP BY
    1,
    2
)
SELECT
  pizza_name,
  STRING_AGG(topping_name, ', ')
FROM
  t1
GROUP BY
  1;
```

| pizza_name | string_agg                                                            |
|------------|-----------------------------------------------------------------------|
| Meatlovers | Mushrooms, Pepperoni, Bacon, Cheese, BBQ Sauce, Salami, Beef, Chicken |
| Vegetarian | Peppers, Cheese, Mushrooms, Tomato Sauce, Onions, Tomatoes            |

---

#### **Q2. What was the most commonly added extra?**
```sql
  WITH t1 AS (
    SELECT
      extras_indiv,
      COUNT(DISTINCT rowcheck) AS frequency
    FROM
      ingredients_pizza
    WHERE
      extras IS NOT NULL
    GROUP BY
      1
  )
SELECT
  pizza_toppings.topping_name AS most_common_extras,
  t1.frequency AS number_of_times_used
FROM
  t1
  LEFT JOIN pizza_runner.pizza_toppings ON pizza_toppings.topping_id = t1.extras_indiv;
```

| most_common_extras | number_of_times_used |
|--------------------|----------------------|
| Bacon              | 4                    |
| Cheese             | 1                    |
| Chicken            | 1                    |

---

#### **Q3. What was the most common exclusion?**
```sql
WITH t1 AS (
    SELECT
      exclusions_indiv,
      COUNT(DISTINCT rowcheck) AS frequency
    FROM
      ingredients_pizza
    WHERE
      exclusions_indiv IS NOT NULL
    GROUP BY
      1
  )
SELECT
  pizza_toppings.topping_name AS most_common_exclusions,
  t1.frequency AS number_of_times_used
FROM
  t1
  LEFT JOIN pizza_runner.pizza_toppings ON pizza_toppings.topping_id = t1.exclusions_indiv;
```

| most_common_exclusions | number_of_times_used |
|------------------------|----------------------|
| BBQ Sauce              | 1                    |
| Cheese                 | 4                    |
| Mushrooms              | 1                    |

---

#### **Q4. Generate an order item for each record in the customers_orders table.**
 
```sql
WITH todo_joins AS (
    SELECT
      order_id,
      pizza_name,
      pt1.topping_name AS exclusions_name,
      pt2.topping_name AS extras_name
    FROM
      ingredients_pizza ip
      LEFT JOIN pizza_runner.pizza_toppings pt1 ON pt1.topping_id = ip.exclusions_indiv
      LEFT JOIN pizza_runner.pizza_toppings pt2 ON pt2.topping_id = ip.extras_indiv
    GROUP BY
      1,
      2,
      3,
      4
  ),
  final_cte AS (
    SELECT
      order_id,
      pizza_name,
      COALESCE(
        ' - Exclude: ' || STRING_AGG(exclusions_name, ', ') over(partition by order_id, pizza_name),
        ''
      ) AS exclusions_full,
      COALESCE(
        ' - Extra: ' || STRING_AGG(extras_name, ', ') over(partition by order_id, pizza_name),
        ''
      ) AS extras_full
    FROM
      todo_joins
    GROUP BY
      1,
      2,
      exclusions_name,
      extras_name
  )
SELECT
  pizza_name || exclusions_full || extras_full AS order_item
FROM
  final_cte
GROUP BY
  1;
```

| order_item                                                          |
|---------------------------------------------------------------------|
| Meatlovers                                                          |
| Meatlovers - Exclude: BBQ Sauce,   Mushrooms - Extra: Bacon, Cheese |
| Meatlovers - Exclude: Cheese                                        |
| Meatlovers - Exclude: Cheese - Extra:   Bacon, Chicken              |
| Meatlovers - Extra: Bacon                                           |
| Vegetarian                                                          |
| Vegetarian - Exclude: Cheese                                        |
| Vegetarian - Extra: Bacon                                           |

---

<details>
<summary> For my next step I would create a temp table (DDL contained here.). 

The table `joined_pizza` is shown below, to get an overview. 
   </summary>

```sql
DROP TABLE IF EXISTS toppings_table;
CREATE TEMP TABLE toppings_table AS (
    WITH todo_exclusions AS (
      SELECT
        order_id,
        pizza_name,
        TRIM(COALESCE(SPLIT_PART(exclusions, ',', 1), '')) AS exclusion_1,
        TRIM(COALESCE(SPLIT_PART(exclusions, ',', 2), '')) AS exclusion_2,
        TRIM(COALESCE(SPLIT_PART(extras, ',', 1), '')) AS extras_1,
        TRIM(COALESCE(SPLIT_PART(extras, ',', 2), '')) AS extras_2,
        STRING_TO_ARRAY(REPLACE(toppings, ' ', ''), ',') AS toppings
      FROM
        ingredients_pizza
      GROUP BY
        1,
        2,
        3,
        4,
        5,
        6,
        7
    ),
    todo_extras AS (
      SELECT
        order_id,
        pizza_name,
        extras_1,
        extras_2,
        ARRAY_REMOVE(
          ARRAY_REMOVE(toppings, exclusion_1),
          exclusion_2
        ) AS toppings_wip
      FROM
        todo_exclusions
    ),
    final_cte AS (
      SELECT
        order_id,
        pizza_name,
        ARRAY_REMOVE(
          ARRAY_APPEND(ARRAY_APPEND(toppings_wip, extras_1), extras_2),
          ''
        ) AS final_toppings,
        ROW_NUMBER() OVER() AS order_toppings_row
      FROM
        todo_extras
    )
    SELECT
      order_id,
      pizza_name,
      UNNEST(final_toppings) :: NUMERIC AS toppings_per_order,
      order_toppings_row,
      COUNT(*) AS _count
    FROM
      final_cte
    GROUP BY
      1,
      2,
      3,
      order_toppings_row
  );
  ```
</details>

| order_id | pizza_name | toppings_per_order | order_toppings_row | _count |
|----------|------------|--------------------|--------------------|--------|
| 1        | Meatlovers | 5                  | 1                  | 1      |
| 6        | Vegetarian | 9                  | 8                  | 1      |
| 9        | Meatlovers | 5                  | 11                 | 2      |
| 8        | Meatlovers | 1                  | 10                 | 1      |
| 4        | Vegetarian | 7                  | 6                  | 1      |
| 8        | Meatlovers | 3                  | 10                 | 1      |
| 10       | Meatlovers | 3                  | 13                 | 1      |
| 7        | Vegetarian | 7                  | 9                  | 1      |
| 1        | Meatlovers | 3                  | 1                  | 1      |
| 9        | Meatlovers | 2                  | 11                 | 1      |
| 7        | Vegetarian | 11                 | 9                  | 1      |
| 7        | Vegetarian | 6                  | 9                  | 1      |
| 6        | Vegetarian | 12                 | 8                  | 1      |
| 7        | Vegetarian | 4                  | 9                  | 1      |
| 5        | Meatlovers | 5                  | 7                  | 1      |

---

#### **Q5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients.**
```sql
  WITH todo_filter AS(
    SELECT
      order_id,
      pizza_name,
      order_toppings_row,
      STRING_AGG(
        CASE
          _count
          WHEN 1 THEN ''
          ELSE CONCAT(_count, 'x ')
        END || pizza_toppings.topping_name,
        ', '
      ) OVER(
        PARTITION BY order_id,
        pizza_name,
        order_toppings_row
        ORDER BY
          pizza_toppings.topping_name
      ) AS combined_toppings,
      ROW_NUMBER() OVER(
        PARTITION BY order_id,
        pizza_name,
        order_toppings_row
        ORDER BY
          pizza_toppings.topping_name DESC
      ) AS flag_num
    FROM
      toppings_table
      LEFT JOIN pizza_runner.pizza_toppings ON pizza_toppings.topping_id = toppings_table.toppings_per_order
  )
SELECT
  order_id,
  pizza_name || ': ' || combined_toppings AS order_spec
FROM
  todo_filter
WHERE
  flag_num = 1;
```

| order_id | order_spec                                                                             |
|----------|----------------------------------------------------------------------------------------|
| 1        | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms,   Pepperoni, Salami    |
| 2        | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms,   Pepperoni, Salami    |
| 3        | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms,   Pepperoni, Salami    |
| 3        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce                 |
| 4        | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami              |
| 4        | Vegetarian: Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce                         |
| 5        | Meatlovers: 2x Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms,   Pepperoni, Salami |
| 6        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce                 |
| 7        | Vegetarian: Bacon, Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato   Sauce        |
| 8        | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms,   Pepperoni, Salami    |
| 9        | Meatlovers: 2x Bacon, BBQ Sauce, Beef, 2x Chicken, Mushrooms, Pepperoni,   Salami      |
| 10       | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms,   Pepperoni, Salami    |

---

#### **Q6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?**
```sql
SELECT
  pizza_toppings.topping_name AS ingredient,
  SUM(_count) AS frequency
FROM
  toppings_table
  LEFT JOIN pizza_runner.pizza_toppings ON pizza_toppings.topping_id = toppings_table.toppings_per_order
GROUP BY
  1
ORDER BY
  2 DESC;
```

| ingredient   | frequency |
|--------------|-----------|
| Bacon        | 13        |
| Mushrooms    | 12        |
| Cheese       | 11        |
| Chicken      | 10        |
| Pepperoni    | 9         |
| Salami       | 9         |
| Beef         | 9         |
| BBQ Sauce    | 8         |
| Tomato Sauce | 4         |
| Onions       | 4         |
| Tomatoes     | 4         |
| Peppers      | 4         |

---

<br /> 

### 💰 PRICING AND RATINGS - QUESTIONS AND SOLUTIONS

<details>
<summary> To solve the questions in this challenge I created a VIEW that encompasses all fields required in the questions for this section D.

The view - `pizza_pricing` is shown below.
</summary>

```sql
DROP VIEW IF EXISTS pizza_pricing;
CREATE VIEW pizza_pricing AS (
  SELECT
    new_customer_orders.order_id,
    runner_id,
    pizza_name,
    customer_id,
    ARRAY_LENGTH(STRING_TO_ARRAY(exclusions, ','), 1) AS exclusions_num,
    ARRAY_LENGTH(STRING_TO_ARRAY(extras, ','), 1) AS extras_num,
    rowcheck,
    order_time,
    pickup_time,
    EXTRACT(
      'minutes'
      from
        AGE(
          pickup_time :: TIMESTAMP,
          order_time :: TIMESTAMP
        )
    ) AS time_btw_order_and_pickup,
    duration,
    cancellation,
    distance,
    ROUND(distance :: NUMERIC / duration, 2) AS average_speed
  FROM
    new_customer_orders
    LEFT JOIN new_runner_orders ON new_runner_orders.order_id = new_customer_orders.order_id
);
 ```
</details>

#### **Q1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?**
```sql
WITH todo_revenue AS (
  SELECT
    order_id,
    CASE
      pizza_name
      WHEN 'Meat Lovers' THEN 12
      ELSE 10
    END AS cost_per1,
    COUNT(rowcheck) AS num_pizzas
  FROM
    pizza_pricing
  GROUP BY
    1,
    2
)
SELECT
  SUM(cost_per1 * num_pizzas) :: MONEY AS revenue
FROM
  todo_revenue;
```

| revenue  |
|----------|
| $160.00  |

---

#### **Q2. What if there was an additional $1 charge for any pizza extras?**
```sql
WITH t1 AS (
    SELECT
      order_id,
      CASE
        pizza_name
        WHEN 'Meat Lovers' THEN 12
        ELSE 10
      END - COALESCE(extras_num, 0) AS cost_extra_charges
    FROM
      pizza_pricing
    WHERE
      cancellation IS NULL
  )
SELECT
  SUM(cost_extra_charges) :: MONEY AS revenue_extra_charges
FROM
  t1;
```

| revenue_extra_charges |
|-----------------------|
| $134.00               |

---

<details>
<summary> Next I created a TEMP TABLE for all the required fields in subsequent questions.

The table  - `dwd_pizza_table` is shown below.
</summary>

```sql
SELECT
  SETSEED(0.9);
DROP TABLE IF EXISTS dwd_pizza_table;
CREATE TEMP TABLE dwd_pizza_table AS (
    WITH todo_rating AS (
      SELECT
        order_id,
        runner_id,
        order_time,
        pickup_time,
        distance || ' km' AS distance,
        time_btw_order_and_pickup || ' minutes' AS time_btw_order_and_pickup,
        duration || ' minutes' AS duration,
        average_speed || ' km/min' AS average_speed,
        COUNT(rowcheck) AS total_number_of_pizzas
      FROM
        pizza_pricing
      WHERE
        pickup_time IS NOT NULL
      GROUP BY
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8
    )
    SELECT
      *,
      ROUND((random() * 5 + 0) :: INTEGER, 1) AS rating
    FROM
      todo_rating
  );
```
</details>

#### **Q3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.**

```sql
SELECT
  order_id,
  rating
FROM
  dwd_pizza_table;
```

| order_id | rating |
|----------|--------|
| 1        | 3      |
| 2        | 2      |
| 3        | 1      |
| 4        | 1      |
| 5        | 4      |
| 7        | 3      |
| 8        | 3      |
| 10       | 3      |

---

#### **Q4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?**
+ `customer_id`, `order_id`, `runner_id`, `rating`, `order_time`, `pickup_time`, time between order and pickup, delivery duration, average speed, and total number of pizzas.

```sql
SELECT
  *
FROM
  dwd_pizza_table;
```

| order_id | runner_id | order_time               | pickup_time     | distance | time_btw_order_and_pickup | duration   | average_speed | total_number_of_pizzas | rating |
|----------|-----------|--------------------------|-----------------|----------|---------------------------|------------|---------------|------------------------|--------|
| 1        | 1         | 2021-01-01 18:05:02  | 2021-01-01 18:15:00  | 20 km    | 10 minutes                | 20 minutes | 1.00 km/min   | 1                      | 3      |
| 2        | 1         | 2021-01-01 19:00:52  | 2021-01-01 19:10:00  | 20 km    | 10 minutes                | 20 minutes | 1.00 km/min   | 1                      | 2      |
| 3        | 1         | 2021-01-02 23:51:23  | 2021-01-03 0:12:00   | 13.4 km  | 21 minutes                | 13 minutes | 1.03 km/min   | 2                      | 1      |
| 4        | 2         | 2021-01-04 13:23:46  | 2021-01-04 13:53:00  | 23.4 km  | 29 minutes                | 23 minutes | 1.02 km/min   | 3                      | 1      |
| 5        | 3         | 2021-01-08 21:00:29  | 2021-01-08 21:10:00  | 10 km    | 10 minutes                | 10 minutes | 1.00 km/min   | 1                      | 4      |
| 7        | 2         | 2021-01-08 21:20:29  | 2021-01-08 21:30:00  | 25 km    | 10 minutes                | 25 minutes | 1.00 km/min   | 1                      | 3      |
| 8        | 2         | 2021-01-09 23:54:33  | 2021-01-10 0:15:00  | 23.4 km  | 20 minutes                | 23 minutes | 1.02 km/min   | 1                      | 3      |
| 10       | 1         | 2021-01-11 18:34:49  | 2021-01-11 18:50:00 | 10 km    | 15 minutes                | 10 minutes | 1.00 km/min   | 2                      | 3      |

---

#### **Q5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for `extras` and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?**

```sql
WITH todo_revenue AS (
    SELECT
      order_id,
      CASE
        pizza_name
        WHEN 'Meat Lovers' THEN 12
        ELSE 10
      END AS cost_per1,
      COUNT(rowcheck) AS num_pizzas
    FROM
      pizza_pricing
    GROUP BY
      1,
      2
  ),
  final_revenue AS (
    SELECT
      SUM(cost_per1 * num_pizzas) :: MONEY AS revenue
    FROM
      todo_revenue
  ),
  runners_expenditure AS (
    SELECT
      SUM(distance) * 0.3 AS runners_cost
    FROM
      pizza_pricing
  )
SELECT
  (
    final_revenue.revenue :: NUMERIC - runners_expenditure.runners_cost
  ) :: MONEY AS leftover_revenue
FROM
  final_revenue,
  runners_expenditure;
```

| leftover_revenue |
|------------------|
| $95.38           |

---

<p>&copy; 2022 Kingsley Izima</p>
