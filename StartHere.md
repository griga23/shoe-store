# STEP 1: Setup Confluent Enviournment using the below instructions.

[You can skip this section if you have local setup of kafka running, but then you will have to replace all bootstrap, credentials etc yourself. We recommend you create a confluent account to get started easily and switch later]

[Note and Credits] We are using fork of Jan Svoboda's [repo](https://github.com/griga23/shoe-store). After completing this excercise you are highly encouraged to try Confluent Flink with the same example.

Sign-up with Confluent Cloud is very easy and you will get a $400 budget for our Hands-on Workshop.

If you already have Confluent Cloud account use CC60COMM to get 60$ free credits.[Thanks Ena for this]

Let terraform create infrastructure for us, follow this [guide](terraform/README.md).

You will deploy this in your Confluent Cloud account:

![image](/terraform/img/terraform_deployment.png)

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

You will need to create following 3 topics in kafka:

`shoe_order_customer_product_os`



End of Flink prerequisites, continue with [LAB 1](osflinklab1.md).
----
