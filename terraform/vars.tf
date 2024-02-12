locals {
  description = "Resource created using terraform"
}

# --------------------------------------------------------
# This 'random_id_4' will make whatever you create (names, etc)
# unique in your account.
# --------------------------------------------------------
resource "random_id" "id" {
  byte_length = 4
}

# ----------------------------------------
# Generic prefix to use in a common organization
# ----------------------------------------
variable "use_prefix" {
  description = "If a common organization is being used, and default names are not updated, choose a prefix"
  type        = string
  default     = ""
}

# ----------------------------------------
# Confluent Cloud Kafka cluster variables
# ----------------------------------------
variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "cc_cloud_provider" {
  type    = string
  default = "AWS"
}

variable "cc_cloud_region" {
  type    = string
  default = "eu-central-1"
}

variable "cc_env_name" {
  type    = string
  default = "flink_handson_terraform"
}

variable "cc_cluster_name" {
  type    = string
  default = "cc_handson_cluster"
}

variable "cc_availability" {
  type    = string
  default = "SINGLE_ZONE"
}

# ------------------------------------------
# Confluent Cloud Schema Registry variables
# ------------------------------------------
variable "sr_cloud_provider" {
  type    = string
  default = "AWS"
}

variable "sr_cloud_region" {
  type    = string
  default = "eu-central-1"
}

variable "sr_package" {
  type    = string
  default = "ESSENTIALS"
}

# --------------------------------------------
# Confluent Cloud Connectors name
# --------------------------------------------
variable "cc_connector_dsoc_products_name" {
  type    = string
  default = "DSoC_products"
}

variable "cc_connector_dsoc_customers_name" {
  type    = string
  default = "DSoC_customers"
}

variable "cc_connector_dsoc_orders_name" {
  type    = string
  default = "DSoC_orders"
}