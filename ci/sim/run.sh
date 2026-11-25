#!/bin/bash
# Run an iPhone app in Apple's iPhone Simulator on a GitHub Mac (there are no real iPhones on GitHub).
# Usage: ci/sim/run.sh <path to .app built for the simulator> <out dir> [seconds to wait, default 25] [input steps]
# The optional steps file has one step per line (AXe does the input; X and Y in points, or as a % of the screen):
#   tap X Y | hold X Y [SECONDS] | swipe X1 Y1 X2 Y2 | tapon LABEL (accessibility label) | trytap LABEL (same, but no failure if absent) | type TEXT | softtype TEXT (on-screen keys) | key NAME (return, escape,
#   backspace, tab, space, up/down/left/right, a letter, or a HID number) | wait SECONDS | shot NAME |
#   ui NAME (save the accessibility tree, list its texts) | uiat X Y (the element at one point) | relaunch (quit and restart the app) | expect TEXT (the text must be on screen: PASS/FAIL) | # comment
# Writes <out>/sim.md (a summary line first; then launched? still running? crash? each step), <out>/sim-<n>s.png
# screenshots, sim-console.log, sim-applog.log, crash reports, and for steps a recording (sim-steps.mp4/.gif,
# sim-sheet.png). Exit 0 only if the app is still running at the end and every step and expect passed.
# Env: SIM_DEVICE="iPhone 16" picks that simulator (name contains it) instead of the last iPhone on the newest iOS.
set -u
# macOS may not have GNU timeout: fall back to perl's alarm (same "timeout SECONDS command..." usage)
command -v timeout > /dev/null || timeout() { local s="$1"; shift; perl -e 'alarm shift; exec @ARGV or exit 127' "$s" "$@"; }
HERE="$(cd "$(dirname "$0")" && pwd)"
APP="$1"; OUT="$2"; WAIT="${3:-25}"; STEPS="${4:-}"
mkdir -p "$OUT"; OUT=$(cd "$OUT" && pwd)   # absolute: the simulator opens --stdout paths from its own folder
BID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP/Info.plist")
EXE=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "$APP/Info.plist")
# newest iOS runtime, first iPhone on it
UDID=$(xcrun simctl list devices available -j | SIM_DEVICE="${SIM_DEVICE:-}" python3 -c "
import json,os,sys,re
d=json.load(sys.stdin)['devices']; want=os.environ['SIM_DEVICE']
rts=sorted([k for k in d if 'iOS' in k], key=lambda k:[int(x) for x in re.findall(r'\d+',k)])
for rt in reversed(rts):
    ph=[x for x in d[rt] if x['name'].startswith('iPhone') and want in x['name']]
    if ph: print(ph[-1]['udid']); break")
NAME=$(xcrun simctl list devices | grep "$UDID" | head -1 | sed 's/ (.*//' | xargs)
{ echo "app: $BID ($EXE)"; echo "simulator: $NAME $UDID"; file "$APP/$EXE" | sed 's/.*: //'; } | tee "$OUT/sim.md"
# The simulator refuses to open a completely unsigned app ("denied by service delegate (SBMainWorkspace)"):
# give it a free local ad-hoc signature (frameworks first, then the app). This changes nothing on a phone build.
find "$APP" -depth \( -name '*.framework' -o -name '*.dylib' -o -name '*.appex' \) -exec codesign --force --sign - --timestamp=none {} \; 2>/dev/null
codesign --force --sign - --timestamp=none "$APP" 2>&1 | tail -1
xcrun simctl boot "$UDID" 2>/dev/null; xcrun simctl bootstatus "$UDID" -b > /dev/null
# skip iOS's one-time "slide to type" keyboard tip: it covers the keyboard and AXe can't tap it (another process)
for dom in com.apple.keyboard.ContinuousPath com.apple.Preferences; do
  xcrun simctl spawn "$UDID" defaults write "$dom" DidShowContinuousPathIntroduction -bool true 2>/dev/null
  xcrun simctl spawn "$UDID" defaults write "$dom" KeyboardContinuousPathEnabled -bool false 2>/dev/null; done
export SIMCTL_CHILD_NSUnbufferedIO=YES   # passed to the app: Foundation output not held back
sleep 15   # let the home screen finish starting, or the first launch is refused too
xcrun simctl install "$UDID" "$APP" || { echo "INSTALL FAILED" | tee -a "$OUT/sim.md"; exit 1; }
before=$(date +%s)
for try in 1 2 3; do
  if [ "$try" = 1 ]; then args=(--terminate-running-process --stdout="$OUT/sim-console.log" --stderr="$OUT/sim-console.log")
  else args=(--terminate-running-process); fi   # later tries: plain launch, in case the redirect is what's refused
  if timeout 150 xcrun simctl launch "${args[@]}" "$UDID" "$BID" >> "$OUT/sim.md" 2>&1; then
    echo "launched (try $try)" | tee -a "$OUT/sim.md"; break
  fi
  # a heavy app (Unity) can keep the launch command waiting past the time limit while it is in fact up
  if xcrun simctl spawn "$UDID" launchctl list 2>/dev/null | grep -q "UIKitApplication:$BID"; then
    echo "launched (try $try; the launch command was slow, but the app is running)" | tee -a "$OUT/sim.md"; break
  fi
  echo "launch refused (try $try)" | tee -a "$OUT/sim.md"; sleep 10
  if [ "$try" = 3 ]; then   # why: SpringBoard's own log lines about this app
    echo "## simulator log about the launch" >> "$OUT/sim.md"
    timeout 120 xcrun simctl spawn "$UDID" log show --last 3m --style compact \
      --predicate "eventMessage CONTAINS[c] '$BID' OR eventMessage CONTAINS[c] '$EXE'" 2>/dev/null | grep -viE "^Timestamp" | tail -40 >> "$OUT/sim.md"
  fi
done
prev=0   # screenshots at 5 s, halfway and at the end
for t in 5 $(( WAIT / 2 )) $WAIT; do
  [ "$t" -gt "$prev" ] || continue; sleep $(( t - prev )); prev=$t
  xcrun simctl io "$UDID" screenshot "$OUT/sim-${t}s.png" > /dev/null 2>&1
done
SN=0; SF=0; EP=0; EF=0   # steps done / failed, expects passed / failed
if [ -n "$STEPS" ] && [ -f "$STEPS" ]; then
  # input: AXe (cameroncooke/AXe, one ready-built program). Meta's idb is not used: no build for older Macs.
  # SIM_AXE_VERSION=v1.6.0: a landscape-only game is drawn turned on the portrait screen, and AXe 1.7+ then fails
  # ("screenshot probing failed for a landscape accessibility frame") or moves the point. 1.6.0 taps the raw
  # portrait screen points, and % steps are then of the portrait screen.
  if [ -n "${SIM_AXE_VERSION:-}" ]; then
    mkdir -p /tmp/axe1 && ( cd /tmp/axe1 && gh release download "$SIM_AXE_VERSION" -R cameroncooke/AXe -p '*.tar.gz' --clobber \
      && for t in *.tar.gz; do tar xzf "$t"; done ) > "$OUT/input-install.log" 2>&1
    ab=$(find /tmp/axe1 -type f -name axe -perm -u+x | head -1)
    if [ -n "$ab" ]; then export PATH="$(dirname "$ab"):$PATH"; else echo "AXe $SIM_AXE_VERSION not found; using the newest" >> "$OUT/sim.md"; fi
  fi
  if ! command -v axe > /dev/null; then
    # no brew self-update (it can take minutes); one retry: a busy runner sometimes stalls the first install
    for t in 1 2; do command -v axe > /dev/null && break
      HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 timeout 480 bash -c 'brew tap cameroncooke/axe && { brew trust cameroncooke/axe 2>/dev/null || true; } && brew install cameroncooke/axe/axe' >> "$OUT/input-install.log" 2>&1
    done
  fi
  echo "## input steps" >> "$OUT/sim.md"
  if ! command -v axe > /dev/null; then
    echo "AXe didn't install (see input-install.log): steps skipped" >> "$OUT/sim.md"; SF=1
  else
    echo "input tool: axe $(axe --version 2>/dev/null | head -1)" >> "$OUT/sim.md"
    UI() { timeout 30 axe describe-ui --udid "$UDID" > "$1" 2>> "$OUT/input.log" < /dev/null; }
    # web pages (WKWebView) don't show in the whole tree, but a lookup at one point finds their text:
    # SCAN asks a grid of points (4 across, every 5% down) and keeps what it finds
    # (4 lookups at a time, one row of the grid; a whole scan takes about a minute instead of several)
    SCAN() { rm -rf /tmp/simscan; mkdir -p /tmp/simscan; local n=0 x y pids
      for y in $(seq 4 5 99); do pids=(); for x in 15 38 62 85; do n=$((n+1))
        timeout 15 axe describe-ui --point "$((x*SW/100)),$((y*SH/100))" --udid "$UDID" > /tmp/simscan/$n.json 2> /dev/null < /dev/null & pids+=($!)
      done; wait "${pids[@]}"; done; python3 "$HERE/ui.py" merge /tmp/simscan/*.json > "$1"; }
    WEB=0   # set once a scan found text the whole tree didn't have: later lookups go straight to the scan
    UI "$OUT/ui-start.json"
    read -r SW SH < <(python3 "$HERE/ui.py" size "$OUT/ui-start.json" || echo "0 0")
    # raw portrait points for AXe 1.6.0, or when the tree timed out (LÖVE): from a screenshot (2x below 1000 pixels wide, else 3x)
    # also when the tree's size isn't the screen's: an app without a UIScene (GameMaker) gave 390x844 on an iPhone SE (375x667)
    xcrun simctl io "$UDID" screenshot /tmp/simsize.png > /dev/null 2>&1
    read -r PW PH < <(python3 -c "import struct,sys;d=open('/tmp/simsize.png','rb').read(24);w,h=struct.unpack('>II',d[16:24]);k=2 if w<1000 else 3;print(w//k,h//k)" 2>/dev/null || echo "0 0")
    if [ -n "${SIM_AXE_VERSION:-}" ] || [ "$SW" = 0 ] || { [ "$PW" != 0 ] && [ "$SW $SH" != "$PW $PH" ] && [ "$SW $SH" != "$PH $PW" ]; }; then
      SW=$PW; SH=$PH
    fi
    echo "screen: ${SW}x${SH} points (steps may give X and Y in points or as 50%)" >> "$OUT/sim.md"
    P() { case "$1" in *%) awk -v v="${1%\%}" -v t="$2" 'BEGIN{printf "%d", v*t/100}';; *) echo "$1";; esac; }
    # one line per step in sim.md; a failed step gets FAILED and its error
    RUN() { local what="$1"; shift
      if timeout 60 "$@" >> "$OUT/input.log" 2>&1 < /dev/null; then echo "$what" >> "$OUT/sim.md"; SN=$((SN+1))
      else echo "$what FAILED: $(tail -1 "$OUT/input.log")" >> "$OUT/sim.md"; SF=$((SF+1)); fi; }
    KEY() { case "$(echo "$1" | tr A-Z a-z)" in
      return|enter) echo 40;; escape|esc) echo 41;; backspace|delete) echo 42;; tab) echo 43;; space) echo 44;;
      right) echo 79;; left) echo 80;; down) echo 81;; up) echo 82;;
      [a-z]) printf '%d' $(( $(printf '%d' "'$(echo "$1" | tr A-Z a-z)") - 93 ));;
      *) echo "$1";; esac; }   # HID usage codes; a number is sent as it is
    # a short screen recording of the steps (turned into a GIF and a contact sheet at the end)
    xcrun simctl io "$UDID" recordVideo --codec=h264 --force "$OUT/sim-steps.mov" > "$OUT/record.log" 2>&1 & REC=$!
    sleep 2
    while IFS= read -r line <&3 || [ -n "$line" ]; do
      line="${line%$'\r'}"; cmd="${line%% *}"; arg="${line#"$cmd"}"; arg="${arg# }"
      read -r a b c d <<< "$arg"
      case "$cmd" in
        tap) RUN "tap $a $b" axe tap -x "$(P "$a" "$SW")" -y "$(P "$b" "$SH")" --udid "$UDID";;
        swipe) RUN "swipe $a,$b -> $c,$d" axe swipe --start-x "$(P "$a" "$SW")" --start-y "$(P "$b" "$SH")" \
                 --end-x "$(P "$c" "$SW")" --end-y "$(P "$d" "$SH")" --duration 0.2 --udid "$UDID";;
        hold) RUN "hold $a $b ${c:-0.3}s" axe touch -x "$(P "$a" "$SW")" -y "$(P "$b" "$SH")" --down --up --delay "${c:-0.3}" --udid "$UDID";;   # touch down, wait, up (for buttons that miss quick taps)
        tapon)   # by accessibility label; if AXe refuses (none, or several), tap the first match's centre
          if timeout 40 axe tap --label "$arg" --udid "$UDID" >> "$OUT/input.log" 2>&1 < /dev/null; then
            echo "tapon \"$arg\"" >> "$OUT/sim.md"; SN=$((SN+1))
          else
            UI "$OUT/ui-now.json"
            python3 "$HERE/ui.py" find "$OUT/ui-now.json" "$arg" > /dev/null || { SCAN "$OUT/ui-now.json"; WEB=1; }
            if xy=$(python3 "$HERE/ui.py" find "$OUT/ui-now.json" "$arg"); then
              RUN "tapon \"$arg\" (at $xy)" axe tap -x "${xy% *}" -y "${xy#* }" --udid "$UDID"
            else echo "tapon \"$arg\" FAILED: not on screen. On screen: $(python3 "$HERE/ui.py" labels "$OUT/ui-now.json")" >> "$OUT/sim.md"; SF=$((SF+1)); fi
          fi;;
        softtype)   # tap the letters on iOS's on-screen keyboard (for games that ignore AXe's hardware-key typing)
          # the keys' places come from the whole tree, else (a game whose tree times out, like LÖVE) from point
          # lookups over the keyboard's half of the screen, done once and kept in ui-keys.json
          kb="$OUT/ui-keys.json"; bad=""
          if [ ! -s "$kb" ] || ! python3 "$HERE/ui.py" find "$kb" q exact > /dev/null; then
            UI "$kb"
            if ! python3 "$HERE/ui.py" find "$kb" q exact > /dev/null; then
              rm -rf /tmp/simkeys; mkdir -p /tmp/simkeys; n=0
              for y in $(seq 58 3 97); do pids=(); for x in $(seq 3 5 98); do n=$((n+1))
                timeout 15 axe describe-ui --point "$((x*SW/100)),$((y*SH/100))" --udid "$UDID" > /tmp/simkeys/$n.json 2> /dev/null < /dev/null & pids+=($!)
                [ $((n % 5)) = 0 ] && { wait "${pids[@]}"; pids=(); }; done; [ ${#pids[@]} -gt 0 ] && wait "${pids[@]}"; done
              python3 "$HERE/ui.py" merge /tmp/simkeys/*.json > "$kb"
            fi
          fi
          for ((i=0; i<${#arg}; i++)); do ch="${arg:i:1}"; [ "$ch" = " " ] && ch=space
            if xy=$(python3 "$HERE/ui.py" find "$kb" "$ch" exact); then
              timeout 60 axe tap -x "${xy% *}" -y "${xy#* }" --udid "$UDID" >> "$OUT/input.log" 2>&1 < /dev/null || bad="$bad$ch"   # a LÖVE app makes each tap take 20-40 s
            else bad="$bad$ch"; fi; sleep 0.3; done
          if [ -z "$bad" ]; then echo "softtype \"$arg\"" >> "$OUT/sim.md"; SN=$((SN+1))
          else echo "softtype \"$arg\" FAILED for: $bad (keyboard not up?)" >> "$OUT/sim.md"; SF=$((SF+1)); fi;;
        trytap)   # tap the element with this label if it is there; no failure if not (e.g. iOS's one-time keyboard tip "Continue")
          timeout 40 axe tap --label "$arg" --udid "$UDID" >> "$OUT/input.log" 2>&1 < /dev/null && echo "trytap \"$arg\": tapped" >> "$OUT/sim.md" || echo "trytap \"$arg\": not there" >> "$OUT/sim.md";;
        type) RUN "type \"$arg\"" axe type "$arg" --udid "$UDID";;
        key) RUN "key $arg" axe key "$(KEY "$a")" --udid "$UDID";;
        wait) sleep "$a";;
        relaunch) timeout 60 xcrun simctl terminate "$UDID" "$BID" > /dev/null 2>&1; sleep 2   # quit and start again: do saves survive?
          RUN "relaunch" xcrun simctl launch "$UDID" "$BID";;
        shot) xcrun simctl io "$UDID" screenshot "$OUT/sim-$a.png" > /dev/null 2>&1 && echo "shot $a" >> "$OUT/sim.md";;
        uiat) timeout 60 axe describe-ui --point "$(P "$a" "$SW"),$(P "$b" "$SH")" --udid "$UDID" > "$OUT/ui-at.json" 2>> "$OUT/input.log" < /dev/null
          echo "uiat $a $b: $(python3 "$HERE/ui.py" labels "$OUT/ui-at.json")" >> "$OUT/sim.md";;
        ui) UI "$OUT/ui-$a.json"; echo "ui $a: $(python3 "$HERE/ui.py" labels "$OUT/ui-$a.json")" >> "$OUT/sim.md";;
        expect)   # the text must be in the accessibility tree; retried for up to ~8 s while the screen settles
          hit=1; for i in 1 2 3 4; do UI "$OUT/ui-now.json"; python3 "$HERE/ui.py" has "$OUT/ui-now.json" "$arg" && { hit=0; break; }
            [ $WEB = 1 ] && break; sleep 2; done
          for i in 1 2; do [ $hit = 1 ] || break   # a web page? its text only shows in point lookups
            SCAN "$OUT/ui-now.json"; python3 "$HERE/ui.py" has "$OUT/ui-now.json" "$arg" && { hit=0; WEB=1; } || sleep 3; done
          if [ $hit = 0 ]; then echo "expect \"$arg\": PASS" >> "$OUT/sim.md"; EP=$((EP+1))
          else echo "expect \"$arg\": FAIL. On screen: $(python3 "$HERE/ui.py" labels "$OUT/ui-now.json")" >> "$OUT/sim.md"; EF=$((EF+1)); fi;;
        ''|'#'*) ;;
        *) echo "unknown step: $line" >> "$OUT/sim.md"; SF=$((SF+1));;
      esac
    done 3< "$STEPS"
    sleep 1; kill -INT $REC 2>/dev/null; wait $REC 2>/dev/null; rm -f "$OUT/ui-now.json"
    # recording -> frames (AVFoundation, through a small Swift script: no ffmpeg on GitHub's Macs) -> GIF + contact sheet.
    # The full-size .mov is too big to keep (180 MB for a few minutes): a small .mp4 copy is kept instead.
    rm -rf /tmp/simframes; mkdir -p /tmp/simframes
    [ -s "$OUT/sim-steps.mov" ] && timeout 240 swift "$HERE/frames.swift" "$OUT/sim-steps.mov" /tmp/simframes 24 >> "$OUT/record.log" 2>&1
    [ -s "$OUT/sim-steps.mov" ] && timeout 240 avconvert --preset PresetLowQuality --source "$OUT/sim-steps.mov" --output "$OUT/sim-steps.mp4" >> "$OUT/record.log" 2>&1
    rm -f "$OUT/sim-steps.mov"
    python3 -m venv /tmp/pilv > /dev/null 2>&1 && timeout 180 /tmp/pilv/bin/pip install -q pillow > /dev/null 2>&1
    /tmp/pilv/bin/python - "$OUT" /tmp/simframes <<'PY' >> "$OUT/record.log" 2>&1
import glob, os, sys
from PIL import Image
out, fr = sys.argv[1], sys.argv[2]
fs = sorted(glob.glob(fr + "/f*.png"))   # frames from the recording, else the step screenshots
if not fs: fs = [f for f in sorted(glob.glob(out + "/sim-*.png"), key=os.path.getmtime) if not f.endswith("sim-sheet.png")]
ims = [Image.open(f).convert("RGB") for f in fs]
ims = [i.resize((200, int(200 * i.height / i.width))) for i in ims]
if ims:
    ims[0].save(out + "/sim-steps.gif", save_all=True, append_images=ims[1:], duration=700, loop=0)
    pick = ims if len(ims) <= 12 else [ims[round(k * (len(ims) - 1) / 11)] for k in range(12)]
    h = max(i.height for i in pick); cols = min(6, len(pick)); rows = (len(pick) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * 204, rows * (h + 4)), "white")
    for n, i in enumerate(pick): sheet.paste(i, ((n % cols) * 204, (n // cols) * (h + 4)))
    sheet.save(out + "/sim-sheet.png")
    print("frames:", len(fs), "from", "recording" if fs[0].startswith(fr) else "screenshots")
PY
    [ -s "$OUT/sim-sheet.png" ] && echo "recording: sim-steps.mp4, sim-steps.gif, sim-sheet.png (contact sheet; $(tail -1 "$OUT/record.log"))" >> "$OUT/sim.md"
  fi
  [ "$SF" -gt 0 ] && { echo "## input errors (last lines)" >> "$OUT/sim.md"; tail -8 "$OUT/input.log" >> "$OUT/sim.md" 2>/dev/null; }
fi
if xcrun simctl spawn "$UDID" launchctl list 2>/dev/null | grep -q "UIKitApplication:$BID"; then
  echo "RESULT: still running after ${WAIT}s" | tee -a "$OUT/sim.md"; ok=0
else
  echo "RESULT: NOT running after ${WAIT}s (crashed or quit)" | tee -a "$OUT/sim.md"; ok=1
fi
# crash reports written since launch
for f in $(find ~/Library/Logs/DiagnosticReports -name "*.ips" -newermt "@$before" 2>/dev/null | grep -i "$EXE"); do
  cp "$f" "$OUT/"; echo "## crash report $(basename "$f")" >> "$OUT/sim.md"
  python3 - "$f" >> "$OUT/sim.md" <<'P'
import json,sys
t=open(sys.argv[1]).read().split('\n',1)
try:
    d=json.loads(t[1]); e=d.get('exception',{}); print('exception:',e.get('type'),e.get('signal'),d.get('termination',{}).get('indicator'))
    th=[x for x in d.get('threads',[]) if x.get('triggered')]
    imgs=d.get('usedImages',[])
    for fr in (th[0]['frames'][:15] if th else []):
        im=imgs[fr['imageIndex']]['name'] if fr.get('imageIndex') is not None and fr['imageIndex']<len(imgs) else '?'
        print('  ',im,fr.get('symbol','?'))
    if d.get('asi'): print('asi:',d['asi'])
except Exception as x: print('could not read report:',x)
P
done
# engines that log through Apple's system log (Godot, Unity, SDL) don't show in the console file: save that log too
timeout 120 xcrun simctl spawn "$UDID" log show --start "$(date -r "$before" '+%Y-%m-%d %H:%M:%S')" --style compact \
  --predicate "process == '$EXE'" 2>/dev/null | grep -viE '^Timestamp|restoration' | head -20000 > "$OUT/sim-applog.log"   # from the start: the first errors matter most
# the first distinct errors say more than the last ones, which often just repeat; the same error with
# another object name, number or address counts once, with how many times it came
echo "## first distinct errors (app output, then system log)" >> "$OUT/sim.md"
python3 "$HERE/ui.py" errors "$OUT/sim-console.log" "$OUT/sim-applog.log" >> "$OUT/sim.md"
echo "## last lines of the app's output" >> "$OUT/sim.md"
tail -40 "$OUT/sim-console.log" >> "$OUT/sim.md" 2>/dev/null
echo "## app's system log (last lines, full in sim-applog.log)" >> "$OUT/sim.md"; tail -25 "$OUT/sim-applog.log" >> "$OUT/sim.md"
# one summary line at the top of sim.md
crashes=$(grep -c '^## crash report' "$OUT/sim.md")
running=$( [ "$ok" = 0 ] && echo 'still running' || echo 'NOT running')
[ "$ok" = 0 ] && [ "$SF" = 0 ] && [ "$EF" = 0 ] && verdict=PASS || { verdict=FAIL; ok=1; }
sum="SUMMARY: $verdict. $(grep -q '^launched' "$OUT/sim.md" && echo launched || echo 'NOT launched'), $running, crash reports $crashes"
[ -n "$STEPS" ] && sum="$sum, steps $SN ok / $SF failed, expects $EP passed / $EF failed"
{ echo "$sum"; echo; cat "$OUT/sim.md"; } > "$OUT/sim.md.new" && mv "$OUT/sim.md.new" "$OUT/sim.md"; echo "$sum"
exit $ok
