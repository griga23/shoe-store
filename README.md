# Confluent Cloud - Flink SQL Shoe Store Workshop
Imagine you are running a shoe shop. You want to get an overview of shoe sales, understand your customers better, and you'd like to start a loyalty program, too. Luckily, you already use Confluent Cloud as a backbone for your data. This means you can leverage Confluent Flink SQL for some ad-hoc analyses, and determine which of your customers are currently eligible for a free pair of shoes!

For a good preparation and first understanding, please read this [Guide to Flink SQL: An In-Depth Exploration](https://www.confluent.io/blog/getting-started-with-apache-flink-sql/) . 
If you want a refresher of the Kafka basics, we highly recommend our [Kafka Fundamentals Workshop](https://www.confluent.io/resources/online-talk/fundamentals-workshop-apache-kafka-101/) .

In this workshop, we will build a Shoe Store Loyalty Engine. We will use Flink SQL in Confluent Cloud on AWS or Azure (GCP coming soon). YOu can find an architecture diagram below.

![image](terraform/img/Flink_Hands-on_Workshop_Complete.png)



## Required Confluent Cloud Resources 
The hands-on consists of two labs (see below), and these require Confluent Cloud infrastructure that has to be provisioned before we can start with the actual workshop. 
 *  Preparation of required Confluent Cloud Resources: You can either create your infrastructure manually with this [guide](prereq.md) or you can use Terraform for an automatated creation: [Terraform guide](terraform/README.md).

 *  The complete finished Hands-on can be created automatically with terraform as well. Please use this [guide](terraform-complete/README.md)

## Workshop Labs
  *  [Lab1](lab1.md): Flink Tables, Select Statements, Aggregations, Time Windows 
  *  [Lab2](lab2.md): Join Statements, Data Enrichment, Statement Sets  

Together, the Labs will design a loyality program within Flink SQL. You can see the complete Mapping of dynamic Tables and Topics in the next graphic.

![image](terraform/img/flink_sql_diagram.png)

Optional:
You can deploy the complete finished workshop with Terraform. Please follow this [guide](terraform-complete/README.md) for a complete and finished Loyalty-Program. Only the notification need to be setup manually.

## Notification Client 
You can find the Python Notification client in this [guide.](notification_client.md) 

## Costs of this Confluent Cloud - Flink SQL Shoe Store Workshop
The lab execution do not consume much money. We calculated an amount of less than 10$ for a couple of hours of testing. If you create the cluster one day before, we recommend to pause all connectors.

