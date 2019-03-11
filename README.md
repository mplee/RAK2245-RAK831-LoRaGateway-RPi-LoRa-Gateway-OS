# RAK2245-RAK831-LoRaGateway-RPi-LoRa-Gateway-OS
Yocto based gateway image including LoRa Server components (https://www.loraserver.io)

##	Introduction 

The aim of this project is to help users set up a LoRa network easily. The User Guide can be get from our Web.

##	Supported platforms

This project currently provides support for the below platforms.

* RAK2245
* RAK831

##	Acknowledgments

This project based on [lora-gateway-os](https://github.com/brocaar/lora-gateway-os)  REV: 8d9815278c1958af7c91228c8701945050268ca7 

##	Changelog

2019-03-11 RAK V2.0.1

* Initial version


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
