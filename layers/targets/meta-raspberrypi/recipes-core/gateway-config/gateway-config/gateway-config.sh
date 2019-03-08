#!/bin/sh

do_setup_admin_password() {
    dialog --title "Setup admin password" --msgbox "You will be asked to enter a new password." 5 60
    passwd admin
    RET=$?
    if [ $RET -eq 0 ]; then
        dialog --title "Setup admin password" --msgbox "Password has been changed succesfully." 5 60
        do_main_menu
    fi
}

do_setup_concentrator_shield() {
#    FUN=$(dialog --title "Setup LoRa concentrator shield" --menu "Select shield:" 15 60 4 \
#        1 "RAK      - RAK831 with GPS module" \
#        2 "RAK      - RAK831 without GPS module" \
#        3>&1 1>&2 2>&3)
#    RET=$?
#    if [ $RET -eq 1 ]; then
#        do_main_menu
#    elif [ $RET -eq 0 ]; then
#        case "$FUN" in
#            1) do_set_concentrator_reset_pin 17 && do_setup_channel_plan "rak831" ".gps";;
             do_set_concentrator_reset_pin 17 && do_setup_channel_plan "rak831" ""
#x        esac
#    fi
}

do_setup_ttn_channel_plan() {
    # $1: concentrator type
    # $2 ttn or loraserver
    FUN=$(dialog --title "TTN Channel-plan configuration" --menu "Select the Channel-plan:" 18 60 12 \
        1 "AS_923" \
        2 "AU_915_928" \
        3 "CN_470_510" \
        4 "EU_863_870" \
        5 "IN_865_867" \
        6 "KR_920_923" \
        7 "RU_864_870" \
        8 "US_902_928" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
            1) do_copy_global_conf $1 "as_923" $2;;
            2) do_copy_global_conf $1 "au_915_928" $2;;
			3) do_copy_global_conf $1 "cn_470_510" $2;;
            4) do_copy_global_conf $1 "eu_863_870" $2;;
            5) do_copy_global_conf $1 "in_865_867" $2;;
			6) do_copy_global_conf $1 "kr_920_923" $2;;
			7) do_copy_global_conf $1 "ru_864_870" $2;;
			8) do_copy_global_conf $1 "us_902_928" $2;;
        esac
    fi
}

set_lora_server_ip()
{
	rm /tmp/gate_server_ip -rf
	mkfifo /tmp/gate_server_ip
	dialog --title "Gateway Server IP" --nocancel --inputbox "SERVER_IP:" 10 40 "127.0.0.1" 2> /tmp/gate_server_ip & 
	RET=$?
	
	if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        gate_server_ip="$( cat /tmp/gate_server_ip  )" 
		sed -i "s/^.*server_address.*$/\t\"server_address\": \"$gate_server_ip\",/" /etc/lora-packet-forwarder/global_conf.json
		rm /tmp/gate_server_ip
		do_set_gateway_id
    fi
}

do_setup_lora_server_channel_plan() {
    # $1: concentrator type
    # $2: config suffix, eg ".gps"
    FUN=$(dialog --title "Lora Server Channel-plan configuration" --menu "Server the Channel-plan:" 18 60 12 \
        1 "AS_923" \
        2 "AU_915_928" \
        3 "CN_470_510" \
        4 "EU_433" \
        5 "EU_863_870" \
        6 "IN_865_867" \
        7 "KR_920_923" \
        8 "RU_864_870" \
        9 "US_902_928" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
            1) do_copy_global_conf $1 "as_923" $2;;
            2) do_copy_global_conf $1 "au_915_928" $2;;
			3) do_copy_global_conf $1 "cn_470_510" $2;;
			4) do_copy_global_conf $1 "eu_433" $2;;
            5) do_copy_global_conf $1 "eu_863_870" $2;;
            6) do_copy_global_conf $1 "in_865_867" $2;;
			7) do_copy_global_conf $1 "kr_920_923" $2;;
			8) do_copy_global_conf $1 "ru_864_870" $2;;
			9) do_copy_global_conf $1 "us_902_928" $2;;
        esac
    fi
}
 
do_setup_channel_plan() {
    # $1: concentrator type
    # $2: config suffix, eg ".gps"
    FUN=$(dialog --title "Server-plan configuration" --menu "Select the Server-plan:" 15 60 3 \
        1 "Server is TTN" \
        2 "Server is LoRa Server" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
            1) do_setup_ttn_channel_plan $1 "ttn";;
            2) do_setup_lora_server_channel_plan $1 "lora_server";;
        esac
    fi
}

do_prompt_concentrator_reset_pin() {
    PIN=$(dialog --inputbox "To which pin is the concentrator reset connected: " 8 60 \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_setup_concentrator_shield
    elif [ $RET -eq 0 ]; then
        do_set_concentrator_reset_pin $PIN
    fi
}

do_set_concentrator_reset_pin() {
    sed -i "s/^\(CONCENTRATOR_RESET_PIN=\).*$/\1$1/" /etc/default/lora-packet-forwarder
}

do_copy_global_conf() {
    cp /etc/lora-packet-forwarder/$1/$3/global_conf.$2.json /etc/lora-packet-forwarder/global_conf.json
    if [ $2 == "us_902_928" ]; then
        cp /etc/loraserver/loraserver-us915.toml /etc/loraserver/loraserver.toml
    else
        cp /etc/loraserver/loraserver-eu868.toml /etc/loraserver/loraserver.toml
    fi
    RET=$?
    if [ $RET -eq 0 ]; then
    	if [ $3 == "lora_server" ]; then
    		set_lora_server_ip
    	else
    		dialog --title "Server-plan configuration" --msgbox "Server-plan configuration has been copied." 5 60
        do_set_gateway_id
    	fi
    fi
}

do_set_gateway_id() {
    /opt/lora-packet-forwarder/update_gwid.sh /etc/lora-packet-forwarder/global_conf.json
    RET=$?
    if [ $RET -eq 0 ]; then
        dialog --title "Set Gateway ID" --msgbox "The Gateway ID has been set." 5 60
        do_restart_packet_forwarder
    fi
}

do_setup_concentrator_shield_rak_rak831() {
    FUN=$(dialog --title "RAK - RAK831/RAK2243 configuration" --menu "Select configuration:" 15 60 4 \
        eu868.json     "EU868 band" \
        eu868.json.gps "EU868 band + GPS" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_setup_concentrator_shield
    elif [ $RET -eq 0 ]; then
        return 1
    fi
}


do_restart_packet_forwarder() {
    monit restart lora-packet-forwarder
    RET=$?
    if [ $RET -eq 0 ]; then
        dialog --title "Restart packet-forwarder" --msgbox "The packet-forwarder has been restarted." 5 60
        do_main_menu
    fi

}

do_restart_lora_gateway_bridge() {
    monit restart lora-gateway-bridge
    RET=$?
    if [ $RET -eq 0 ]; then
        dialog --title "Restart LoRa Gateway Bridge" --msgbox "The LoRa Gateway Bridge has been restarted." 5 60
        do_main_menu
    fi

}

do_configure_wifi() {
    dialog --title "Configure WIFI" --msgbox "This will open the 'connmanctl' utility to configure the WIFI." 5 75
    dialog --title "connmanctl quickstart" --msgbox "1) Enable wifi:\n
enable wifi\n\n
2) Scan available wifi networks:\n
scan wifi\n\n
3) Display available wifi networks:\n
services\n\n
4) Turn on agent:\n
agent on\n\n
5) Connect to network:\n
connect wifi_...\n\n
6) Quit connmanctl:\n
quit" 25 60
    clear
    connmanctl
    RET=$?
    if [ $RET -eq 0 ]; then
        do_main_menu
    fi
}

do_resize_root_fs() {
    dialog --title "Resize root FS" --msgbox "This will resize the root FS to utilize all available space. The gateway will reboot after which the resize process will start. Please note that depending the SD Card size, this will take some time during which the gateway cann be less responsive.\n\n
To monitor the root FS resize, you can use the following command:\ndf -h" 25 60

    clear
    echo "The gateway will now reboot!"
    /etc/init.d/resize-rootfs start
}

check_ipaddr()
{
    echo $1|grep "^[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}[0-9]\{1,3\}$" > /dev/null;
    if [ $? -ne 0 ]
    then
        echo "Bad IP address" 
        return 1
    fi
    ipaddr=$1
    a=`echo $ipaddr|awk -F . '{print $1}'`
    b=`echo $ipaddr|awk -F . '{print $2}'`
    c=`echo $ipaddr|awk -F . '{print $3}'`
    d=`echo $ipaddr|awk -F . '{print $4}'`
    for num in $a $b $c $d
    do
        if [ $num -gt 255 ] || [ $num -lt 0 ] 
        then
            echo "Bad IP address" 
            return 1
        fi
   done

   return 0
}

set_eth0_ip()
{
	rm /tmp/eth0_ip -rf
	mkfifo /tmp/eth0_ip
	dialog --title "Eth0 IP" --nocancel --inputbox "IP:" 10 40 "192.168.10.10" 2> /tmp/eth0_ip & 
	RET=$?
	
	if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        eth0_ip="$( cat /tmp/eth0_ip  )" 
        check_ipaddr $eth0_ip
        RET2=$?
        if [ $RET2 -eq 1 ]; then
        	echo "Bad IP address"
            exit
        fi
		sed -i "4csudo ifconfig eth0 $eth0_ip" /etc/init.d/rebootinit.sh
		rm /tmp/eth0_ip
		echo "Restart to make the IP take effect"
    fi
}


do_main_menu() {
    FUN=$(dialog --title "LoRa Gateway OS(Rak 2.0)" --cancel-label "Quit" --menu "Configuration options:" 18 80 20 \
        1 "Set admin password" \
        2 "Setup RAK831/RAK2245 LoRa concentrator" \
        3 "Edit packet-forwarder config" \
        4 "Edit LoRa Gateway Bridge config" \
        5 "Restart packet-forwarder" \
        6 "Restart LoRa Gateway Bridge" \
        7 "Configure WIFI" \
        8 "Resize root FS" \
		9 "Edit eth0 IP"	\
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        clear
        return 0
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
            1) do_setup_admin_password;;
            2) do_setup_concentrator_shield;;
            3) nano /etc/lora-packet-forwarder/global_conf.json && do_main_menu;;
            4) nano /etc/lora-gateway-bridge/lora-gateway-bridge.toml && do_main_menu;;
            5) do_restart_packet_forwarder;;
            6) do_restart_lora_gateway_bridge;;
            7) do_configure_wifi;;
            8) do_resize_root_fs;;
			9) set_eth0_ip;;
        esac
    fi
}

do_main_menu
