![image](terraform/img/confluent-logo-300-2.png)
# Lab 1

All required resources must be already created for this lab to work correctly. If you haven't already, follow the [prerequisites](prereq.md).

[1. Verify Confluent Cloud Resources](lab1.md#1-verify-confluent-cloud-resources)

[2. Create Pool and Connecting to Flink](lab1.md#2-create-pool-and-connecting-to-flink)

[3. Flink Tables](lab1.md#3-flink-tables)

[4. Select Queries](lab1.md#4-select-queries)

[5. Aggregations](lab1.md#5-aggregations)

[6. Time Windows](lab1.md#6-time-windows)

[7. Tables with Primary Key](lab1.md#7-tables-with-primary-key)

[8. Flink Jobs](lab1.md#8-flink-jobs)

## 1. Verify Confluent Cloud Resources
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

### Datagen Connectors
Your Kafka cluster should have three Datagen Source Connectors running. Check if topic and template configurations are correct.

| Connector Name (can be anything)     |      Topic      | Format |             Template | 
|--------------------------------------|:---------------:|-------:|---------------------:|
| **DatagenSourceConnector_products**  |  shoe_products  |   AVRO |            **Shoes** | 
| **DatagenSourceConnector_customers** | shoe_customers  |   AVRO |  **Shoes customers** | 
| **DatagenSourceConnector_orders**    |   shoe_orders   |   AVRO |     **Shoes orders** | 

## 2. Create Pool and Connecting to Flink

IMPORTANT TO KNOW FOR THE WORKSHOP:
We run in AWS only. Currently we do support [4 Regions](https://docs.confluent.io/cloud/current/flink/reference/op-supported-features-and-limitations.html#cloud-regions) within AWS cloud.
The complete onsite team is working in region: `eu-central-1` (all terraform and manual guide do not need to change)
The online team is working in different regions:
 - Attendees with Lastname first Letter A-I working in region `us-east1` 
     * Flink SQL Pool in `us-east1`
 - Attendees with Lastname first Letter J-R working in region `us-east2` 
     * Flink SQL Pool in `us-east2`
 - Attendees with Lastname first Letter S-Z working in region `eu-west-1` 
     * Flink SQL Pool in `eu-west-1`

Create Flink Compute Pool in environment `handson-flink`
Go back to environment `handson-flink` and choose `Flink (preview)` Tab. From there we create a new compute pool:
* choose AWS region (remember the Lastname Rule), click `continue` and 
* enter Pool Name: `cc_flink_compute_pool` with 5 Confluent Flink Units (CFU) and 
* click `Continue` button and then `Finish`.
The pool will be provisioned and ready to use in a couple of moments.

![image](terraform/img/flinkpool.png)


## 2. Connecting to Flink 
You can use your web browser or console to enter Flink SQL statements.
  * **Web UI** - click on the button Open SQL workspace on your Flink Compute Pool
    Open the SQL Workspace of compute pool and set:
    - the environment name `handson-flink` as catalog
    - and the cluster name `cc_handson_cluster` as database
    
    Via the dropdown boxes, see graphic
    ![image](terraform/img/sqlworksheet.png)

  * **Console** - copy/paste command from your Flink Compute Pool to the command line   
  Of course you could also use the the Flink SQL Shell. Copy the command out of the `Compute Pool Window` and execute in your terminal (we prefer iterm2)
  ```bash
  confluent flink shell --compute-pool <pool id> --environment <env-id>
  ```
  If you have used Terraform for the prerequisites:
  ```
  eval $(echo -e "confluent flink shell --compute-pool $(terraform output cc_compute_pool_name) --environment $(terraform output cc_hands_env)")
  ```

NOTE: you can access your Flink Compute Pool from the Data Portal. Just click on the Data Portal in the main menu on the left side. Then select your Environment. You should see your topics. When you click on any of the topic tile you can query topic's data using Flink. 

Data Portal: Kafka Topics Tiles
![image](terraform/img/dataPortal1.png)

Data Portal: shoe_order topic selected. Click on Query button.
![image](terraform/img/dataPortal2.png)


NOTE: you need to have confluent cloud console tool installed and be logged in with correct access rights.

## 3. Flink Tables
Let's start with exploring our Flink tables.
Kafka topics and schemas are always in sync with our Flink cluster. Any topic created in Kafka is visible directly as a table in Flink, and any table created in Flink is visible as a topic in Kafka. Effectively, Flink provides a SQL interface on top of Confluent Cloud.

Following mapping exist:
| Kafka          | Flink     | 
| ------------   |:---------:|
| Environment    | Catalog   | 
| Cluster        | Database  |
| Topic + Schema | Table     |

We will now work with SQL Worksheet:
![image](terraform/img/sql_worksheet.png)

Make sure you work with correct Flink catalog (=environment) and database (=Kafka cluster).
```
SHOW CATALOGS;
```
```
SHOW DATABASES;
```
```
USE CATALOG <MY CONFLUENT ENVIRONMENT NAME>;
USE cc_handson_cluster;
```
List all Flink Tables (=Kafka topics) in your Confluent Cloud cluster
```
SHOW TABLES;
```
Do you see tables shoe_products, shoe_customers, shoe_orders?

You can add multiple query boxes by clicking the + button on the left of it

![image](terraform/img/add-query-box.png)

Understand how was the table created
```
SHOW CREATE TABLE shoe_products;
```
More info to understand all parameters https://docs.confluent.io/cloud/current/flink/reference/statements/create-table.html

### 4. Select Queries
Our Flink tables are populated by the Datagen connectors.

We can first check the table schema for our shoe product catalog. This should be the same as the topic schema in Schema Registry.
```
DESCRIBE shoe_products;
```

Let's check if any product records exist in the table.
```
SELECT * FROM shoe_products;
```

Check if customers schema exist. 
```
DESCRIBE shoe_customers;
```

Are there any customers in Texas with name starting with B. ?
```
SELECT * FROM shoe_customers
  WHERE `state` = 'Texas' AND `last_name` LIKE 'B%';
```

Check all attributes of shoe_orders table including hidden attributes.
```
DESCRIBE EXTENDED shoe_orders;
```

Check first 10 orders for one customer.
```
SELECT order_id, product_id, customer_id, $rowtime
  FROM shoe_orders
  WHERE customer_id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a'
  LIMIT 10;
```

### 5. Aggregations
Let's try to run more advanced queries.

First find out number of customers records and then number of unique customers.
```
SELECT COUNT(id) AS num_customers FROM shoe_customers;
```
```
SELECT COUNT(DISTINCT id) AS num_customers FROM shoe_customers;
```

We can try some basic aggregations with the product catalog records.
For each shoe brand find number of shoe models, average rating and maximum model price. 
```
SELECT brand as brand_name, 
    COUNT(DISTINCT name) as models_by_brand, 
    ROUND(AVG(rating),2) as avg_rating,
    MAX(sale_price)/100 as max_price
FROM shoe_products
GROUP BY brand;
```
### 6. Time Windows

Let's try Flink time windowing functions for shoe order records.
Column names “window_start” and “window_end” are commonly used in Flink's window operations, especially when dealing with event time windows.

Find amount of orders for 1 minute intervals (tumbling window aggregation).
```
SELECT
 window_end,
 COUNT(DISTINCT order_id) AS num_orders
FROM TABLE(
   TUMBLE(TABLE shoe_orders, DESCRIPTOR(`$rowtime`), INTERVAL '1' MINUTES))
GROUP BY window_end;
```

Find amount of orders for 10 minute intervals advanced by 5 minutes (hopping window aggregation).
```
SELECT
 window_start, window_end,
 COUNT(DISTINCT order_id) AS num_orders
FROM TABLE(
   HOP(TABLE shoe_orders, DESCRIPTOR(`$rowtime`), INTERVAL '5' MINUTES, INTERVAL '10' MINUTES))
GROUP BY window_start, window_end;
```

NOTE: More info about Flink Window aggregations https://nightlies.apache.org/flink/flink-docs-release-1.18/docs/dev/table/sql/queries/window-agg/

### 7. Tables with Primary Key 

Flink allows you to define primary key for your table. Primary key is a column that is unique for each record.

Let's create a new table that will store unique customers only
```
CREATE TABLE shoe_customers_keyed(
  customer_id STRING,
  first_name STRING,
  last_name STRING,
  email STRING,
  PRIMARY KEY (customer_id) NOT ENFORCED
  );
```
Compare created keyed table with shoe_customers, what is the difference.
```bash
SHOW CREATE TABLE shoe_customers_keyed;
```
We do have a different [changelog.mode](https://docs.confluent.io/cloud/current/flink/reference/statements/create-table.html#changelog-mode) and a [primary key](https://docs.confluent.io/cloud/current/flink/reference/statements/create-table.html#primary-key-constraint) contraint. What does this mean?

NOTE: More information about Primary key constraint https://docs.confluent.io/cloud/current/flink/reference/statements/create-table.html#primary-key-constraint

Create a new Flink job to copy customer data from the original table to the new table
```
INSERT INTO shoe_customers_keyed
  SELECT id, first_name, last_name, email
    FROM shoe_customers;
```

Show amount of cutomers in the new table
```
SELECT COUNT(*) as AMOUNTROWS FROM shoe_customers_keyed;
```

Look up one specific customer
```
SELECT * 
 FROM shoe_customers_keyed  
 WHERE customer_id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a';
```

Compare it with all customer records for one specific customer
```
SELECT *
 FROM shoe_customers
 WHERE id = 'b523f7f3-0338-4f1f-a951-a387beeb8b6a';
```

We also need to create Primary Key table for our product catalog.

Prepare a new table that will store unique products only
```
CREATE TABLE shoe_products_keyed(
  product_id STRING,
  brand STRING,
  model STRING,
  sale_price INT,
  rating DOUBLE,
  PRIMARY KEY (product_id) NOT ENFORCED
  );
```

Create a new Flink job to copy product data from the original table to the new table
```
INSERT INTO shoe_products_keyed
  SELECT id, brand, `name`, sale_price, rating 
    FROM shoe_products;
```

Check if only single record is returned for some product
```
SELECT * 
 FROM shoe_products_keyed  
 WHERE product_id = '0fd15be0-8b95-4f19-b90b-53aabf4c49df';
```

### 8. Flink Jobs 

Now, you can finally check with jobs are still running, which jobs failed, and which stopped. Go to Flink (Preview) in environments and choose `Flink Statements`. Check what you can do here.
![image](terraform/img/flink_jobs.png)

or you could use the confluent cli
```bash
confluent login
confluent flink statement list --cloud aws --region eu-central-1 --environment <your env-id> --compute-pool <your pool id>
#          Creation Date         |        Name        |           Statement            | Compute Pool |  Status   |              Status Detail               
#--------------------------------+--------------------+--------------------------------+--------------+-----------+------------------------------------------
#...
# 2023-11-15 16:14:38 +0000 UTC | f041ae19-c932-403f | CREATE TABLE                   | lfcp-jvv9jq  | COMPLETED | Table 'shoe_customers_keyed'             
#                                |                    | shoe_customers_keyed(          |              |           | created                                  
#                                |                    |  customer_id STRING,           |              |           |                                          
#                                |                    | first_name STRING,   last_name |              |           |                                          
#                                |                    | STRING,   email STRING,        |              |           |                                          
#                                |                    | PRIMARY KEY (customer_id) NOT  |              |           |                                          
#                                |                    | ENFORCED   );                  |              |           |                                          
# ....
# Exceptions
confluent flink statement exception list <name> --cloud aws --region eu-central-1 --environment <your env-id>
# Descriobe Statements
confluent flink statement describe <name> --cloud aws --region eu-central-1 --environment <your env-id>
```

End of Lab1, continue with [Lab2](lab2.md).
