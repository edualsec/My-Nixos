#!/usr/bin/env python3
import json
import subprocess

def get_notifications():
    try:
        # Obtiene el historial en JSON de dunst
        res = subprocess.run(["dunstctl", "history"], capture_output=True, text=True)
        if res.returncode != 0 or not res.stdout.strip():
            return []
        
        raw_data = json.loads(res.stdout)
        data = raw_data.get("data", [[]])[0]
        
        items = []
        for n in data[:15]:  # Máximo 15 notificaciones recientes
            app = n.get("appname", {}).get("data", "Sistema")
            summary = n.get("summary", {}).get("data", "")
            body = n.get("body", {}).get("data", "")
            nid = n.get("id", {}).get("data", 0)

            # Limpiar saltos de línea para el widget
            clean_body = body.replace("\n", " ").strip()
            
            items.append({
                "id": nid,
                "app": app,
                "summary": summary if summary else "Sin título",
                "body": clean_body if clean_body else "..."
            })
        return items
    except Exception:
        return []

if __name__ == "__main__":
    print(json.dumps(get_notifications()))
