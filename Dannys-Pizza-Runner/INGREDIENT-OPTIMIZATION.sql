DROP VIEW IF EXISTS ingredients_pizza CASCADE;
CREATE VIEW ingredients_pizza AS (
    WITH todo_union AS (
      SELECT
        new_customer_orders.pizza_id,
        order_id,
        customer_id,
        exclusions,
        extras,
        rowcheck,
        new_pizza_recipe.toppings,
        toppings_indiv,
        topping_name,
        --UNNEST(string_to_array(COALESCE(exclusions,''),',')) AS exclusions_indiv,
        --UNNEST(string_to_array(COALESCE(extras,''), ','))  AS extras_indiv,
        pizza_names.pizza_name --pizza_names table
      FROM
        new_customer_orders
        LEFT JOIN new_pizza_recipe ON new_customer_orders.pizza_id = new_pizza_recipe.pizza_id
        LEFT JOIN pizza_runner.pizza_names ON pizza_names.pizza_id = new_customer_orders.pizza_id
    )
    SELECT
      *,
      UNNEST(string_to_array(exclusions, ','))::NUMERIC AS exclusions_indiv,
      UNNEST(string_to_array(COALESCE(extras, ''), ','))::NUMERIC AS extras_indiv
    FROM
      todo_union
    WHERE
      exclusions IS NOT NULL
        OR extras IS NOT NULL
    UNION
    SELECT
      *,
      null,
      null
    FROM
      todo_union
    WHERE
      exclusions IS NULL
      AND extras IS NULL
  );

--1. What are the standard ingredients for each pizza?
WITH t1 AS (
  SELECT
    pizza_name,
    topping_name
  FROM
    ingredients_pizza
  GROUP BY
    1,
    2
)
SELECT
  pizza_name,
  STRING_AGG(topping_name, ', ')
FROM
  t1
GROUP BY
  1;

--2. What was the most commonly added extra?
  WITH t1 AS (
    SELECT
      extras_indiv,
      COUNT(DISTINCT rowcheck) AS frequency
    FROM
      ingredients_pizza
    WHERE
      extras IS NOT NULL
    GROUP BY
      1
  )
SELECT
  pizza_toppings.topping_name AS most_common_extras,
  t1.frequency AS number_of_times_used
FROM
  t1
  LEFT JOIN pizza_runner.pizza_toppings ON pizza_toppings.topping_id = t1.extras_indiv;

--3. What was the most common exclusion?
  WITH t1 AS (
    SELECT
      exclusions_indiv,
      COUNT(DISTINCT rowcheck) AS frequency
    FROM
      ingredients_pizza
    WHERE
      exclusions_indiv IS NOT NULL
    GROUP BY
      1
  )
SELECT
  pizza_toppings.topping_name AS most_common_exclusions,
  t1.frequency AS number_of_times_used
FROM
  t1
  LEFT JOIN pizza_runner.pizza_toppings ON pizza_toppings.topping_id = t1.exclusions_indiv;

--4. Generate an order item for each record in the customers_orders table.
  WITH todo_joins AS (
    SELECT
      order_id,
      pizza_name,
      pt1.topping_name AS exclusions_name,
      pt2.topping_name AS extras_name
    FROM
      ingredients_pizza ip
      LEFT JOIN pizza_runner.pizza_toppings pt1 ON pt1.topping_id = ip.exclusions_indiv
      LEFT JOIN pizza_runner.pizza_toppings pt2 ON pt2.topping_id = ip.extras_indiv
    GROUP BY
      1,
      2,
      3,
      4
  ),
  final_cte AS (
    SELECT
      order_id,
      pizza_name,
      COALESCE(
        ' - Exclude: ' || STRING_AGG(exclusions_name, ', ') over(partition by order_id, pizza_name),
        ''
      ) AS exclusions_full,
      COALESCE(
        ' - Extra: ' || STRING_AGG(extras_name, ', ') over(partition by order_id, pizza_name),
        ''
      ) AS extras_full
    FROM
      todo_joins
    GROUP BY
      1,
      2,
      exclusions_name,
      extras_name
  )
SELECT
  pizza_name || exclusions_full || extras_full AS order_item
FROM
  final_cte
GROUP BY
  1;
-- Next we create a TEMP TABLE to continue with our queries.
DROP TABLE IF EXISTS toppings_table;
CREATE TEMP TABLE toppings_table AS (
    WITH todo_exclusions AS (
      SELECT
        order_id,
        pizza_name,
        TRIM(COALESCE(SPLIT_PART(exclusions, ',', 1), '')) AS exclusion_1,
        TRIM(COALESCE(SPLIT_PART(exclusions, ',', 2), '')) AS exclusion_2,
        TRIM(COALESCE(SPLIT_PART(extras, ',', 1), '')) AS extras_1,
        TRIM(COALESCE(SPLIT_PART(extras, ',', 2), '')) AS extras_2,
        STRING_TO_ARRAY(REPLACE(toppings, ' ', ''), ',') AS toppings
      FROM
        ingredients_pizza
      GROUP BY
        1,
        2,
        3,
        4,
        5,
        6,
        7
    ),
    todo_extras AS (
      SELECT
        order_id,
        pizza_name,
        extras_1,
        extras_2,
        ARRAY_REMOVE(
          ARRAY_REMOVE(toppings, exclusion_1),
          exclusion_2
        ) AS toppings_wip
      FROM
        todo_exclusions
    ),
    final_cte AS (
      SELECT
        order_id,
        pizza_name,
        ARRAY_REMOVE(
          ARRAY_APPEND(ARRAY_APPEND(toppings_wip, extras_1), extras_2),
          ''
        ) AS final_toppings,
        ROW_NUMBER() OVER() AS order_toppings_row
      FROM
        todo_extras
    )
    SELECT
      order_id,
      pizza_name,
      UNNEST(final_toppings) :: NUMERIC AS toppings_per_order,
      order_toppings_row,
      COUNT(*) AS _count
    FROM
      final_cte
    GROUP BY
      1,
      2,
      3,
      order_toppings_row
  );

--5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients.
  WITH todo_filter AS(
    SELECT
      order_id,
      pizza_name,
      order_toppings_row,
      STRING_AGG(
        CASE
          _count
          WHEN 1 THEN ''
          ELSE CONCAT(_count, 'x ')
        END || pizza_toppings.topping_name,
        ', '
      ) OVER(
        PARTITION BY order_id,
        pizza_name,
        order_toppings_row
        ORDER BY
          pizza_toppings.topping_name
      ) AS combined_toppings,
      ROW_NUMBER() OVER(
        PARTITION BY order_id,
        pizza_name,
        order_toppings_row
        ORDER BY
          pizza_toppings.topping_name DESC
      ) AS flag_num
    FROM
      toppings_table
      LEFT JOIN pizza_runner.pizza_toppings ON pizza_toppings.topping_id = toppings_table.toppings_per_order
  )
SELECT
  order_id,
  pizza_name || ': ' || combined_toppings AS order_spec
FROM
  todo_filter
WHERE
  flag_num = 1;

--6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
SELECT
  pizza_toppings.topping_name AS ingredient,
  SUM(_count) AS frequency
FROM
  toppings_table
  LEFT JOIN pizza_runner.pizza_toppings ON pizza_toppings.topping_id = toppings_table.toppings_per_order
GROUP BY
  1
ORDER BY
  2 DESC;