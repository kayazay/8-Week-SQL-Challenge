--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
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

--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
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

--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
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

--4. What was the average distance travelled for each customer?
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

--5. What was the difference between the longest and shortest delivery times for all orders?
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

--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
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

--7. What is the successful delivery percentage for each runner?
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