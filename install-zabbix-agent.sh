#!/bin/bash

. /etc/os-release && \
wget https://repo.zabbix.com/zabbix/7.4/release/${ID}/pool/main/z/zabbix-release/zabbix-release_latest_7.4+${ID}${VERSION_ID}_all.deb && \
dpkg -i zabbix-release_latest_7.4+${ID}${VERSION_ID}_all.deb

apt-get update && apt-get install -y zabbix-agent2

HOST_NAME=$(hostname)

TO_REPLACE="s/Hostname=system.hostname/Hostname=$HOST_NAME/g"

sed -i -e ${TO_REPLACE} zabbix_agent2.conf

awk 'NR==146' zabbix_agent2.conf

mv zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf

systemctl restart zabbix-agent2.service

ufw allow from 109.123.238.167 to any port 10050 && ufw reload
