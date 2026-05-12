#!/bin/bash
# start_cameras.sh — BeagleY-AI (Zero-Latency / Anti-Queue)

source ./.camera_env

# 1. Augmenter les buffers réseau du noyau Linux (Fixe la saturation immédiate)
sudo sysctl -w net.core.rmem_max=26214400 2>/dev/null
sudo sysctl -w net.core.wmem_max=26214400 2>/dev/null

RECORD=false
while getopts "e" opt; do
  case $opt in
    e) RECORD=true ;;
    *) echo "Usage: $0 [-e]"; exit 1 ;;
  esac
done

killall -9 ffmpeg mediamtx 2>/dev/null

MEDIAMTX_DIR="$(dirname "$0")"

# 2. Configurer MediaMTX pour accepter des gros flux sans bloquer
# On s'assure que les buffers internes sont énormes
sed -i 's/readBufferCount: [0-9]*/readBufferCount: 4096/g' "$MEDIAMTX_DIR/mediamtx.yml"
sed -i 's/writeQueueSize: [0-9]*/writeQueueSize: 4096/g' "$MEDIAMTX_DIR/mediamtx.yml"

"$MEDIAMTX_DIR/mediamtx" "$MEDIAMTX_DIR/mediamtx.yml" &
MTPID=$!
sleep 2

launch_cam() {
    local DEV=$1
    local NAME=$2
    
    if [ ! -e "$DEV" ]; then return; fi

    echo "🚀 Lancement $NAME..."

    # On publie en UDP vers MediaMTX. 
    # Si la queue est pleine, FFmpeg va jeter les frames au lieu de freezer.
    RTSP_URL="rtsp://127.0.0.1:8554/$NAME"
    
    if [ "$RECORD" = true ]; then
        mkdir -p "/mnt/usb/recordings/$NAME"
        # Le secret ici est d'utiliser un buffer plus petit pour le disque pour ne pas ralentir le réseau
        FF_OUT="-f tee [f=rtsp:rtsp_transport=udp]${RTSP_URL}|[f=segment:segment_time=60:segment_format=mp4:strftime=1]/mnt/usb/recordings/$NAME/%Y%m%d_%H%M.mp4"
    else
        FF_OUT="-f rtsp -rtsp_transport udp ${RTSP_URL}"
    fi

    # -re : force FFmpeg à lire à la vitesse réelle (évite d'envoyer 100 frames d'un coup au démarrage)
    # -fifo_size : tampon de sortie
    ffmpeg -re -thread_queue_size 2048 -f v4l2 -input_format mjpeg -video_size 854x480 -framerate 15 \
      -i "$DEV" \
      -c:v libx264 -preset ultrafast -tune zerolatency -b:v 400k -g 30 \
      $FF_OUT -loglevel error &
}

launch_cam "${CAM1}" "cam1"
launch_cam "${CAM2}" "cam2"
launch_cam "${CAM3}" "cam3"
launch_cam "${CAM4}" "cam4"

wait $MTPID