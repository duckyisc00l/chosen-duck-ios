"""Add (or replace) an iOS export preset in a recovered Godot project: Xcode project only,
no signing, so the Mac runner can build an unsigned IPA with xcodebuild.

Usage: python3 ci/godot/preset.py <project dir> <major 3|4> <bundle id> <name>
"""
import os, re, sys

proj, major, bundle, name = sys.argv[1:5]
path = os.path.join(proj, "export_presets.cfg")
text = open(path).read() if os.path.exists(path) else ""
# Godot 3 calls the bundle id application/identifier, Godot 4 application/bundle_identifier.
# Both refuse to export without a team id, even unsigned: any 10 letters work.
# Desktop-only native libraries (Steam etc.) are left out of the iPhone export.
# drop any existing iOS preset (it would carry the original developer's signing settings)
blocks = re.split(r"(?=^\[preset\.\d+\]\s*$)", text, flags=re.M)
kept = []
for b in blocks:
    if b.strip() and 'platform="iOS"' not in b:
        kept.append(b)
# renumber the kept presets (each [preset.N] is followed by its [preset.N.options])
out, n, i = [], 0, 0
while i < len(kept):
    b = kept[i]
    if re.match(r"\[preset\.\d+\]", b):
        out.append(re.sub(r"\[preset\.\d+\]", f"[preset.{n}]", b, count=1))
        if i + 1 < len(kept) and re.match(r"\[preset\.\d+\.options\]", kept[i + 1]):
            out.append(re.sub(r"\[preset\.\d+\.options\]", f"[preset.{n}.options]", kept[i + 1], count=1))
            i += 1
        n += 1
    i += 1

common = f'''[preset.{n}]

name="iOS"
platform="iOS"
runnable=true
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter="*.dll, *.dylib, *.so, *.exe"
export_path=""

[preset.{n}.options]

'''
if major == "4":
    opts = f'''application/app_store_team_id="AAAAAAAAAA"
application/export_project_only=true
application/bundle_identifier="{bundle}"
application/name="{name}"
application/short_version="1.0"
application/version="1"
application/min_ios_version="15.0"
application/targeted_device_family=2
capabilities/access_wifi=false
'''
else:
    opts = f'''application/app_store_team_id="AAAAAAAAAA"
application/export_project_only=true
application/identifier="{bundle}"
application/name="{name}"
application/short_version="1.0"
application/version="1"
application/targeted_device_family=2
architectures/arm64=true
'''
# iOS (and Godot 3's exporter) refuse a transparent App Store icon: flatten the project icon onto black.
# Godot 4.7 also fails on any empty icon slot, so every slot gets the same 1024 icon (Godot resizes it).
ICON_KEYS = ["app_store_1024x1024", "icon_1024x1024", "iphone_120x120", "iphone_180x180", "ipad_76x76", "ipad_152x152",
             "ipad_167x167", "spotlight_40x40", "spotlight_80x80", "settings_58x58", "settings_87x87",
             "notification_40x40", "notification_60x60"]
icon_opt = ""
try:
    from PIL import Image
    cfg = open(os.path.join(proj, "project.godot"), errors="replace").read()
    m = re.search(r'config/icon\s*=\s*"res://([^"]+)"', cfg)
    src = os.path.join(proj, m.group(1)) if m else os.path.join(proj, "icon.png")
    if os.path.exists(src) and not src.endswith(".svg"):
        im = Image.open(src).convert("RGBA")
        bg = Image.new("RGBA", im.size, (0, 0, 0, 255))
        bg.alpha_composite(im)
        icon_img = bg.convert("RGB").resize((1024, 1024), Image.LANCZOS)
        print("opaque 1024 icon made from", os.path.relpath(src, proj))
    else:
        icon_img = Image.new("RGB", (1024, 1024), (40, 40, 48))   # no usable project icon: a plain one
        print("no project icon: plain 1024 icon made")
    icon_img.save(os.path.join(proj, "_ios_icon_1024.png"))
    icon_opt = "".join(f'icons/{k}="res://_ios_icon_1024.png"\n' for k in ICON_KEYS)
except Exception as e:  # no PIL: Godot uses its own
    print("icon not made:", e)
opts += icon_opt
open(path, "w").write("".join(out) + ("\n" if out else "") + common + opts)
print(f"iOS preset added as preset.{n} (Godot {major}), bundle {bundle}")
