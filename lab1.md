# Lab 1

Prepare required resources (if not already done automatically with the Terraform lab) 

## Verify Kafka Resources

### Kafka Topics
Create following topics (1 partition is ok):
 * shoe_products (for product data aka Product Catalog)
 * shoe_customers (for customer data aka Customer CRM)
 * shoe_orders (for realtime order transactions aka Billing System)
Skip Topic Schemas. They will be created automatically by the Datagen Connectors.

### Connectors - Data Sources

Create following 3 Datagen Source Connectors:
  * Topic **shoe_products** , API Key Global Access, AVRO format, **Shoes** template, 1 task
  * Topic **shoe_customers** , API Key Global Access, AVRO format, **Shoe customers** template, 1 task
  * Topic **shoe_orders** , API Key Global Access, AVRO format, **Shoe orders** template, 1 task

NOTE: We use Datagen with following templates:
  * Shoe Products https://github.com/confluentinc/kafka-connect-datagen/blob/master/src/main/resources/shoes.avro
  * Shoe Customers https://github.com/confluentinc/kafka-connect-datagen/blob/master/src/main/resources/shoe_customers.avro
  * Shoe Orders https://github.com/confluentinc/kafka-connect-datagen/blob/master/src/main/resources/shoe_orders.avro

### Flink Pool

If already not present create Flink Pool Cluster


## Flink

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
DESCRIBE shoe_orders;
```
```
SELECT * FROM shoe_orders 
  WHERE customer_id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a';
```

### Select Advanced
Show amount of unique customers
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

Show last 10 orders
```
SELECT $rowtime, order_id FROM shoe_orders LIMIT 10;
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

End of Lab1
