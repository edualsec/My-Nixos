#!/usr/bin/env bash
# Uso: wifi-connect.sh "SSID" [contraseña]
ssid="$1"
pass="$2"

if nmcli -t -f NAME connection show | grep -Fxq -- "$ssid"; then
  out=$(nmcli connection up id "$ssid" 2>&1); rc=$?
elif [ -n "$pass" ]; then
  out=$(nmcli dev wifi connect "$ssid" password "$pass" 2>&1); rc=$?
else
  out=$(nmcli dev wifi connect "$ssid" 2>&1); rc=$?
fi

if [ $rc -eq 0 ]; then
  notify-send -u low "Wi-Fi" "Conectado a $ssid"
else
  notify-send -u normal "Wi-Fi" "No se pudo conectar a $ssid"
  # Si falló con contraseña, borramos el perfil roto para poder reintentar
  nmcli connection delete id "$ssid" >/dev/null 2>&1
fi
