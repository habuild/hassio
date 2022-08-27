#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
#  Publish MQTT sensors for Config discovery.

#set -x

CONFIG_PATH=/data/options.json

PLANTNAME="$(jq --raw-output '.Plantname' $CONFIG_PATH)"
MQTT_Host="$(jq --raw-output '.MQTT_Host' $CONFIG_PATH)"
MQTT_User="$(jq --raw-output '.MQTT_User' $CONFIG_PATH)"
MQTT_Pass="$(jq --raw-output '.MQTT_Pass' $CONFIG_PATH)"
MQTT_Topic="$(jq --raw-output '.MQTT_Topic' $CONFIG_PATH)"
MQTT_Data="$(jq --raw-output '.MQTT_Data' $CONFIG_PATH)"

echo "$MQTT_Host"
echo "$MQTT_User"
#  echo "$MQTT_Pass"
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
mosquitto_sub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t "$(bashio::addon.name)/device" -C 1 >> /usr/bin/sbfspot/device.json

DEVICE_PATH=/usr/bin/sbfspot/device.json

InvSerial="$(jq --raw-output '.InvSerial' $DEVICE_PATH)"   #    <<< ---- change to Dummy serial if needed to get from mqtt 
# InvName="$(jq --raw-output '.InvName' $DEVICE_PATH)"     #    <<< ---- prints bad formant SN: SerialNo
InvSwVer="$(jq --raw-output '.InvSwVer' $DEVICE_PATH)"
InvType="$(jq --raw-output '.InvType' $DEVICE_PATH)"
InvClass="$(jq --raw-output '.InvClass' $DEVICE_PATH)"

bashio::log.info "${__BASHIO_COLORS_RED}" "$InvSerial"
bashio::log.info "${__BASHIO_COLORS_RED}" "$InvSerial"
bashio::log.info "${__BASHIO_COLORS_RED}" "$InvSwVer"
bashio::log.info "${__BASHIO_COLORS_RED}" "$InvType"
bashio::log.info "${__BASHIO_COLORS_RED}" "$InvClass"

#   ALL Values
#   MQTT_Data=Timestamp,InvTime,SunRise,SunSet,InvSerial,InvName,InvClass,InvType,InvSwVer,InvStatus,InvTemperature,InvGridRelay,EToday,ETotal,PACTot,UDC1,UDC2,IDC1,IDC2,PDC1,PDC2,PDCTot,OperTm,FeedTm,PAC1,PAC2,PAC3,UAC1,UAC2,UAC3,IAC1,IAC2,IAC3,GridFreq,BTSignal,BatTmpVal,BatVol,BatAmp,BatChaStt
#
#  Known Working MQTT msg and variables
#
#  value='InvName'               << -- Change to value you need
#  describe='SMA Inverter Nom'   << -- Short descriptuion for HA Name
#  mdi_icon='mdi:flash'          << -- mdi icons
#
#  /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
#
# dev state icon uom
# /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d


set -x

if bashio::var.has_value "${MQTT_Data}" "InvName" ; then
   value='InvName'
   describe='SMA Inverter Nom'
   mdi_icon='mdi:card-bulleted'
   devClass=
   stClass=
   UoM=
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "Timestamp" ; then
   value='Timestamp'
   describe='SMA Timestamp'
   mdi_icon='mdi:clock'
   devClass=
   stClass=
   UoM=
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "SunRise" ; then
   value=SunRise
   describe='SMA Sun Rise'
   mdi_icon='mdi:sun'
   devClass=
   stClass=
   UoM=
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "SunSet" ; then
   value='SunSet'
   describe='SMA Sun Rise'
   mdi_icon='mdi:weather-sunny'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvSerial" ; then
   value='InvSerial'
   describe='SMA Serial No'
   mdi_icon='mdi:card-bulleted-settings'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvClass" ; then
   value='InvClass'
   describe='SMA device'
   mdi_icon='mdi:card-bulleted-settings'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvType" ; then
   value='InvType'
   describe='SMA device'
   mdi_icon='mdi:card-bulleted-settings'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvSwVer" ; then
   value='InvSwVer'
   describe='SMA Software Version.'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvStatus" ; then
   value='InvStatus'
   describe='SMA Status'
   //usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvTemperature" ; then
   value='InvTemperature'
   describe='SMA Inverter Running Temp'
   mdi_icon='mdi:coolant-temperature'
   devClass='temperature'
   stClass=
   UoM='°C'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvGridRelay" ; then
   value='InvGridRelay'
   describe='SMA Grid Relay'
   mdi_icon='mdi:electric-switch'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvEToday" ; then
   value='InvEToday'
   describe='SMA Daily Energy'
   mdi_icon='mdi:flash'
   devClass='energy'
   stClass='total_increasing'
   UoM='kWh'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "InvETotal" ; then
   value='InvETotal'
   describe='SMA Total Energy'
   mdi_icon='mdi:flash'
   devClass='energy'
   stClass='total_increasing'
   UoM='kWh'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "PACTot" ; then
   value='PACTot'
   describe='SMA AC Power'
   mdi_icon='mdi:flash'
   devClass='energy'
   stClass='measurement'
   UoM='Watts'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "UDC1" ; then
   value='UDC1'
   describe='SMA DC Array'
   mdi_icon='mdi:solar-panel-large'
   devClass='voltage'
   stClass=
   UoM='Volts'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "UDC2" ; then
   value='UDC2'
   describe='SMA DC Array2'
   mdi_icon='mdi:solar-panel'
   devClass='voltage'
   stClass=
   UoM='Volts'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "IDC1" ; then
   value='IDC1'
   describe='SMA DC Array'
   mdi_icon='mdi:solar-panel-large'
   devClass='current'
   stClass=
   UoM='Amps'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "IDC2" ; then
   value='IDC2'
   describe='SMA DC Array'
   mdi_icon='mdi:solar-panel'
   devClass='current'
   stClass=
   UoM='Amps'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "PDC1" ; then
   value='PDC1'
   describe='SMA DC Array'
   mdi_icon='mdi:solar-panel-large'
   devClass='power'
   stClass=
   UoM='Watts'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "PDC2" ; then
   value='PDC2'
   describe='SMA DC Array'
   mdi_icon='mdi:solar-panel'
   devClass='power'
   stClass=
   UoM='Watts'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "PDCTot" ; then
   value='PDCTot'
   describe='SMA DC All Strings'
   mdi_icon='mdi:solar-panel-large'
   devClass='power'
   stClass=
   UoM='Watts'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "OperTm" ; then
   value='OperTm'
   describe='SMA Total Operating Time'
   mdi_icon='mdi:clock'
   devClass=
   stClass=
   UoM=
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "FeedTm" ; then
   value='FeedTm'
   describe='SMA Total Feed In Time'
   mdi_icon='mdi:clock'
   devClass=
   stClass=
   UoM=
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "PAC1" ; then
   value='PAC1'
   describe='SMA AC Power Line 1'
   mdi_icon='mdi:transmission-tower'
   devClass='power'
   stClass='measurement'
   UoM='Watts'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "PAC2" ; then
   value='PAC2'
   describe='SMA AC Power Line 2'
   mdi_icon='mdi:transmission-tower'
   devClass='power'
   stClass='measurement'
   UoM='Watts'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "PAC3" ; then
   value='PAC3'
   describe='SMA AC Power Line 3'
   mdi_icon='mdi:transmission-tower'
   devClass='power'
   stClass='measurement'
   UoM='Watts'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "UAC1" ; then
   value='UAC1'
   describe='SMA Grid Voltage Phase 1'
   mdi_icon='mdi:transmission-tower'
   devClass='voltage'
   stClass=
   UoM='Volts'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "UAC2" ; then
   value='UAC2'
   describe='SMA Grid Voltage Phase 2'
   mdi_icon='mdi:transmission-tower'
   devClass='voltage'
   stClass=
   UoM='Volts'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "UAC3" ; then
   value='UAC3'
   describe='SMA Grid Voltage Phase 3'
   mdi_icon='mdi:transmission-tower'
   devClass='voltage'
   stClass=
   UoM='Volts'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "IAC1" ; then
   value='IAC1'
   describe='SMA Grid Current Phase 1'
   mdi_icon='mdi:transmission-tower'
   devClass='current'
   stClass=
   UoM='Amps'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "IAC2" ; then
   value='IAC2'
   describe='SMA Grid Current Phase 2'
   mdi_icon='mdi:transmission-tower'
   devClass='current'
   stClass=
   UoM='Amps'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "IAC3" ; then
   value='IAC3'
   describe='SMA Grid Current Phase 3'
   mdi_icon='mdi:transmission-tower'
   devClass='current'
   stClass=
   UoM='Amps'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "GridFreq" ; then
   value='GridFreq'
   describe='SMA Grid Frequency'
   mdi_icon='mdi:transmission-tower'
   devClass='frequency'
   stClass=
   UoM='Hz'   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "BTSignal" ; then
   value='BTSignal'
   describe='SMA Bluetooth Signal'
   mdi_icon='mdi:bluetooth'
   devClass=
   stClass=
   UoM='rssi' 
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "BatTmpVal" ; then
   value='BatTmpVal'
   describe='SMA Battery Temp'
   mdi_icon='mdi:home-battery-outline'
   devClass='temperature'
   stClass=
   UoM='°C' 
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "BatVol" ; then
   value='BatVol'
   describe='SMA Battery Voltage'
   mdi_icon='mdi:battery-charging-medium'
   devClass='voltage'
   stClass=
   UoM='Volts'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "BatAmp" ; then
   value='BatVol'
   describe='SMA Battery Current'
   mdi_icon='mdi:battery-charging-medium'
   devClass='current'
   stClass=
   UoM='Amps'
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

if bashio::var.has_value "${MQTT_Data}" "BatChaStt" ; then
    value='BatChaStt'
   describe='SMA Battery Charging Status'
   mdi_icon='mdi:battery-clock'
   devClass='current'
   stClass='meausrement'
   UoM='Amps'   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\" \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d
fi

rm ./device.json
