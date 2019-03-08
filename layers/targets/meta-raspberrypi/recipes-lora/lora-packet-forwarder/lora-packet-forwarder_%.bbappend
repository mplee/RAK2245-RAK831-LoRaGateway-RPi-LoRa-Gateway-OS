SRC_URI_append = "file://lora-packet-forwarder.default \
	          file://dbs-data \
		  file://rak831/ttn/global_conf.as_923.json \
		  file://rak831/ttn/global_conf.au_915_928.json \
		  file://rak831/ttn/global_conf.cn_470_510.json \
		  file://rak831/ttn/global_conf.eu_863_870.json \
		  file://rak831/ttn/global_conf.in_865_867.json \
		  file://rak831/ttn/global_conf.kr_920_923.json \
		  file://rak831/ttn/global_conf.ru_864_870.json \
		  file://rak831/ttn/global_conf.us_902_928.json \
		  file://rak831/lora_server/global_conf.as_923.json \
		  file://rak831/lora_server/global_conf.au_915_928.json \
		  file://rak831/lora_server/global_conf.cn_470_510.json \
		  file://rak831/lora_server/global_conf.eu_433.json \
		  file://rak831/lora_server/global_conf.eu_863_870.json \
		  file://rak831/lora_server/global_conf.in_865_867.json \
		  file://rak831/lora_server/global_conf.kr_920_923.json \
		  file://rak831/lora_server/global_conf.ru_864_870.json \
		  file://rak831/lora_server/global_conf.us_902_928.json \
"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

do_install_append() {
     install -d ${D}
     install -d ${D}${LORA_CONF_DIR}/rak831
     install -d ${D}${LORA_CONF_DIR}/rak831/ttn
     install -d ${D}${LORA_CONF_DIR}/rak831/lora_server

     install -m 0644 ${WORKDIR}/rak831/ttn/* ${D}${LORA_CONF_DIR}/rak831/ttn 
     install -m 0644 ${WORKDIR}/rak831/lora_server/* ${D}${LORA_CONF_DIR}/rak831/lora_server
    
     install -m 644 ${WORKDIR}/dbs-data ${D}${LORA_CONF_DIR}/rak831/dbs-data.tar.gz
     install -m 0755 ${WORKDIR}/rak831/lora_server/global_conf.eu_863_870.json ${D}${LORA_CONF_DIR}/global_conf.json
}
