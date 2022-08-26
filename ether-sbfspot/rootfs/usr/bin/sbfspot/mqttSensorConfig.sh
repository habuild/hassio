#!/usr/bin/with-contenv bashio

#  Publish MQTT sensors for Config discovery.

set -x

CONFIG_PATH=/data/options.json

#  Wait for for first publish to get serial

PLANTNAME="$(jq --raw-output '.Plantname' $CONFIG_PATH)"

MQTT_Host="$(jq --raw-output '.MQTT_Host' $CONFIG_PATH)"
MQTT_User="$(jq --raw-output '.MQTT_User' $CONFIG_PATH)"
MQTT_Pass="$(jq --raw-output '.MQTT_Pass' $CONFIG_PATH)"
MQTT_Topic="$(jq --raw-output '.MQTT_Topic' $CONFIG_PATH)"
MQTT_Data="$(jq --raw-output '.MQTT_Data' $CONFIG_PATH)"

echo "$MQTT_Host"
echo "$MQTT_User"
echo "$MQTT_Pass"
echo "$MQTT_Topic"
echo "$MQTT_Data"


#  topic= insert into existing topic /sensor/ varJson

#  InvName delete
#  -h {host} -u {MQTT_User} -P {MQTT_Pass} -t {topic} -m
/usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"InvName/config -m "" -d
