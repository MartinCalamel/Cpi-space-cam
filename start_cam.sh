#!/bin/bash
# start_cameras.sh — Pi FUSÉE (Version Opti)
# Lance MediaMTX puis les 4 flux FFmpeg via l'encodeur matériel du Pi

source ./.camera_env

MEDIAMTX_DIR="$(dirname "$0")"

# 1. Démarrer MediaMTX en arrière-plan
"$MEDIAMTX_DIR/mediamtx" "$MEDIAMTX_DIR/mediamtx.yml" &
MTPID=$!
echo "MediaMTX démarré (PID $MTPID)"
sleep 3  # Un peu plus de temps pour stabiliser le serveur

# Fonction pour lancer FFmpeg (évite la répétition et facilite la maintenance)
launch_cam() {
    local DEV=$1
    local NAME=$2
    
    ffmpeg -f v4l2 -input_format mjpeg -video_size 854x480 -framerate 24 \
      -i "$DEV" \
      -c:v h264_v4l2m2m -b:v 800k -g 48 \
      -map 0 -f tee \
      "[f=rtsp]rtsp://localhost:8554/$NAME|[f=segment:segment_time=60:segment_format=mp4:strftime=1]/mnt/usb/recordings/$NAME/%Y%m%d_%H%M.mp4" \
      -loglevel warning &
    echo "$NAME démarrée sur $DEV"
}

# 2. Lancement des caméras avec l'encodeur matériel
launch_cam "${CAM1}" "cam1"
launch_cam "${CAM2}" "cam2"
launch_cam "${CAM3}" "cam3"
launch_cam "${CAM4}" "cam4"

echo "---------------------------------------"
echo "Flux RTSP disponibles :"
IP_ADDR=$(hostname -I | awk '{print $1}')
echo "  rtsp://$IP_ADDR:8554/cam1"
echo "  rtsp://$IP_ADDR:8554/cam2"
echo "  rtsp://$IP_ADDR:8554/cam3"
echo "  rtsp://$IP_ADDR:8554/cam4"
echo "---------------------------------------"

# Attendre MediaMTX
wait $MTPID