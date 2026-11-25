"""Settings the iPhone build needs, added to the recovered project.godot (game files unchanged).
Usage: python3 ci/patch_project.py <project dir>"""
import re, sys
p = sys.argv[1] + "/project.godot"
t = open(p).read()

def put(section, key, value):
    global t
    line = f"{key}={value}\n"
    t = re.sub(rf"(?m)^{re.escape(key)}=.*\n", "", t)
    if f"[{section}]\n" in t:
        t = t.replace(f"[{section}]\n", f"[{section}]\n\n{line}", 1)
    else:
        t += f"\n[{section}]\n\n{line}"

# textures: the web build only has desktop (S3TC) textures; iPhones need ETC2/ASTC ones,
# otherwise every texture fails to load and the screen is pink
put("rendering", "textures/vram_compression/import_etc2_astc", "true")
# 120 Hz on ProMotion iPhones, smooth: the game moves things 60 times a second (physics),
# so draw the in-between positions instead of showing each one twice
put("display", "window/ios/allow_high_refresh_rate", "true")
put("physics", "common/physics_interpolation", "true")
# Godot's own log in Documents/logs (visible in the Files app)
put("debug", "file_logging/enable_file_logging", "true")
open(p, "w").write(t)
print("project.godot patched")
