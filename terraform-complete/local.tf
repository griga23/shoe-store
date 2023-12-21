resource "null_resource" "flink_sql_statements" {
  depends_on = [
    resource.confluent_environment.cc_handson_env,
    resource.confluent_schema_registry_cluster.cc_sr_cluster,
    resource.confluent_kafka_cluster.cc_kafka_cluster,
    resource.confluent_connector.datagen_products,
    resource.confluent_connector.datagen_customers,
    resource.confluent_connector.datagen_orders,
    resource.confluent_flink_compute_pool.cc_flink_compute_pool
  ]
  provisioner "local-exec" {
    command = "./00_create_client.properties.sh"
  }
}
