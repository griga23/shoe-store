import io
from confluent_kafka import Consumer
import http.client, urllib
from avro.io import DatumReader, BinaryDecoder
import avro.schema

schemavalue = avro.schema.parse(open("schema/schema-shoe_promotions-value-v1.avsc").read())
readervalue = DatumReader(schemavalue)
schemakey = avro.schema.parse(open("schema/schema-shoe_promotions-key-v1.avsc").read())
readerkey = DatumReader(schemakey)

def decode_value(msg_value):
    message_bytes = io.BytesIO(msg_value)
    decoder = BinaryDecoder(message_bytes)
    event_dict = readervalue.read(decoder)
    return event_dict

def decode_key(msg_value):
    message_bytes = io.BytesIO(msg_value)
    decoder = BinaryDecoder(message_bytes)
    event_dict = readerkey.read(decoder)
    return event_dict


# Consume from Topic
from confluent_kafka import Consumer

config = {
     'bootstrap.servers': '<add you bootstrap server here>',     
     'security.protocol': 'SASL_SSL',
     'sasl.mechanisms': 'PLAIN',
     'sasl.username': '<add your KEY here>', 
     'sasl.password': '<add your SECRET here>',
     'group.id': 'shoe_promotions',
     'auto.offset.reset': 'latest'}

consumer = Consumer(config)
consumer.subscribe(["shoe_promotions"])
# Here you can change the numbers. Pushover is not for free.
max_message=2
message_count=1
try:
    while True:
        msg = consumer.poll(1.0)
        if msg is None:
            continue
        if msg.error():
            print("Consumer error: {}".format(msg.error()))
            continue
        if msg is not None and msg.error() is None:
            # send message to IOS 
            msg_value = msg.value()
            msg_key = msg.key()
            if message_count <= max_message and msg_value is not None: 
                eventvalue_dict = decode_value(msg_value)            
                eventkey_dict = decode_key(msg_key)            
                who = eventkey_dict.get('email')
                what = eventvalue_dict.get('promotion_name')
                message = 'Promotion: ' + str(what) + ' for Email: ' + str(who) + ' ready to execute!'
                print(message)
                conn = http.client.HTTPSConnection("api.pushover.net:443")
                conn.request("POST", "/1/messages.json",
                urllib.parse.urlencode({
                    "token": "<add your PUSHOVER Token here>",
                    "user": "<add your USER KEY here>",
                    "message": message,
                }), { "Content-type": "application/x-www-form-urlencoded" })
                response=conn.getresponse()
                print('Status: %s Reason:%s' % (response.status, response.reason))
                conn.close()
                message_count=message_count + 1
except KeyboardInterrupt:
    pass
finally:
    consumer.close()



