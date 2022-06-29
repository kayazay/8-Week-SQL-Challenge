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

--1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
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

--2. What if there was an additional $1 charge for any pizza extras?
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
-- We then create a TEMP TABLE as required by the DwD course.
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

--3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
SELECT
  order_id,
  rating
FROM
  dwd_pizza_table;

--4. Using your newly generated table - can you join all of the information together to form a table which has all information for successful deliveries?
SELECT
  *
FROM
  dwd_pizza_table;

--5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
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