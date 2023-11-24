#!/bin/bash

eval $(echo -e "confluent flink statement create --sql \"CREATE TABLE shoe_customers_keyed(customer_id STRING,first_name STRING,last_name STRING,email STRING,PRIMARY KEY (customer_id) NOT ENFORCED);\" --compute-pool $(terraform output cc_compute_pool_name) --environment $(terraform output cc_hands_env) --database cc_handson_cluster")
sleep 10
eval $(echo -e "confluent flink statement create --sql \"INSERT INTO shoe_customers_keyed SELECT id, first_name, last_name, email FROM shoe_customers;\" --compute-pool $(terraform output cc_compute_pool_name) --environment $(terraform output cc_hands_env) --database cc_handson_cluster")
sleep 10
eval $(echo -e "confluent flink statement create --sql \"CREATE TABLE shoe_products_keyed(product_id STRING,brand STRING,model STRING,sale_price INT,rating DOUBLE,PRIMARY KEY (product_id) NOT ENFORCED);\" --compute-pool $(terraform output cc_compute_pool_name) --environment $(terraform output cc_hands_env) --database cc_handson_cluster")
sleep 10
eval $(echo -e "confluent flink statement create --sql \"INSERT INTO shoe_products_keyed SELECT id, brand, name, sale_price, rating FROM shoe_products;\" --compute-pool $(terraform output cc_compute_pool_name) --environment $(terraform output cc_hands_env) --database cc_handson_cluster")
sleep 10
eval $(echo -e "confluent flink statement create --sql \"CREATE TABLE shoe_order_customer(order_id INT,product_id STRING,first_name STRING,last_name STRING,email STRING) WITH ('changelog.mode' = 'retract');\" --compute-pool $(terraform output cc_compute_pool_name) --environment $(terraform output cc_hands_env) --database cc_handson_cluster")
sleep 10
eval $(echo -e "confluent flink statement create --sql \"INSERT INTO shoe_order_customer (order_id,product_id,first_name,last_name,email) SELECT order_id,product_id,first_name,last_name,email FROM shoe_orders INNER JOIN shoe_customers_keyed ON shoe_orders.customer_id = shoe_customers_keyed.customer_id;\" --compute-pool $(terraform output cc_compute_pool_name) --environment $(terraform output cc_hands_env) --database cc_handson_cluster")
sleep 10
eval $(echo -e "confluent flink statement create --sql \"CREATE TABLE shoe_order_customer_product(order_id INT,first_name STRING,last_name STRING,email STRING,brand STRING,model STRING,sale_price INT,rating DOUBLE)WITH ('changelog.mode' = 'retract');\" --compute-pool $(terraform output cc_compute_pool_name) --environment $(terraform output cc_hands_env) --database cc_handson_cluster")
sleep 10
eval $(echo -e "confluent flink statement create --sql \"INSERT INTO shoe_order_customer_product (order_id,first_name,last_name,email,brand,model,sale_price,rating) SELECT order_id,first_name,last_name,email,brand,model,sale_price,rating FROM shoe_order_customer INNER JOIN shoe_products_keyed ON shoe_order_customer.product_id = shoe_products_keyed.product_id;\" --compute-pool $(terraform output cc_compute_pool_name) --environment $(terraform output cc_hands_env) --database cc_handson_cluster")
sleep 10
eval $(echo -e "confluent flink statement create --sql \"CREATE TABLE shoe_loyalty_levels(email STRING,total BIGINT,rewards_level STRING,PRIMARY KEY (email) NOT ENFORCED);\" --compute-pool $(terraform output cc_compute_pool_name) --environment $(terraform output cc_hands_env) --database cc_handson_cluster")
sleep 10
eval $(echo -e "confluent flink statement create --sql \"INSERT INTO shoe_loyalty_levels(email,total,rewards_level) SELECT email,SUM(sale_price) AS total,CASE WHEN SUM(sale_price) > 80000000 THEN 'GOLD' WHEN SUM(sale_price) > 7000000 THEN 'SILVER' WHEN SUM(sale_price) > 600000 THEN 'BRONZE' ELSE 'CLIMBING' END AS rewards_level FROM shoe_order_customer_product GROUP BY email;\" --compute-pool $(terraform output cc_compute_pool_name) --environment $(terraform output cc_hands_env) --database cc_handson_cluster")
sleep 10
eval $(echo -e "confluent flink statement create --sql \"CREATE TABLE shoe_promotions(email STRING,promotion_name STRING,PRIMARY KEY (email) NOT ENFORCED);\" --compute-pool $(terraform output cc_compute_pool_name) --environment $(terraform output cc_hands_env) --database cc_handson_cluster")
sleep 10
eval $(echo -e "confluent flink statement create --sql \"$(cat ./sql.sql)\" --compute-pool $(terraform output cc_compute_pool_name) --environment $(terraform output cc_hands_env) --database cc_handson_cluster")

