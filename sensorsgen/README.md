Bash script for creating Home Assistant MQTT Discovery sensors for SBFspot using multiple inverters and MIS.

Typical multi inverter SBFspot MQTT messaging is:

homeassistant/sbfspot_Your_Plantname/sbfspot_Inverter_Serial

When using multiple Inverters MQTT messages are published as follows

Inverter One:
Topic: homeassistant/sbfspot_Plantname_Inverter_One/sbfspot_InvSerial

            Message: {Inverter:One, Key1:Value1, Key2:Value2}

Inverter two, then publishes it's message to Inverter Ones Topic using Inverter Two data. The same is true for Inverter Three

Inverter Two:
Topic: homeassistant/sbfspot_Plantname_Inverter_One/sbfspot_InvSerial_Two
Message: {Inverter:Two, Key1:Value1, Key2:Value2}

MQTT Discovery requires Unique messages for Devices and entities.
With this addon Sensor Generation should be simplified for Mulit inverter setups.
