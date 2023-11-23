output "cc_compute_pool_name" {
  value = confluent_flink_compute_pool.cc_flink_compute_pool.id
}

output "cc_hands_env" {
  description = "Confluent Cloud Environment ID"
  value       = resource.confluent_environment.cc_handson_env.id
}

output "cc_handson_sr" {
  description = "CC Schema Registry Region"
  value       = data.confluent_schema_registry_region.cc_handson_sr
}

output "cc_sr_cluster" {
  description = "CC SR Cluster ID"
  value       = resource.confluent_schema_registry_cluster.cc_sr_cluster.id
}

output "cc_kafka_cluster" {
  description = "CC Kafka Cluster ID"
  value       = resource.confluent_kafka_cluster.cc_kafka_cluster.id
}

output "datagen_products" {
  description = "CC Datagen Products Connector ID"
  value       = resource.confluent_connector.datagen_products.id
}

output "datagen_customers" {
  description = "CC Datagen Customers Connector ID"
  value       = resource.confluent_connector.datagen_customers.id
}
output "datagen_orders" {
  description = "CC Datagen Orders Connector ID"
  value       = resource.confluent_connector.datagen_orders.id
}