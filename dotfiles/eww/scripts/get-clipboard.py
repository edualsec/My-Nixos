#!/usr/bin/env python3
import json
import subprocess

def get_clip_history():
    try:
        res = subprocess.run(["cliphist", "list"], capture_output=True, text=True)
        if res.returncode != 0 or not res.stdout.strip():
            return []

        items = []
        for line in res.stdout.strip().splitlines()[:30]:
            parts = line.split("\t", 1)
            if len(parts) == 2:
                clip_id = parts[0].strip()
                # Limpiar saltos de línea para evitar romper la sintaxis de yuck
                clean_preview = parts[1].replace("\n", " ").replace("\r", " ").strip()
                if not clean_preview:
                    clean_preview = "[Binario / Imagen]"
                items.append({
                    "id": clip_id,
                    "preview": clean_preview
                })
        return items
    except Exception:
        return []

if __name__ == "__main__":
    print(json.dumps(get_clip_history()))