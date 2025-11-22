#!/bin/bash
if apt list --installed | grep zabbix-agent2  &>/dev/null; then
    echo 'zabbix-agent2 is installed';
else
    . /etc/os-release && \
    wget https://repo.zabbix.com/zabbix/7.4/release/${ID}/pool/main/z/zabbix-release/zabbix-release_latest_7.4+${ID}${VERSION_ID}_all.deb && \
    dpkg -i zabbix-release_latest_7.4+${ID}${VERSION_ID}_all.deb

    apt-get update && apt-get install -y zabbix-agent2

    cp zabbix_agent2.conf zabbix_agent2.conf_orig

    HOST_NAME=$(hostname)

    TO_REPLACE="s/Hostname=system.hostname/Hostname=$HOST_NAME/g"

    sed -i -e ${TO_REPLACE} zabbix_agent2.conf

    awk 'NR==146' zabbix_agent2.conf

    cp zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf
    # ufw allow from 172.31.17.0/28 to 172.31.17.1 если агент и сервер на одном хосте
    ufw allow from 109.123.238.167 to any port 10050 && ufw reload  
fi

mkdir /etc/systemd/system/zabbix-agent2.service.d
printf "[Service]\nUser=root\nGroup=root\n" > /etc/systemd/system/zabbix-agent2.service.d/override.conf
cat /etc/systemd/system/zabbix-agent2.service.d/override.conf

ADAPTER_NAME=$(ip -br link show | awk 'NR==2' | awk '{print $1}')
TO_REPLACE_ADAPTER="s/eth0/$ADAPTER_NAME/g"
sed -i -e ${TO_REPLACE_ADAPTER} traffic.conf

cat traffic.conf

apt-get install vnstat

cp service-check.conf /etc/zabbix/zabbix_agent2.d/
cp traffic.conf /etc/zabbix/zabbix_agent2.d/
cp cert.conf /etc/zabbix/zabbix_agent2.d/
cp logs.conf /etc/zabbix/zabbix_agent2.d/
cp system.conf /etc/zabbix/zabbix_agent2.d/

systemctl daemon-reload
systemctl restart zabbix-agent2.service
