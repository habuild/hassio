#!/usr/bin/with-contenv bashio

#  Publish MQTT sensors for Config discovery.

CONFIG_PATH=/data/options.json

#  Wait for for first publish to get serial

CONFIG_MQTT_HOST="$(jq --raw-output '.MQTT_Host' $CONFIG_PATH)"
CONFIG_MQTT_USER="$(jq --raw-output '.MQTT_User' $CONFIG_PATH)"
CONFIG_MQTT_PASS="$(jq --raw-output '.MQTT_Pass' $CONFIG_PATH)"
CONFIG_MQTT_TOPIC="$(jq --raw-output '.MQTT_Topic' $CONFIG_PATH)"
CONFIG_MQTT_DATA="$(jq --raw-output '.MQTT_Data' $CONFIG_PATH)"

echo "$MQTT_HOST"
echo "$MQTT_USER
echo "$MQTT_PASS
echo "$MQTT_TOPIC"
echo "$MQTT_DATA"


#  topic= insert into existing topic /sensor/ varJson

#  InvName delete
#  -h {host} -u {MQTT_User} -P {MQTT_Pass} -t {topic} -m
/usr/bin/mosquitto_pub -h "$MQTT_HOST" -u "$MQTT_USER" -P "$MQTT_PASS" -t homeassistant/sensor/sbfspot_HasSMA5000TL-20/sbfspot_2100443252InvName/config -m "" -d
