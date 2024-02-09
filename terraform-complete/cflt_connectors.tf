# --------------------------------------------------------
# Service Accounts (Connectors)
# --------------------------------------------------------
resource "confluent_service_account" "connectors" {
  display_name = "connectors-${random_id.id.hex}"
  description  = local.description
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Access Control List (ACL)
# --------------------------------------------------------
resource "confluent_kafka_acl" "connectors_source_describe_cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  host          = "*"
  rest_endpoint = confluent_kafka_cluster.cc_kafka_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka_cluster_key.id
    secret = confluent_api_key.app_manager_kafka_cluster_key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}
# Demo topics
resource "confluent_kafka_acl" "connectors_source_create_topic_demo" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "shoe_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "CREATE"
  permission    = "ALLOW"
  host          = "*"
  rest_endpoint = confluent_kafka_cluster.cc_kafka_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka_cluster_key.id
    secret = confluent_api_key.app_manager_kafka_cluster_key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_kafka_acl" "connectors_source_write_topic_demo" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "shoe_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "WRITE"
  permission    = "ALLOW"
  host          = "*"
  rest_endpoint = confluent_kafka_cluster.cc_kafka_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka_cluster_key.id
    secret = confluent_api_key.app_manager_kafka_cluster_key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_kafka_acl" "connectors_source_read_topic_demo" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "shoe_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "READ"
  permission    = "ALLOW"
  host          = "*"
  rest_endpoint = confluent_kafka_cluster.cc_kafka_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka_cluster_key.id
    secret = confluent_api_key.app_manager_kafka_cluster_key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}
# DLQ topics (for the connectors)
resource "confluent_kafka_acl" "connectors_source_create_topic_dlq" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "dlq-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "CREATE"
  permission    = "ALLOW"
  host          = "*"
  rest_endpoint = confluent_kafka_cluster.cc_kafka_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka_cluster_key.id
    secret = confluent_api_key.app_manager_kafka_cluster_key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_kafka_acl" "connectors_source_write_topic_dlq" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "dlq-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "WRITE"
  permission    = "ALLOW"
  host          = "*"
  rest_endpoint = confluent_kafka_cluster.cc_kafka_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka_cluster_key.id
    secret = confluent_api_key.app_manager_kafka_cluster_key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_kafka_acl" "connectors_source_read_topic_dlq" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "dlq-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "READ"
  permission    = "ALLOW"
  host          = "*"
  rest_endpoint = confluent_kafka_cluster.cc_kafka_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka_cluster_key.id
    secret = confluent_api_key.app_manager_kafka_cluster_key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}
# Consumer group
resource "confluent_kafka_acl" "connectors_source_consumer_group" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  resource_type = "GROUP"
  resource_name = "connect"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "READ"
  permission    = "ALLOW"
  host          = "*"
  rest_endpoint = confluent_kafka_cluster.cc_kafka_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka_cluster_key.id
    secret = confluent_api_key.app_manager_kafka_cluster_key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Credentials / API Keys
# --------------------------------------------------------
resource "confluent_api_key" "connector_key" {
  display_name = "connector-${var.cc_cluster_name}-key-${random_id.id.hex}"
  description  = local.description
  owner {
    id          = confluent_service_account.connectors.id
    api_version = confluent_service_account.connectors.api_version
    kind        = confluent_service_account.connectors.kind
  }
  managed_resource {
    id          = confluent_kafka_cluster.cc_kafka_cluster.id
    api_version = confluent_kafka_cluster.cc_kafka_cluster.api_version
    kind        = confluent_kafka_cluster.cc_kafka_cluster.kind
    environment {
      id = confluent_environment.cc_handson_env.id
    }
  }
  depends_on = [
    confluent_kafka_acl.connectors_source_create_topic_demo,
    confluent_kafka_acl.connectors_source_write_topic_demo,
    confluent_kafka_acl.connectors_source_read_topic_demo,
    confluent_kafka_acl.connectors_source_create_topic_dlq,
    confluent_kafka_acl.connectors_source_write_topic_dlq,
    confluent_kafka_acl.connectors_source_read_topic_dlq,
    confluent_kafka_acl.connectors_source_consumer_group,
  ]
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Create Kafka topics for the DataGen Connectors
# --------------------------------------------------------
resource "confluent_kafka_topic" "products" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  topic_name    = "shoe_products"
  partitions_count   = 1
  rest_endpoint = confluent_kafka_cluster.cc_kafka_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka_cluster_key.id
    secret = confluent_api_key.app_manager_kafka_cluster_key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_kafka_topic" "customers" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  topic_name    = "shoe_customers"
  partitions_count   = 1
  rest_endpoint = confluent_kafka_cluster.cc_kafka_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka_cluster_key.id
    secret = confluent_api_key.app_manager_kafka_cluster_key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_kafka_topic" "orders" {
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  topic_name    = "shoe_orders"
  partitions_count   = 1
  rest_endpoint = confluent_kafka_cluster.cc_kafka_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka_cluster_key.id
    secret = confluent_api_key.app_manager_kafka_cluster_key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Create Tags
# --------------------------------------------------------
resource "confluent_tag" "pii" {
  schema_registry_cluster {
    id = confluent_schema_registry_cluster.cc_sr_cluster.id
  }
  rest_endpoint = confluent_schema_registry_cluster.cc_sr_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.sr_cluster_key.id
    secret = confluent_api_key.sr_cluster_key.secret
  }

  name = "PII"
  description = "PII tag"

  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_tag" "public" {
  schema_registry_cluster {
    id = confluent_schema_registry_cluster.cc_sr_cluster.id
  }
  rest_endpoint = confluent_schema_registry_cluster.cc_sr_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.sr_cluster_key.id
    secret = confluent_api_key.sr_cluster_key.secret
  }

  name = "Public"
  description = "Public tag"

  lifecycle {
    prevent_destroy = false
  }
}
# --------------------------------------------------------
# Bind Tags to Topics
# --------------------------------------------------------
resource "confluent_tag_binding" "customers" {
  schema_registry_cluster {
    id = confluent_schema_registry_cluster.cc_sr_cluster.id
  }
  rest_endpoint = confluent_schema_registry_cluster.cc_sr_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.sr_cluster_key.id
    secret = confluent_api_key.sr_cluster_key.secret
  }

  tag_name = "PII"
  entity_name = "${confluent_schema_registry_cluster.cc_sr_cluster.id}:${confluent_kafka_cluster.cc_kafka_cluster.id}:${confluent_kafka_topic.customers.topic_name}"
  entity_type = "kafka_topic"

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_tag_binding" "products" {
  schema_registry_cluster {
    id = confluent_schema_registry_cluster.cc_sr_cluster.id
  }
  rest_endpoint = confluent_schema_registry_cluster.cc_sr_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.sr_cluster_key.id
    secret = confluent_api_key.sr_cluster_key.secret
  }

  tag_name = "Public"
  entity_name = "${confluent_schema_registry_cluster.cc_sr_cluster.id}:${confluent_kafka_cluster.cc_kafka_cluster.id}:${confluent_kafka_topic.products.topic_name}"
  entity_type = "kafka_topic"

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_tag_binding" "orders" {
  schema_registry_cluster {
    id = confluent_schema_registry_cluster.cc_sr_cluster.id
  }
  rest_endpoint = confluent_schema_registry_cluster.cc_sr_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.sr_cluster_key.id
    secret = confluent_api_key.sr_cluster_key.secret
  }

  tag_name = "Public"
  entity_name = "${confluent_schema_registry_cluster.cc_sr_cluster.id}:${confluent_kafka_cluster.cc_kafka_cluster.id}:${confluent_kafka_topic.orders.topic_name}"
  entity_type = "kafka_topic"

  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Connectors
# --------------------------------------------------------

# datagen_products
resource "confluent_connector" "datagen_products" {
  environment {
    id = confluent_environment.cc_handson_env.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  config_sensitive = {}
  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "${var.use_prefix}${var.cc_connector_dsoc_products_name}"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.connectors.id
    "kafka.topic"              = confluent_kafka_topic.products.topic_name
    "output.data.format"       = "AVRO"
    "quickstart"               = "SHOES"
    "tasks.max"                = "1"
    "max.interval"             = "500"
  }
  depends_on = [
    confluent_kafka_acl.connectors_source_create_topic_demo,
    confluent_kafka_acl.connectors_source_write_topic_demo,
    confluent_kafka_acl.connectors_source_read_topic_demo,
    confluent_kafka_acl.connectors_source_create_topic_dlq,
    confluent_kafka_acl.connectors_source_write_topic_dlq,
    confluent_kafka_acl.connectors_source_read_topic_dlq,
    confluent_kafka_acl.connectors_source_consumer_group,
  ]
  lifecycle {
    prevent_destroy = false
  }
}

# datagen_customers
resource "confluent_connector" "datagen_customers" {
  environment {
    id = confluent_environment.cc_handson_env.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  config_sensitive = {}
  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "${var.use_prefix}${var.cc_connector_dsoc_customers_name}"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.connectors.id
    "kafka.topic"              = confluent_kafka_topic.customers.topic_name
    "output.data.format"       = "AVRO"
    "quickstart"               = "SHOE_CUSTOMERS"
    "tasks.max"                = "1"
    "max.interval"             = "500"
  }
  depends_on = [
    confluent_kafka_acl.connectors_source_create_topic_demo,
    confluent_kafka_acl.connectors_source_write_topic_demo,
    confluent_kafka_acl.connectors_source_read_topic_demo,
    confluent_kafka_acl.connectors_source_create_topic_dlq,
    confluent_kafka_acl.connectors_source_write_topic_dlq,
    confluent_kafka_acl.connectors_source_read_topic_dlq,
    confluent_kafka_acl.connectors_source_consumer_group,
  ]
  lifecycle {
    prevent_destroy = false
  }
}

# datagen_orders
resource "confluent_connector" "datagen_orders" {
  environment {
    id = confluent_environment.cc_handson_env.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  config_sensitive = {}
  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "${var.use_prefix}${var.cc_connector_dsoc_orders_name}"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.connectors.id
    "kafka.topic"              = confluent_kafka_topic.orders.topic_name
    "output.data.format"       = "AVRO"
    "quickstart"               = "SHOE_ORDERS"
    "tasks.max"                = "1"
    "max.interval"             = "500"
  }
  depends_on = [
    confluent_kafka_acl.connectors_source_create_topic_demo,
    confluent_kafka_acl.connectors_source_write_topic_demo,
    confluent_kafka_acl.connectors_source_read_topic_demo,
    confluent_kafka_acl.connectors_source_create_topic_dlq,
    confluent_kafka_acl.connectors_source_write_topic_dlq,
    confluent_kafka_acl.connectors_source_read_topic_dlq,
    confluent_kafka_acl.connectors_source_consumer_group,
  ]
  lifecycle {
    prevent_destroy = false
  }
}
