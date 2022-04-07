[![DockerHub stars](https://img.shields.io/docker/stars/jessejamescox/kbus-api.svg?flat&logo=docker "DockerHub stars")](https://hub.docker.com/r/jessejamescox/kbus-api)
[![DockerHub pulls](https://img.shields.io/docker/pulls/jessejamescox/kbus-api.svg?flat&logo=docker "DockerHub pulls")](https://hub.docker.com/r/jessejamescox/kbus-api)
# What is the pfc-kbus-api
This is an open-source project to enable reading and writing of WAGO PFCX00 Controllers IO data over the MQTT protocol. The controller status and IO values are published cyclically at a rate specified in the configuration file. 

Here is an example of received data published by the pfc-kbus-api:
```JSON
{
  "state": {
    "reported": {
      "node_id": "PFC200",
      "timestamp": 1649356003,
      "switch_state": "RUN",
      "module_count": 6,
      "modules": {
        "module1": {
          "pn": 36865,
          "position": 1,
          "type": "DI",
          "input_channel_count": 2,
          "output_channel_count": 0,
          "process_data": {
            "inputs": {
              "channel1": {
                "value": true,
                "label": "myFirstLabeledChan"
              },
              "channel2": {
                "value": false,
                "label": "m1_input2"
              }
            }
          }
        }
      }
    }
  }
}
```

To write to an IO channel, use the following structure:
```JSON
{
  "state": {
    "desired": {
      "modules": {
        "module2": {
          "process_data": {
            "outputs": {
              "channel1": {
                "value": false
              }
            }
          }
        }
      }
    }
  }
}
```
 It is also possible to label the channels for identification across multiple programs rovisualization
 ```JSON
 {
  "state": {
    "desired": {
      "modules": {
        "module2": {
          "process_data": {
            "outputs": {
              "channel1": {
                "label": "xPumpSignal"
              }
            }
          }
        }
      }
    }
  }
}
 ```

# How to run kbus-api container

## Prerequisites for tutorial
- Preinstalled SSH Client (e.g. https://www.putty.org/)
- Wago PFC with Docker (see https://github.com/WAGO/docker-ipk)

## PFC Login
Start SSH Client e.g. Putty 
 ```bash
login as `root`
password `wago`
 ```

 ## Check docker installation

```bash
docker info
docker ps # to see all running container (no container should run)
docker images # to see all preinstalled images
 ```

 ## Get prebuild pfc-kbus-api image
```bash
docker pull jessejamescox/pfc-kbus-api 
 ```

## Setup PFC environment for execution of pfc-kbus-api container. 
Before the kbus-api container can be started it is necessary to create a special environment on the PFC. There are two ways to achieve it: 
- automatically with the help of a script 
- manually

### Automatically
1. copy script setup_environment.sh to PFC.
2. chmod x setup_environment.sh
3. execute: ./setup_environment.sh

#### Restore original PFC environment.
To undo the environment created in the previous step, perform the following steps:
1. copy script undo_environment.sh to PFC.
2. chmod x undo_environment.sh
3. execute: ./undo_environment.sh

### Manually 
1. Start Wago PFC.
2. Open WBM (Web Base Management) menu "General PLC Runtime Configuration"
3. Set PLC runtime version to "None"
4. Start container, with credentials: We need the root password to start kbus on the host and the IP address of the PLC controller.
5. Set PFC onboard switch in 'running' state.

<b>LED Signal U1 shows: RED=kbus init on host engaded, YELLOW=prepare kbus for container, GREEN=kbus is working from container.</b>


## Start pfc-kbus-api container

  ```bash
docker run -d --init \
--restart unless-stopped --privileged \
--network=host \
-v kbusapidata:/etc/kbus-api \
-v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket \
jessejamescox/pfc-kbus-api
 ```
## Point this to your MQTT broker
Access the config file to setup custom configurations:
1. use "nano" to modify the file
```bash
nano /home/docker/kbusapidata/_data/kbus-api.cfg
```

2. Change the default configuration to support your application architecture including adding your certs/keys and connecting directly to a cloud host (i.e. AWS)

```
# The main configuration file for the Kbus <> MQTT
# client service.  Please configure all points.

# The hostname or some unique identifier to the
# MQTT broker.  This will default to hostname.
# If AWS shadaow compatibility is enabled, this will
# be used as your thing name from the IoT Core
# ** if blank, the controller hostname will be used ***
node_id = "PFC200";

# Set the communication type.  Enable the publish cyclic
# in this state all messages are published to status topic
# to publish the kbus on a set cycle.    
# DO NOT CHANGE - for future use
publish_cyclic = true;

# publish cycle in milliseconds.  default is 100ms
# performance with cloud broker may be unstable with 
# faster cycle speed
publish_interval = 100;

# The broker network address, this can be localhost
# or an external device address
mqtt_endpoint = "127.0.0.1";

# Mqtt broker port.  The beta version only supports
# non-TLS encrypted connections and no SSL config
mqtt_port = 1883;

# Use username and password for secure broker connections
support_userpasswd = false;
mqtt_username = "johnDoe";
mqtt_password = "myPassword";

# Maximum number of retries before the program exits
# setting this to a negative number will loop infinitely
max_retries = -1;

# Setting this to true enables the TLS capabiltiy from
# the client only. TLS is not currently supported by the
# local broker. When enabled, you must have cert, key,
# and rootCA paths mapped below
support_tls = false;

# direct path to your certificate
cert_path = "/etc/ssl/certs/mycert.pem.crt";

# direct path to your private key
key_path = "/etc/ssl/certs/mykey.pem.key";

# direct path to your rootCA certificate
rootca_path = "/etc/ssl/certs/root.ca.pem";

# setting this true formats the mqtt topics and payload
# to comply with the AWS IoT Thing Shadow formatting
support_aws_shadow = false;

#TOPICS
# subscribe topic for kbus events. publish to this topic
# to command kbus outputs.  Unless formatted to AWS Thing
# Shadow, the topic will be prefixed with the Node ID.
event_sub_topic = "/controller/kbus/event/outputs";

# publish topic for kbus events. subscribe to this topic
# for messages on input change-of-state.  Unless formatted
# AWS Thing Shadow, the topic will be prefixed with the
# Node ID.
event_pub_topic = "/controller/kbus/event/inputs";

# publish topic for kbus status. subscribe to this topic
# for messages on status change-of-state.  Unless formatted
# AWS Thing Shadow, the topic will be prefixed with the
# Node ID.
status_pub_topic = "/controller/status";

# setting this creates a deadband with analog input signals
# which for now is the decimal value threshold you must
# exceed to trigger an update to  publish.  See README for 
# instructions on how to set individual deadband for each channel
default_analog_deadband = 10;
```
## Node-RED Integration
Use this api alongside Node-RED with the pre-built palette.  This is pre-installed with the container:
https://hub.docker.com/repository/docker/jessejamescox/pfc-kbus-api-nodered 