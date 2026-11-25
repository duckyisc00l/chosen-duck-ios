#!/bin/bash
# Build an Xcode project for the iPhone Simulator and run it there with ci/sim/run.sh.
# Usage: ci/sim/build-and-run.sh <.xcodeproj or .xcworkspace> <scheme> <out dir> [wait seconds] [input steps file]
# Env: SIM_PRE_RUN="command" runs after the build with $APP set to the built .app (to add files, e.g. a JS bundle).
#      SIM_XCODE_ARGS='SETTING="value with spaces"' adds build settings to the simulator build only.
#      SIM_ARCHS=x86_64 builds only that simulator architecture (Godot's simulator templates are Intel-only;
#      Apple-chip Macs run such apps through Rosetta).
set -u
P="$1"; S="$2"; OUT="$3"; WAIT="${4:-30}"; STEPS="${5:-}"
HERE="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$OUT"; OUT=$(cd "$OUT" && pwd)
case "$P" in *.xcworkspace) kind=-workspace;; *) kind=-project;; esac
DD="$(dirname "$P")/simdd"
arch_args=(ONLY_ACTIVE_ARCH=NO)
[ -n "${SIM_ARCHS:-}" ] && arch_args=(ARCHS="$SIM_ARCHS" ONLY_ACTIVE_ARCH=NO EXCLUDED_ARCHS="")
[ -n "${SIM_XCODE_ARGS:-}" ] && eval "arch_args+=($SIM_XCODE_ARGS)"
xcodebuild $kind "$P" -scheme "$S" -configuration Release -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DD" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" "${arch_args[@]}" build > "$OUT/sim-build.log" 2>&1
xc=$?
echo "simulator build exit $xc" | tee "$OUT/sim-build.md"
grep -E "error:|\*\* BUILD" "$OUT/sim-build.log" | sort -u | head -20 | tee -a "$OUT/sim-build.md"
[ "$xc" = 0 ] || exit 1
APP=$(find "$DD/Build/Products" -maxdepth 2 -name '*.app' | head -1)
[ -n "${SIM_PRE_RUN:-}" ] && APP="$APP" bash -c "$SIM_PRE_RUN"
"$HERE/run.sh" "$APP" "$OUT" "$WAIT" "$STEPS"
