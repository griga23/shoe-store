#!/usr/bin/env python
# =============================================================================
#
# Helper module
#
# =============================================================================

import argparse, sys
from confluent_kafka import avro, KafkaError
from jproperties import Properties

pushover_configs = Properties()
with open('pushover.properties', 'rb') as config_file:
    pushover_configs.load(config_file)

email_schema = """
{
  "fields": [
    {
      "name": "email",
      "type": "string"
    }
  ],
  "name": "record",
  "namespace": "org.apache.flink.avro.generated",
  "type": "record"
}
"""

class Email(object):
    """
        Name stores the deserialized Avro record for the Kafka key.
    """

    # Use __slots__ to explicitly declare all data members.
    __slots__ = ["email"]

    def __init__(self, email=None):
        self.email = email

    @staticmethod
    def dict_to_email(obj, ctx):
        return Email(obj['email'])

    @staticmethod
    def email_to_dict(email, ctx):
        return Email.to_dict(email)

    def to_dict(self):
        """
            The Avro Python library does not support code generation.
            For this reason we must provide a dict representation of our class for serialization.
        """
        return dict(email=self.email)


# Schema used for serializing Count class, passed in as the Kafka value
promotion_schema = """
{
  "fields": [
    {
      "default": null,
      "name": "promotion_name",
      "type": [
        "null",
        "string"
      ]
    }
  ],
  "name": "record",
  "namespace": "org.apache.flink.avro.generated",
  "type": "record"
}
"""


class Promotion(object):
    """
        Count stores the deserialized Avro record for the Kafka value.
    """

    # Use __slots__ to explicitly declare all data members.
    __slots__ = ["promotion_name"]

    def __init__(self, promotion_name=None):
        self.promotion_name = promotion_name

    @staticmethod
    def dict_to_promotion(obj, ctx):
        return Promotion(obj['promotion_name'])

    @staticmethod
    def promotion_to_dict(promotion_name, ctx):
        return Promotion.to_dict(promotion_name)

    def to_dict(self):
        """
            The Avro Python library does not support code generation.
            For this reason we must provide a dict representation of our class for serialization.
        """
        return dict(promotion_name=self.promotion_name)

def parse_args():
    """Parse command line arguments"""

    parser = argparse.ArgumentParser(
             description="Confluent Python Client example to consume messages to Confluent Cloud")
    parser._action_groups.pop()
    required = parser.add_argument_group('required arguments')
    required.add_argument('-f',
                          dest="config_file",
                          help="path to Confluent Cloud configuration file",
                          required=True)
    required.add_argument('-t',
                          dest="topic",
                          help="topic name",
                          required=True)
    args = parser.parse_args()

    return args


def read_ccloud_config(config_file):
    """Read Confluent Cloud configuration for librdkafka clients"""

    conf = {}
    with open(config_file) as fh:
        for line in fh:
            line = line.strip()
            if len(line) != 0 and line[0] != "#":
                parameter, value = line.strip().split('=', 1)
                conf[parameter] = value.strip()

    return conf


def pop_schema_registry_params_from_config(conf):
    """Remove potential Schema Registry related configurations from dictionary"""

    conf.pop('schema.registry.url', None)
    conf.pop('basic.auth.user.info', None)
    conf.pop('basic.auth.credentials.source', None)

    return conf


