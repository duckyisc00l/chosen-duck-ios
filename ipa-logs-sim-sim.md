SUMMARY: FAIL. launched, NOT running, crash reports 0, steps 1 ok / 0 failed, expects 0 passed / 0 failed

app: com.duckyisc00l.thechosenduck (TheChosenDuck)
simulator: iPhone 17 8EBAA496-5654-45BF-897F-3C4FD73935F1
Mach-O 64-bit executable x86_64
com.duckyisc00l.thechosenduck: 14838
launched (try 1)
## input steps
input tool: axe 1.6.0
screen: 402x874 points (steps may give X and Y in points or as 50%)
shot menu
tap 46% 49%
shot campaign-60s
shot campaign-120s
shot campaign-180s
recording: sim-steps.mp4, sim-steps.gif, sim-sheet.png (contact sheet; frames: 24 from recording)
RESULT: NOT running after 90s (crashed or quit)
## first distinct errors (app output, then system log)
sim-console.log:4: objc[14838]: Class AKAlertImageURLProvider is implemented in both /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AuthKit.framework/AuthKit (0x12a058f40) and /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 
sim-console.log:5: objc[14838]: Class AKBiometricRatchetUtility is implemented in both /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AuthKit.framework/AuthKit (0x12a05af48) and /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iO
sim-console.log:6: objc[14838]: Class UIAccessibilityLoaderWebShared is implemented in both /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/AccessibilityBundles/WebCore.axbundle/WebCore (0x1c2653328) and /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runt
## last lines of the app's output
2026-11-25 05:14:52.622 TheChosenDuck[14838:47369] Warning: Unable to create restoration in progress marker file
2026-11-25 05:15:05.563 TheChosenDuck[14838:47369] Setting up an OpenGL ES 3.0 context.
2026-11-25 05:15:58.486 TheChosenDuck[14838:47369] TCDUpdater: up to date (20693309/krime)
objc[14838]: Class AKAlertImageURLProvider is implemented in both /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AuthKit.framework/AuthKit (0x12a058f40) and /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AuthKitUI.framework/AuthKitUI (0x19b12f170). This may cause spurious casting failures and mysterious crashes. One of the duplicates must be removed or renamed.
objc[14838]: Class AKBiometricRatchetUtility is implemented in both /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AuthKit.framework/AuthKit (0x12a05af48) and /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AuthKitUI.framework/AuthKitUI (0x19b12f1e8). This may cause spurious casting failures and mysterious crashes. One of the duplicates must be removed or renamed.
objc[14838]: Class UIAccessibilityLoaderWebShared is implemented in both /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/AccessibilityBundles/WebCore.axbundle/WebCore (0x1c2653328) and /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/AccessibilityBundles/WebKit.axbundle/WebKit (0x1c25d9398). This may cause spurious casting failures and mysterious crashes. One of the duplicates must be removed or renamed.
## app's system log (last lines, full in sim-applog.log)
