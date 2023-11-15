![image](terraform/img/confluent-logo-300-2.png)
# Lab 2
Finishing Lab 1 is required for this lab. If you have not completed it, go to [LAB 1](lab1.md).


[Flink Joins](lab2.md#flink-joins)

[Understand Timestamps](lab2.md#understand-timestamps)

[Understand Joins](lab2.md#understand-joins)

[Data Enrichment](lab2.md#data-enrichment)

[Loyalty Levels Calculation](lab2.md#loyalty-levels-calculation)

[Promotions Calculation](lab2.md#promotions-calculation)



## Flink Joins

Flink SQL supports complex and flexible join operations over dynamic tables. There are a number of different types of joins to account for the wide variety of semantics that queries may require.
By default, the order of joins is not optimized. Tables are joined in the order in which they are specified in the FROM clause.

### Understand Timestamps
Let's first look at our data records and their timestamps. Open Flink SQL workspace.

If you left the Flink SQL Workspace or refreshed the page, Catalog and Database dropdowns are reset. Make sure they are selected again.
![image](terraform/img/catalog-and-database-dropdown.png)

Find all customer records for one customer and display timestamps when events were ingested in the shoe_customers Kafka topic
```
SELECT id,$rowtime 
FROM shoe_customers  
WHERE id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a';
```
NOTE: Check timestamp when were the customer records generated.

Find all orders for one customer and display timestamps when events were ingested in the shoe_orders Kafka topic
```
SELECT order_id, customer_id, $rowtime
FROM shoe_orders
WHERE customer_id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a';
```
NOTE: Check timestamp when were the orders generated. This is important for join operation we will do next.

### Understand Joins
Now, we can look at different types of joins available. 
We will join order records and customer records.

Join orders with non-keyed customer records (Regular Join)
```
SELECT order_id, shoe_orders.`$rowtime`, first_name, last_name
FROM shoe_orders
INNER JOIN shoe_customers 
ON shoe_orders.customer_id = shoe_customers.id
WHERE customer_id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a';
```
NOTE: Look at the number of rows returned. There are many duplicates for each order!

Join orders with non-keyed customer records in some time windows (Interval Join)
```
SELECT order_id, shoe_orders.`$rowtime`, first_name, last_name
FROM shoe_orders
INNER JOIN shoe_customers
ON shoe_orders.customer_id = shoe_customers.id
WHERE customer_id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a' AND
  shoe_orders.`$rowtime` BETWEEN shoe_customers.`$rowtime` - INTERVAL '1' HOUR AND shoe_customers.`$rowtime`;
```

Join orders with keyed customer records (Regular Join with Keyed Table)
```
SELECT order_id, shoe_orders.`$rowtime`, first_name, last_name
FROM shoe_orders
INNER JOIN shoe_customers_keyed 
ON shoe_orders.customer_id = shoe_customers_keyed.customer_id
WHERE shoe_customers_keyed.customer_id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a';
```
NOTE: Look at the number of rows returned. There are no duplicates for each order! This is because we have only one customer record for each customer id.

Join orders with keyd customer records in time when order was created (Temporal Join with Keyed Table)
```
SELECT order_id, shoe_orders.`$rowtime`, first_name, last_name
FROM shoe_orders
INNER JOIN shoe_customers_keyed FOR SYSTEM_TIME AS OF shoe_orders.`$rowtime`
ON shoe_orders.customer_id = shoe_customers_keyed.customer_id
WHERE shoe_customers_keyed.customer_id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a';
```
NOTE: There might be empty result set if keyed customers tables was created after the order records were ingested in the shoe_orders topic. 

NOTE: If Temporal Join returns no values you might need to run following command to decrease time interval for table scans 
```
SET 'sql.tables.scan.idle-timeout' = '1s';
```

### Data Enrichment
We can store the result of a join to a new table.

Prepare new table for to string result of the Order <-> Customer join 
```
CREATE TABLE shoe_order_customer(
  order_id INT,
  product_id STRING,
  first_name STRING,
  last_name STRING,
  email STRING
) WITH (
    'changelog.mode' = 'retract'
);
```
NOTE: we need to create a table which will be com[patible with our Table <-> Stream join
Check Dynamic Table stream encodings https://docs.confluent.io/cloud/current/flink/concepts/dynamic-tables.html#table-to-stream-conversion

Insert data in the created table
```
INSERT INTO shoe_order_customer(
  order_id,
  product_id,
  first_name,
  last_name,
  email)
SELECT
  order_id,
  product_id,
  first_name,
  last_name,
  email
FROM shoe_orders
  INNER JOIN shoe_customers_keyed 
  ON shoe_orders.customer_id = shoe_customers_keyed.customer_id;
```

Verify that data are joined successfully. 
```
SELECT * FROM shoe_order_customer;
```

Prepare a new table for Order <-> Customer <-> Product Join
```
CREATE TABLE shoe_order_customer_product(
  order_id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  brand STRING,
  model STRING,
  sale_price INT,
  rating DOUBLE
)WITH (
    'changelog.mode' = 'retract'
);
```

Insert data in the created table
```
INSERT INTO shoe_order_customer_product(
  order_id,
  first_name,
  last_name,
  email,
  brand,
  model,
  sale_price,
  rating)
SELECT
  order_id,
  first_name,
  last_name,
  email,
  brand,
  model,
  sale_price,
  rating
FROM shoe_order_customer
  INNER JOIN shoe_products_keyed
  ON shoe_order_customer.product_id = shoe_products_keyed.product_id;
```

Verify that data are joined successfully. 
```
SELECT * FROM shoe_order_customer_product;
```

### Loyalty Levels Calculation

Now we are ready to calculate loyalty level for our customers

First let's see which loyalty levels are being calculated
```
SELECT
  email,
  SUM(sale_price) AS total,
  CASE
    WHEN SUM(sale_price) > 80000000 THEN 'GOLD'
    WHEN SUM(sale_price) > 7000000 THEN 'SILVER'
    WHEN SUM(sale_price) > 600000 THEN 'BRONZE'
    ELSE 'CLIMBING'
  END AS rewards_level
FROM shoe_order_customer_product
GROUP BY email;
```
NOTE: You might need to change the loyalty level numbers according to amount of the data you have ingested.


Prepare table for loyalty levels
```
CREATE TABLE shoe_loyalty_levels(
  email STRING,
  total BIGINT,
  rewards_level STRING,
  PRIMARY KEY (email) NOT ENFORCED
);
```

Now you can calculate loyalty levels and store results in the created table.
```
INSERT INTO shoe_loyalty_levels(
 email,
 total,
 rewards_level)
SELECT
  email,
  SUM(sale_price) AS total,
  CASE
    WHEN SUM(sale_price) > 80000000 THEN 'GOLD'
    WHEN SUM(sale_price) > 7000000 THEN 'SILVER'
    WHEN SUM(sale_price) > 600000 THEN 'BRONZE'
    ELSE 'CLIMBING'
  END AS rewards_level
FROM shoe_order_customer_product
GROUP BY email;
```

Verify results
```
SELECT * FROM shoe_loyalty_levels;
```

### Promotions Calculation

Let's find out if some customers are eligible for some special promotions.

Find which customer should receive special promotion for their 10th order of the same brand
```
SELECT
   email,
   COUNT(*) AS total,
   (COUNT(*) % 10) AS sequence,
   (COUNT(*) % 10) = 0 AS next_one_free
 FROM shoe_order_customer_product
 WHERE brand = 'Jones-Stokes'
 GROUP BY email;
 ```
NOTE: We calculate number of orders of Jones-Stokes brand for each customer and offer a free product if it's 10th order.

Find which customer have ordered related brands in large volumes
```
SELECT
     email,
     COLLECT(brand) AS products,
     'bundle_offer' AS promotion_name
  FROM shoe_order_customer_product
  WHERE brand IN ('Braun-Bruen', 'Will Inc')
  GROUP BY email
  HAVING COUNT(DISTINCT brand) = 2 AND COUNT(brand) > 10;
```
NOTE: We sum all orders of brands Braun-Bruen and Will Inc for each customer and offer a special promotion if sum is larger than 10.  

Now we are ready to store the results for all calculated promotions. 

Prepare table for promotion notifications
```
CREATE TABLE shoe_promotions(
  email STRING,
  promotion_name STRING,
  PRIMARY KEY (email) NOT ENFORCED
);
```

Write both calculated promotions in a single statement set to the shoe_promotions table
```
EXECUTE STATEMENT SET 
BEGIN

INSERT INTO shoe_promotions
SELECT
   email,
   'next_free' AS promotion_name
FROM shoe_order_customer_product
WHERE brand = 'Jones-Stokes'
GROUP BY email
HAVING COUNT(*) % 10 = 0;

INSERT INTO shoe_promotions
SELECT
     email,
     'bundle_offer' AS promotion_name
  FROM shoe_order_customer_product
  WHERE brand IN ('Braun-Bruen', 'Will Inc')
  GROUP BY email
  HAVING COUNT(DISTINCT brand) = 2 AND COUNT(brand) > 10;

END;
```
NOTE: there is a bug in the Web UI. Remove the first 2 lines and the last line to be able to run the job.

Check if all promotion notifications are stored correctly
```
select * from shoe_promotions;
```

End of Lab2.
