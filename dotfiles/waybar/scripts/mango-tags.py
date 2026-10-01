#!/usr/bin/env python3
import json
import subprocess
import sys

def get_focused_tag():
    try:
        # Consulta el tag enfocado mediante mmsg
        res = subprocess.run(["mmsg", "-j", "getmonitors"], capture_output=True, text=True)
        data = json.loads(res.stdout)
        for mon in data:
            if mon.get("focused", False):
                return str(mon.get("tag", 1))
    except Exception:
        pass
    return "1"

if __name__ == "__main__":
    target_tag = sys.argv[1] if len(sys.argv) > 1 else "1"
    current = get_focused_tag()
    is_active = (current == target_tag)
    
    out = {
        "text": target_tag,
        "class": "active" if is_active else "inactive"
    }
    print(json.dumps(out))
