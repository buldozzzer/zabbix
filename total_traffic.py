#!/usr/bin/python3
import apt
import logging
import subprocess
import json

def check_deps(deps: str = "vnstat") -> bool:
    cache = apt.Cache()
    return cache[deps].is_installed

def check_total_traffic(interface: str = "eth0"):
    command = ["vnstat", "-m", "-i", interface]
    try:
        output = subprocess.check_output(command, text=True)
        data = json.loads(output)
        
    except subprocess.CalledProcessError as e:
        logging.error(f"Ошбика исполнения vnstat: {e}")
        print(f"Общий трафик для {interface}: {data['interfaces'][0]['traffic']['total']['rx'] + data['interfaces'][0]['traffic']['total']['tx']} bytes")
if __name__ == "__main__":
    if check_deps():
        pass
    else:
        logging.error("Пакет 'vnstat' не установлен (команда 'apt install vnstat')")
