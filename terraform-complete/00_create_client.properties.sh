#!/bin/bash

export srkey=$(echo -e "$(terraform output -raw SRKey)")
#echo $srkey
export srsecret=$(echo -e "$(terraform output -raw SRSecret)")
#echo $srsecret
export clientkey=$(echo -e "$(terraform output -raw ClientKey)")
#echo $clientkey
export clientsecret=$(echo -e "$(terraform output -raw ClientSecret)")
#echo $clientsecret
export bootstrap=$(echo -e "$(terraform output -raw cc_kafka_cluster_bootsrap)")
#echo $bootstrap
export srurl=$(echo -e "$(terraform output -raw cc_sr_cluster_endpoint)")
#echo $srurl


echo "
bootstrap.servers=$bootstrap
security.protocol=SASL_SSL
sasl.mechanisms=PLAIN
sasl.username=$clientkey
sasl.password=$clientsecret
session.timeout.ms=45000
schema.registry.url=$srurl
basic.auth.credentials.source=USER_INFO
basic.auth.user.info=$srkey:$srsecret
group.id=shoe_promotions
auto.offset.reset=earliest" > client.properties

cat client.properties

echo "Start IOS Notification Client: python push2ios.py -f client.properties -t shoe_promotions"
