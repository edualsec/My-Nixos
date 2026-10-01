#!/usr/bin/env python3
"""Estado de CPU / RAM / GPU en JSON para eww (uso + temperatura)."""
import glob
import json
import os
import shutil
import subprocess
import time

TEMP_WARM = 60
TEMP_HOT = 80


def leer(path, default=None):
    try:
        with open(path) as f:
            return f.read().strip()
    except Exception:
        return default


def nivel(temp):
    if temp is None:
        return "na"
    if temp >= TEMP_HOT:
        return "hot"
    if temp >= TEMP_WARM:
        return "warm"
    return "cool"


def temp_txt(temp):
    return "N/A" if temp is None else f"{temp:.0f}°C"


def hwmons():
    """Devuelve [(nombre_chip, ruta)] de /sys/class/hwmon."""
    res = []
    for p in glob.glob("/sys/class/hwmon/hwmon*"):
        res.append((leer(f"{p}/name", ""), p))
    return res


# ---------------- CPU ----------------
def cpu_times():
    campos = leer("/proc/stat").splitlines()[0].split()[1:]
    v = [int(x) for x in campos]
    idle = v[3] + (v[4] if len(v) > 4 else 0)
    return sum(v), idle


def cpu_usage():
    t1, i1 = cpu_times()
    time.sleep(0.25)
    t2, i2 = cpu_times()
    dt = t2 - t1
    return 0 if dt <= 0 else round(100 * (1 - (i2 - i1) / dt))


def cpu_temp():
    for nombre, p in hwmons():
        if nombre in ("k10temp", "zenpower"):
            for f in ("temp1_input", "temp2_input"):  # Tctl / Tdie
                v = leer(f"{p}/{f}")
                if v:
                    return int(v) / 1000
        if nombre == "coretemp":
            for lab in glob.glob(f"{p}/temp*_label"):
                if "Package" in (leer(lab, "")):
                    v = leer(lab.replace("_label", "_input"))
                    if v:
                        return int(v) / 1000
            v = leer(f"{p}/temp1_input")
            if v:
                return int(v) / 1000
    v = leer("/sys/class/thermal/thermal_zone0/temp")
    return int(v) / 1000 if v else None


# ---------------- RAM ----------------
def ram():
    info = {}
    for linea in leer("/proc/meminfo").splitlines():
        k, v = linea.split(":")
        info[k] = int(v.split()[0])  # kB
    total = info["MemTotal"]
    usada = total - info["MemAvailable"]
    # Sensores SPD de los módulos (solo existen en algunas placas/RAM DDR5)
    temps = []
    for nombre, p in hwmons():
        if nombre in ("spd5118", "jc42"):
            v = leer(f"{p}/temp1_input")
            if v:
                temps.append(int(v) / 1000)
    t = max(temps) if temps else None
    return {
        "usage": round(100 * usada / total),
        "detail": f"{usada / 1048576:.1f} / {total / 1048576:.1f} GB",
        "temp": t,
    }


# ---------------- GPU ----------------
def gpu_nvidia():
    if not shutil.which("nvidia-smi"):
        return None
    try:
        out = subprocess.run(
            ["nvidia-smi",
             "--query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total",
             "--format=csv,noheader,nounits"],
            capture_output=True, text=True, timeout=3).stdout.strip().splitlines()[0]
        u, t, mu, mt = [x.strip() for x in out.split(",")]
        return {"usage": int(u), "temp": float(t),
                "detail": f"{int(mu) / 1024:.1f} / {int(mt) / 1024:.1f} GB VRAM"}
    except Exception:
        return None


def gpu_amd():
    mejor = None
    for dev in glob.glob("/sys/class/drm/card[0-9]*/device"):
        if leer(f"{dev}/gpu_busy_percent") is None:
            continue
        vram_t = int(leer(f"{dev}/mem_info_vram_total", "0"))
        if mejor is None or vram_t > mejor[1]:
            mejor = (dev, vram_t)
    if not mejor:
        return None
    dev, vram_t = mejor
    vram_u = int(leer(f"{dev}/mem_info_vram_used", "0"))
    temp = None
    for f in glob.glob(f"{dev}/hwmon/hwmon*/temp1_input"):
        v = leer(f)
        if v:
            temp = int(v) / 1000
            break
    detail = f"{vram_u / 2**30:.1f} / {vram_t / 2**30:.1f} GB VRAM" if vram_t else ""
    return {"usage": int(leer(f"{dev}/gpu_busy_percent", "0")), "temp": temp, "detail": detail}


def gpu():
    return gpu_nvidia() or gpu_amd() or {"usage": 0, "temp": None, "detail": "GPU no detectada"}


def main():
    c_use = cpu_usage()
    c_temp = cpu_temp()
    r = ram()
    g = gpu()
    salida = {
        "cpu": {"usage": c_use, "temp_txt": temp_txt(c_temp), "level": nivel(c_temp),
                "detail": f"{os.cpu_count()} hilos"},
        "ram": {"usage": r["usage"], "temp_txt": temp_txt(r["temp"]), "level": nivel(r["temp"]),
                "detail": r["detail"]},
        "gpu": {"usage": g["usage"], "temp_txt": temp_txt(g["temp"]), "level": nivel(g["temp"]),
                "detail": g["detail"]},
    }
    print(json.dumps(salida, ensure_ascii=False))


if __name__ == "__main__":
    main()
