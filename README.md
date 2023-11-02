# shoe-store
Shoe Store Loyalty Engine - Flink SQL Workshop

# Create Confluent Cloud Resources with terraform
Please follow this [guide](terraform/README.md)

# Create Confluent Cloud Resources manually

## Kafka
Environment, Schema Registry, CLuster, Service accounts, Role Binding

### Kafka Topics
-create new topics with 1 partition: customers, products, orders

### Data Sources
Using Datagen with following templates:
  * Shoe Products https://github.com/confluentinc/kafka-connect-datagen/blob/master/src/main/resources/shoes.avro
  * Shoe Customers https://github.com/confluentinc/kafka-connect-datagen/blob/master/src/main/resources/shoe_customers.avro
  * Shoe Orders https://github.com/confluentinc/kafka-connect-datagen/blob/master/src/main/resources/shoe_orders.avro

## Flink

### Select Basics
```
select * from shoe_products;
select * from shoe_customers;
select * from shoe_orders;
```

### Order <-> Customer Join
```
CREATE TABLE order_customer(
  order_id INT,
  product_id STRING,
  ts TIMESTAMP(3),
  first_name STRING,
  last_name STRING,
  email STRING,
  phone STRING,
  street_address STRING,
  state STRING,
  zip_code STRING,
  country STRING,
  country_code STRING);
```

```
 INSERT INTO order_customer(
  order_id,
  product_id,
  ts,
  first_name,
  last_name,
  email,
  phone,
  street_address,
  state,
  zip_code,
  country,
  country_code)
SELECT
  order_id,
  product_id,
  ts,
  first_name,
  last_name,
  email,
  phone,
  street_address,
  state,
  zip_code,
  country,
  country_code
FROM shoe_orders
  INNER JOIN shoe_customers
  ON show_orders.customer_id = shoe_customers.id;
```

### Order <-> Customer <-> Product Join
```
CREATE TABLE order_customer_product(
  order_id INT,
  ts TIMESTAMP(3),
  first_name STRING,
  last_name STRING,
  email STRING,
  phone STRING,
  street_address STRING,
  state STRING,
  zip_code STRING,
  country STRING,
  country_code STRING,
  brand STRING,
  model STRING,
  sale_price INT,
  rating DOUBLE
);
```

```
INSERT INTO order_customer_product(
  order_id,
  ts,
  first_name,
  last_name,
  email,
  phone,
  street_address,
  state,
  zip_code,
  country,
  country_code,
  brand,
  model,
  sale_price,
  rating)
SELECT
  order_id,
  ts,
  first_name,
  last_name,
  email,
  phone,
  street_address,
  state,
  zip_code,
  country,
  country_code,
  brand,
  name,
  sale_price,
  rating
FROM order_customer
  INNER JOIN shoe_products
  ON order_customer.product_id = shoe_products.id;
```
  
