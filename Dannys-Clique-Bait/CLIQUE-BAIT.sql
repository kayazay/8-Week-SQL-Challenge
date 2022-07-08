--  Section A
--1. How many users are there?
SELECT
  COUNT (DISTINCT user_id) AS num_customers
FROM
  clique_bait.users;
--2. How many cookies does each user have on average?
  WITH count_of_cookies AS (
    SELECT
      user_id,
      COUNT(DISTINCT cookie_id) AS _count
    FROM
      clique_bait.users
    GROUP BY
      1
  )
SELECT
  ROUND(AVG(_count), 2) AS avg_cookies_per_user
FROM
  count_of_cookies;
--3. What is the unique number of visits by all users per month?
SELECT
  DATE_TRUNC('month', event_time) AS start_month,
  COUNT(DISTINCT visit_id) AS number_of_visits
FROM
  clique_bait.events
GROUP BY
  1
ORDER BY
  1;
--4. What is the number of events for each event type?
SELECT
  event_name,
  COUNT(*) frequency_of_occurence
FROM
  clique_bait.events
  LEFT JOIN clique_bait.event_identifier ON event_identifier.event_type = events.event_type
GROUP BY
  1
ORDER BY
  2 DESC;
--5. What is the percentage of visits which have a purchase event?
  WITH purchase_cte AS (
    SELECT
      visit_id,
      MAX(
        CASE
          WHEN event_type = 3 THEN 3
          ELSE 0
        END
      ) AS flaga
    FROM
      clique_bait.events
    GROUP BY
      visit_id
    ORDER BY
      1
  )
SELECT
  SUM(
    CASE
      WHEN flaga = 3 THEN 1
      ELSE 0
    END
  ) AS visits_that_turned_to_purchase,
  ROUND(
    100 * SUM(
      CASE
        WHEN flaga = 3 THEN 1
        ELSE 0
      END
    ) :: NUMERIC / COUNT(*),
    2
  ) AS percent_of_total
FROM
  purchase_cte;
--6. What is the percentage of visits which view the checkout page but do not have a purchase event?
  WITH boolean_bought AS (
    SELECT
      visit_id,
      MAX(
        CASE
          WHEN event_type = 1
          AND page_id = 12 THEN 5
          ELSE 0
        END
      ) AS view_checkout_page,
      MAX(
        CASE
          WHEN event_type = 3 THEN 7
          ELSE 0
        END
      ) AS purchased
    FROM
      clique_bait.events
    GROUP BY
      visit_id
  )
SELECT
  SUM(
    CASE
      WHEN purchased = 7 THEN 0
      ELSE 1
    END
  ) AS view_checkout_page_but_no_purchase,
  ROUND(
    100 * SUM(
      CASE
        WHEN purchased = 7 THEN 0
        ELSE 1
      END
    ) :: NUMERIC / COUNT(*),
    2
  ) AS percent_total
FROM
  boolean_bought
WHERE
  view_checkout_page = 5;
--7. What are the top 3 pages by number of views?
SELECT
  page_name,
  COUNT(visit_id) AS number_of_views
FROM
  clique_bait.events
  LEFT JOIN clique_bait.page_hierarchy ON page_hierarchy.page_id = events.page_id
WHERE
  event_type = 1
GROUP BY
  1
ORDER BY
  2 DESC;
--8. What is the number of views and cart adds for each product category?
SELECT
  product_category,
  SUM(
    CASE
      WHEN event_type = 2 THEN 1
      ELSE 0
    END
  ) AS num_cart_adds,
  SUM(
    CASE
      WHEN event_type = 1 THEN 1
      ELSE 0
    END
  ) AS num_views
FROM
  clique_bait.events
  INNER JOIN clique_bait.page_hierarchy ON page_hierarchy.page_id = events.page_id
WHERE
  product_category IS NOT null
GROUP BY
  1;
--9. What are the top 3 products by purchases?
  WITH filtered_cte AS (
    SELECT
      visit_id,
      cookie_id,
      event_type,
      page_id
    FROM
      clique_bait.events t1
    WHERE
      EXISTS (
        SELECT
          'BOMBOCLAAT'
        FROM
          clique_bait.events t2
        WHERE
          event_type = 3
          AND t1.visit_id = t2.visit_id
          AND t1.cookie_id = t2.cookie_id
      )
  )
SELECT
  page_name,
  SUM(
    CASE
      WHEN event_type = 2 THEN 1
      ELSE 0
    END
  ) AS num_times_purchase_item
FROM
  filtered_cte
  INNER JOIN (
    SELECT
      *
    FROM
      clique_bait.page_hierarchy
    WHERE
      page_id NOT IN (1, 2, 12, 13)
  ) page_hierarchy ON page_hierarchy.page_id = filtered_cte.page_id
GROUP BY
  1
ORDER BY
  2 DESC;

-- SECTION 2
-- 1. Aggregated on page name - products.
DROP TABLE IF EXISTS page_name_table;
CREATE TEMP TABLE page_name_table AS (
  WITH actual_df AS (
    SELECT
      visit_id,
      cookie_id,
      events.page_id,
      event_type,
      page_name,
      product_category
    FROM
      clique_bait.events
      LEFT JOIN clique_bait.page_hierarchy ON page_hierarchy.page_id = events.page_id
  ),
  view_cart_buy AS (
    SELECT
      visit_id,
      page_id,
      page_name,
      product_category,
      SUM(
        CASE
          WHEN event_type = 1 THEN 1
          ELSE 0
        END
      ) AS num_views,
      SUM(
        CASE
          WHEN event_type = 2 THEN 1
          ELSE 0
        END
      ) AS cart_adds,
      MAX(
        CASE
          WHEN page_id = 13 THEN 1
          ELSE 0
        END
      ) OVER(PARTITION BY visit_id) AS purchased
    FROM
      actual_df
    GROUP BY
      1,
      2,
      3,
      4
  ),
  todo_groupby AS (
    SELECT
      visit_id,
      page_name,
      product_category,
      num_views,
      cart_adds,
      CASE
        WHEN purchased = 1
        AND cart_adds = 0 THEN 0
        ELSE purchased
      END AS purchased
    FROM
      view_cart_buy
    WHERE
      page_id NOT IN (1, 2, 12, 13)
  )
  SELECT
    page_name,
    SUM(num_views) AS total_views,
    SUM(cart_adds) AS added_to_cart,
    SUM(
      CASE
        WHEN cart_adds = 1
        AND purchased = 0 THEN 1
        ELSE 0
      END
    ) AS cart_but_abandoned,
    SUM(purchased) AS purchased
  FROM
    todo_groupby
  GROUP BY
    1
);
--2. Aggregated on product category.
DROP TABLE IF EXISTS product_category_table;
CREATE TEMP TABLE product_category_table AS (
    WITH actual_df AS (
      SELECT
        visit_id,
        cookie_id,
        events.page_id,
        event_type,
        page_name,
        product_category
      FROM
        clique_bait.events
        LEFT JOIN clique_bait.page_hierarchy ON page_hierarchy.page_id = events.page_id
    ),
    view_cart_buy AS (
      SELECT
        visit_id,
        page_id,
        page_name,
        product_category,
        SUM(
          CASE
            WHEN event_type = 1 THEN 1
            ELSE 0
          END
        ) AS num_views,
        SUM(
          CASE
            WHEN event_type = 2 THEN 1
            ELSE 0
          END
        ) AS cart_adds,
        MAX(
          CASE
            WHEN page_id = 13 THEN 1
            ELSE 0
          END
        ) OVER(PARTITION BY visit_id) AS purchased
      FROM
        actual_df
      GROUP BY
        1,
        2,
        3,
        4
    ),
    todo_groupby AS (
      SELECT
        visit_id,
        page_name,
        product_category,
        num_views,
        cart_adds,
        CASE
          WHEN purchased = 1
          AND cart_adds = 0 THEN 0
          ELSE purchased
        END AS purchased
      FROM
        view_cart_buy
      WHERE
        page_id NOT IN (1, 2, 12, 13)
    )
    SELECT
      page_name,
      SUM(num_views) AS total_views,
      SUM(cart_adds) AS added_to_cart,
      SUM(
        CASE
          WHEN cart_adds = 1
          AND purchased = 0 THEN 1
          ELSE 0
        END
      ) AS cart_but_abandoned,
      SUM(purchased) AS purchased
    FROM
      todo_groupby
    GROUP BY
      1
  );
--SECTION 3 
DROP TABLE IF EXISTS info_user;
CREATE TEMP TABLE info_user AS (
  WITH order_items_cart AS (
    SELECT
      visit_id,
      STRING_AGG(page_name, ', ') OVER(
        PARTITION BY visit_id
        ORDER BY
          sequence_number
      ) AS cart_products,
      ROW_NUMBER() OVER(
        PARTITION BY visit_id
        ORDER BY
          sequence_number DESC
      ) AS flag
    FROM
      clique_bait.events
      LEFT JOIN clique_bait.page_hierarchy ON page_hierarchy.page_id = events.page_id
    WHERE
      event_type = 2
  ),
  other_fields AS (
    SELECT
      visit_id,
      cookie_id,
      MIN(event_time :: TIMESTAMP) AS visit_start_time,
      SUM(
        CASE
          WHEN event_type = 1 THEN 1
          ELSE 0
        END
      ) AS page_views,
      SUM(
        CASE
          WHEN event_type = 2 THEN 1
          ELSE 0
        END
      ) AS cart_adds,
      MAX(
        CASE
          WHEN event_type = 3
          AND page_id = 13 THEN 'yes'
          ELSE 'no'
        END
      ) AS purchase,
      SUM(
        CASE
          WHEN event_type = 4 THEN 1
          ELSE 0
        END
      ) AS impressions,
      SUM(
        CASE
          WHEN event_type = 5 THEN 1
          ELSE 0
        END
      ) AS clicks
    FROM
      clique_bait.events
    GROUP BY
      1,
      2
  )
  SELECT
    user_id,
    other_fields.visit_id,
    visit_start_time,
    page_views,
    cart_adds,
    purchase,
    campaign_name,
    impressions,
    clicks,
    COALESCE(cart_products, '') AS cart_products
  FROM
    other_fields
    LEFT JOIN clique_bait.campaign_identifier ON other_fields.visit_start_time BETWEEN campaign_identifier.start_date
    AND campaign_identifier.end_date
    LEFT JOIN clique_bait.users ON users.cookie_id = other_fields.cookie_id
    LEFT JOIN (
      SELECT
        *
      FROM
        order_items_cart
      WHERE
        flag = 1
    ) otc ON otc.visit_id = other_fields.visit_id
  ORDER BY
    user_id,
    visit_id
);
