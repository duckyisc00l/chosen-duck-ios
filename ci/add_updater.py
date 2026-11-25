"""Add ios/TCDUpdater.m (update checker) to the Xcode project Godot exported.
Usage: python3 ci/add_updater.py <export dir>"""
import glob, os, shutil, sys
from pbxproj import XcodeProject
exp = sys.argv[1]
pbx = glob.glob(os.path.join(exp, "*.xcodeproj", "project.pbxproj"))[0]
dst = os.path.join(exp, "TCDUpdater.m")
shutil.copy(os.path.join(os.path.dirname(__file__), "..", "ios", "TCDUpdater.m"), dst)
proj = XcodeProject.load(pbx)
proj.add_file("TCDUpdater.m", force=False)
proj.save()
print("added", dst, "to", pbx)
