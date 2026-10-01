#!/usr/bin/env bash

VIDEOS_DIR="$HOME/Videos/Recordings"
mkdir -p "$VIDEOS_DIR"

# Si ya está grabando, detener la grabación
if pgrep -x "wf-recorder" > /dev/null; then
    pkill -INT -x wf-recorder
    notify-send -t 2000 "Grabación" "Grabación finalizada y guardada en $VIDEOS_DIR"
    exit 0
fi

# Seleccionar región con slurp
GEOM=$(slurp)
if [ -z "$GEOM" ]; then
    exit 0
fi

FILENAME="$VIDEOS_DIR/recording_$(date +'%Y-%m-%d_%H-%M-%S').mp4"

notify-send -t 2000 "Grabación" "Iniciando grabación..."
wf-recorder -g "$GEOM" -f "$FILENAME" --pixel-format yuv420p &
