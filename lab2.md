# Lab 2

Finishing Lab 1 is required for this lab.

## Flink

### Data Enrichment
Prepare table for Order <-> Customer join 
```
CREATE TABLE shoe_order_customer(
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

Insert data in the created table
```
 INSERT INTO shoe_order_customer(
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
  ON shoe_orders.customer_id = shoe_customers.id;
```

Prepare table for Order <-> Customer <-> Product Join
```
CREATE TABLE shoe_order_customer_product(
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

Insert data in the created table
```
INSERT INTO shoe_order_customer_product(
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
FROM shoe_order_customer
  INNER JOIN shoe_products
  ON shoe_order_customer.product_id = shoe_products.id;
```

### Loyalty Levels Calculation

Prepare table for loyalty levels
```
CREATE TABLE shoe_loyalty_levels(
  email STRING,
  total BIGINT,
  rewards_level STRING,
  PRIMARY KEY (email) NOT ENFORCED
);
```

Calculate loyalty levels
```
INSERT INTO shoe_loyalty_levels(
 email,
 total,
 rewards_level)
SELECT
  email,
  SUM(sale_price) AS total,
  CASE
    WHEN SUM(sale_price) > 8000000 THEN 'GOLD'
    WHEN SUM(sale_price) > 7000000 THEN 'SILVER'
    WHEN SUM(sale_price) > 6000000 THEN 'BRONZE'
    ELSE 'CLIMBING'
  END AS rewards_level
FROM shoe_order_customer_product
GROUP BY email;
```

### Promotions Calculation

Find which customers should receive special promotion for their 10th order of the same brand
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

Find which customers have ordered related brands in large volumes
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

Find customers who bought twice shoes with high rating and then bought shoes with low rating
```
SELECT *
FROM shoe_order_customer_product
     MATCH_RECOGNIZE (
         PARTITION BY email
         ORDER BY $rowtime
         MEASURES
           a.rating AS rating1,
           b.rating AS rating2,
           c.rating AS rating3,
           c.order_id AS order_id,
           $rowtime AS order_time
         AFTER MATCH SKIP TO NEXT ROW
         PATTERN (a b c)
         DEFINE
           a AS a.rating > 4,
           b AS b.rating > 4,
           c AS c.rating > 0 AND c.rating < 2);
```

Prepare table for promotion notifications
```
CREATE TABLE shoe_promotions(
  email STRING,
  promotion_name STRING,
  PRIMARY KEY (email) NOT ENFORCED
);
```

Write all 3 calculated promotions in a single statement set to the shoe_promotions table
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

INSERT INTO shoe_promotions
SELECT email,
  'better_experience' AS promotion_name
FROM shoe_order_customer_product
     MATCH_RECOGNIZE (
         PARTITION BY email
         ORDER BY $rowtime
         MEASURES
           a.rating AS rating1,
           b.rating AS rating2,
           c.rating AS rating3
         AFTER MATCH SKIP TO NEXT ROW
         PATTERN (a b c)
         DEFINE
           a AS a.rating > 4,
           b AS b.rating > 4,
           c AS c.rating > 0 AND c.rating < 2);

END;
```

End of Lab 2
