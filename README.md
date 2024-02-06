# Confluent Cloud - Open Source Apache Flink SQL Shoe Store Workshop

This workshop is intended to give you a taste of low code open source Apache Flink capabilities. We are using Confluent Cloud to setup kafka source.

[Note and Credits] We are using fork of Jan Svoboda's [repo](https://github.com/griga23/shoe-store). This repo demonstrates the same example using Confluent Cloud completely. After completing this excercise you are highly encouraged to try Confluent Flink.

Terraform will be used to create the infrastructure. This workshop is be based on a shoe store example where three topics `shoe_orders`, `shoe_products` and `shoe_customers` will be auto populated for you through datagen connectors. We will setup local Flink using docker-compose runtime enviornment. For one example we will also need a mysql container.

The overall architecture looks like this at a high level.

![alt text](/images/overallarch.png)


Kindly follow the links in sequence:

1. [StartHere](StartHere.md)
2. [OpenSourceFlinkLab](OpenSourceFlinkLab.md)

Happy Learning!

Let me know your questions here:
ravi_tomar@persistent.com 

