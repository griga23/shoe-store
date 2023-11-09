# Lab 1

All required resources must be already crreated for this lab to work correctly.

## Verify Confluent Cloud Resources
Let's verify if all resources were created correctly and we can start using them.

### Kafka Topics
Check if following topics exist in your Kafka cluster:
 * shoe_products (for product data aka Product Catalog)
 * shoe_customers (for customer data aka Customer CRM)
 * shoe_orders (for realtime order transactions aka Billing System)

### Schemas in Schema Registry
Check if following Avro schemas exist in your Schema Registry:
 * shoe_products-value
 * shoe_customers-value
 * shoe_orders-value

NOTE: Schema Registry is at the Environment level and can be used for multiple Kafka clusters.

### Connectors
Your Kafka cluster should have three Datagen Source Connectors running. Check if topic and template configurations are correct.

| Connector Name (can be anything)| Topic      | Format | Template            | 
| --------------------------- |:-------------:| -----:|----------------------:|
| **DatagenSourceConnector_0**| shoe_products  | AVRO   | **Shoes**           | 
| **DatagenSourceConnector_1**| shoe_customers | AVRO   | **Shoes customers** | 
| **DatagenSourceConnector_2**| shoe_orders    | AVRO   | **Shoes orders**    | 

NOTE: We use Datagen Connectors with following templates:
  * Shoe Products https://github.com/confluentinc/kafka-connect-datagen/blob/master/src/main/resources/shoes.avro
  * Shoe Customers https://github.com/confluentinc/kafka-connect-datagen/blob/master/src/main/resources/shoe_customers.avro
  * Shoe Orders https://github.com/confluentinc/kafka-connect-datagen/blob/master/src/main/resources/shoe_orders.avro

### Flink Compute Pool

Check if Flink Cluster has been created. Is it running in the same region as your Kafka cluster?

NOTE: Flink Cluster is at the Environment level and can be used with multiple Kafka clusters.


## Flink Tables

### Select Basics
```
DESCRIBE shoe_products;
```
```
SELECT * FROM shoe_products;
```
```
DESCRIBE shoe_customers;
```
```
SELECT * FROM shoe_customers
  WHERE `state` = 'Texas' AND `last_name` LIKE 'B%';
```
```
DESCRIBE EXTENDED shoe_orders;
```
```
SELECT order_id, product_id, customer_id, $rowtime
  FROM shoe_orders
  WHERE customer_id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a'
  LIMIT 10;
```

### Select Advanced
Show amount of (unique) customers
```
SELECT COUNT(id) AS num_customers FROM shoe_customers;
```
```
SELECT COUNT(DISTINCT id) AS num_customers FROM shoe_customers;
```

Show amount of shoe models, average rating and maximum model price for each brand
```
SELECT brand as brand_name, 
    COUNT(DISTINCT name) as models_by_brand, 
    ROUND(AVG(rating),2) as avg_rating,
    MAX(sale_price)/100 as max_price
FROM shoe_products
GROUP BY brand;
```

Show amount of orders for 1 minute intervals
```
SELECT
 window_end,
 COUNT(DISTINCT order_id) AS num_orders
FROM TABLE(
   TUMBLE(TABLE shoe_orders, DESCRIPTOR(`$rowtime`), INTERVAL '1' MINUTES))
GROUP BY window_end;
```

### Tables with Primary Key 
Create a new table for unique customers
```
CREATE TABLE shoe_customers_keyed(
  id STRING,
  first_name STRING,
  last_name STRING,
  email STRING,
  PRIMARY KEY (id) NOT ENFORCED
  );
```

Copy customer data from the original table 
```
INSERT INTO shoe_customers_keyed
  SELECT id, first_name, last_name, email
    FROM shoe_customers;
```

Show amount of cutomers in the new table
```
SELECT COUNT(*) FROM shoe_customers_keyed;
```

End of Lab1
