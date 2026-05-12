#!/bin/bash

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

echo "${BLUE}[INFO] Creating environnement...${END}"
sudo mkdir /mnt/usb >/dev/null
sudo mount /dev/sda1 /mnt/usb >/dev/null

sudo mkdir /mnt/usb/recordings >/dev/null
sudo mkdir /mnt/usb/recordings/cam1 >/dev/null
sudo mkdir /mnt/usb/recordings/cam2 >/dev/null
sudo mkdir /mnt/usb/recordings/cam3 >/dev/null
sudo mkdir /mnt/usb/recordings/cam4 >/dev/null

echo "${GREEN}[Success] Environnement created !\n\n${END}"

echo "${BLUE}[INFO] Setup the ENV variables...${END}"
export CAM1="" CAM2="" CAM3="" CAM4=""
idx=1
 
for dev in /dev/video*; do
    # Garder uniquement les USB
    bus=$(v4l2-ctl -d "$dev" --info 2>/dev/null | grep "Bus info" | grep -i "usb")
    if [ -n "$bus" ]; then
        # Ignorer les nœuds metadata (impairs souvent, mais vérifier via cap)
        cap=$(v4l2-ctl -d "$dev" --info 2>/dev/null | grep "Video Capture")
        if [ -n "$cap" ]; then
            eval "CAM$idx=$dev"
            echo "CAM$idx=$dev"
            idx=$((idx + 1))
            [ $idx -gt 4 ] && break
        fi
    fi
done
 
if [ $idx -eq 1 ]; then
    echo "${RED}[FAILED] Aucune caméra USB détectée${END}"
else
    # On écrit les variables dans un fichier caché
    echo "export CAM1=$CAM1" > ./.camera_env
    echo "export CAM2=$CAM2" >> ./.camera_env
    echo "export CAM3=$CAM3" >> ./.camera_env
    echo "export CAM4=$CAM4" >> ./.camera_env
    chmod +x ~/.camera_env
fi

echo "${GREEN}[Success] ENV variables set\n\n${END}"

echo "${BLUE}[INFO] Getting files... [0/2]${END}"
curl -o start_cam.sh https://raw.githubusercontent.com/MartinCalamel/Cpi-space-cam/refs/heads/main/start_cam.sh >/dev/null || echo "[failed]"
chmod +x start_cam.sh
echo "${BLUE}[INFO] Getting files... [1/2]${END}"
curl -o mediamtx.yml https://raw.githubusercontent.com/MartinCalamel/Cpi-space-cam/refs/heads/main/mediamtx.yml >/dev/null || echo "[failed]"
echo "${BLUE}[INFO] Getting files... [2/2]\n\n${END}"

echo "${GREEN}[Success] Ended successfully !${END}"

echo "${BLUE}[INFO] To start recording : ./start_cam.sh${END}"