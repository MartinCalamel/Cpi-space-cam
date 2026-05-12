#!/bin/bash
# start_cameras.sh — Pi FUSÉE
# Lance MediaMTX puis les 3 flux FFmpeg USB

MEDIAMTX_DIR="$(dirname "$0")"

source ./.camera_env

# Démarrer MediaMTX en arrière-plan
"$MEDIAMTX_DIR/mediamtx" "$MEDIAMTX_DIR/mediamtx.yml" &
MTPID=$!
echo "MediaMTX démarré (PID $MTPID)"
sleep 2

# CAM 1 — HD Web Camera /dev/video0
ffmpeg -f v4l2 -input_format mjpeg -video_size 854x480 -framerate 24 \
  -i ${CAM1} \
  -c:v libx264 -preset ultrafast -tune zerolatency -b:v 800k -g 48 \
  -map 0 -f tee \
  "[f=rtsp:rtsp_transport=tcp]rtsp://localhost:8554/cam1|[f=segment:segment_time=60:segment_format=mp4:strftime=1]/mnt/usb/recordings/cam1/%Y%m%d_%H%M.mp4" \
  -loglevel warning &
echo "CAM1 démarrée"

# CAM 2 — Webcam C170 /dev/video2
ffmpeg -f v4l2 -input_format mjpeg -video_size 854x480 -framerate 24 \
  -i ${CAM2} \
  -c:v libx264 -preset ultrafast -tune zerolatency -b:v 800k -g 48 \
  -map 0 -f tee \
  "[f=rtsp:rtsp_transport=tcp]rtsp://localhost:8554/cam2|[f=segment:segment_time=60:segment_format=mp4:strftime=1]/mnt/usb/recordings/cam2/%Y%m%d_%H%M.mp4" \
  -loglevel warning &
echo "CAM2 démarrée"

# CAM 3 — HD Web Camera /dev/video4
ffmpeg -f v4l2 -input_format mjpeg -video_size 854x480 -framerate 24 \
  -i ${CAM3} \
  -c:v libx264 -preset ultrafast -tune zerolatency -b:v 800k -g 48 \
  -map 0 -f tee \
  "[f=rtsp:rtsp_transport=tcp]rtsp://localhost:8554/cam3|[f=segment:segment_time=60:segment_format=mp4:strftime=1]/mnt/usb/recordings/cam3/%Y%m%d_%H%M.mp4" \
  -loglevel warning &
echo "CAM3 démarrée"

# CAM 4
ffmpeg -f v4l2 -input_format mjpeg -video_size 854x480 -framerate 24 \
  -i ${CAM4} \
  -c:v libx264 -preset ultrafast -tune zerolatency -b:v 800k -g 48 \
  -map 0 -f tee \
  "[f=rtsp:rtsp_transport=tcp]rtsp://localhost:8554/cam4|[f=segment:segment_time=60:segment_format=mp4:strftime=1]/mnt/usb/recordings/cam4/%Y%m%d_%H%M.mp4" \
  -loglevel warning &
echo "CAM4 démarrée"

echo "Flux RTSP disponibles :"
echo "  rtsp://$(hostname -I | awk '{print $1}'):8554/cam1"
echo "  rtsp://$(hostname -I | awk '{print $1}'):8554/cam2"
echo "  rtsp://$(hostname -I | awk '{print $1}'):8554/cam3"
echo "  rtsp://$(hostname -I | awk '{print $1}'):8554/cam4"

# Attendre MediaMTX
wait $MTPID