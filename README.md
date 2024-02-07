# Confluent Cloud - Open Source Apache Flink SQL Shoe Store Workshop

This workshop is intended to give you a taste of low code open source Apache Flink capabilities. We are using Confluent Cloud to setup kafka source.

[Note and Credits] We are using fork of Jan Svoboda's [repo](https://github.com/griga23/shoe-store). This repo demonstrates the same example using Confluent Cloud completely. After completing this excercise you are highly encouraged to try Confluent Flink.

 This workshop is based on a shoe store example where three topics `shoe_orders`, `shoe_products` and `shoe_customers` will be auto populated for you through datagen connectors. Terraform is used to create this infrastructure.
 
 We will then setup a local Flink cluster using docker-compose runtime enviornment. We will use sql-client to submit our jobs to the job manager. Just to know the hetrogeneous connectivity I have added one example under advanced topic to read from a MYSQL DB in jdbc and cdc mode. 

The overall architecture looks like this at a high level.

![alt text](/images/overallarch.png)


Kindly follow the links in sequence:

1. [StartHere](StartHere.md)
2. [OpenSourceFlinkLab](OpenSourceFlinkLab.md)

Happy Learning!

Let me know your questions here:
ravi_tomar@persistent.com 

[![text](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ravitomar7)


