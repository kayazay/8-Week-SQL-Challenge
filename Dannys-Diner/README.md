# 📶 Case Study #1 - Danny's Diner
<p align="center">

<img src="https://user-images.githubusercontent.com/60517587/175916811-83b01187-1a33-4bc2-9d8f-7a29115b2233.png" width=40% height=40% />

## 📕 Table Of Contents
* ### 🛠️ [Problem Statement](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Diner#%EF%B8%8F-problem-statement)
* ### 📂 [Dataset](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Diner#-dataset)
* ### ❓ [Case Study Questions](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Diner#question%EF%B8%8F-case-study-questions)
* ### 🚀 [Solutions](https://github.com/kayazay/8-Week-SQL-Challenge/tree/main/Dannys-Diner#-solutions-1)
  
---

## 🛠️ Problem Statement

> Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favorite. Having this deeper connection with his customers will help him deliver a better and more personalized experience for his loyal customers.

 <br /> 


## 📂 Dataset
Danny has shared with you 3 key datasets for this case study:

### **```sales```**

<details>
<summary>
View table
</summary>

The sales table captures all `customer_id` level purchases with an corresponding `order_date` and `product_id` information for when and what menu items were ordered.

|customer_id|order_date|product_id|
|-----------|----------|----------|
|A          |2021-01-01|1         |
|A          |2021-01-01|2         |
|A          |2021-01-07|2         |
|A          |2021-01-10|3         |
|A          |2021-01-11|3         |
|A          |2021-01-11|3         |
|B          |2021-01-01|2         |
|B          |2021-01-02|2         |
|B          |2021-01-04|1         |
|B          |2021-01-11|1         |
|B          |2021-01-16|3         |
|B          |2021-02-01|3         |
|C          |2021-01-01|3         |
|C          |2021-01-01|3         |
|C          |2021-01-07|3         |

 </details>

### **`menu`**

<details>
<summary>
View table
</summary>

The menu table maps the `product_id` to the actual `product_name` and price of each menu item.

|product_id |product_name|price     |
|-----------|------------|----------|
|1          |sushi       |10        |
|2          |curry       |15        |
|3          |ramen       |12        |

</details>

### **`members`**

<details>
<summary>
View table
</summary>

The final members table captures the `join_date` when a `customer_id` joined the beta version of the Danny’s Diner loyalty program.

|customer_id|join_date |
|-----------|----------|
|A          |1/7/2021  |
|B          |1/9/2021  |

 </details>

### **Relationship between Tables**
<details>

<summary>
View E.R.D diagram
</summary>
<img src="https://user-images.githubusercontent.com/60517587/175916813-f7a5997b-7b0f-4be5-939a-e488ed24b2b5.png" width=50% height=50%>
</details>

<br/>

## :question:️ Case Study Questions
<p align="center">
<img src="https://user-images.githubusercontent.com/60517587/175916801-6d714682-2d02-426e-8a9f-4ad5f716dc98.gif" width=30% height=10%>

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

 <br /> 

## 🚀 Solutions

### **Q1. What is the total amount each customer spent at the restaurant?**

```sql
SELECT
  customer_id,
  SUM(price) AS total_amount
FROM
  joined_diner
GROUP BY
  1;
 ```

| customer_id | total_amount |
|-------------|--------------|
| B | 74 |
| C | 36 |
| A | 76 |

---

### **Q2. How many days has each customer visited the restaurant?**

```sql
SELECT
  customer_id,
  COUNT(DISTINCT order_date)
FROM
  joined_diner
GROUP BY
  1;
```

| customer_id | count |
|-------------|-------|
| A | 4 |
| B | 6 |
| C | 2 |

---

### **Q3. What was the first item from the menu purchased by each customer?**

```sql
WITH ranked_products AS (
    SELECT
      customer_id,
      product_name,
      RANK() OVER(
        PARTITION BY customer_id
        ORDER BY
          order_date
      ) AS date_purchase
    FROM
      joined_diner
  )
SELECT
  DISTINCT customer_id,
  product_name
FROM
  ranked_products
WHERE
  date_purchase = 1;
```

|customer_id | product_name |
|-------------|--------------|
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

---

### **Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?**
```sql
SELECT
  menu.product_name,
  COUNT(sales.product_id) AS order_count
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
GROUP BY
  menu.product_name
ORDER BY order_count DESC
LIMIT 1;
```

|product_id|product_name|order_count|
|----------|------------|-----------|
|3         |ramen       |8          |

---

### **Q5. Which item was the most popular for each customer?**
```sql
  WITH customer_most_purchased AS (
    SELECT
      customer_id,
      product_name,
      RANK() OVER (
        PARTITION BY customer_id
        ORDER BY
          COUNT(*) DESC
      ) AS _rank
    FROM
      joined_diner
    GROUP BY
      1,
      2
  )
SELECT
  customer_id,
  product_name AS most_popular_purchase
FROM
  customer_most_purchased
WHERE
  _rank = 1;
```
 | customer_id | most_popular_purchase |
|-------------|-----------------------|
| A           | ramen                 |
| B           | sushi                 |
| B           | curry                 |
| B           | ramen                 |
| C           | ramen                 |
---


### **Q6. Which item was purchased first by the customer after they became a member?**
```sql
WITH t1 AS (
    SELECT
      customer_id,
      product_name,
      RANK() OVER(
        PARTITION BY customer_id
        ORDER BY
          order_date
      ) AS _rank,
      order_date
    FROM
      joined_diner
    WHERE
      order_date - join_date >= 0
  )
SELECT
  customer_id,
  order_date:: DATE,
  product_name AS first_product_post_member
FROM
  t1
WHERE
  _rank = 1;
 ```
| customer_id | order_date               | first_product_post_member |
|-------------|--------------------------|---------------------------|
| A           | 2021-01-07 | curry                     |
| B           | 2021-01-11 | sushi                     |

---

### **Q7. Which item was purchased just before the customer became a member?**

```sql
WITH t1 AS (
    SELECT
      customer_id,
      product_name,
      RANK() OVER(
        PARTITION BY customer_id
        ORDER BY
          order_date DESC
      ) AS _rank,
      order_date
    FROM
      joined_diner
    WHERE
      order_date - join_date < 0
  )
SELECT
  customer_id,
  order_date,
  product_name AS last_product_bought
FROM
  t1
WHERE
  _rank = 1;
```
| customer_id | order_date               | last_product_bought |
|-------------|--------------------------|---------------------|
| A           | 2021-01-01 | sushi               |
| A           | 2021-01-01 | curry               |
| B           | 2021-01-04 | sushi               |

---

### **Q8. What is the total items and amount spent for each member before they became a member?**
```sql
WITH t1 AS (
    SELECT
      customer_id,
      product_name,
      price
    FROM
      joined_diner
    WHERE
      order_date - join_date < 0
  )
SELECT
  customer_id,
  COUNT(DISTINCT product_name) AS count_items_pre_member,
  SUM(price) AS sum_price_pre_member
FROM
  t1
GROUP BY
  1;
```

| customer_id | count_items_pre_member | sum_price_pre_member |
|-------------|------------------------|----------------------|
| A           | 2                      | 25                   |
| B           | 2                      | 40                   |

---

### **Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
```sql
SELECT
  customer_id,
  SUM(
    CASE
      product_name
      WHEN 'sushi' THEN price * 20
      ELSE price * 10
    END
  ) AS points
FROM
  joined_diner
GROUP BY
  1;
```

| customer_id | points |
|-------------|--------|
| B           | 940    |
| C           | 360    |
| A           | 860    |

---

### **Q10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

```sql
SELECT
  customer_id,
  SUM(
    10 * price * CASE
      WHEN product_name = 'sushi' THEN 2
      WHEN EXTRACT(
        'days'
        from
          AGE(order_date, join_date)
      ) BETWEEN 0
      AND 6 THEN 2
      ELSE 1
    END
  ) AS total_points
FROM
  joined_diner
WHERE
  join_date IS NOT NULL
  AND order_date < '2021-02-01' :: DATE
GROUP BY
  1;
```

| customer_id | total_points |
|-------------|--------------|
| A           | 1370         |
| B           | 820          |

---
<p>&copy; 2022 Kingsley Izima</p>
