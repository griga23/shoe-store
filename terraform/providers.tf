terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.54.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.1"
    }
  }
}

provider "confluent" {
  # Environment variables to be set on ./env_credentials.sh (see README.md)
  #CONFLUENT_CLOUD_API_KEY    = "XXXXX"
  #CONFLUENT_CLOUD_API_SECRET = "XXXXX"
}

data "external" "env_vars" {
  program = ["${path.module}/shell/env_terraform.sh"]
}
