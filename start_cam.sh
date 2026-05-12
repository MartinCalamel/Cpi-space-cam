#!/bin/bash
# start_cameras.sh — BeagleY-AI Optimized

source ./.camera_env

# Gestion de l'argument -e
RECORD=false
while getopts "e" opt; do
  case $opt in
    e) RECORD=true ;;
    *) echo "Usage: $0 [-e]"; exit 1 ;;
  esac
done

# Nettoyage
killall ffmpeg mediamtx 2>/dev/null

MEDIAMTX_DIR="$(dirname "$0")"
"$MEDIAMTX_DIR/mediamtx" "$MEDIAMTX_DIR/mediamtx.yml" &
sleep 2

launch_cam() {
    local DEV=$1
    local NAME=$2
    
    if [ ! -e "$DEV" ]; then
        echo "⚠️  $NAME ($DEV) introuvable."
        return
    fi

    echo "🚀 Lancement de $NAME..."

    # Construction de la sortie FFmpeg
    # On utilise libx264 car l'intégration hardware TI peut varier selon votre noyau
    OUTPUT="rtsp://localhost:8554/$NAME"
    
    if [ "$RECORD" = true ]; then
        echo "💾 Enregistrement activé pour $NAME"
        # Création du dossier si manquant
        mkdir -p "/mnt/usb/recordings/$NAME"
        
        # Utilisation de 'tee' pour doubler le flux vers le disque
        FF_OUT="-f tee [f=rtsp]${OUTPUT}|[f=segment:segment_time=60:segment_format=mp4:strftime=1]/mnt/usb/recordings/$NAME/%Y%m%d_%H%M.mp4"
    else
        FF_OUT="-f rtsp ${OUTPUT}"
    fi

    ffmpeg -f v4l2 -input_format mjpeg -video_size 854x480 -framerate 20 \
      -i "$DEV" \
      -c:v libx264 -preset ultrafast -tune zerolatency -b:v 600k -g 40 \
      $FF_OUT -loglevel error &
}

launch_cam "${CAM1}" "cam1"
launch_cam "${CAM2}" "cam2"
launch_cam "${CAM3}" "cam3"
launch_cam "${CAM4}" "cam4"

echo "---------------------------------------"
echo "BeagleY-AI streaming..."
[ "$RECORD" = true ] && echo "MODE: Streaming + Enregistrement" || echo "MODE: Streaming seul"
echo "---------------------------------------"

wait