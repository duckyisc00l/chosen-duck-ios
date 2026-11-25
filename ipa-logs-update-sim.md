SUMMARY: PASS. launched, still running, crash reports 0, steps 2 ok / 0 failed, expects 0 passed / 0 failed

app: com.duckyisc00l.thechosenduck (TheChosenDuck)
simulator: iPhone 17 8EBAA496-5654-45BF-897F-3C4FD73935F1
Mach-O 64-bit executable x86_64
com.duckyisc00l.thechosenduck: 35075
launched (try 1)
## input steps
input tool: axe 1.6.0
screen: 402x874 points (steps may give X and Y in points or as 50%)
shot alert
tap 38.6% 58.4%
shot downloading
shot downloaded
relaunch
shot after-update
recording: sim-steps.mp4, sim-steps.gif, sim-sheet.png (contact sheet; frames: 24 from recording)
RESULT: still running after 30s
## first distinct errors (app output, then system log)
sim-console.log:1: objc[35075]: Class AKAlertImageURLProvider is implemented in both /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AuthKit.framework/AuthKit (0x128968f40) and /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 
sim-console.log:2: objc[35075]: Class AKBiometricRatchetUtility is implemented in both /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AuthKit.framework/AuthKit (0x12896af48) and /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iO
sim-console.log:4: objc[35075]: Class UIAccessibilityLoaderWebShared is implemented in both /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/AccessibilityBundles/WebCore.axbundle/WebCore (0x1b94f3328) and /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runt
## last lines of the app's output
objc[35075]: Class AKAlertImageURLProvider is implemented in both /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AuthKit.framework/AuthKit (0x128968f40) and /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AuthKitUI.framework/AuthKitUI (0x18ac25170). This may cause spurious casting failures and mysterious crashes. One of the duplicates must be removed or renamed.
objc[35075]: Class AKBiometricRatchetUtility is implemented in both /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AuthKit.framework/AuthKit (0x12896af48) and /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AuthKitUI.framework/AuthKitUI (0x18ac251e8). This may cause spurious casting failures and mysterious crashes. One of the duplicates must be removed or renamed.
2026-11-25 05:26:24.578 TheChosenDuck[35075:96559] Setting up an OpenGL ES 3.0 context.
objc[35075]: Class UIAccessibilityLoaderWebShared is implemented in both /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/AccessibilityBundles/WebCore.axbundle/WebCore (0x1b94f3328) and /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/AccessibilityBundles/WebKit.axbundle/WebKit (0x1b927d398). This may cause spurious casting failures and mysterious crashes. One of the duplicates must be removed or renamed.
2026-11-25 05:27:17.611 TheChosenDuck[35075:96559] TCDUpdater: new build on itch.io: 20693309/krime (playing old/test)
2026-11-25 05:27:25.626 TheChosenDuck[35075:96559] TCDUpdater: couldn't read the start of the new game data (status 206, 0 bytes); will check it after downloading
2026-11-25 05:29:56.971 TheChosenDuck[35075:96559] TCDUpdater: downloading https://html-classic.itch.zone/html/20693309/krime/index.pck
2026-11-25 05:30:02.945 TheChosenDuck[35075:96559] TCDUpdater: downloaded 20693309/krime (56386768 bytes)
## app's system log (last lines, full in sim-applog.log)
