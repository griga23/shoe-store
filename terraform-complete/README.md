![image](img/confluent-logo-300-2.png)

# Finished Workshop Deployment via terraform

This is the deployment of confluent cloud infrastructure resources including all finished LABS from the Flink SQL Hands-on Workshop.
We will deploy with terraform:
 - Environment:
     - Name: flink_hands-on+UUID
     - with enabled Schema Registry (essentails) in AWS region (eu-central-1)
 - Confluent Cloud Basic Cloud: cc_handson_cluster
    - in AWS in region (eu-central-1)
 - Connectors:
    - Datagen for shoe_products
    - Datagen for shoe_customers 
    - Datagen for show_orders
 - Service Accounts
    - app_manager-XXXX with Role EnvironmentAdmin
    - sr-XXXX with Role EnvironmentAdmin
    - clients-XXXX with Role CloudClusterAdmin
    - connectors-XXXX
 - Flink Compute Pool cc_handson_flink in AWS region eu-central-1 with 5 CFUs
 - all flink SQL statments from [lab1](../lab1.md) and [lab2](../lab2.md)

![image](img/Flink_Hands-on_Workshop_Complete.png)

# Pre-requisites
- User account on [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree)
- Local install of [Terraform](https://www.terraform.io) (details below)
- Local install of [jq](https://jqlang.github.io/jq/download) (details below)
- Local install Confluent CLI, [install the cli](https://docs.confluent.io/confluent-cli/current/install.html) 
- Create API Key in Confluent Cloud via CLI:
    ```bash
    confluent login
    confluent api-key create --resource cloud --description "API for terraform"
    # It may take a couple of minutes for the API key to be ready.
    # Save the API key and secret. The secret is not retrievable later.
    #+------------+------------------------------------------------------------------+
    #| API Key    | <your generated key>                                             |
    #| API Secret | <your generated secret>                                          |
    #+------------+------------------------------------------------------------------+
    ``````
 - Or visit the [Cloud API Key](https://confluent.cloud/settings/api-keys) page to create a Cloud API Key for your user, if you don't have any yet.

# Installation (only need to do that once)

## Install Terraform on MacOS
```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew update
brew upgrade hashicorp/tap/terraform
```
If you are running Windows, please use this [guide](https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-windows-bash?tabs=bash) <br>
If you are running on Ubuntu (or WSL2 with Ubuntu), please use this [guide](https://computingforgeeks.com/how-to-install-terraform-on-ubuntu/)

This tutorial was tested with Terraform v1.6.4 and confluent terraform provider 1.55.0 . To upgrade terraform on MacOS use
```bash
brew upgrade terraform
```
Or download new version from [website](https://www.terraform.io/downloads.html)

## Install jq
```
brew install jq
```
If you are running Windows, download from [here](https://jqlang.github.io/jq/download/) <br>
If you are running on Ubuntu (or WSL2 with Ubuntu), please follow the instructions [here](https://lindevs.com/install-jq-on-ubuntu)

## Install Confluent Cli
Please install the Confluent CLI, with these [instructions](https://docs.confluent.io/confluent-cli/current/install.html) 
```
brew install confluentinc/tap/cli
```

This tutorial was tested with Confluent CLI v3.41.0.

# Provision services for the demo

## Set environment variables
- Add your API key to the Terraform variables by creating a tfvars file
```bash
cat > $PWD/terraform-complete/terraform.tfvars <<EOF
confluent_cloud_api_key = "{Cloud API Key}"
confluent_cloud_api_secret = "{Cloud API Key Secret}"
EOF
```

## Deploy via terraform
run the following commands:
```Bash
cd ./terraform
terraform init
terraform plan
terraform apply
terraform output -json
# for sensitive data
terraform output -raw SRSecret
terraform output -raw AppManagerSecret
terraform output -raw ClientSecret
```

Please check whether the terraform execution went without errors.

There are two ways to continue, either over shell or over UI. If you want to start with the shell, please type:

```bash
eval $(echo -e "confluent flink shell --compute-pool $(terraform output cc_compute_pool_name) --environment $(terraform output cc_hands_env)")
```

You can copy the login instruction also from the UI.

To continue with the UI:
 - Access Confluent Cloud WebUI: https://confluent.cloud/login
 - Access your Environment: `flink_handson_terraform-XXXXXXXX`
 - Select tab `Flink (preview)`
 - Access your Flink Compute Pool: `standard_compute_pool-XXXXXXXX`
 - Click `Open SQL workspace`
 - Make sure to select:
   - Catalog: `flink_handson_terraform-XXXXXXXX`
   - Database: `cc-handson-cluster`

You deployed:

![image](img/Flink_Hands-on_Workshop_Complete.png)

All Labs are deployed and running, please check via [Confluent Console](https://confluent.cloud/login).
For the last lab [Notification Client](/../notification_client.md) a `client.prperties` will be generation. Take this file to run the [Notification Client](/../notification_client.md).
A last optional lab would to configure and run the [Notification Client](/../notification_client.md)

# Destroy the hands.on infrastructure
```bash
terraform destroy
```
There could be a conflict destroying everything with our Tags. In this case destroy again via terraform.
```bash
#╷
#│ Error: error deleting Tag "<tagID>/PII": 409 Conflict
#│ 
#│ 
#╵
#╷
#│ Error: error deleting Tag "<tagID>/Public": 409 Conflict
#│ 
#│ 
#╵
# destroy again
terraform destroy
``` 
