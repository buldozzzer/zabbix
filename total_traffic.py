#!/usr/bin/python3
import apt
import logging
import subprocess
import json
import os

INTERFACE = "ens5" # имя интерфейса
LIMIT = 1990 # лимит в GB

logging.basicConfig(filename='/var/log/traffic.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


def bytes_to_tb(bytes_value):
    terabytes = bytes_value / (1024**4)
    return terabytes

def bytes_to_gb(bytes_value):
    terabytes = bytes_value / (1024**3)
    return terabytes

def bytes_to_mb(bytes_value):
    terabytes = bytes_value / (1024**2)
    return terabytes

def check_deps(deps: str = "vnstat") -> bool:
    cache = apt.Cache()
    return cache[deps].is_installed

def check_total_traffic(interface: str = "eth0"):
    check_stat = ["vnstat", "-m", "--json", "--limit", "1", "-i", interface]
    try:
        output = subprocess.check_output(check_stat, text=True)
        data = json.loads(output)
        total_traffic = data['interfaces'][0]['traffic']['total']['rx'] + data['interfaces'][0]['traffic']['total']['tx'] # в байтах
        logging.info(f"Общий трафик для {interface}: {bytes_to_gb(total_traffic)} TB")
        if bytes_to_gb(total_traffic) > LIMIT:
            stop_xray = ["systemctl", "stop", "xray"]
            result = subprocess.run(stop_xray, check=True, capture_output=True, text=True)
            logging.info(f"Сервис 'xray' остановлен: {result.stdout}")
            logging.info("Выключение....")
            os.system("shutdown now")
    except subprocess.CalledProcessError as e:
        logging.error(f"Ошбика исполнения vnstat: {e}")

if __name__ == "__main__":
    if check_deps():
        check_total_traffic(INTERFACE)
    else:
        logging.error("Пакет 'vnstat' не установлен (команда 'apt install vnstat')")
