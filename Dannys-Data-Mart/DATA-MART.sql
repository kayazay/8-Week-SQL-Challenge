--Section A
DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TEMP TABLE clean_weekly_sales AS (
  SELECT
    TO_DATE(week_date, 'DD/MM/YY') AS week_date,
    to_char(TO_DATE(week_date, 'DD/MM/YY'), 'WW') :: NUMERIC AS week_number,
    EXTRACT(
      'month'
      FROM
        TO_DATE(week_date, 'DD/MM/YY')
    ) AS month_number,
    EXTRACT(
      'year'
      FROM
        TO_DATE(week_date, 'DD/MM/YY')
    ) AS calendar_year,
    region,
    platform,
    CASE
      WHEN segment = 'null' THEN 'unknown'
      ELSE (
        CASE
          RIGHT(segment, 1) :: NUMERIC
          WHEN 1 THEN 'Young Adults'
          WHEN 2 THEN 'Middle Aged'
          WHEN 3 THEN 'Retirees'
          WHEN 4 THEN 'Retirees'
        END
      )
    END AS age_band,
    CASE
      WHEN segment = 'null' THEN 'unknown'
      ELSE (
        CASE
          LEFT(segment, 1)
          WHEN 'C' THEN 'Couples'
          WHEN 'F' THEN 'Families'
        END
      )
    END AS demographic,
    customer_type,
    transactions,
    sales,
    ROUND(sales :: NUMERIC / transactions, 2) AS avg_transaction
  FROM
    data_mart.weekly_sales
);
--SECTION B
--1. What day of the week is used for each week_date value?
SELECT
  to_char(week_date, 'Day') AS day_of_data_capture
FROM
  clean_weekly_sales
GROUP BY
  1;
--2. What range of week numbers are missing from the dataset?
WITH to_string_agg AS (
  SELECT
    GENERATE_SERIES(1, 53, 1) months_missing
  EXCEPT
  SELECT
    DISTINCT week_number
  FROM
    clean_weekly_sales
  ORDER BY
    1
)
SELECT
  STRING_AGG(months_missing :: TEXT, ', ') AS month_missing
FROM
  to_string_agg;
--3. How many total transactions were there for each year in the dataset?
SELECT
  calendar_year,
  to_char(SUM(transactions), '9,999,999,999') AS sum_transactions
FROM
  clean_weekly_sales
GROUP BY
  1
ORDER BY
  1;
--4. What is the total sales for each region for each month?
SELECT
  region,
  DATE_TRUNC('Month', week_date) AS start_month,
  to_char(SUM(sales), '9,999,999,999,999') AS sum_sales
FROM
  clean_weekly_sales
GROUP BY
  1,
  2
ORDER BY
  random()
LIMIT
  10;
--5. What is the total count of transactions for each platform
SELECT
  platform,
  to_char(SUM(transactions), '9,999,999,999') AS sum_transactions
FROM
  clean_weekly_sales
GROUP BY
  1;
--6. What is the percentage of sales for Retail vs Shopify for each month?
  WITH raw_sales AS (
    SELECT
      DATE_TRUNC('Month', week_date) AS start_month,
      platform,
      SUM(sales) AS sales
    FROM
      clean_weekly_sales
    GROUP BY
      1,
      2
  ),
  platform_segmented AS (
    SELECT
      t1.start_month,
      t1.sales AS shopify,
      t2.sales AS retail
    FROM
      raw_sales t1 FULL
      OUTER JOIN (
        SELECT
          start_month,
          sales
        FROM
          raw_sales
        WHERE
          platform = 'Retail'
      ) t2 ON t1.start_month = t2.start_month
    WHERE
      platform = 'Shopify'
  )
SELECT
  start_month,
  ROUND(100 * shopify :: NUMERIC / (retail + shopify)) || '%' AS shopify,
  ROUND(100 * retail :: NUMERIC / (retail + shopify)) || '%' AS retail
FROM
  platform_segmented
ORDER BY
  1;
--7. What is the percentage of sales by demographic for each year in the dataset?
  WITH raw_sales AS (
    SELECT
      calendar_year,
      demographic,
      SUM(sales) AS sales
    FROM
      clean_weekly_sales
    GROUP BY
      1,
      2
  ),
  demographic_year AS (
    SELECT
      t1.calendar_year,
      t1.sales AS families,
      t2.sales AS couples,
      t3.sales AS unknown
    FROM
      raw_sales t1 FULL
      OUTER JOIN (
        SELECT
          calendar_year,
          sales
        FROM
          raw_sales
        WHERE
          demographic = 'Couples'
      ) t2 ON t1.calendar_year = t2.calendar_year FULL
      OUTER JOIN (
        SELECT
          calendar_year,
          sales
        FROM
          raw_sales
        WHERE
          demographic = 'unknown'
      ) t3 ON t1.calendar_year = t3.calendar_year
    WHERE
      demographic = 'Families'
  )
SELECT
  calendar_year,
  ROUND(
    100 * families :: NUMERIC /(families + couples + unknown)
  ) || '%' AS families,
  ROUND(
    100 * couples :: NUMERIC /(families + couples + unknown)
  ) || '%' AS couples,
  ROUND(
    100 * unknown :: NUMERIC /(families + couples + unknown)
  ) || '%' AS unknown
FROM
  demographic_year;
--8. Which age_band and demographic values contribute the most to Retail sales?
SELECT
  age_band,
  demographic,
  to_char(SUM(sales), '9,999,999,999') AS sum_sales,
  ROUND(
    100 * SUM(sales) :: NUMERIC / SUM(SUM(sales)) OVER()
  ) || '%' AS percent
FROM
  clean_weekly_sales
WHERE
  platform = 'Retail'
  AND (
    demographic != 'unknown'
    OR demographic != 'unknown'
  )
GROUP BY
  1,
  2
ORDER BY
  3 DESC;
--9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
  WITH raw_transactions AS (
    SELECT
      calendar_year,
      platform,
      ROUND(AVG(transactions)) AS transactions
    FROM
      clean_weekly_sales
    GROUP BY
      1,
      2
  )
SELECT
  t1.calendar_year,
  to_char(t1.transactions, '9,999,999') AS retail,
  to_char(t2.transactions, '9,999,999') AS shopify
FROM
  raw_transactions t1 FULL
  OUTER JOIN (
    SELECT
      calendar_year,
      transactions
    FROM
      raw_transactions
    WHERE
      platform = 'Shopify'
  ) t2 ON t1.calendar_year = t2.calendar_year
WHERE
  platform = 'Retail';
-- SECTION C
--1. Comparison of 4 weeks period before and after change - '2020-06-15'
  WITH period_cte AS (
    SELECT
      to_char('2020-06-15' :: DATE, 'ww') :: NUMERIC AS week_of_change,
      4 AS period_length
  ),
  parameters AS (
    SELECT
      week_of_change,
      week_of_change + period_length AS right_date,
      week_of_change - period_length + 1 AS left_date
    FROM
      period_cte
  ),
  separate_cte AS (
    SELECT
      CASE
        WHEN week_number BETWEEN left_date
        AND week_of_change THEN '1. Before'
        WHEN week_number BETWEEN week_of_change + 1
        AND right_date THEN '2. After'
      END AS status,
      SUM(sales) AS total_sum
    FROM
      clean_weekly_sales,
      parameters
    WHERE
      calendar_year = 2020
      AND week_number BETWEEN left_date
      AND right_date
    GROUP BY
      1
  ),
  remove_nulls AS (
    SELECT
      (
        total_sum - LAG(total_sum) OVER(
          ORDER BY
            status
        )
      ) :: MONEY AS diff_sales,
      ROUND(
        100 * (
          total_sum - LAG(total_sum) OVER(
            ORDER BY
              status
          )
        ) :: NUMERIC / total_sum,
        2
      ) || '%' AS sales_change
    FROM
      separate_cte
  )
SELECT
  *
FROM
  remove_nulls
WHERE
  diff_sales IS NOT NULL;
--2. Comparison of 12 weeks period before and after change - '2020-06-15'
  WITH period_cte AS (
    SELECT
      to_char('2020-06-15' :: DATE, 'ww') :: NUMERIC AS week_of_change,
      12 AS period_length
  ),
  parameters AS (
    SELECT
      week_of_change,
      week_of_change + period_length AS right_date,
      week_of_change - period_length + 1 AS left_date
    FROM
      period_cte
  ),
  separate_cte AS (
    SELECT
      CASE
        WHEN week_number BETWEEN left_date
        AND week_of_change THEN '1. Before'
        WHEN week_number BETWEEN week_of_change + 1
        AND right_date THEN '2. After'
      END AS status,
      SUM(sales) AS total_sum
    FROM
      clean_weekly_sales,
      parameters
    WHERE
      calendar_year = 2020
      AND week_number BETWEEN left_date
      AND right_date
    GROUP BY
      1
  ),
  remove_nulls AS (
    SELECT
      (
        total_sum - LAG(total_sum) OVER(
          ORDER BY
            status
        )
      ) :: MONEY AS diff_sales,
      ROUND(
        100 * (
          total_sum - LAG(total_sum) OVER(
            ORDER BY
              status
          )
        ) :: NUMERIC / total_sum,
        2
      ) || '%' AS sales_change
    FROM
      separate_cte
  )
SELECT
  *
FROM
  remove_nulls
WHERE
  diff_sales IS NOT NULL;
--1. Comparison of 4 weeks period before and after change - '[x]-06-15' across all years. 
  WITH period_cte AS (
    SELECT
      24 AS week_of_change,
      4 AS period_length
  ),
  parameters AS (
    SELECT
      week_of_change,
      week_of_change + period_length AS right_date,
      week_of_change - period_length + 1 AS left_date
    FROM
      period_cte
  ),
  separate_cte AS (
    SELECT
      calendar_year,
      CASE
        WHEN week_number BETWEEN left_date
        AND week_of_change THEN '1. Before'
        WHEN week_number BETWEEN week_of_change + 1
        AND right_date THEN '2. After'
      END AS status,
      SUM(sales) AS total_sum
    FROM
      clean_weekly_sales,
      parameters
    WHERE
      week_number BETWEEN left_date
      AND right_date
    GROUP BY
      1,
      2
  ),
  remove_nulls AS (
    SELECT
      calendar_year,(
        total_sum - LAG(total_sum) OVER(
          PARTITION BY calendar_year
          ORDER BY
            status
        )
      ) :: MONEY AS diff_sales,
      ROUND(
        100 * (
          total_sum - LAG(total_sum) OVER(
            PARTITION BY calendar_year
            ORDER BY
              status
          )
        ) :: NUMERIC / total_sum,
        2
      ) || '%' AS sales_change
    FROM
      separate_cte
  )
SELECT
  *
FROM
  remove_nulls
WHERE
  diff_sales IS NOT NULL;
--1. Comparison of 12 weeks period before and after change - '[x]-06-15' across all years.
  WITH period_cte AS (
    SELECT
      24 AS week_of_change,
      12 AS period_length
  ),
  parameters AS (
    SELECT
      week_of_change,
      week_of_change + period_length AS right_date,
      week_of_change - period_length + 1 AS left_date
    FROM
      period_cte
  ),
  separate_cte AS (
    SELECT
      calendar_year,
      CASE
        WHEN week_number BETWEEN left_date
        AND week_of_change THEN '1. Before'
        WHEN week_number BETWEEN week_of_change + 1
        AND right_date THEN '2. After'
      END AS status,
      SUM(sales) AS total_sum
    FROM
      clean_weekly_sales,
      parameters
    WHERE
      week_number BETWEEN left_date
      AND right_date
    GROUP BY
      1,
      2
  ),
  remove_nulls AS (
    SELECT
      calendar_year,(
        total_sum - LAG(total_sum) OVER(
          PARTITION BY calendar_year
          ORDER BY
            status
        )
      ) :: MONEY AS diff_sales,
      ROUND(
        100 * (
          total_sum - LAG(total_sum) OVER(
            PARTITION BY calendar_year
            ORDER BY
              status
          )
        ) :: NUMERIC / total_sum,
        2
      ) || '%' AS sales_change
    FROM
      separate_cte
  )
SELECT
  *
FROM
  remove_nulls
WHERE
  diff_sales IS NOT NULL;
