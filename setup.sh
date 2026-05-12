#!/bin/bash
<<<<<<< Updated upstream
echo "[INFO] Updating system..."
sudo apt update >/dev/null
sudo apt upgrade -y >/dev/null
echo "[INFO] System up to date !"

echo "[INFO] Installing tools..."
sudo apt install ffmpeg >/dev/null

wget https://github.com/bluenviron/mediamtx/releases/download/v1.9.0/mediamtx_v1.9.0_linux_arm64v8.tar.gz >/dev/null
tar xf mediamtx_v1.9.0_linux_arm64v8.tar.gz >/dev/null
echo "[INFO] Tools installed !"
=======

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
END="\e[0m"

echo "${BLUE}[INFO] Updating system...${END}"
sudo apt update
sudo apt upgrade -y
echo "\n\n\n${GREEN}[Success] System up to date !${END}"

echo "${BLUE}[INFO] Installing tools... [0/2]${END}"
sudo apt install ffmpeg -y >/dev/null

echo "${BLUE}[INFO] Installing tools... [1/2]${END}"
wget https://github.com/bluenviron/mediamtx/releases/download/v1.9.0/mediamtx_v1.9.0_linux_arm64v8.tar.gz >/dev/null
tar xf mediamtx_v1.9.0_linux_arm64v8.tar.gz >/dev/null
echo "${BLUE}[INFO] Tools installed [2/2]!${END}"
>>>>>>> Stashed changes

echo "${BLUE}[INFO] Creating environnement...${END}"
sudo mkdir /mnt/usb >/dev/null
sudo mount /dev/sda1 /mnt/usb >/dev/null

sudo mkdir /mnt/usb/recordings >/dev/null
sudo mkdir /mnt/usb/recordings/cam1 >/dev/null
sudo mkdir /mnt/usb/recordings/cam2 >/dev/null
sudo mkdir /mnt/usb/recordings/cam3 >/dev/null
sudo mkdir /mnt/usb/recordings/cam4 >/dev/null

<<<<<<< Updated upstream
echo "[INFO] Environnement created !"
echo "[Success] Ended successfully !"
=======
echo "${BLUE}[INFO] Environnement created !${END}"

echo "${BLUE}[INFO] Getting files... [0/2]${END}"
curl -o start_cam.sh https://raw.githubusercontent.com/MartinCalamel/Cpi-space-cam/refs/heads/main/start_cam.sh >/dev/null || echo "${RED}[failed]${END}"
chmod +x start_cam.sh
echo "${BLUE}[INFO] Getting files... [1/2]${END}"
curl -o mediamtx.yml https://raw.githubusercontent.com/MartinCalamel/Cpi-space-cam/refs/heads/main/mediamtx.yml >/dev/null || echo "${RED}[failed]${END}"
echo "${BLUE}[INFO] Getting files... [2/2]\n\n${END}"

echo "${GREEN}[Success] Ended successfully !"
echo "${BLUE}[INFO] To start recording : ./start_cam.sh"
>>>>>>> Stashed changes
