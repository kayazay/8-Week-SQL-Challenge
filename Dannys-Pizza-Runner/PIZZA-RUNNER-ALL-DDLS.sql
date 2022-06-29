--CUSTOMER ORDERS NEW TABLE

DROP VIEW IF EXISTS new_customer_orders CASCADE;
CREATE VIEW new_customer_orders AS (
  SELECT
    order_id,
    customer_id,
    customer_orders.pizza_id,
    CASE
      WHEN pizza_name = 'Meatlovers' THEN 'Meat Lovers'
      ELSE pizza_name
    END AS pizza_name,
    CASE
      WHEN exclusions IN ('', null, 'null') THEN null
      ELSE exclusions
    END AS exclusions,
    CASE
      WHEN extras IN ('', null, 'null') THEN null
      ELSE extras
    END AS extras,
    order_time,
    row_number() over() AS rowcheck
  FROM
    pizza_runner.customer_orders
    inner join pizza_runner.pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id
);


--RUNNER ORDERS NEW TABLE
DROP VIEW IF EXISTS new_runner_orders CASCADE;
CREATE VIEW new_runner_orders AS(
  SELECT
    order_id,
    runner_orders.runner_id,
    CASE
      WHEN pickup_time IN ('null', null, '') THEN null
      ELSE pickup_time
    END AS pickup_time,
    CASE
      WHEN distance IN (null, 'null') THEN null
      ELSE TRIM(REPLACE(distance, 'km', '')) :: NUMERIC
    END AS distance,
    CASE
      WHEN duration IN (null, 'null') THEN null
      ELSE LEFT(distance, 2) :: NUMERIC
    END AS duration,
    CASE
      WHEN cancellation IN (null, '', 'null') THEN null
      ELSE cancellation
    END AS cancellation,
    registration_date :: DATE
  FROM
    pizza_runner.runner_orders
    LEFT JOIN pizza_runner.runners ON runners.runner_id = runner_orders.runner_id
);


-- PIZZA RECIPE NEW VIEW
DROP VIEW IF EXISTS new_pizza_recipe CASCADE;
CREATE VIEW new_pizza_recipe AS (
    WITH t1 AS (
      SELECT
        *,
        TRIM(UNNEST(string_to_array(toppings, ','))) :: NUMERIC AS toppings_indiv
      FROM
        pizza_runner.pizza_recipes
    )
    SELECT
      t1.pizza_id,
      t1.toppings,
      t1.toppings_indiv,
      pizza_toppings.topping_name
    FROM
      t1
      LEFT JOIN pizza_runner.pizza_toppings ON pizza_toppings.topping_id :: NUMERIC = t1.toppings_indiv
  );

--JOINED & CLEANED NEW PIZZA TABLE
DROP MATERIALIZED VIEW IF EXISTS joined_pizza;
CREATE MATERIALIZED VIEW joined_pizza AS(
  SELECT
    new_runner_orders.order_id,
    new_runner_orders.runner_id,
    new_runner_orders.pickup_time,
    new_runner_orders.distance,
    new_runner_orders.duration,
    new_runner_orders.cancellation,
    -- new_runner_orders table
    runners.registration_date,
    -- runners table
    new_customer_orders.customer_id,
    new_customer_orders.pizza_id,
    new_customer_orders.exclusions,
    new_customer_orders.extras,
    new_customer_orders.order_time,
    new_customer_orders.rowcheck,
    -- new_customer_orders table
    pizza_names.pizza_name,
    -- pizza_names table
    new_pizza_recipe.toppings -- pizza_recipes table
  FROM
    new_runner_orders
    INNER JOIN pizza_runner.runners ON runners.runner_id = new_runner_orders.runner_id
    INNER JOIN new_customer_orders ON new_customer_orders.order_id = new_runner_orders.order_id
    INNER JOIN pizza_runner.pizza_names ON pizza_names.pizza_id = new_customer_orders.pizza_id
    INNER JOIN new_pizza_recipe ON new_pizza_recipe.pizza_id = new_customer_orders.pizza_id
);

