#!/bin/bash

. /etc/os-release && \
wget https://repo.zabbix.com/zabbix/7.4/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.4+${ID}${VERSION_ID}_all.deb && \
dpkg -i zabbix-release_latest_7.4+${ID}${VERSION_ID}_all.deb
