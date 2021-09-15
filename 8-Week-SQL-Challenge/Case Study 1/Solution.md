# 🍜 Case Study #1: Danny's Diner

## Solution

### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT
  s.customer_id,
  SUM(m.price) AS amount_spent
FROM sales s
JOIN menu m
  ON s.product_id = m.product_id
GROUP BY customer_id;
````

#### Steps:
- Use **SUM** and **GROUP BY** to find out ```amount_spent``` contributed by each customer.
- Use **JOIN** to merge ```sales``` and ```menu``` tables as ```customer_id``` and ```price``` are from both tables.


#### Answer:
| customer_id | amount_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |


***

### 2. How many days has each customer visited the restaurant?

````sql
SELECT
  customer_id,
  COUNT(DISTINCT order_date) AS days_visited
FROM sales
GROUP BY customer_id;
````

#### Steps:
- Use **DISTINCT** and wrap with **COUNT** to find out the ```days_visited``` for each customer.
- If we do not use **DISTINCT** on ```order_date```, the number of days may be repeated. For example, if Customer A visited the restaurant twice on '2021–01–07', then number of days is counted as 2 days instead of 1 day.

#### Answer:
|customer_id|days_visited|
|-----------|-----------|
|A          |4          |
|B          |6          |
|C          |2          |

***

### 3. What was the first item from the menu purchased by each customer?

````sql
WITH cte_first_order
AS (SELECT
  *,
  DENSE_RANK() OVER
  (PARTITION BY customer_id
  ORDER BY order_date) AS order_number
FROM sales)
SELECT
  c.customer_id,
  m.product_name
FROM cte_first_order c
JOIN menu m
  ON m.product_id = c.product_id
WHERE order_number = 1;
````

#### Steps:
- Create a temp table ```cte_first_order``` and use **Windows function** with **DENSE_RANK** to create a new column ```order_number``` based on ```order_date```.
- Instead of **ROW_NUMBER** or **RANK**, use **DENSE_RANK** as ```order_date``` is not time-stamped hence, there is no sequence as to which item is ordered first if 2 or more items are ordered on the same day.
- Subsequently, **GROUP BY** all columns to show ```order_number = 1``` only.

#### Answer:
| customer_id | product_name | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |



***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT
  m.product_name AS most_purchased,
  COUNT(s.product_id) AS item_count
FROM sales s
JOIN menu m
  ON m.product_id = s.product_id
GROUP BY s.product_id
HAVING COUNT(s.product_id)
= (SELECT
  MAX(mycount)
FROM (SELECT
  product_id,
  COUNT(product_id) AS mycount
FROM sales
GROUP BY product_id
ORDER BY product_id) max_tbl);
````

#### Steps:
- Use **NESTED QUERY** to select **MAX** from ```product_id``` count to filter highest number of purchased item.

#### Answer:
| most_purchased | item_count | 
| ----------- | ----------- |
| ramen       | 8 |


***

### 5. Which item was the most popular for each customer?

````sql
WITH cte_favorite
AS (SELECT
  s.customer_id,
  m.product_name,
  COUNT(s.product_id) AS order_count,
  DENSE_RANK() OVER (PARTITION BY customer_id
  ORDER BY COUNT(product_id) DESC) AS myrank
FROM sales s
JOIN menu m
  ON s.product_id = m.product_id
GROUP BY s.customer_id,
         s.product_id
ORDER BY s.customer_id)
SELECT
  customer_id,
  product_name,
  order_count
FROM cte_favorite
WHERE myrank = 1;
````

#### Steps:
- Create a ```cte_favourite``` and use **DENSE_RANK** to ```rank``` the ```order_count``` for each product by descending order for each customer.
- Generate results where product ```myrank = 1``` only as the most popular product for each customer.

#### Answer:
| customer_id | product_name | order_count |
| ----------- | ---------- |------------  |
| A           | ramen        |  3   |
| B           | sushi        |  2   |
| B           | curry        |  2   |
| B           | ramen        |  2   |
| C           | ramen        |  3   |


***

### 6. Which item was purchased first by the customer after they became a member?

````sql
WITH cte_order_after_member
AS (SELECT
  s.customer_id,
  s.order_date,
  s.product_id,
  m.join_date,
  DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS myrank
FROM sales s
JOIN members m
  ON s.customer_id = m.customer_id
WHERE s.order_date >= m.join_date)
SELECT
  c.customer_id,
  c.order_date,
  m2.product_name
FROM cte_order_after_member c
JOIN menu m2
  ON m2.product_id = c.product_id
WHERE myrank = 1
ORDER BY c.customer_id;
````

#### Steps:
- Create ```cte_order_after_member``` by using **windows function** and partitioning ```customer_id``` by ascending ```order_date```. Then, filter ```order_date``` to be on or after ```join_date```.
- Then, filter table by ```rank = 1``` to show 1st item purchased by each customer.

#### Answer:
| customer_id | order_date  | product_name |
| ----------- | ---------- |----------  |
| A           | 2021-01-07 | curry        |
| B           | 2021-01-11 | sushi        |


***

### 7. Which item was purchased just before the customer became a member?

````sql
WITH cte_order_before_member
AS (SELECT
  s.customer_id,
  s.order_date,
  s.product_id,
  m.join_date,
  DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS myrank
FROM sales s
JOIN members m
  ON s.customer_id = m.customer_id
WHERE s.order_date < m.join_date)
SELECT
  c.customer_id,
  c.order_date,
  m2.product_name
FROM cte_order_before_member c
JOIN menu m2
  ON m2.product_id = c.product_id
WHERE myrank = 1
ORDER BY c.customer_id;
````

#### Steps:
- Create a ```cte_order_before_member``` to create new column ```rank``` by using **Windows function** and partitioning ```customer_id``` by descending ```order_date``` to find out the last ```order_date``` before customer becomes a member.
- Filter ```order_date``` before ```join_date```.

#### Answer:
| customer_id | order_date  | product_name |
| ----------- | ---------- |----------  |
| A           | 2021-01-01 |  sushi        |
| A           | 2021-01-01 |  curry        |
| B           | 2021-01-04 |  sushi        |



***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
SELECT
  s.customer_id,
  COUNT(DISTINCT s.product_id) AS items_count,
  SUM(m.price) AS total_spent
FROM sales s
JOIN members me
  ON s.customer_id = me.customer_id
JOIN menu m
  ON s.product_id = m.product_id
WHERE s.order_date < me.join_date
GROUP BY s.customer_id;
````

#### Steps:
- Filter ```order_date``` before ```join_date``` and perform a **COUNT** **DISTINCT** on ```product_id``` and **SUM** the ```total spent``` before becoming member.

#### Answer:
| customer_id | items_count | total_spent |
| ----------- | ---------- |----------  |
| A           | 2 |  25       |
| B           | 2 |  40       |


***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

````sql
SELECT
  s.customer_id,
  SUM(CASE
    WHEN m.product_name = "sushi" THEN m.price * 2 * 10
    ELSE m.price * 10
  END) AS total_points
FROM sales s
JOIN menu m
  ON s.product_id = m.product_id
GROUP BY s.customer_id;
````

#### Steps:
Let’s breakdown the question.
- Each $1 spent = 10 points.
- But, sushi (product_id 1) gets 2x points, meaning each $1 spent = 20 points
So, we use CASE WHEN to create conditional statements
- If product_name = "sushi", then every $1 price multiply by 20 points
- All other product_name that is not "sushi", multiply $1 by 10 points
Using ```total_points```, **SUM** the ```points```.

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 860 |
| B           | 940 |
| C           | 360 |


***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

````sql
WITH points_purch_member
AS (SELECT
  s.customer_id,
  mn.product_name,
  mn.price,
  s.order_date,
  CASE
    WHEN mn.product_name = 'sushi' THEN 2
    WHEN s.customer_id IN (SELECT
        customer_id
      FROM members) AND
      (s.order_date >= mb.join_date AND
      s.order_date < (mb.join_date + 7)) THEN 2
    ELSE 1
  END AS multiplier,
  (mn.price * 10) AS points
FROM sales s
JOIN menu mn
  ON mn.product_id = s.product_id
JOIN members mb
  ON mb.customer_id = s.customer_id)
SELECT
  customer_id,
  SUM((points * multiplier)) AS total_points
FROM points_purch_member
GROUP BY customer_id
ORDER BY customer_id;
````

#### Steps:
- In cte ```points_purch_member```, find out multiplier.
- Then calculate total points using ```total_points```.

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 1370 |
| B           | 820 |

