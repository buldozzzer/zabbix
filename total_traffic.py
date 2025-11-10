#!/usr/bin/python3
import apt
import logging
import subprocess
import json
import os

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
    command = ["vnstat", "-m", "-i", interface, "--json"]
    try:
        output = subprocess.check_output(command, text=True)
        data = json.loads(output)
        limit = 2199023255552
        total_traffic = data['interfaces'][0]['traffic']['total']['rx'] + data['interfaces'][0]['traffic']['total']['tx']
        print(f"Общий трафик для {interface}: {bytes_to_tb(total_traffic)} TB")
        
    except subprocess.CalledProcessError as e:
        logging.error(f"Ошбика исполнения vnstat: {e}")

if __name__ == "__main__":
    if check_deps():
        check_total_traffic("ens5")
    else:
        logging.error("Пакет 'vnstat' не установлен (команда 'apt install vnstat')")
