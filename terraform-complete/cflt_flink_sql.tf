
# --------------------------------------------------------
# Flink SQL: CREATE TABLE shoe_customers_keyed
# --------------------------------------------------------
resource "confluent_flink_statement" "create_shoe_customers_keyed" {
  depends_on = [
    resource.confluent_environment.cc_handson_env,
    resource.confluent_schema_registry_cluster.cc_sr_cluster,
    resource.confluent_kafka_cluster.cc_kafka_cluster,
    resource.confluent_connector.datagen_products,
    resource.confluent_connector.datagen_customers,
    resource.confluent_connector.datagen_orders,
    resource.confluent_flink_compute_pool.cc_flink_compute_pool
  ]    
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app_manager.id
  }
  statement  = "CREATE TABLE shoe_customers_keyed(customer_id STRING,first_name STRING,last_name STRING,email STRING,PRIMARY KEY (customer_id) NOT ENFORCED) WITH ('kafka.partitions' = '1');"
  properties = {
    "sql.current-catalog"  = confluent_environment.cc_handson_env.display_name
    "sql.current-database" = confluent_kafka_cluster.cc_kafka_cluster.display_name
  }
  rest_endpoint   =  confluent_flink_compute_pool.cc_flink_compute_pool.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink SQL: CREATE TABLE shoe_products_keyed
# --------------------------------------------------------
resource "confluent_flink_statement" "create_shoe_products_keyed" {
  depends_on = [
    resource.confluent_environment.cc_handson_env,
    resource.confluent_schema_registry_cluster.cc_sr_cluster,
    resource.confluent_kafka_cluster.cc_kafka_cluster,
    resource.confluent_connector.datagen_products,
    resource.confluent_connector.datagen_customers,
    resource.confluent_connector.datagen_orders,
    resource.confluent_flink_compute_pool.cc_flink_compute_pool
  ]    
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app_manager.id
  }
  statement  = "CREATE TABLE shoe_products_keyed(product_id STRING,brand STRING,model STRING,sale_price INT,rating DOUBLE,PRIMARY KEY (product_id) NOT ENFORCED) WITH ('kafka.partitions' = '1');"
  properties = {
    "sql.current-catalog"  = confluent_environment.cc_handson_env.display_name
    "sql.current-database" = confluent_kafka_cluster.cc_kafka_cluster.display_name
  }
  rest_endpoint   =  confluent_flink_compute_pool.cc_flink_compute_pool.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink SQL: INSERT INTO shoe_customers_keyed
# --------------------------------------------------------
resource "confluent_flink_statement" "insert_shoe_customers_keyed" {
  depends_on = [
    resource.confluent_flink_statement.create_shoe_customers_keyed
  ]    
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app_manager.id
  }
  statement  = "INSERT INTO shoe_customers_keyed SELECT id, first_name, last_name, email FROM shoe_customers;"
  properties = {
    "sql.current-catalog"  = confluent_environment.cc_handson_env.display_name
    "sql.current-database" = confluent_kafka_cluster.cc_kafka_cluster.display_name
  }
  rest_endpoint   =  confluent_flink_compute_pool.cc_flink_compute_pool.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink SQL: INSERT INTO shoe_products_keyed 
# --------------------------------------------------------
resource "confluent_flink_statement" "insert_shoe_products_keyed" {
  depends_on = [
    resource.confluent_flink_statement.create_shoe_products_keyed
  ]    
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app_manager.id
  }
  statement  = "INSERT INTO shoe_products_keyed SELECT id, brand, name, sale_price, rating FROM shoe_products;"
  properties = {
    "sql.current-catalog"  = confluent_environment.cc_handson_env.display_name
    "sql.current-database" = confluent_kafka_cluster.cc_kafka_cluster.display_name
  }
  rest_endpoint   =  confluent_flink_compute_pool.cc_flink_compute_pool.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink SQL: CREATE TABLE shoe_order_customer
# --------------------------------------------------------
resource "confluent_flink_statement" "create_shoe_order_customer" {
  depends_on = [
    resource.confluent_environment.cc_handson_env,
    resource.confluent_schema_registry_cluster.cc_sr_cluster,
    resource.confluent_kafka_cluster.cc_kafka_cluster,
    resource.confluent_connector.datagen_products,
    resource.confluent_connector.datagen_customers,
    resource.confluent_connector.datagen_orders,
    resource.confluent_flink_compute_pool.cc_flink_compute_pool,
    resource.confluent_flink_statement.create_shoe_products_keyed,
    resource.confluent_flink_statement.create_shoe_customers_keyed
  ]    
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app_manager.id
  }
  statement  = "CREATE TABLE shoe_order_customer(order_id INT,product_id STRING,first_name STRING,last_name STRING,email STRING) WITH ('changelog.mode' = 'retract', 'kafka.partitions' = '1');"
  properties = {
    "sql.current-catalog"  = confluent_environment.cc_handson_env.display_name
    "sql.current-database" = confluent_kafka_cluster.cc_kafka_cluster.display_name
  }
  rest_endpoint   =  confluent_flink_compute_pool.cc_flink_compute_pool.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink SQL: INSERT INTO shoe_order_customer
# --------------------------------------------------------
resource "confluent_flink_statement" "insert_shoe_order_customer" {
  depends_on = [
    resource.confluent_flink_statement.create_shoe_order_customer
  ]    
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app_manager.id
  }
  statement  = "INSERT INTO shoe_order_customer (order_id,product_id,first_name,last_name,email) SELECT order_id,product_id,first_name,last_name,email FROM shoe_orders INNER JOIN shoe_customers_keyed ON shoe_orders.customer_id = shoe_customers_keyed.customer_id;"
  properties = {
    "sql.current-catalog"  = confluent_environment.cc_handson_env.display_name
    "sql.current-database" = confluent_kafka_cluster.cc_kafka_cluster.display_name
  }
  rest_endpoint   =  confluent_flink_compute_pool.cc_flink_compute_pool.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink SQL: CREATE TABLE shoe_order_customer_product
# --------------------------------------------------------
resource "confluent_flink_statement" "create_shoe_order_customer_product" {
  depends_on = [
    resource.confluent_environment.cc_handson_env,
    resource.confluent_schema_registry_cluster.cc_sr_cluster,
    resource.confluent_kafka_cluster.cc_kafka_cluster,
    resource.confluent_connector.datagen_products,
    resource.confluent_connector.datagen_customers,
    resource.confluent_connector.datagen_orders,
    resource.confluent_flink_compute_pool.cc_flink_compute_pool,
    resource.confluent_flink_statement.create_shoe_products_keyed,
    resource.confluent_flink_statement.create_shoe_customers_keyed,
    resource.confluent_flink_statement.create_shoe_order_customer
  ]    
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app_manager.id
  }
  statement  = "CREATE TABLE shoe_order_customer_product(order_id INT,first_name STRING,last_name STRING,email STRING,brand STRING,model STRING,sale_price INT,rating DOUBLE) WITH ('changelog.mode' = 'retract', 'kafka.partitions' = '1');"
  properties = {
    "sql.current-catalog"  = confluent_environment.cc_handson_env.display_name
    "sql.current-database" = confluent_kafka_cluster.cc_kafka_cluster.display_name
  }
  rest_endpoint   =  confluent_flink_compute_pool.cc_flink_compute_pool.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink SQL: INSERT INTO shoe_order_customer_product
# --------------------------------------------------------
resource "confluent_flink_statement" "insert_shoe_order_customer_product" {
  depends_on = [
    resource.confluent_flink_statement.create_shoe_order_customer_product
  ]    
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app_manager.id
  }
  statement  = "INSERT INTO shoe_order_customer_product (order_id,first_name,last_name,email,brand,model,sale_price,rating) SELECT order_id,first_name,last_name,email,brand,model,sale_price,rating FROM shoe_order_customer INNER JOIN shoe_products_keyed ON shoe_order_customer.product_id = shoe_products_keyed.product_id;"
  properties = {
    "sql.current-catalog"  = confluent_environment.cc_handson_env.display_name
    "sql.current-database" = confluent_kafka_cluster.cc_kafka_cluster.display_name
  }
  rest_endpoint   =  confluent_flink_compute_pool.cc_flink_compute_pool.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink SQL: CREATE TABLE shoe_loyalty_levels
# --------------------------------------------------------
resource "confluent_flink_statement" "create_shoe_loyalty_levels" {
  depends_on = [
    resource.confluent_environment.cc_handson_env,
    resource.confluent_schema_registry_cluster.cc_sr_cluster,
    resource.confluent_kafka_cluster.cc_kafka_cluster,
    resource.confluent_connector.datagen_products,
    resource.confluent_connector.datagen_customers,
    resource.confluent_connector.datagen_orders,
    resource.confluent_flink_compute_pool.cc_flink_compute_pool,
    resource.confluent_flink_statement.create_shoe_products_keyed,
    resource.confluent_flink_statement.create_shoe_customers_keyed,
    resource.confluent_flink_statement.create_shoe_order_customer,
    resource.confluent_flink_statement.create_shoe_order_customer_product
  ]    
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app_manager.id
  }
  statement  = "CREATE TABLE shoe_loyalty_levels(email STRING,total BIGINT,rewards_level STRING,PRIMARY KEY (email) NOT ENFORCED) WITH ('kafka.partitions' = '1');"
  properties = {
    "sql.current-catalog"  = confluent_environment.cc_handson_env.display_name
    "sql.current-database" = confluent_kafka_cluster.cc_kafka_cluster.display_name
  }
  rest_endpoint   =  confluent_flink_compute_pool.cc_flink_compute_pool.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink SQL: INSERT INTO shoe_loyalty_levels
# --------------------------------------------------------
resource "confluent_flink_statement" "insert_shoe_loyalty_levels" {
  depends_on = [
    resource.confluent_flink_statement.create_shoe_loyalty_levels
  ]    
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app_manager.id
  }
  statement  = "INSERT INTO shoe_loyalty_levels(email,total,rewards_level) SELECT email,SUM(sale_price) AS total,CASE WHEN SUM(sale_price) > 80000000 THEN 'GOLD' WHEN SUM(sale_price) > 7000000 THEN 'SILVER' WHEN SUM(sale_price) > 600000 THEN 'BRONZE' ELSE 'CLIMBING' END AS rewards_level FROM shoe_order_customer_product GROUP BY email;"
  properties = {
    "sql.current-catalog"  = confluent_environment.cc_handson_env.display_name
    "sql.current-database" = confluent_kafka_cluster.cc_kafka_cluster.display_name
  }
  rest_endpoint   =  confluent_flink_compute_pool.cc_flink_compute_pool.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink SQL: CREATE TABLE shoe_promotions
# --------------------------------------------------------
resource "confluent_flink_statement" "create_shoe_promotions" {
  depends_on = [
    resource.confluent_environment.cc_handson_env,
    resource.confluent_schema_registry_cluster.cc_sr_cluster,
    resource.confluent_kafka_cluster.cc_kafka_cluster,
    resource.confluent_connector.datagen_products,
    resource.confluent_connector.datagen_customers,
    resource.confluent_connector.datagen_orders,
    resource.confluent_flink_compute_pool.cc_flink_compute_pool,
    resource.confluent_flink_statement.create_shoe_products_keyed,
    resource.confluent_flink_statement.create_shoe_customers_keyed,
    resource.confluent_flink_statement.create_shoe_order_customer,
    resource.confluent_flink_statement.create_shoe_order_customer_product,
    resource.confluent_flink_statement.create_shoe_loyalty_levels
  ]    
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app_manager.id
  }
  statement  = "CREATE TABLE shoe_promotions(email STRING,promotion_name STRING,PRIMARY KEY (email) NOT ENFORCED) WITH ('kafka.partitions' = '1');"
  properties = {
    "sql.current-catalog"  = confluent_environment.cc_handson_env.display_name
    "sql.current-database" = confluent_kafka_cluster.cc_kafka_cluster.display_name
  }
  rest_endpoint   =  confluent_flink_compute_pool.cc_flink_compute_pool.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink SQL: Insert into shoe_promotions
# --------------------------------------------------------
resource "confluent_flink_statement" "insert_shoe_promotion" {
  depends_on = [
    resource.confluent_flink_statement.create_shoe_promotions
  ]    
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app_manager.id
  }
  statement  = "EXECUTE STATEMENT SET BEGIN INSERT INTO shoe_promotions SELECT email, 'next_free' AS promotion_name FROM shoe_order_customer_product WHERE brand = 'Jones-Stokes' GROUP BY email HAVING COUNT(*) % 10 = 0; INSERT INTO shoe_promotions SELECT  email, 'bundle_offer' AS promotion_name FROM shoe_order_customer_product WHERE brand IN ('Braun-Bruen', 'Will Inc') GROUP BY email HAVING COUNT(DISTINCT brand) = 2 AND COUNT(brand) > 10; END;"
  properties = {
    "sql.current-catalog"  = confluent_environment.cc_handson_env.display_name
    "sql.current-database" = confluent_kafka_cluster.cc_kafka_cluster.display_name
  }
  rest_endpoint   =  confluent_flink_compute_pool.cc_flink_compute_pool.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}
