#!/usr/bin/env python3
import json
import subprocess

def get_apps():
    try:
        # PipeWire soporta formato JSON directo en pactl
        res = subprocess.run(
            ["pactl", "-f", "json", "list", "sink-inputs"],
            capture_output=True,
            text=True
        )
        if res.returncode != 0 or not res.stdout.strip():
            return []
        
        data = json.loads(res.stdout)
    except Exception:
        # Fallback a parseo de texto si la versión no soporta -f json
        return parse_text_fallback()

    apps = []
    if isinstance(data, dict):
        data = [data]

    for item in data:
        try:
            input_id = item.get("index")
            props = item.get("properties", {})
            
            # Nombre de la aplicación (comprobando varias claves comunes en PipeWire)
            name = (
                props.get("application.name")
                or props.get("media.name")
                or props.get("node.name")
                or "Audio"
            )

            # Extraer volumen del primer canal
            vol_dict = item.get("volume", {})
            volume = 100
            for channel, details in vol_dict.items():
                if isinstance(details, dict) and "value_percent" in details:
                    pct_str = details["value_percent"].replace("%", "").strip()
                    volume = int(pct_str)
                    break

            apps.append({
                "id": str(input_id),
                "name": str(name),
                "volume": volume
            })
        except Exception:
            continue

    return apps

def parse_text_fallback():
    try:
        output = subprocess.check_output(["pactl", "list", "sink-inputs"], text=True)
    except Exception:
        return []

    apps = []
    current_app = {}

    for line in output.splitlines():
        line = line.strip()
        if line.startswith("Sink Input #"):
            if current_app and "id" in current_app and "name" in current_app:
                apps.append(current_app)
            current_app = {"id": line.split("#")[1].strip(), "name": "App", "volume": 100}
        elif "application.name =" in line and current_app:
            current_app["name"] = line.split("=")[1].replace('"', '').strip()
        elif "media.name =" in line and current_app and current_app.get("name") == "App":
            current_app["name"] = line.split("=")[1].replace('"', '').strip()
        elif line.startswith("Volume:") and current_app:
            parts = line.split("/")
            if len(parts) > 1:
                pct = parts[1].replace("%", "").strip()
                if pct.isdigit():
                    current_app["volume"] = int(pct)

    if current_app and "id" in current_app and "name" in current_app:
        apps.append(current_app)

    return apps

if __name__ == "__main__":
    print(json.dumps(get_apps()))