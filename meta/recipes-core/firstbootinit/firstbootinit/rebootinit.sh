#!/bin/sh

sudo ifconfig eth0 down
sudo ifconfig eth0 192.168.10.10
sudo ifconfig eth0 up

# wait until postgresql is accepting connections
while ! sudo -u postgres /usr/bin/pg_isready -h localhost; do
    sleep 1
done

sudo /opt/lora-packet-forwarder/update_gwid.sh /etc/lora-packet-forwarder/global_conf.json

id=`cat /etc/lora-packet-forwarder/global_conf.json | grep ID | cut -d '"' -f 4`

sudo -u postgres /usr/bin/psql loraserver_ns -c "INSERT INTO gateway (gateway_id, created_at, updated_at,location,altitude,gateway_profile_id) VALUES ('\x$id','2019-01-11 11:18:45.582951+00','2019-01-11 11:18:45.582951+00','(0,0)',0,'dcb98245-13e6-49d8-93cb-09b6fa6b71fa');"

sudo -u postgres /usr/bin/psql loraserver_as -c "INSERT INTO gateway (mac, created_at, 
updated_at,name,description,organization_id,ping,network_server_id) VALUES   ('\x$id','2019-01-11 
11:18:45.582951+00','2019-01-11 11:18:45.582951+00','Box-$id','CH-EU868',1,'f',1);"

sudo rm -rf /var/lib/redis/*
