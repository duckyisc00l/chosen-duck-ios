#!/usr/bin/env python3
"""Helpers for ci/sim/run.sh (plain Python 3, nothing to install).
  ui.py size   <describe-ui.json>          -> "W H": the screen in points (largest frame)
  ui.py find   <describe-ui.json> <label>  -> "X Y": centre of the first element with that label
                                              (exact, else contains, case ignored); exit 1 if none
  ui.py merge  <json>...                   -> one list of all the elements (from point lookups)
  ui.py has    <describe-ui.json> <text>   -> exit 0 if any label/value/title contains the text
  ui.py labels <describe-ui.json>          -> the texts on screen, one line, for the report
  ui.py errors <log> [<log>...]            -> first distinct errors, repeats grouped with a count
"""
import json, re, sys

def walk(node):
    if isinstance(node, list):
        for x in node: yield from walk(x)
    elif isinstance(node, dict):
        yield node
        for v in node.values():
            if isinstance(v, (list, dict)): yield from walk(v)

def load(p):
    try: return list(walk(json.load(open(p))))
    except Exception: return []

def texts(el):
    out = []
    for k in ("AXLabel", "AXValue", "title", "label", "value", "AXUniqueId"):
        v = el.get(k)
        if isinstance(v, str) and v.strip(): out.append(v.strip())
    return out

def frame(el):
    f = el.get("frame")
    if isinstance(f, dict) and "width" in f: return f["x"], f["y"], f["width"], f["height"]
    return None

cmd = sys.argv[1]
if cmd == "size":
    fr = [frame(e) for e in load(sys.argv[2]) if frame(e)]
    w, h = max(((f[2], f[3]) for f in fr), key=lambda t: t[0] * t[1], default=(0, 0))
    if not w: sys.exit(1)
    print(int(w), int(h))
if cmd == "find":
    want = sys.argv[3].strip().lower(); els = [e for e in load(sys.argv[2]) if frame(e)]
    for exact in ((True,) if sys.argv[4:] == ["exact"] else (True, False)):
        for e in els:
            for t in texts(e):
                if (t.lower() == want) if exact else (want in t.lower()):
                    x, y, w, h = frame(e)
                    if w > 0 and h > 0: print(int(x + w / 2), int(y + h / 2)); sys.exit(0)
    sys.exit(1)
if cmd == "merge":   # several describe-ui outputs (one per point) -> one list
    out = []
    for p in sys.argv[2:]:
        try: d = json.load(open(p))
        except Exception: continue
        out.extend(d if isinstance(d, list) else [d])
    print(json.dumps(out))
if cmd == "has":
    want = sys.argv[3]
    sys.exit(0 if any(want in t for e in load(sys.argv[2]) for t in texts(e)) else 1)
if cmd == "labels":
    seen = []
    for e in load(sys.argv[2]):
        for t in texts(e):
            t = " ".join(t.split())[:60]
            if t not in seen: seen.append(t)
    print(" | ".join(seen)[:1500] or "(no text in the accessibility tree: a game view, or not loaded yet)")
if cmd == "errors":
    pat = re.compile(r"exception|error|fail|missing|not found|could not|unable", re.I)
    skip = re.compile(r"restoration", re.I)
    groups = {}
    for p in sys.argv[2:]:
        try: lines = open(p, errors="replace").read().splitlines()
        except OSError: continue
        for n, line in enumerate(lines, 1):
            if not pat.search(line) or skip.search(line): continue
            # the same error with a different object name, address, time or number is one error
            body = re.sub(r"^\d{4}-\d\d-\d\d[ T][\d:.]+\S*\s+(\S+\s+)?\S+\[\d+:\w+\]\s*", "", line)
            key = re.sub(r"'[^']*'|\"[^\"]*\"|‘[^’]*’|“[^”]*”", "'…'", body)
            key = re.sub(r"0x[0-9a-fA-F]+|\b[0-9a-fA-F]{8}-[0-9a-fA-F-]{27}\b|\d+(\.\d+)?", "#", key)
            g = groups.setdefault(key, {"first": f"{p.split('/')[-1]}:{n}: {body.strip()[:400]}", "count": 0})
            g["count"] += 1
    for i, g in enumerate(groups.values()):
        if i >= 25: print(f"... and {len(groups) - 25} more distinct errors"); break
        print(g["first"] + (f"   [x{g['count']} similar]" if g["count"] > 1 else ""))
