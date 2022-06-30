 --1. How many customers has Foodie - Fi ever had ?
SELECT
  COUNT(DISTINCT customer_id)
FROM
  joined_foodie;

--2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value.
SELECT
  DATE_TRUNC('month', start_date) AS actual_month,
  COUNT(*) AS number_of_subscribers
FROM
  joined_foodie
WHERE
  plan_name = 'trial'
GROUP BY
  1
ORDER BY
  1;

--3. What plan start_date values occur after the year 2020 for our dataset ? Show the breakdown by count of events for each plan_name.
SELECT
  plan_id,
  plan_name,
  COUNT(*) AS events
FROM
  joined_foodie
WHERE
  start_date > '2020-12-31' :: DATE
GROUP BY
  1,
  2
ORDER BY
  1;

--4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place ?
  WITH churned_customers AS (
    SELECT
      customer_id,
      CASE
        WHEN plan_name = 'churn' THEN 1
        ELSE 0
      END AS num_churned
    FROM
      joined_foodie
  )
SELECT
  SUM(num_churned) AS churn_customers,
  ROUND(
    100 * SUM(num_churned) :: NUMERIC / COUNT(DISTINCT customer_id),
    1
  ) || '%' AS percentage
FROM
  churned_customers;

--5. How many customers have churned straight after their initial free trial - what percentage is this rounded to 1 decimal place ?
  WITH t1 AS (
    SELECT
      customer_id,
      plan_name,
      start_date,
      CASE
        WHEN plan_name = 'trial'
        AND LEAD(plan_name) OVER(
          PARTITION BY customer_id
          ORDER BY
            start_date
        ) = 'churn' THEN 1
        ELSE 0
      END AS trial_then_churn
    FROM
      joined_foodie
  )
SELECT
  SUM(trial_then_churn) AS num_trial_then_churn,
  ROUND(
    100 * SUM(trial_then_churn) / COUNT(DISTINCT customer_id) :: NUMERIC,
    1
  ) || '%' AS percentage
FROM
  t1;

--6. What is the number and percentage of customer plans after their initial free trial ?
  WITH t1 AS (
    SELECT
      plan_id,
      customer_id,
      plan_name,
      LAG(plan_name) OVER(
        PARTITION BY customer_id
        ORDER BY
          start_date
      ) AS prev_plan
    FROM
      joined_foodie
  )
SELECT
  plan_id,
  plan_name,
  COUNT(*) AS num_subscribers,
  ROUND(
    100 * COUNT(*) / SUM(COUNT(*)) OVER() :: NUMERIC
  ) || '%' AS percentage
FROM
  t1
WHERE
  prev_plan = 'trial'
GROUP BY
  1,
  2;

--7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31 ?
  WITH t1 AS (
    SELECT
      customer_id,
      plan_id,
      plan_name,
      ROW_NUMBER() OVER(
        PARTITION BY customer_id
        ORDER BY
          start_date DESC,
          plan_name
      ) AS rownum
    FROM
      joined_foodie
    WHERE
      start_date <= '2020-12-31' :: DATE
  )
SELECT
  plan_id,
  plan_name,
  COUNT(*) AS num_subscribers,
  ROUND(
    100 * COUNT(*) :: NUMERIC / SUM(COUNT(*)) OVER(),
    1
  ) || '%' AS percentage
FROM
  t1
WHERE
  rownum = 1
GROUP BY
  1,
  2
ORDER BY
  1;

--8. How many customers have upgraded to an annual plan in 2020 ?
SELECT
  COUNT(*) AS annual_subscribers_2020
FROM
  joined_foodie
WHERE
  EXTRACT(
    'year'
    from
      start_date
  ) = 2020
  AND plan_name = 'pro annual';

--9. How many days on average does it take for a customer to an annual plan from the day they join Foodie - Fi ?
SELECT
  ROUND(AVG(jf1.start_date - jf2.start_date)) AS avg_days_before_pro_annual
FROM
  joined_foodie jf1
  LEFT JOIN (
    SELECT
      customer_id,
      start_date
    FROM
      joined_foodie
    WHERE
      plan_name = 'trial'
  ) AS jf2 ON jf1.customer_id = jf2.customer_id
WHERE
  plan_name = 'pro annual';

--10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)?
  WITH t1 AS (
    SELECT
      jf1.start_date,
      jf2.start_date AS join_date,
      jf1.start_date - jf2.start_date AS days
    FROM
      joined_foodie jf1
      LEFT JOIN (
        SELECT
          customer_id,
          start_date
        FROM
          joined_foodie
        WHERE
          plan_name = 'trial'
      ) AS jf2 ON jf1.customer_id = jf2.customer_id
    WHERE
      plan_name = 'pro annual'
  ),
  max_days AS (
    SELECT
      MIN(days),
      MAX(days)
    FROM
      t1
  ),
  todo_range AS (
    SELECT
      30 * FLOOR(days / 30) AS start_range,
      30 * FLOOR(days / 30) + 30 AS end_range,
      COUNT(*) AS num_subscribers
    FROM
      t1
    GROUP BY
      1
  )
SELECT
  start_range :: TEXT || '-' || end_range :: TEXT || ' days' AS after_30_day_periods,
  num_subscribers
FROM
  todo_range
ORDER BY
  start_range;

--11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
  WITH first_cte AS (
    SELECT
      *
    FROM
      joined_foodie
    WHERE
      EXTRACT(
        'year'
        from
          start_date
      ) = 2020
  ),
  year_2020 AS (
    SELECT
      fc1.customer_id,
      fc1.start_date AS pm_start_date,
      fc2.start_date AS bm_start_date
    FROM
      first_cte fc1
      INNER JOIN (
        SELECT
          customer_id,
          start_date
        FROM
          first_cte fc2
        WHERE
          plan_name = 'basic monthly'
      ) fc2 ON fc1.customer_id = fc2.customer_id
    WHERE
      plan_name = 'pro monthly'
  )
SELECT
  SUM(
    CASE
      WHEN pm_start_date > bm_start_date THEN 1
      ELSE 0
    END
  ) AS customers_who_downgraded_pm_to_bm
FROM
  year_2020;

-- New payment table.
DROP TABLE IF EXISTS new_payment_table;
CREATE TEMP TABLE new_payment_table AS (
  WITH first_cte AS (
    SELECT
      customer_id,
      plan_id,
      plan_name,
      LEAD(plan_name) OVER(
        PARTITION BY customer_id
        ORDER BY
          start_date
      ) AS next_plan,
      start_date,
      LEAD(start_date) OVER(
        PARTITION BY customer_id
        ORDER BY
          start_date
      ) AS next_plan_date,
      price,
      LEAD(price) OVER(
        PARTITION BY customer_id
        ORDER BY
          start_date
      ) AS next_plan_price
    FROM
      joined_foodie
    WHERE
      plan_name != 'trial'
  ),
  revised_next_plan_date1 AS (
    SELECT
      customer_id,
      plan_id,
      plan_name,
      next_plan,
      start_date,
      CASE
        WHEN next_plan IS NULL THEN (
          CASE
            WHEN plan_name = 'pro annual' THEN start_date :: TEXT
            ELSE CONCAT(
              '2020-12-',
              SUBSTRING(start_date :: TEXT, 9, 2)
            )
          END
        )
        ELSE next_plan_date :: TEXT
      END AS next_plan_date,
      price
    FROM
      first_cte
    WHERE
      start_date <= '2020-12-31' :: DATE
      AND plan_name != 'churn'
  ),
  revised_next_plan_date2 AS (
    SELECT
      customer_id,
      plan_id,
      plan_name,
      next_plan,
      start_date,
      CASE
        WHEN SUBSTRING(next_plan_date, 1, 4) != '2020' THEN '2020-12-31'
        ELSE next_plan_date
      END :: DATE AS next_plan_date,
      price
    FROM
      revised_next_plan_date1
  ),
  finished_next_plan_date AS (
    SELECT
      customer_id,
      plan_id,
      plan_name,
      start_date,
      CASE
        WHEN start_date + INTERVAL '1 MONTH' > next_plan_date THEN start_date
        ELSE next_plan_date
      END AS next_plan_date,
      price
    FROM
      revised_next_plan_date2
  ),
  final_date1 AS (
    SELECT
      customer_id,
      plan_id,
      plan_name,
      start_date,
      '2020-' || LPAD(
        GENERATE_SERIES(
          SUBSTRING(start_date :: TEXT, 6, 2) :: NUMERIC,
          SUBSTRING(next_plan_date :: TEXT, 6, 2) :: NUMERIC,
          1
        ) :: TEXT,
        2,
        '0'
      ) || '-' || SUBSTRING(start_date :: TEXT, 9, 2) AS next_plan_date,
      price
    FROM
      finished_next_plan_date
  ),
  final_date2 AS (
    SELECT
      customer_id,
      plan_id,
      plan_name,
      start_date,
      next_plan_date,
      SUBSTRING(next_plan_date, 9, 2) :: INT AS next_plan_day,
      SUBSTRING(next_plan_date, 6, 2) AS next_plan_month,
      price
    FROM
      final_date1
  ),
  final_date AS (
    SELECT
      customer_id,
      plan_id,
      plan_name,
      start_date,
      next_plan_date,
      '2020-' || next_plan_month || '-' || CASE
        WHEN next_plan_day = '31'
        AND next_plan_month IN ('09', '04', '06', '11') THEN (next_plan_day -1)
        WHEN next_plan_day > 29
        AND next_plan_month = '02' THEN 29
        ELSE next_plan_day
      END AS fixed_date,
      price
    FROM
      final_date2
  ),
  todo_price2 AS(
    SELECT
      customer_id,
      plan_id,
      plan_name,
      fixed_date :: DATE,
      price
    FROM
      final_date
  ),
  final_cte AS (
    SELECT
      customer_id,
      plan_id,
      plan_name,
      fixed_date,
      COALESCE(
        LAG(price) OVER(
          PARTITION BY customer_id
          ORDER BY
            fixed_date :: DATE
        ),
        price
      ) AS lag_new_price,
      COALESCE(
        LAG(plan_name) OVER(
          PARTITION BY customer_id
          ORDER BY
            fixed_date :: DATE
        ),
        plan_name
      ) AS lag_new_plan,
      price
    FROM
      todo_price2
  )
  SELECT
    customer_id,
    plan_id,
    plan_name,
    fixed_date AS payment_date,
    CASE
      WHEN lag_new_price != price
      AND lag_new_plan = 'basic monthly'
      AND plan_name = 'pro monthly' THEN price - lag_new_price
      ELSE price
    END AS amount,
    ROW_NUMBER() OVER(
      PARTITION BY customer_id
      ORDER BY
        fixed_date
    ) AS payment_order
  FROM
    final_cte
);
