[![DockerHub stars](https://img.shields.io/docker/stars/jessejamescox/kbus-api.svg?flat&logo=docker "DockerHub stars")](https://hub.docker.com/r/jessejamescox/kbus-api)
[![DockerHub pulls](https://img.shields.io/docker/pulls/jessejamescox/kbus-api.svg?flat&logo=docker "DockerHub pulls")](https://hub.docker.com/r/jessejamescox/kbus-api)

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

 ## Get prebuild pfc-modbus-server image
```bash
docker pull jessejamescox/kbus-api 
 ```

## Setup PFC environment for execution of pfc-modbus-server container. 
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


## Start pfc-modbus-server container

  ```bash
docker run -d --init \
--privileged \
--restart unless-stopped \
-v /etc/kbus-api/kbus-api.cfg:/etc/kbus-api/kbus-api.cfg \
-v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket \
jessejamescox/kbus-api 
 ```
