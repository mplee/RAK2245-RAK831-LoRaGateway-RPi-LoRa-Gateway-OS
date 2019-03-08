# RAK2245-RAK831-LoRaGateway-RPi-LoRa-Gateway-OS
Yocto based gateway image including LoRa Server components (https://www.loraserver.io)

##	Introduction 

The last RAK version of lora-gateway-os for RAK2245 is based on the [lora-gateway-os](https://github.com/brocaar/lora-gateway-os) Commit ID : 7c97acc1f0866e1b238f74ae8076f0b1058492af and GPS uses I2C interface.

This is the second RAK version with GPS back to uart, and supports RAK831 as well.  
[lora-gateway-os](https://github.com/brocaar/lora-gateway-os) updated to Commit ID : 8d9815278c1958af7c91228c8701945050268ca7


##	Building images

A Docker based build environment is provided for compiling the images.

### Initial setup

Run the following command to fetch the git submodules

    # update the submodules
    make submodules

    # setup permissions
    make permissions
    
Run the following command to set the /build folder permissions:

    # on the host
    docker-compose run --rm busybox

    # within the container
    chown 999:999 /build
    
### Building

Run the following command to setup the build environment:

    # on the host
    docker-compose run --rm yocto bash

    # within the container

    # initialize the yocto / openembedded build environment
    source oe-init-build-env /build/ /lora-gateway-os/bitbake/


    # build the lora-gateway-os-full image
    bitbake lora-gateway-os-full
    
    
Please refer : https://www.loraserver.io/lora-gateway-os/community/source/ for more information.
