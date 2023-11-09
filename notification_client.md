![image](terraform/img/confluent-logo-300-2.png)
# Build a notification client 
The beauty of an event streaming platform is, when you see the the results in real-time.
For we can build a simple notifcation client in Python, which will consume our promotion table and send notofcstion to your mobile device.

with FLink SQL we created a loyalty program and placed all promotion in one Table.
All events are stored now in topic show_promotions;

## Prereq
- Have Python 3 running
- install important python modules
- Demo Account for Pushover

Prepare your Python
```bash
python --version
# Python 3.9.6
# Install moduls
pip install confluent-kafka
pip install avro
pip install http.client
pip install urllib3
```
If you do not want to use Pushover, then use [Telegram](https://github.com/ora0600/apache-kafka-as-a-service-by-confluent/tree/master/webinar1). In my github repositories I do have some samples around Telegram. Signup to Pushover you will get free access for a week or so.

* Install PushOver App on you iPhone
* Login into [Pushover](https://pushover.net/login)
Add your Device
Create a new Application (enter the name e.g. Shoe Promotions is enough) and copy the token and your user key
Change token in Python script Change Python script push2ios.py:
```bash
# change 
urllib.parse.urlencode({
            "token": "ABCD",
            "user": "EFGH",
```
You also need to access the confluent cloud cluster. Normally a Service Account with API Key and is allowed to read  the topic show_promotions. In our Hands-on we will use the client process, which generate an API Key on our User Account:
* go to client (left side) and click `add new client` and choose python
* create API Key for Cluster click `Create Kafka cluster API Key`, set description `Python API KEY`
* create API Key for Schema Registry click `Create Schema Registry API Key`, set description `Python Schema API KEY`
* click `Copy` and you have the complete configuration to connect to your confluent cloud cluster, store this into file `client.properties`
```bash
# copy the values into config dict
config = {
     'bootstrap.servers': '<bootstrap.servers>',     
     'security.protocol': 'SASL_SSL',
     'sasl.mechanisms': 'PLAIN',
     'sasl.username': '<sasl.username>', 
     'sasl.password': 'sasl.password',
     'group.id': 'shoe_promotions',
     'auto.offset.reset': 'latest'}
```

## Python Notifcation Service
start notification service and check what is happening on your iPhone
```bash
python push2ios.py
...
```

The notification looks like this (only with content):
![image](terraform/img/notification_iphone.png)

End Lab