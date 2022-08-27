#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
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


InvSerial="210043252"    #    <<< ---- Dummy serial need to get from mqtt
InvSwVer="0192.21.2"
InvType=Fakverterr
#  InvClass=Fakeplant

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
    bashio::log.info "${__BASHIO_COLORS_BLUE}" "||    Generating HA Sensors    ||"
    bashio::log.info
elif bashio::var.equals "${value}" "Ethernet"; then
    /usr/bin/sbfspot/genSenEth.sh
    bashio::log.info
    bashio::log.info
    message=$(echo "||    Generating HA Sensors     ||")
    bashio::log.info "${__BASHIO_COLORS_MAGENTA}" "${message:=""}"
    bashio::log.info
else
    bashio::log.info "${__BASHIO_COLORS_RED}" ===================================
    bashio::log.info "${__BASHIO_COLORS_RED}" "Setup failed to create HA Sensors"
    bashio::log.info "${__BASHIO_COLORS_RED}" ===================================
fi

#  Use SetConfig.cfg to post initial mqtt msg for sensors
/usr/bin/sbfspot/SBFspot -v -finq -mqtt -cfg/usr/bin/sbfspot/SetConfig.cfg

#  Subscribe to read SBFspot sensor post
mosquitto_sub -h $MQTT_Host -u $MQTT_User -P $MQTT_Pass -v -t $(bashio::addon.name)/device > printf %s

#   ALL Values
#   MQTT_Data=Timestamp,InvTime,SunRise,SunSet,InvSerial,InvName,InvClass,InvType,InvSwVer,InvStatus,InvTemperature,InvGridRelay,EToday,ETotal,PACTot,UDC1,UDC2,IDC1,IDC2,PDC1,PDC2,PDCTot,OperTm,FeedTm,PAC1,PAC2,PAC3,UAC1,UAC2,UAC3,IAC1,IAC2,IAC3,GridFreq,BTSignal,BatTmpVal,BatVol,BatAmp,BatChaStt


#  InvName delete
#  -h {host} -u {MQTT_User} -P {MQTT_Pass} -t {topic} -m
#  /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"InvName/config -m "" -d
#  /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_2100443252"$value"/config -m "{ "name": "SMA Inverter Nom", "state_topic": "homeassistant/sbfspot_HasSMA5000TL-20/sbfspot_2100443252", "value_template": "{{ value_json.InvName }}", "unique_id": "2100443252_{$value}", "device": { "identifiers": ["sbfspot_HasSMA5000TL-20/sbfspot_2100443252/"], "name": "SMA ", "model": "SMA5000", "manufacturer": "SMA", "sw_version": "1.X" } }" -d

if bashio::var.has_value "${MQTT_Data}" "InvName" ; then
   value=InvName
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m \{ "name": \"SMA Inverter Nom\", "state_topic": \"homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"\", "value_template": "\{{ value_json.InvName }\}", "unique_id": "\"$InvSerial"_\{$value\}\", "icon": \"mdi:flash\", "device": \{ "identifiers": [\"sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/\], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" \}\}\ -d
fi

if bashio::var.has_value "${MQTT_Data}" "Timestamp" ; then
   value=Timestamp
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Timestamp", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.Timestamp }}", "unique_id": ""$InvSerial"_{$value}", "icon": "mdi:clock", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "SunRise" ; then
   value=SunRise
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Sun Rise", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.SunRise }}", "unique_id": ""$InvSerial"_{$value}", "icon": "mdi:weather-sunny", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "SunSet" ; then
   value=SunSet
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Sun Set", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.SunSet }}", "unique_id": ""$InvSerial"_{$value}", "icon": "mdi:weather-sunny", icon: "mdi": "weather-sunset-down", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvSerial" ; then
   value=InvSerial
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Serial No.", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.InvSerial }}", "unique_id": ""$InvSerial"_{$value}", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvClass" ; then
   value=InvClass
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Device Type.", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.InvClass }}", "unique_id": ""$InvSerial"_{$value}", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvType" ; then
   value=InvType
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Model.", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.InvType }}", "unique_id": ""$InvSerial"_{$value}", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvSwVer" ; then
   value=InvSwVer
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Software Version.", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.InvSwVer }}", "unique_id": ""$InvSerial"_{$value}", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvStatus" ; then
   value=InvStatus
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Status.", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.InvStatus }}", "unique_id": ""$InvSerial"_{$value}", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvTemperature" ; then
   value=InvTemperature
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Inverter Running Temp", "device_class": "temperature", "unit_of_measurement": "°C", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.InvTemperature }}", "unique_id": ""$InvSerial"_{$value}", "icon": "mdi:coolant-temperature", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvGridRelay" ; then
   value=InvGridRelay
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Grid Relay", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.InvGridRelay }}", "unique_id": ""$InvSerial"_{$value}", icon: "mdi:electric-switch", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvEToday" ; then
   value=InvEToday
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Daily Energy", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.InvEToday }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "kWh", "icon": "mdi:solar-power", "device_class": "energy", "state_class": "total_increasing", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvETotal" ; then
   value=InvETotal
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Lifetime Energy", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.InvETotal }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "kWh", "device_class": "energy", "state_class": "total_increasing", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "PACTot" ; then
   value=PACTot
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA AC Power", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.PACTot }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Watts", "icon": "mdi:flash", "device_class": "power", "state_class": "measurement", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "UDC1" ; then
   value=UDC1
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA DC Array", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.UDC1 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Volts", "icon": "mdi:solar-panel-large", "device_class": "voltage", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "UDC2" ; then
   value=UDC2
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA DC Array2", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.UDC2 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Volts", "icon": "mdi:solar-panel", "device_class": "voltage", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "IDC1" ; then
   value=IDC1
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA DC Array", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.IDC1 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Amps", "icon": "mdi:solar-panel-large", "device_class": "current", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "IDC2" ; then
   value=IDC2
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA DC Array2", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.IDC2 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Amps", "icon": "mdi:solar-panel", "device_class": "current", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "PDC1" ; then
   value=PDC1
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA DC Array", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.PDC1 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Watts", "icon": "mdi:solar-panel-large", "device_class": "power", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "PDC2" ; then
   value=PDC2
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA DC Array2", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.PDC2 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Watts", "icon": "mdi:solar-panel", "device_class": "power", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "PDCTot" ; then
   value=PDCTot
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA DC All Strings", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.PDCTot }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Watts", "icon": "mdi:solar-panel", "device_class": "power", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "OperTm" ; then
   value=OperTm
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "Total Operating Time", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.OperTm }}", "unique_id": ""$InvSerial"_{$value}", "icon": "mdi:clock", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "FeedTm" ; then
   value=FeedTm
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "Feed In Time", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.OperTm }}", "unique_id": ""$InvSerial"_{$value}", "icon": "mdi:clock", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "PAC1" ; then
   value=PAC1
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA AC Power Line 1", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.PAC1 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Watts", "icon": "mdi:transmission-tower", "device_class": "power", "state_class": "measurement", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "PAC2" ; then
   value=PAC2
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA AC Power Line 2", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.PAC2 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Watts", "icon": "mdi:transmission-tower", "device_class": "power", "state_class": "measurement", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "PAC3" ; then
   value=PAC3
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA AC Power", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.PAC3 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Watts", "icon": "mdi:transmission-tower", "device_class": "power", "state_class": "measurement", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "UAC1" ; then
   value=UAC1
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Grid Voltage Phase 1", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.UAC1 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Volts", "icon": "mdi:transmission-tower", "device_class": "voltage", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "UAC2" ; then
   value=UAC2
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Grid Voltage Phase 2", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.UAC2 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Volts", "icon": "mdi:transmission-tower", "device_class": "voltage", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "UAC3" ; then
   value=UAC3
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Grid Voltage Phase 3", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.UAC3 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Volts", "icon": "mdi:transmission-tower", "device_class": "voltage", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "IAC1" ; then
   value=IAC1
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA AC Current Phase 1", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.IAC1 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Amps", "icon": "mdi:transmission-tower", "device_class": "current", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "IAC2" ; then
   value=IAC2
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA AC Current Phase 2", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.IAC2 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Amps", "icon": "mdi:transmission-tower", "device_class": "current", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "IAC3" ; then
   value=IAC3
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA AC Current Phase 3", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.IAC3 }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Amps", "icon": "mdi:transmission-tower", "device_class": "current", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "GridFreq" ; then
   value=GridFreq
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA AC Grid Frequency", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.GridFreq }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Hz", "icon": "mdi:transmission-tower-import", "device_class": "frequency", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "BTSignal" ; then
   value=BTSignal
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Bluetooth Signal", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.BTSignal }}", "unique_id": ""$InvSerial"_{$value}", "icon": "mdi:bluetooth", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "BatTmpVal" ; then
   value=BatTmpVal
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Battery Temp", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.BatTmpVal }}", "unique_id": ""$InvSerial"_{$value}", "icon": "mdi:home-battery-outline", "device_class": "temperature", "unit_of_measurement": "°C", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "BatVol" ; then
   value=BatVol
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Battery Voltage", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.BatVol }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Volts", "icon": "mdi:battery-charging-medium", "device_class": "voltage", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "BatAmp" ; then
   value=BatAmp
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Battery Current", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.BatAmp }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Amps", "icon": "mdi:battery-charging-medium", "device_class": "current", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi

if bashio::var.has_value "${MQTT_Data}" "BatChaStt" ; then
   value=BatChaStt
   /usr/bin/mosquitto_pub -h core-mosquitto -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m '{ "name": "SMA Battery Charging Status", "state_topic": "homeassistant/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"", "value_template": "{{ value_json.BatChaStt }}", "unique_id": ""$InvSerial"_{$value}", "unit_of_measurement": "Amps", "icon": "mdi:battery-clock", "device_class": "current", "device": { "identifiers": ["sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial"/"], "name": "HAOS-SBFspot", "model": "$InvType", "manufacturer": "SMA", "sw_version": "InvSwVer" } }' -d
fi
