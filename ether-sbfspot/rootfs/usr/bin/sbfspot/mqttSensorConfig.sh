#!/usr/bin/with-contenv bashio

#  Publish MQTT sensors for Config discovery.

#set -x

CONFIG_PATH=/data/options.json

PLANTNAME="$(jq --raw-output '.Plantname' $CONFIG_PATH)"
MQTT_Host="$(jq --raw-output '.MQTT_Host' $CONFIG_PATH)"
MQTT_User="$(jq --raw-output '.MQTT_User' $CONFIG_PATH)"
MQTT_Pass="$(jq --raw-output '.MQTT_Pass' $CONFIG_PATH)"
MQTT_Topic="$(jq --raw-output '.MQTT_Topic' $CONFIG_PATH)"
MQTT_Data="$(jq --raw-output '.MQTT_Data' $CONFIG_PATH)"
arg="$(jq --raw-output '.MQTT_Data' /data/options.json | tr ',' '\n')"

echo "$MQTT_Host"
echo "$MQTT_User"
#  echo "$MQTT_Pass"
echo "$MQTT_Topic"
echo "$MQTT_Data"

#  make set config
if bashio::fs.file_exists '/data/device'; then
   bashio::log.info Using Existing Device info
   else
        value="$(jq --raw-output '.Connection_Type' $CONFIG_PATH)"
        if  bashio::var.equals "${value}" "Bluetooth"; then
            /usr/bin/sbfspot/genSenBlue
            bashio::log.info
            bashio::log.info
            bashio::log.info "${__BASHIO_COLORS_BLUE}" "||    Generating HA Sensors    ||"
            
            #  Use SetConfig.cfg to post initial mqtt msg for sensors
            /usr/bin/sbfspot/SBFspot -v -finq -mqtt -cfg/usr/bin/sbfspot/SetConfig.cfg
            
            #  Subscribe to read SBFspot sensor post
            mosquitto_sub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t "$(bashio::addon.name)/device" -C 1 > /data/device            
            
        elif bashio::var.equals "${value}" "Ethernet"; then
            /usr/bin/sbfspot/genSenEth
            bashio::log.info
            bashio::log.info
            message=$(echo "||    Generating HA Sensors     ||")
            bashio::log.info "${__BASHIO_COLORS_MAGENTA}" "${message:=""}"
            
            #  Use SetConfig.cfg to post initial mqtt msg for sensors
            /usr/bin/sbfspot/SBFspot -v -finq -mqtt -cfg/usr/bin/sbfspot/SetConfig.cfg
            
            #  Subscribe to read SBFspot sensor post
            mosquitto_sub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t "$(bashio::addon.name)/device" -C 1 > /data/device
                        
        else
            bashio::log.info "${__BASHIO_COLORS_RED}" ===================================
            bashio::log.info "${__BASHIO_COLORS_RED}" "Setup failed to create HA Sensors"
            bashio::log.info "${__BASHIO_COLORS_RED}" ===================================
        fi
fi

DEVICE_PATH=/data/device

InvSerial="$(jq --raw-output '.InvSerial' $DEVICE_PATH)"   #    <<< ---- change to Dummy serial if needed to get from mqtt 
InvName="$(jq --raw-output '.InvName' $DEVICE_PATH)"     #    <<< ---- prints bad formant SN: SerialNo or perhaps not
InvSwVer="$(jq --raw-output '.InvSwVer' $DEVICE_PATH)"
InvType="$(jq --raw-output '.InvType' $DEVICE_PATH)"
InvClass="$(jq --raw-output '.InvClass' $DEVICE_PATH)"
BTmac="$(jq --raw-output '.BTAddress' /data/options.json | tr -d ':' )"   #  <<< --- Compress BT MAC to use in Unique ID


#  Publish Device data to default topic
msg="$(jq --raw-output '.' $DEVICE_PATH)"
mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t "homeassistant/sbfspot_\"$PLANTNAME\"/sbfspot_\"$InvSerial"\" -m "$msg" -r

bashio::log.info "${__BASHIO_COLORS_RED}" "$InvSerial"
bashio::log.info "${__BASHIO_COLORS_RED}" "$InvSerial"
bashio::log.info "${__BASHIO_COLORS_RED}" "$InvSwVer"
bashio::log.info "${__BASHIO_COLORS_RED}" "$InvType"
bashio::log.info "${__BASHIO_COLORS_RED}" "$InvClass"
bashio::log.info "${__BASHIO_COLORS_RED}" "$BTmac"

#   ALL Values
#   MQTT_Data=Timestamp,InvTime,SunRise,SunSet,InvSerial,InvName,InvClass,InvType,InvSwVer,InvStatus,InvTemperature,InvGridRelay,EToday,ETotal,PACTot,UDC1,UDC2,IDC1,IDC2,PDC1,PDC2,PDCTot,OperTm,FeedTm,PAC1,PAC2,PAC3,UAC1,UAC2,UAC3,IAC1,IAC2,IAC3,GridFreq,BTSignal,BatTmpVal,BatVol,BatAmp,BatChaStt
#
#  Known Working MQTT msg and variables
#
#  value='InvName'               << -- Change to value you need
#  describe='SMA Inverter Nom'   << -- Short descriptuion for HA Name
#  mdi_icon='mdi:flash'          << -- mdi icons
#
#  /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$BTmac"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d -r
#
# dev state icon uom
# /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$BTmac"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" -d -r


#set -x

debugMQTT='-d'    #  ' -d' or '--quiet'

MQTT_Data=$(bashio::config 'MQTT_Data' | tr ',' '\n')

if bashio::config 'InvName' ; then
   value='InvName'
   describe='SMA Inverter Nom'
   mdi_icon='mdi:card-bulleted'
   #  devClass= << add in \"device_class\": \"$devClass\",
   #  stClass=  << add in \"state_class\": \"$stClass\",
   #  UoM=      << add in \"unit_of_measurement\": \"$UoM\",
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'Timestamp' ; then
   value='Timestamp'
   describe='SMA Timestamp'
   mdi_icon='mdi:clock'
   devClass=
   stClass=
   UoM=
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'InvTime' ; then
   value='InvTime'
   describe='SMA Time Inverter'
   mdi_icon='mdi:clock-digital'
   devClass=
   stClass=
   UoM=
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'SunRise' ; then
   value='SunRise'
   describe='SMA Sun Rise'
   mdi_icon='mdi:weather-sunny'
   devClass=
   stClass=
   UoM=
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'SunSet' ; then
   value='SunSet'
   describe='SMA Sun Set'
   mdi_icon='mdi:weather-hazy'
   devClass=
   stClass=
   UoM=
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'InvSerial' ; then
   value='InvSerial'
   describe='SMA Serial No'
   mdi_icon='mdi:card-bulleted-settings'
   devClass=
   stClass=
   UoM=
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'InvClass' ; then
   value='InvClass'
   describe='SMA device type'
   mdi_icon='mdi:cupboard-outline'
   devClass=
   stClass=
   UoM=
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'InvType' ; then
   value='InvType'
   describe='SMA device Model'
   mdi_icon='mdi:card-bulleted-settings'
   devClass=
   stClass=
   UoM=
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'InvSwVer' ; then
   value='InvSwVer'
   describe='SMA Firmware Vers'
   mdi_icon=mdi:select-inverse
   devClass=
   stClass=
   UoM=
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'InvStatus' ; then
   value='InvStatus'
   describe='SMA Status'
   mdi_icon=mdi:select-inverse
   devClass=
   stClass=
   UoM=
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'InvTemperature' ; then
   value='InvTemperature'
   describe='SMA Inverter Running Temp'
   mdi_icon='mdi:coolant-temperature'
   devClass='temperature'
   stClass='measurement'
   UoM='°C'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'InvGridRelay' ; then
   value='InvGridRelay'
   describe='SMA Grid Relay'
   mdi_icon='mdi:electric-switch'
   devClass=
   stClass=
   UoM=
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'EToday' ; then
   value='EToday'
   describe='SMA Daily Energy'
   mdi_icon='mdi:flash'
   devClass='energy'
   stClass='total_increasing'
   UoM='kWh'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'ETotal' ; then
   value='ETotal'
   describe='SMA Total Energy'
   mdi_icon='mdi:flash'
   devClass='energy'
   stClass='total_increasing'
   UoM='kWh'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'PACTot' ; then
   value='PACTot'
   describe='SMA AC Power'
   mdi_icon='mdi:flash'
   devClass='energy'
   stClass='measurement'
   UoM='W'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'UDC1' ; then
   value='UDC1'
   describe='SMA UDC Array'
   mdi_icon='mdi:solar-panel-large'
   devClass='voltage'
   stClass='measurement'
   UoM='V'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'UDC2' ; then
   value='UDC2'
   describe='SMA UDC Array2'
   mdi_icon='mdi:solar-panel'
   devClass='voltage'
   stClass='measurement'
   UoM='V'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'IDC1' ; then
   value='IDC1'
   describe='SMA IDC Array'
   mdi_icon='mdi:solar-panel-large'
   devClass='current'
   stClass='measurement'
   UoM='A'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'IDC2' ; then
   value='IDC2'
   describe='SMA IDC Array2'
   mdi_icon='mdi:solar-panel'
   devClass='current'
   stClass='measurement'
   UoM='A'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'PDC1' ; then
   value='PDC1'
   describe='SMA PDC Array'
   mdi_icon='mdi:solar-panel-large'
   devClass='power'
   stClass='measurement'
   UoM='W'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'PDC2' ; then
   value='PDC2'
   describe='SMA PDC Array2'
   mdi_icon='mdi:solar-panel'
   devClass='power'
   stClass='measurement'
   UoM='W'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'PDCTot' ; then
   value='PDCTot'
   describe='SMA DC All Strings'
   mdi_icon='mdi:solar-panel-large'
   devClass='power'
   stClass='measurement'
   UoM='W'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'OperTm' ; then
   value='OperTm'
   describe='SMA Total Operating Time'
   mdi_icon='mdi:clock'
   devClass='duration'
   stClass='total_increasing'
   UoM=
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'FeedTm' ; then
   value='FeedTm'
   describe='SMA Total Feed In Time'
   mdi_icon='mdi:clock'
   devClass='duration'
   stClass='total_increasing'
   UoM=
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'PAC1' ; then
   value='PAC1'
   describe='SMA AC Power Line 1'
   mdi_icon='mdi:transmission-tower'
   devClass='power'
   stClass='measurement'
   UoM='W'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'PAC2' ; then
   value='PAC2'
   describe='SMA AC Power Line 2'
   mdi_icon='mdi:transmission-tower'
   devClass='power'
   stClass='measurement'
   UoM='W'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'PAC3' ; then
   value='PAC3'
   describe='SMA AC Power Line 3'
   mdi_icon='mdi:transmission-tower'
   devClass='power'
   stClass='measurement'
   UoM='W'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'UAC1' ; then
   value='UAC1'
   describe='SMA Grid Voltage Phase 1'
   mdi_icon='mdi:transmission-tower'
   devClass='voltage'
   stClass='measurement'
   UoM='V'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'UAC2' ; then
   value='UAC2'
   describe='SMA Grid Voltage Phase 2'
   mdi_icon='mdi:transmission-tower'
   devClass='voltage'
   stClass='measurement'
   UoM='V'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'UAC3' ; then
   value='UAC3'
   describe='SMA Grid Voltage Phase 3'
   mdi_icon='mdi:transmission-tower'
   devClass='voltage'
   stClass='measurement'
   UoM='V'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'IAC1' ; then
   value='IAC1'
   describe='SMA Grid Current Phase 1'
   mdi_icon='mdi:transmission-tower'
   devClass='current'
   stClass='measurement'
   UoM='A'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'IAC2' ; then
   value='IAC2'
   describe='SMA Grid Current Phase 2'
   mdi_icon='mdi:transmission-tower'
   devClass='current'
   stClass='measurement'
   UoM='A'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'IAC3' ; then
   value='IAC3'
   describe='SMA Grid Current Phase 3'
   mdi_icon='mdi:transmission-tower'
   devClass='current'
   stClass='measurement'
   UoM='A'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'GridFreq' ; then
   value='GridFreq'
   describe='SMA Grid Frequency'
   mdi_icon='mdi:transmission-tower'
   devClass='frequency'
   stClass='measurement'
   UoM='Hz'   
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'BTSignal' ; then
   value='BTSignal'
   describe='SMA Bluetooth Signal'
   mdi_icon='mdi:bluetooth'
   devClass='signal_strength'
   stClass='measurement'
   UoM='dB' 
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'BatTmpVal' ; then
   value='BatTmpVal'
   describe='SMA Battery Temp'
   mdi_icon='mdi:home-battery-outline'
   devClass='temperature'
   stClass='measurement'
   UoM='°C' 
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'BatVol' ; then
   value='BatVol'
   describe='SMA Battery Voltage'
   mdi_icon='mdi:battery-charging-medium'
   devClass='voltage'
   stClass='measurement'
   UoM='V'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'BatAmp' ; then
   value='BatAmp'
   describe='SMA Battery Current'
   mdi_icon='mdi:battery-charging-medium'
   devClass='current'
   stClass='measurement'
   UoM='A'
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi

if bashio::config 'BatChaStt' ; then
    value='BatChaStt'
   describe='SMA Battery Charging Status'
   mdi_icon='mdi:battery-clock'
   devClass='battery'
   stClass='total'
   UoM='%'   
   
   bashio::log.info Setting Up "$value"
   
   /usr/bin/mosquitto_pub -h "$MQTT_Host" -u "$MQTT_User" -P "$MQTT_Pass" -t homeassistant/sensor/sbfspot_"$PLANTNAME"/sbfspot_"$InvSerial""$value"/config -m "{\"name\": \"$describe\", \"state_topic\": \"homeassistant/sbfspot_$PLANTNAME/sbfspot_$InvSerial\", \"value_template\": \"{{ value_json.$value | default() }}\", \"unique_id\": \"$InvSerial"'_'"$value\", \"device_class\": \"$devClass\", \"state_class\": \"$stClass\", \"unit_of_measurement\": \"$UoM\", \"icon\": \"$mdi_icon\", \"device\": { \"identifiers\": [\"$(bashio::addon.name)""-Sensors\"], \"name\": \"HAOS-SBFspot\", \"model\": \"$InvType\", \"manufacturer\": \"SMA\", \"sw_version\": \"$InvSwVer\" }}" "$debugMQTT"  -r
fi
