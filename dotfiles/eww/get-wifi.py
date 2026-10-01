#!/usr/bin/env python3
"""Lista de redes Wi-Fi en JSON para eww (sin forzar rescan, es barato)."""
import json
import shlex
import subprocess

MAX_REDES = 15
ICONOS = ["󰤟", "󰤢", "󰤥", "󰤨"]  # de débil a fuerte
LOCK = "󰌾"


def run(cmd):
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=5).stdout
    except Exception:
        return ""


def split_terse(line):
    """nmcli -t escapa ':' y '\\' con barra invertida."""
    campos, cur, esc = [], "", False
    for ch in line:
        if esc:
            cur += ch
            esc = False
        elif ch == "\\":
            esc = True
        elif ch == ":":
            campos.append(cur)
            cur = ""
        else:
            cur += ch
    campos.append(cur)
    return campos


def icono(signal):
    return ICONOS[min(signal // 25, 3)]


def main():
    guardadas = set()
    for linea in run(["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]).splitlines():
        c = split_terse(linea)
        if len(c) >= 2 and c[1] == "802-11-wireless":
            guardadas.add(c[0])

    redes = {}
    salida = run(["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY",
                  "dev", "wifi", "list", "--rescan", "no"])
    for linea in salida.splitlines():
        c = split_terse(linea)
        if len(c) < 4 or not c[1]:
            continue
        en_uso, ssid, signal, seg = c[0].strip() == "*", c[1], c[2], c[3].strip()
        signal = int(signal) if signal.isdigit() else 0
        previa = redes.get(ssid)
        # Varios APs con el mismo SSID: nos quedamos con el más fuerte
        if previa and not en_uso and previa["active"]:
            continue
        if previa and not en_uso and previa["signal"] >= signal:
            continue
        redes[ssid] = {"active": en_uso, "signal": signal, "secured": seg not in ("", "--")}

    resultado = []
    for ssid, d in redes.items():
        q = shlex.quote(ssid)
        guardada = ssid in guardadas
        if d["active"]:
            cmd = "true"
        elif d["secured"] and not guardada:
            cmd = f"eww update wifi_selected={q} wifi_pass="
        else:
            cmd = f"~/.config/eww/scripts/wifi-connect.sh {q}; eww close wifi_popup"
        resultado.append({
            "ssid": ssid,
            "signal": d["signal"],
            "icon": icono(d["signal"]),
            "lock": LOCK if d["secured"] else "",
            "active": d["active"],
            "status": "Conectada" if d["active"] else ("Guardada" if guardada else ""),
            "cmd": cmd,
        })

    resultado.sort(key=lambda r: (not r["active"], -r["signal"]))
    print(json.dumps(resultado[:MAX_REDES], ensure_ascii=False))


if __name__ == "__main__":
    main()
