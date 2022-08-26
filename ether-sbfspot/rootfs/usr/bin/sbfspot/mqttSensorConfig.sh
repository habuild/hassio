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


InvSerial='210043252'    #    <<< ---- Dummy serial need to get from mqtt

echo "$MQTT_Host"
echo "$MQTT_User"
echo "$MQTT_Pass"
echo "$MQTT_Topic"
echo "$MQTT_Data"

#  make set config

value="$(jq --raw-output '.Connection_Type' $CONFIG_PATH)"
if  bashio::var.equals "${value}" "Bluetooth"; then
    /usr/bin/sbfspot/genSenBlue.sh
    bashio::log.info
    bashio::log.info
    message=$(echo "||    Generating HA Sensors    ||")
    bashio::log.info ${__BASHIO_COLORS_BLUE} "${message:=""}"
    bashio::log.info
elif bashio::var.equals "${value}" "Ethernet"; then
    /usr/bin/sbfspot/genSenEth.sh
    bashio::log.info
    bashio::log.info
    message=$(echo "||    Generating HA Sensors     ||")
    bashio::log.info ${__BASHIO_COLORS_MAGENTA} "${message:=""}"
    bashio::log.info
else
    bashio::log.info ${__BASHIO_COLORS_RED} ===================================
    bashio::log.info ${__BASHIO_COLORS_RED} "Setup failed to create HA Sensors"
    bashio::log.info ${__BASHIO_COLORS_RED} ===================================
fi

#  Use SetConfig.cfg to post initial mqtt msg for sensors
/usr/bin/sbfspot/SBFspot -v -finq -mqtt -cfg/usr/bin/sbfspot/SetConfig.cfg

#  Subscribe to read SBFspot sensor post
mosquitto_sub -h $MQTT_Host -u $MQTT_User -P $MQTT_Pass -v -t /"$(bashio::addon.name)"/device

#   ALL Values
#   MQTT_Data=Timestamp,InvTime,SunRise,SunSet,InvSerial,InvName,InvClass,InvType,InvSwVer,InvStatus,InvTemperature,InvGridRelay,EToday,ETotal,PACTot,UDC1,UDC2,IDC1,IDC2,PDC1,PDC2,PDCTot,OperTm,FeedTm,PAC1,PAC2,PAC3,UAC1,UAC2,UAC3,IAC1,IAC2,IAC3,GridFreq,BTSignal,BatTmpVal,BatVol,BatAmp,BatChaStt


#  InvName delete
#  -h {host} -u {MQTT_User} -P {MQTT_Pass} -t {topic} -m
#  /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"InvName/config -m "" -d
#  /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_2100443252"$value"/config -m '{ "name": "SMA Inverter Nom", "state_topic": "homeassistant/sbfspot_HasSMA5000TL-20/sbfspot_2100443252", "value_template": "{{ value_json.InvName }}", "unique_id": "2100443252_{$value}", "device": { "identifiers": ["sbfspot_HasSMA5000TL-20/sbfspot_2100443252/"], "name": "SMA ", "model": "SMA5000", "manufacturer": "SMA", "sw_version": "1.X" } }' -d

if bashio::var.has_value "${MQTT_Data}" "InvName" ; then
   value=InvName
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Inverter Nom", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.InvName }}", "unique_id": ""$InvSerial"_{$value}", "icon":"mdi:flash", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "Timestamp" ; then
   value=Timestamp
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Timestamp", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.Timestamp }}", "unique_id": ""$InvSerial"_{$value}", "icon":"mdi:clock", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "SunRise" ; then
     echo 'do SunRise sensor'
fi

if bashio::var.has_value "${MQTT_Data}" "SunSet" ; then
     echo 'do SunSet'

fi
