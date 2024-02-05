# Open Source Flink Lab 2

# Lab 2
Finishing Lab 1 is required for Lab 2. If you have not completed it, go back to [Lab 1](osflinklab1.md).


[1. Flink Joins](osflinklab2.md#1-flink-joins)

[2. Understand Timestamps](lab2.md#2-understand-timestamps)

[3. Understand Joins](lab2.md#3-understand-joins)

[4. Data Enrichment](lab2.md#4-data-enrichment)

[5. Loyalty Levels Calculation](lab2.md#5-loyalty-levels-calculation)

[6. Promotions Calculation](lab2.md#6-promotions-calculation)



## 1. Flink Joins

Flink SQL supports complex and flexible join operations over dynamic tables. There are a number of different types of joins to account for the wide variety of semantics that queries may require.
By default, the order of joins is not optimized. Tables are joined in the order in which they are specified in the FROM clause.

You can find more information about Flink SQL Joins [here.](https://nightlies.apache.org/flink/flink-docs-release-1.18/docs/dev/table/sql/queries/joins/)

### 2. Understand Timestamps
This is an important piece to understand in stream procssing. Two types of event times exist:

1. **Event Time** : This is the time of event happened, this can be contained inside the payload or we can derive this from the metadata(in kafka connectors) which can be (Create Time/ Ingestion Time based on Producer configs). This produces consistent results despite out-of-order or late events.

2. **Processing Time**: This is the Wall Clock Time of system processing the messages. This prooduces non-deterministic events and is useful in some usecases. 

We will understand both by examples here.

***EVENT TIME***

Let us, find all customer records for one customer and display the timestamps from when the events were ingested in the `shoe_customers` Kafka topic.

Open the Flink SQL CLI.

First try this:
```
DESCRIBE EXTENDED shoe_customers;
```
![Alt text](/images/show_customerswots.png)

Did you observe you dont have any time field here, whereas in confluent flink you will find `$rowtime` automatically created.[Try it on Confluent cloud as well for more understanding!]

Let's add this colum to our existing table now,

Run this command now:

```
ALTER TABLE shoe_customers ADD (ingestion_time timestamp_ltz(3) NOT NULL metadata from 'timestamp');
```
 followed by:

 ```
DESCRIBE EXTENDED shoe_customers;
 ```

 Voila! we have added a new column with [TIMESTAMP_LTZ(3)](https://nightlies.apache.org/flink/flink-docs-master/docs/dev/table/types/#timestamp_ltz) field here, and have learned one new command [ALTER](https://nightlies.apache.org/flink/flink-docs-release-1.18/docs/dev/table/sql/alter/).
 
![Alt text](/images/show_cutomersts.png)


Now you can try this command to view event time.

```
SELECT id,ingestion_time 
FROM shoe_customers  
WHERE id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a';
```

NOTE: Check the timestamps from when the customer records were generated.

Find all orders for one customer and display the timestamps from when the events were ingested in the `shoe_orders` Kafka topic.

Note: We have already added ingestion_time in `shoe_orders` table in previous lab, so no need to add field here.
```
SELECT order_id, customer_id, ingestion_time
FROM shoe_orders
WHERE customer_id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a';
```
NOTE: Check the timestamps when the orders were generated. This is important for the join operations we will do next.

 ***Processing Time***

 The processing time is automatically inserted in table using predefined `PROCTIME()` method. To understand run following SQLs:

 ```
 DESCRIBE shoe_orders;
 ```
![Alt text](/images/proctime1.png)

Observe, we already have proc_time column created in our prewvious lab in this table.

Now, Run this:
```
SELECT order_id,ingestion_time, time_type, proc_time from shoe_orders;
```
![Alt text](images/timeview.png)

You should observe `proc_time` column is dispplaying you current system time & ingestion_time will show you the time that the kafka record was produced with time_type(Create Time/LogAppendTime).


### 3. Understand Joins
Now, we can look at the different types of joins available. 
We will join `order` records and `customer` records.

Join orders with non-keyed customer records (Regular Join):
```
SELECT order_id, shoe_orders.`ingestion_time`, first_name, last_name
FROM shoe_orders
INNER JOIN shoe_customers 
ON shoe_orders.customer_id = shoe_customers.id
WHERE customer_id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a';
```

NOTE: Look at the number of rows returned. There are many duplicates!

Join orders with non-keyed customer records in some time windows (Interval Join):

```
SELECT order_id, shoe_orders.`ingestion_time`, first_name, last_name
FROM shoe_orders
INNER JOIN shoe_customers
ON shoe_orders.customer_id = shoe_customers.id
WHERE customer_id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a' AND
  shoe_orders.`ingestion_time` BETWEEN shoe_customers.`ingestion_time` - INTERVAL '1' HOUR AND shoe_customers.`ingestion_time`;
```

Join orders with keyed customer records (Regular Join with Keyed Table):
```
SELECT order_id, shoe_orders.`ingestion_time`, first_name, last_name
FROM shoe_orders
INNER JOIN shoe_customers_keyed_os
ON shoe_orders.customer_id = shoe_customers_keyed_os.customer_id
WHERE shoe_customers_keyed_os.customer_id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a';
```
NOTE: Look at the number of rows returned. There are no duplicates! This is because we have only one customer record for each customer id.

Join orders with keyed customer records at the time when order was created (Temporal Join with Keyed Table):
```
SELECT order_id, shoe_orders.`ingestion_time`, first_name, last_name
FROM shoe_orders
INNER JOIN shoe_customers_keyed_os FOR SYSTEM_TIME AS OF shoe_orders.`ingestion_time`
ON shoe_orders.customer_id = shoe_customers_keyed_os.customer_id
WHERE shoe_customers_keyed_os.customer_id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a';
```

Facing Error? Any idea?
![Alt text](/images/versionederror.png)

Here 2 things are missing:

1. **Timestamp column:** As discussed previously, we can use following SQL. Run this
```
ALTER TABLE shoe_customers_keyed_os ADD (ingestion_time timestamp_ltz(3) NOT NULL metadata from 'timestamp');
```
2. **A ROWTIME attribute:** A row time attribute is a special column in a Flink table that represents the event time of each row. You can define a row time attribute and a watermark strategy using the WATERMARK statement as below or during DDL like we did in `shoe_order` table in previous lab. Run this.

```
ALTER TABLE shoe_customers_keyed_os ADD WATERMARK FOR ingestion_time AS ingestion_time - INTERVAL '5' SECOND;
```

Now your table should look like this:

![Alt text](/images/rowtimeattr.png)


NOTE 1: There might be empty result set if keyed customers tables was created after the order records were ingested in the shoe_orders topic. 

NOTE 2: You can find more information about Temporal Joins with Flink SQL [here.](https://nightlies.apache.org/flink/flink-docs-release-1.18/docs/dev/table/sql/queries/joins/#temporal-joins)

---------------- Done for now----
### 4. Data Enrichment
We can store the result of a join in a new table. 
We will join data from: Order, Customer, Product tables together in a single SQL statement.

Create a new table for `Order <-> Customer <-> Product` join result:
```
CREATE TABLE shoe_order_customer_product(
  order_id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  brand STRING,
  model STRING,
  sale_price INT,
  rating DOUBLE,
  PRIMARY KEY (order_id) NOT ENFORCED
)
WITH 
(
  'connector' = 'upsert-kafka',
  'topic' = 'shoe_order_customer_product_os',
  'properties.bootstrap.servers'='pkc-7xoy1.eu-central-1.aws.confluent.cloud:9092',
  'properties.security.protocol'='SASL_SSL',
  'properties.sasl.jaas.config'='org.apache.flink.kafka.shaded.org.apache.kafka.common.security.plain.PlainLoginModule required username="WCPMDIVBYNGIIH2C" password="n1n+kx0mPXh+RA2xboO63yKE5mJNBOZDH0FpTtX0/gEon1mlqm5qNlc/eGtAZXGv";',
  'properties.sasl.mechanism'='PLAIN',
  'properties.group.id' = 'testGroup',
  'key.format' = 'raw',
  'value.format' = 'avro-confluent',
  'value.avro-confluent.url' = 'https://psrc-xm8wx.eu-central-1.aws.confluent.cloud',
  'value.fields-include' = 'EXCEPT_KEY',
  'value.avro-confluent.basic-auth.credentials-source'='USER_INFO',
  'value.avro-confluent.basic-auth.user-info'='P5MI4D3DM4ZDEOTY:fks9JpuSV2kcYN/t/h4FmASTdoMrr+Wkcpa9aYOhAtviPAhz27BGN6bYvd1qLi8F'
);
```

Insert joined data from 3 tables into the new table:
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
  so.order_id,
  sc.first_name,
  sc.last_name,
  sc.email,
  sp.brand,
  sp.model,
  sp.sale_price,
  sp.rating
FROM 
  shoe_orders so
  INNER JOIN shoe_customers_keyed_os sc 
    ON so.customer_id = sc.customer_id
  INNER JOIN shoe_products_keyed_os sp
    ON so.product_id = sp.product_id;
```

Verify that the data was joined successfully. 
```
SELECT * FROM shoe_order_customer_product;
```

### 5. Loyalty Levels Calculation

Now we are ready to calculate loyalty levels for our customers.

First let's see which loyalty levels are being calculated:
```
SELECT
  email,
  SUM(sale_price) AS total,
  CASE
    WHEN SUM(sale_price) > 800000 THEN 'GOLD'
    WHEN SUM(sale_price) > 70000 THEN 'SILVER'
    WHEN SUM(sale_price) > 6000 THEN 'BRONZE'
    ELSE 'CLIMBING'
  END AS rewards_level
FROM shoe_order_customer_product
GROUP BY email;
```
NOTE: You might need to change the loyalty level numbers according to the amount of the data you have already ingested.


Prepare the table for loyalty levels:
```
CREATE TABLE shoe_loyalty_levels(
  email STRING,
  total BIGINT,
  rewards_level STRING,
  PRIMARY KEY (email) NOT ENFORCED
);
```

Now you can calculate loyalty levels and store the results in the new table.
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

Verify your results:
```
SELECT * FROM shoe_loyalty_levels;
```

### 6. Promotions Calculation

Let's find out if some customers are eligible for special promotions.

Find which customer should receive a special promotion for their 10th order of the same shoe brand.
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
NOTE: We calculate the number of orders of the brand 'Jones-Stokes' for each customer and offer a free product if it's their 10th order.

Find which customers have ordered related brands in large volumes.
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
NOTE: We sum all orders of brands 'Braun-Bruen' and 'Will Inc' for each customer and offer a special promotion if the sum is larger than ten.  

Now we are ready to store the results for all calculated promotions. 

Create a table for promotion notifications:
```
CREATE TABLE shoe_promotions(
  email STRING,
  promotion_name STRING,
  PRIMARY KEY (email) NOT ENFORCED
);
```

Write both calculated promotions in a single statement set to the `shoe_promotions` table.
NOTE: There is a bug in the Web UI. Remove the first two lines and the last line to be able to run the statement.

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


Check if all promotion notifications are stored correctly.
```
SELECT * from shoe_promotions;
```

All data products are created now and events are in motion. Visit the brand new data portal to get all information you need and query the data. Give it a try!

![image](terraform/img/dataportal.png)

## End of Lab2.

# If you don't need your infrastructure anymore, do not forget to delete the resources!
