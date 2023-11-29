# :pizza: Case Study #2: Pizza runner - Pizza Metrics

## Case Study Questions - Solutions

***

###  1. How many pizzas were ordered?

```sql
SELECT count(pizza_id) AS "Total Number Of Pizzas Ordered"
FROM pizza_runner.customer_orders;
``` 
	
#### Result set:
| Total Number Of Pizzas Ordered |
|-------------------------------|
|               14              |

***

###  2. How many unique customer orders were made?

```sql
SELECT 
  COUNT(DISTINCT order_id) AS 'Number Of Unique Orders'
FROM customer_orders_temp;
``` 
	
#### Result set:
| Number Of Unique Orders |
|-------------------------|
|               10        |


***

###  3. How many successful orders were delivered by each runner?

```sql
SELECT runner_id,
       count(order_id) AS 'Number Of Successful Orders'
FROM pizza_runner.runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id;
``` 
	
#### Result set:
| runner_id | Number Of Successful Orders |
|-----------|-----------------------------|
|    1      |             4               |
|    2      |             3               |
|    3      |             1               |

***

###  4. How many of each type of pizza was delivered?

```sql

SELECT pizza_id,
       pizza_name,
       count(pizza_id) AS 'Number Of Pizzas Delivered'
FROM pizza_runner.runner_orders_temp
INNER JOIN customer_orders_temp USING (order_id)
INNER JOIN pizza_names USING (pizza_id)
WHERE cancellation IS NULL
GROUP BY pizza_id;
``` 
	
#### Result set:
| pizza_id | pizza_name | Number Of Pizzas Delivered |
|----------|------------|---------------------------|
|   1      | Meatlovers |            9              |
|   2      | Vegetarian |            3              |

***

###  5. How many Vegetarian and Meatlovers were ordered by each customer?

```sql
SELECT customer_id,
       pizza_name,
       count(pizza_id) AS 'Number Of Pizzas Ordered'
FROM customer_orders_temp
INNER JOIN pizza_names USING (pizza_id)
GROUP BY customer_id,
         pizza_id
ORDER BY customer_id ;
``` 
	
#### Result set:
![image](https://github.com/skr-learn/skr-learn/assets/73553929/8f8a4604-0d6d-41ea-a018-59f461fbd632)


- The counts of the Meat lover and Vegetarian pizzas ordered by the customers is not discernible.

```sql
SELECT customer_id,
       SUM(CASE
               WHEN pizza_id = 1 THEN 1
               ELSE 0
           END) AS 'Meat lover Pizza Count',
       SUM(CASE
               WHEN pizza_id = 2 THEN 1
               ELSE 0
           END) AS 'Vegetarian Pizza Count'
FROM customer_orders_temp
GROUP BY customer_id
ORDER BY customer_id;
``` 
	
#### Result set:
![image](https://github.com/skr-learn/skr-learn/assets/73553929/fc9c329f-1216-4667-82c4-6ec3dd74b0e2)


***

###  6. What was the maximum number of pizzas delivered in a single order?

```sql
SELECT customer_id,
       order_id,
       count(order_id) AS pizza_count
FROM customer_orders_temp
GROUP BY order_id
ORDER BY pizza_count DESC
LIMIT 1;
``` 
	
#### Result set:
![image](https://github.com/skr-learn/skr-learn/assets/73553929/1442f469-65f7-4c6f-9315-afff62655316)


***

###  7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
- at least 1 change -> either exclusion or extras 
- no changes -> exclusion and extras are NULL

```sql
SELECT customer_id,
       SUM(CASE
               WHEN (exclusions IS NOT NULL
                     OR extras IS NOT NULL) THEN 1
               ELSE 0
           END) AS change_in_pizza,
       SUM(CASE
               WHEN (exclusions IS NULL
                     AND extras IS NULL) THEN 1
               ELSE 0
           END) AS no_change_in_pizza
FROM customer_orders_temp
INNER JOIN runner_orders_temp USING (order_id)
WHERE cancellation IS NULL
GROUP BY customer_id
ORDER BY customer_id;
``` 

#### Result set:
![image](https://github.com/skr-learn/skr-learn/assets/73553929/1f138bc9-4fa4-4766-880e-ca41f43a01af)


***

###  8. How many pizzas were delivered that had both exclusions and extras?

```sql

SELECT customer_id,
       SUM(CASE
               WHEN (exclusions IS NOT NULL
                     AND extras IS NOT NULL) THEN 1
               ELSE 0
           END) AS both_change_in_pizza
FROM customer_orders_temp
INNER JOIN runner_orders_temp USING (order_id)
WHERE cancellation IS NULL
GROUP BY customer_id
ORDER BY customer_id;
``` 
	
#### Result set:
![image](https://github.com/skr-learn/skr-learn/assets/73553929/4f63e4f5-0c7e-43a4-80c1-fabb1b5a06e4)


***

###  9. What was the total volume of pizzas ordered for each hour of the day?

```sql
SELECT hour(order_time) AS 'Hour',
       count(order_id) AS 'Number of pizzas ordered',
       round(100*count(order_id) /sum(count(order_id)) over(), 2) AS 'Volume of pizzas ordered'
FROM pizza_runner.customer_orders_temp
GROUP BY 1
ORDER BY 1;
``` 
	
#### Result set:
![image](https://github.com/skr-learn/skr-learn/assets/73553929/2a31f97c-739b-45aa-82f2-425679784d46)


***

###  10. What was the volume of orders for each day of the week?
- The DAYOFWEEK() function returns the weekday index for a given date ( 1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday, 7=Saturday )
- DAYNAME() returns the name of the week day 

```sql
SELECT dayname(order_time) AS 'Day Of Week',
       count(order_id) AS 'Number of pizzas ordered',
       round(100*count(order_id) /sum(count(order_id)) over(), 2) AS 'Volume of pizzas ordered'
FROM pizza_runner.customer_orders_temp
GROUP BY 1
ORDER BY 2 DESC;
``` 
	
#### Result set:
![image](https://github.com/skr-learn/skr-learn/assets/73553929/3434465b-d315-42e1-8f8d-f29bfb548094)


***
