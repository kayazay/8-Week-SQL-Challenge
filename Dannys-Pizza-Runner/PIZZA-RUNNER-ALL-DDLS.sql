CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 12:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 12:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-02 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
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

