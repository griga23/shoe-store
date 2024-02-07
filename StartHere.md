# STEP 1: Setup Confluent Enviournment using the below instructions.

[You can skip this section if you have local setup of kafka running, but then you will have to replace all bootstrap, credentials etc yourself. You also will need to populate your topics. We recommend you create a confluent account to get started easily and switch later]

Sign-up with Confluent Cloud is very easy and you will get a $400 budget for this Hands-on Workshop.

If you already have Confluent Cloud account use CC60COMM to get 60$ free credits.[Thanks Ena for this]

Let terraform create infrastructure for us, follow this [guide](terraform/README.md).

# Grab your Credentials

Once you are done setting up your Confluent Cloud infrastructure using the above steps, you would see, we will now grab few properties we will need to communicate to Confluent Cloud from our local flink: 

![alt text](/images/tfop.png)

Grab these two id's: `cc_hands_env`, `cc_kafka_cluster`, 

Grab these two from terminal: 
`terraform output -raw SRSecret`
`terraform output -raw SRKey`

Lastly we will need a global API key to avoid any Authorization issues:

Visit Confluent Cloud -> Env -> Cluster -> API Keys(Left Nav)->Add Keys->Global Access-> Give it a name and Download

OR 

You can directly navigate here after login to confluent cloud:
https://confluent.cloud/environments/<cc_hands_env>/clusters/<cc_kafka_cluster>

`[Note: This is not recommended in production env, we should use service accounts with granual permissions]`

Also copy the `Schema Registry URL` by visiting, you will find Stream Governance Endpoint on bottom right here:

https://confluent.cloud/environments/<cc_hands_env>/clusters

You will deploy this in your Confluent Cloud account:

![image](/terraform/img/terraform_deployment.png)

You will need following values to perform the labs:
1. username (Gloabal Key download from poral)
2. password (Gobal Secret downloaded from portal)
3. value.avro-confluent.url (fetched from env endpoint)
4. value.avro-confluent.basic-auth.user-info (Format like this: SRKey:SRSecret)

# STEP 2: Prerequisite for Open Source Flink
For performinbg labs based on Open Source Apaceh Flink, we need a local Flink Cluster running:

- Docker
- Docker-compose

## Setup using Docker

- Make sure you have docker engine installed and docker-compse in your path.
- In  your terminal, Goto [docker-compose.yml](/flink/docker/docker-compose.yml) and type:
`docker-compose run sql-client`
- It will take some time and will get you started with sql-client, as we will be doing low-code sql examples here.

![Alt text](/images/image.png)

You will need to create following 3 topics in kafka(if not already created, they should have been created though):

* `shoe_order_customer_product_os`
* `shoe_products_keyed_os`
* `shoe_customers_keyed_os`

End of Flink prerequisites, continue with [LAB](OpenSourceFlinkLab.md).
----
