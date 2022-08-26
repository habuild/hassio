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

#  make set config

cp /usr/bin/sbfspot/SBFspot.cfg /usr/bin/sbfspot/SetConfig.cfg
sed -i 's/MQTT_Data / MQTT_Data=InvSerial,InvName,InvClass,InvType,InvSwVer /g' /usr/bin/sbfspot/SetConfig.cfg

/usr/bin/sbfspot/SBFspot -v -finq -mqtt -cfg/usr/bin/sbfspot/SetConfig.cfg

#  Subscribe to set config /haos-sbfspot/  <<<< ---  slug=$(bashio::addon.name )   <<<  -- echo "$slug"
mosquitto_sub -h $MQTT_Host -u $MQTT_User -P $MQTT_Pass -v -t /"$(bashio::addon.name)"/device
#  post set config via SBFspot


#   ALL Values
#   MQTT_Data=Timestamp,InvTime,SunRise,SunSet,InvSerial,InvName,InvClass,InvType,InvSwVer,InvStatus,InvTemperature,InvGridRelay,EToday,ETotal,PACTot,UDC1,UDC2,IDC1,IDC2,PDC1,PDC2,PDCTot,OperTm,FeedTm,PAC1,PAC2,PAC3,UAC1,UAC2,UAC3,IAC1,IAC2,IAC3,GridFreq,BTSignal,BatTmpVal,BatVol,BatAmp,BatChaStt


#  InvName delete
#  -h {host} -u {MQTT_User} -P {MQTT_Pass} -t {topic} -m
/usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"InvName/config -m "" -d
/usr/bin/mosquitto_pub -h core-mosquitto -u hasmqtt -P pas0th5 -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_2100443252"$value"/config -m '{ "name": "SMA Inverter Nom", "state_topic": "homeassistant/sbfspot_HasSMA5000TL-20/sbfspot_2100443252", "value_template": "{{ value_json.InvName }}", "unique_id": "2100443252_{$value}", "device": { "identifiers": ["sbfspot_HasSMA5000TL-20/sbfspot_2100443252/"], "name": "SMA ", "model": "SMA5000", "manufacturer": "SMA", "sw_version": "1.X" } }' -d

if bashio::var.has_value "${MQTT_Data}" "Timestamp" ; then
   echo 'has Timestamp'
fi

if bashio::var.has_value "${MQTT_Data}" "SunRise" ; then
     echo 'do SunRise sensor'
fi

if bashio::var.has_value "${MQTT_Data}" "SunSet" ; then
     echo 'do SunSet'

fi
