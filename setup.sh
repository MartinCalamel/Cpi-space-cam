#!/bin/bash
echo "[INFO] Updating system..."
sudo apt update
sudo apt upgrade -y
echo "\n\n\n[INFO] System up to date !"

echo "[INFO] Installing tools... [0/2]"
sudo apt install ffmpeg -y >/dev/null

echo "[INFO] Installing tools... [1/2]"
wget https://github.com/bluenviron/mediamtx/releases/download/v1.9.0/mediamtx_v1.9.0_linux_arm64v8.tar.gz >/dev/null
tar xf mediamtx_v1.9.0_linux_arm64v8.tar.gz >/dev/null
echo "[INFO] Tools installed [2/2]!"

echo "[INFO] Creating environnement..."
sudo mkdir /mnt/usb >/dev/null
sudo mount /dev/sda1 /mnt/usb >/dev/null

sudo mkdir /mnt/usb/recordings >/dev/null
sudo mkdir /mnt/usb/recordings/cam1 >/dev/null
sudo mkdir /mnt/usb/recordings/cam2 >/dev/null
sudo mkdir /mnt/usb/recordings/cam3 >/dev/null
sudo mkdir /mnt/usb/recordings/cam4 >/dev/null

echo "[INFO] Environnement created !"

echo "[INFO] Getting files... [0/2]"
curl -o start_cam.sh https://raw.githubusercontent.com/MartinCalamel/Cpi-space-cam/refs/heads/main/start_cam.sh >/dev/null || echo "[failed]"
chmod +x start_cam.sh
echo "[INFO] Getting files... [1/2]"
curl -o mediamtx.yml https://raw.githubusercontent.com/MartinCalamel/Cpi-space-cam/refs/heads/main/mediamtx.yml >/dev/null || echo "[failed]"
echo "[INFO] Getting files... [2/2]\n\n"

echo "[Success] Ended successfully !"
echo "[INFO] To start recording : ./start_cam.sh"