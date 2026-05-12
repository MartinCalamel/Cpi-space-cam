#!/bin/bash
echo "[INFO] Updating system..."
sudo apt update >/dev/null
sudo apt upgrade -y >/dev/null
echo "[INFO] System up to date !"

echo "[INFO] Installing tools..."
sudo apt install ffmpeg >/dev/null

wget https://github.com/bluenviron/mediamtx/releases/download/v1.9.0/mediamtx_v1.9.0_linux_arm64v8.tar.gz >/dev/null
tar xf mediamtx_v1.9.0_linux_arm64v8.tar.gz >/dev/null
echo "[INFO] Tools installed !"

echo "[INFO] Creating environnement..."
sudo mkdir /mnt/usb >/dev/null
sudo mount /dev/sda1 /mnt/usb >/dev/null

sudo mkdir /mnt/usb/recordings >/dev/null
sudo mkdir /mnt/usb/recordings/cam1 >/dev/null
sudo mkdir /mnt/usb/recordings/cam2 >/dev/null
sudo mkdir /mnt/usb/recordings/cam3 >/dev/null
sudo mkdir /mnt/usb/recordings/cam4 >/dev/null

echo "[INFO] Environnement created !"
echo "[Success] Ended successfully !"