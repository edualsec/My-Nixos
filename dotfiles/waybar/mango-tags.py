#!/usr/bin/env python3
import json
import subprocess
import os
import glob

if "MANGO_INSTANCE_SIGNATURE" not in os.environ:
    try:
        socks = sorted(glob.glob("/tmp/mango-*"), key=os.path.getmtime)
        if socks:
            os.environ["MANGO_INSTANCE_SIGNATURE"] = socks[-1]
    except Exception:
        pass

proc = subprocess.Popen(["mmsg", "watch", "all-monitors"], stdout=subprocess.PIPE, text=True)

for line in proc.stdout:
    try:
        data = json.loads(line)
        monitors = data.get("monitors", [])
        active_mon = next((m for m in monitors if m.get("active")), monitors[0] if monitors else None)
        if not active_mon:
            continue

        tags = active_mon.get("tags", [])
        # Diccionario con el estado de cada tag (1 a 9)
        active_tag_idx = 1
        for t in tags:
            if t.get("is_active"):
                active_tag_idx = t.get("index", 1)
                break

        # Construir los círculos del 1 al 9
        items = []
        for i in range(1, 10):
            if i == active_tag_idx:
                items.append(f"<span class='active'> {i} </span>")
            else:
                items.append(f"<span class='dot'>{i}</span>")

        payload = {
            "text": " ".join(items),
            "tooltip": f"Escritorio actual: {active_tag_idx}"
        }
        print(json.dumps(payload), flush=True)
    except Exception:
        continue
