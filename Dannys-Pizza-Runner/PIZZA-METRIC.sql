--1. How many pizzas were ordered?
SELECT
  COUNT(DISTINCT rowcheck) AS num_pizzas_ordered
FROM
  joined_pizza;

--2. How many unique customer orders were made?
SELECT
  COUNT(DISTINCT order_id) AS num_unique_customers
FROM
  joined_pizza;

--3. How many successful orders were delivered by each runner?
SELECT
  runner_id,
  COUNT(DISTINCT order_id) AS successful_runner_deliveries
FROM
  joined_pizza
WHERE
  cancellation IS NULL
GROUP BY
  1;

--4. How many of each type of pizza was delivered?
SELECT
  pizza_name,
  COUNT(DISTINCT rowcheck) AS successful_pizza_deliveries
FROM
  joined_pizza
WHERE
  cancellation IS NULL
GROUP BY
  1;

--5. How many Vegetarian and Meatlovers were ordered by each customer?
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

--6. What was the maximum number of pizzas delivered in a single order?
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

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
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

--8. How many pizzas were delivered that had both exclusions and extras?
SELECT
  COUNT(DISTINCT rowcheck) AS both_excl_and_extr_pizzas
FROM
  joined_pizza
WHERE
  extras IS NOT NULL
  AND exclusions IS NOT NULL;

--9. What was the total volume of pizzas ordered for each hour of the day?
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

--10. What was the volume of orders for each day of the week?
SELECT
  TO_CHAR(order_time,'Day') AS day_of_week,
  COUNT(DISTINCT rowcheck) AS volume_pizzas_per_day
FROM
  joined_pizza
GROUP BY
  1;