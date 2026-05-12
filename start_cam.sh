#!/bin/bash
# start_cameras.sh — BeagleY-AI (Fix Queue Full)

source ./.camera_env

# 1. Gestion de l'argument -e
RECORD=false
while getopts "e" opt; do
  case $opt in
    e) RECORD=true ;;
    *) echo "Usage: $0 [-e]"; exit 1 ;;
  esac
done

# 2. Nettoyage des processus
killall -9 ffmpeg mediamtx 2>/dev/null

MEDIAMTX_DIR="$(dirname "$0")"

# 3. Ajustement dynamique de MediaMTX (Optionnel mais conseillé)
# On s'assure que writeQueueSize est assez grand dans le .yml
sed -i 's/writeQueueSize: [0-9]*/writeQueueSize: 2048/g' "$MEDIAMTX_DIR/mediamtx.yml"

# 4. Lancement de MediaMTX
"$MEDIAMTX_DIR/mediamtx" "$MEDIAMTX_DIR/mediamtx.yml" &
MTPID=$!
sleep 2

launch_cam() {
    local DEV=$1
    local NAME=$2
    
    if [ ! -e "$DEV" ]; then
        echo "⚠️  $NAME ($DEV) absent."
        return
    fi

    echo "🚀 Lancement de $NAME..."

    # --- FIX QUEUE : Paramètres FFmpeg ---
    # -thread_queue_size 1024 : Augmente la file d'attente en entrée
    # -rtsp_transport udp : Utilise l'UDP vers localhost pour éviter le blocage TCP
    
    RTSP_URL="rtsp://localhost:8554/$NAME"
    
    if [ "$RECORD" = true ]; then
        mkdir -p "/mnt/usb/recordings/$NAME"
        # On utilise l'UDP pour le RTSP pour ne pas bloquer si l'écriture disque ralentit
        FF_OUT="-f tee [f=rtsp:rtsp_transport=udp]${RTSP_URL}|[f=segment:segment_time=60:segment_format=mp4:strftime=1]/mnt/usb/recordings/$NAME/%Y%m%d_%H%M.mp4"
    else
        FF_OUT="-f rtsp -rtsp_transport udp ${RTSP_URL}"
    fi

    ffmpeg -thread_queue_size 1024 -f v4l2 -input_format mjpeg -video_size 854x480 -framerate 20 \
      -i "$DEV" \
      -c:v libx264 -preset ultrafast -tune zerolatency -b:v 600k -g 40 \
      $FF_OUT -loglevel error &
}

# Lancement des caméras
launch_cam "${CAM1}" "cam1"
launch_cam "${CAM2}" "cam2"
launch_cam "${CAM3}" "cam3"
launch_cam "${CAM4}" "cam4"

echo "---------------------------------------"
echo "BeagleY-AI : Streaming en cours..."
[ "$RECORD" = true ] && echo "MODE: Enregistrement ACTIF" || echo "MODE: Streaming SEUL"
echo "---------------------------------------"

wait $MTPID