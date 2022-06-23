DROP VIEW IF EXISTS joined_diner;
CREATE VIEW joined_diner AS (
  SELECT
    sales.customer_id,
    sales.order_date,
    menu.product_name,
    menu.price,
    members.join_date
  FROM
    dannys_diner.sales
    LEFT JOIN dannys_diner.menu ON menu.product_id = sales.product_id
    LEFT JOIN dannys_diner.members ON members.customer_id = sales.customer_id
);
-- 1.What is the total amount each customer spent at the restaurant ?
SELECT
  customer_id,
  SUM(price) AS total_amount
FROM
  joined_diner
GROUP BY
  1;
-- 2.How many days has each customer visited the restaurant ?
SELECT
  customer_id,
  COUNT(DISTINCT order_date)
FROM
  joined_diner
GROUP BY
  1;
-- 3.What was the first item(s) from the menu purchased by each customer?
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
-- 4.What is the most purchased item on the menu and how many times was it purchased by all customers ?
SELECT
  product_name,
  COUNT(*) AS purchase_count
FROM
  joined_diner
GROUP BY
  1
LIMIT
  1;
-- 5.Which item was the most popular for each customer?
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
-- 6.Which item was purchased first by the customer after they became a member ?
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
  order_date,
  product_name AS first_product_post_member
FROM
  t1
WHERE
  _rank = 1;
-- 7.Which item was purchased just before the customer became a member ?
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
-- 8.What is the total items and amount spent for each member before they became a member ?
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
-- 9.If each $ 1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have ?
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
--10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
  --not just sushi - how many points do customer A and B have at the end of January ?
SELECT
  customer_id,
  /*product_name,
      EXTRACT('days' from AGE(order_date,join_date)) AS num_days,
      order_date,
      join_date,*/
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