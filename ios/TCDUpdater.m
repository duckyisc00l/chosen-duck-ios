// TCDUpdater.m: keeps The Chosen Duck up to date with the itch.io release.
//
// At launch, if Documents/update/game.pck exists (a newer version downloaded earlier), Godot is
// started with "--main-pack <that file>" instead of the game data inside the app. If that version
// fails to keep running for 25 seconds, the next launch goes back to the built-in version.
//
// A few seconds after launch, when online, it reads the itch.io page. If the web build there is
// newer than the one being played and uses the same Godot version (4.7), it asks before
// downloading it (about 55 MB). The new version is used from the next launch.
// Saves live in Documents (Godot's user://) and are shared by every version.
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define TCD_PAGE @"https://fogorredo.itch.io/the-chosen-duck"
#define TCD_BUNDLED_BUILD @"20693309/krime"   // the itch.io web build inside this app
#define TCD_GODOT_MAJOR 4
#define TCD_GODOT_MINOR 7

static NSArray<NSString *> *tcdExtraArgs = nil;
static BOOL tcdUsingUpdate = NO;

static NSString *TCDDir(void) {
    NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [docs stringByAppendingPathComponent:@"update"];
}
static NSString *TCDFile(NSString *name) { return [TCDDir() stringByAppendingPathComponent:name]; }
static BOOL TCDExists(NSString *name) { return [[NSFileManager defaultManager] fileExistsAtPath:TCDFile(name)]; }
static void TCDWrite(NSString *name, NSString *text) {
    [[NSFileManager defaultManager] createDirectoryAtPath:TCDDir() withIntermediateDirectories:YES attributes:nil error:nil];
    [text writeToFile:TCDFile(name) atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
static NSString *TCDRead(NSString *name) {
    NSString *s = [NSString stringWithContentsOfFile:TCDFile(name) encoding:NSUTF8StringEncoding error:nil];
    return [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
static void TCDRemove(NSString *name) { [[NSFileManager defaultManager] removeItemAtPath:TCDFile(name) error:nil]; }
static void TCDLog(NSString *msg) {
    NSLog(@"TCDUpdater: %@", msg);
    NSString *line = [NSString stringWithFormat:@"%@ %@\n", [NSDate date], msg];
    NSString *path = TCDFile(@"updater-log.txt");
    [[NSFileManager defaultManager] createDirectoryAtPath:TCDDir() withIntermediateDirectories:YES attributes:nil error:nil];
    NSFileHandle *h = [NSFileHandle fileHandleForWritingAtPath:path];
    if (!h) { [line writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil]; return; }
    [h seekToEndOfFile]; [h writeData:[line dataUsingEncoding:NSUTF8StringEncoding]]; [h closeFile];
}

// The build being played: the downloaded one if it's in use, else the one inside the app.
static NSString *TCDCurrentBuild(void) {
    if (tcdUsingUpdate) { NSString *b = TCDRead(@"build.txt"); if (b.length) return b; }
    NSString *fake = [[NSUserDefaults standardUserDefaults] stringForKey:@"TCDFakeCurrent"];  // test hook: pretend to be older
    if (fake.length) return fake;
    return TCD_BUNDLED_BUILD;
}

// ---- Choosing which game data Godot starts with ----
@implementation NSProcessInfo (TCDUpdater)
- (NSArray<NSString *> *)tcd_arguments {
    NSArray *orig = [self tcd_arguments];   // swapped: calls the original
    if (!tcdExtraArgs.count || orig.count == 0) return orig;
    NSMutableArray *a = [NSMutableArray arrayWithObject:orig[0]];
    [a addObjectsFromArray:tcdExtraArgs];
    [a addObjectsFromArray:[orig subarrayWithRange:NSMakeRange(1, orig.count - 1)]];
    return a;
}
@end

static void TCDChoosePack(void) {
    @autoreleasepool {
        if (!TCDExists(@"game.pck")) return;
        if (TCDExists(@"ok")) {
            tcdUsingUpdate = YES;
        } else if (TCDExists(@"trying")) {
            // last launch of this version didn't last: go back to the built-in game
            NSString *bad = TCDRead(@"build.txt");
            TCDLog([NSString stringWithFormat:@"update %@ didn't start properly; using the built-in version", bad]);
            if (bad.length) TCDWrite(@"skip.txt", bad);
            TCDRemove(@"game.pck"); TCDRemove(@"trying"); TCDRemove(@"build.txt"); TCDRemove(@"override.cfg");
            return;
        } else {
            TCDWrite(@"trying", @"1");
            tcdUsingUpdate = YES;
        }
        TCDLog([NSString stringWithFormat:@"starting with downloaded version %@", TCDRead(@"build.txt")]);
        tcdExtraArgs = @[@"--main-pack", TCDFile(@"game.pck")];
        Method m1 = class_getInstanceMethod([NSProcessInfo class], @selector(arguments));
        Method m2 = class_getInstanceMethod([NSProcessInfo class], @selector(tcd_arguments));
        method_exchangeImplementations(m1, m2);
    }
}

// ---- Checking itch.io for a newer version ----
@interface TCDUpdater : NSObject <NSURLSessionDownloadDelegate>
@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, strong) UIAlertController *progressAlert;
@property(nonatomic, copy) NSString *pendingBuild;
@property(nonatomic) long long expectedSize;
@property(nonatomic) BOOL retried;
@property(nonatomic) BOOL wrongEngine;
@end

static TCDUpdater *tcdUpdater = nil;

static UIViewController *TCDTopController(void) {
    UIWindow *win = nil;
    for (UIScene *s in UIApplication.sharedApplication.connectedScenes) {
        if (![s isKindOfClass:[UIWindowScene class]]) continue;
        for (UIWindow *w in ((UIWindowScene *)s).windows) if (w.isKeyWindow) { win = w; break; }
        if (!win) win = ((UIWindowScene *)s).windows.firstObject;
    }
    if (!win) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        win = UIApplication.sharedApplication.keyWindow ?: UIApplication.sharedApplication.windows.firstObject;
#pragma clang diagnostic pop
    }
    UIViewController *vc = win.rootViewController;
    while (vc.presentedViewController) vc = vc.presentedViewController;
    return vc;
}

static NSString *TCDFirstMatch(NSString *text, NSString *pattern, NSUInteger group) {
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSTextCheckingResult *m = [re firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
    if (!m || [m rangeAtIndex:group].location == NSNotFound) return nil;
    return [text substringWithRange:[m rangeAtIndex:group]];
}

@implementation TCDUpdater

- (instancetype)init {
    if ((self = [super init])) {
        NSURLSessionConfiguration *c = [NSURLSessionConfiguration defaultSessionConfiguration];
        c.timeoutIntervalForRequest = 20; c.timeoutIntervalForResource = 1800;
        c.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        self.session = [NSURLSession sessionWithConfiguration:c delegate:self delegateQueue:NSOperationQueue.mainQueue];
    }
    return self;
}

- (void)fetch:(NSString *)url range:(NSString *)range done:(void (^)(NSData *data, NSInteger status))done {
    NSMutableURLRequest *r = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    if (range) [r setValue:range forHTTPHeaderField:@"Range"];
    [r setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X)" forHTTPHeaderField:@"User-Agent"];
    [[self.session dataTaskWithRequest:r completionHandler:^(NSData *d, NSURLResponse *resp, NSError *e) {
        NSInteger st = [resp isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse *)resp).statusCode : 0;
        done(e ? nil : d, st);
    }] resume];
}

- (void)check {
    NSString *current = TCDCurrentBuild();
    [self fetch:TCD_PAGE range:nil done:^(NSData *data, NSInteger st) {
        if (st == 429 && !self.retried) {   // itch.io asked to slow down: try once more a bit later
            self.retried = YES; TCDLog(@"itch.io busy (429), trying again in 45 s");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 45 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ [self check]; });
            return;
        }
        if (!data || st != 200) { TCDLog([NSString stringWithFormat:@"offline or page unavailable (%ld)", (long)st]); return; }
        NSString *page = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
        NSString *build = TCDFirstMatch(page, @"html-classic\\.itch\\.zone/html/([0-9]+(?:/[A-Za-z0-9_.\\-]+)*)/index\\.html", 1);
        if (!build) { TCDLog(@"no web build found on the page"); return; }
        if ([build isEqualToString:current]) { TCDLog([NSString stringWithFormat:@"up to date (%@)", build]); return; }
        if ([build isEqualToString:TCDRead(@"skip.txt")]) { TCDLog([NSString stringWithFormat:@"skipping %@", build]); return; }
        TCDLog([NSString stringWithFormat:@"new build on itch.io: %@ (playing %@)", build, current]);
        [self inspect:build];
    }];
}

- (void)inspect:(NSString *)build {
    NSString *base = [NSString stringWithFormat:@"https://html-classic.itch.zone/html/%@/", build];
    [self fetch:[base stringByAppendingString:@"index.html"] range:nil done:^(NSData *data, NSInteger st) {
        NSString *html = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (!html || st != 200) { TCDLog(@"couldn't read the new build's page"); return; }
        NSString *exe = TCDFirstMatch(html, @"\"executable\"\\s*:\\s*\"([^\"]+)\"", 1) ?: @"index";
        NSString *pckName = [exe stringByAppendingString:@".pck"];
        NSString *size = TCDFirstMatch(html, [NSString stringWithFormat:@"\"%@\"\\s*:\\s*([0-9]+)", [NSRegularExpression escapedPatternForString:pckName]], 1);
        self.expectedSize = size.longLongValue;
        NSString *pckURL = [base stringByAppendingString:pckName];
        // the Godot version is in the first bytes of the game data
        [self fetch:pckURL range:@"bytes=0-31" done:^(NSData *head, NSInteger st2) {
            if (!head || head.length < 20) {
                TCDLog([NSString stringWithFormat:@"couldn't read the start of the new game data (status %ld, %lu bytes); will check it after downloading", (long)st2, (unsigned long)head.length]);
                NSString *mb = self.expectedSize > 0 ? [NSString stringWithFormat:@" (%lld MB)", (self.expectedSize + 524288) / 1048576] : @"";
                [self ask:@"Update available"
                  message:[NSString stringWithFormat:@"A new version of The Chosen Duck is out on itch.io. Download it now%@? Your saves are kept.", mb]
                       ok:@"Download" cancel:@"Later" then:^{ [self download:pckURL build:build]; }];
                return;
            }
            const uint8_t *b = head.bytes;
            uint32_t v[5]; memcpy(v, b, 20);
            if (memcmp(b, "GDPC", 4) != 0) { TCDLog(@"new game data isn't a Godot pack"); return; }
            TCDLog([NSString stringWithFormat:@"new build uses Godot %u.%u.%u", v[2], v[3], v[4]]);
            if (v[2] != TCD_GODOT_MAJOR || v[3] != TCD_GODOT_MINOR) {
                TCDWrite(@"skip.txt", build);
                [self ask:@"Update needs a new app"
                  message:[NSString stringWithFormat:@"A new version of The Chosen Duck is out, but it's made with Godot %u.%u, which this app can't run. Ask for a new IPA to get it. You can keep playing this version.", v[2], v[3]]
                       ok:@"OK" cancel:nil then:nil];
                return;
            }
            NSString *mb = self.expectedSize > 0 ? [NSString stringWithFormat:@" (%lld MB)", (self.expectedSize + 524288) / 1048576] : @"";
            [self ask:@"Update available"
              message:[NSString stringWithFormat:@"A new version of The Chosen Duck is out on itch.io. Download it now%@? Your saves are kept.", mb]
                   ok:@"Download" cancel:@"Later" then:^{ [self download:pckURL build:build]; }];
        }];
    }];
}

- (void)ask:(NSString *)title message:(NSString *)msg ok:(NSString *)ok cancel:(NSString *)cancel then:(void (^)(void))then {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    if (cancel) [a addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil]];
    [a addAction:[UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:^(UIAlertAction *x) { if (then) then(); }]];
    [TCDTopController() presentViewController:a animated:YES completion:nil];
}

- (void)download:(NSString *)url build:(NSString *)build {
    self.pendingBuild = build;
    TCDLog([NSString stringWithFormat:@"downloading %@", url]);
    self.progressAlert = [UIAlertController alertControllerWithTitle:@"Downloading update" message:@"0%" preferredStyle:UIAlertControllerStyleAlert];
    NSURLSessionDownloadTask *t = [self.session downloadTaskWithURL:[NSURL URLWithString:url]];
    [self.progressAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *x) { [t cancel]; }]];
    [TCDTopController() presentViewController:self.progressAlert animated:YES completion:nil];
    UIApplication.sharedApplication.idleTimerDisabled = YES;
    [t resume];
}

- (void)URLSession:(NSURLSession *)s downloadTask:(NSURLSessionDownloadTask *)t didWriteData:(int64_t)w totalBytesWritten:(int64_t)tw totalBytesExpectedToWrite:(int64_t)te {
    int64_t total = te > 0 ? te : self.expectedSize;
    if (total > 0) self.progressAlert.message = [NSString stringWithFormat:@"%d%%  (%lld of %lld MB)", (int)(tw * 100 / total), tw / 1048576, total / 1048576];
}

- (void)URLSession:(NSURLSession *)s downloadTask:(NSURLSessionDownloadTask *)t didFinishDownloadingToURL:(NSURL *)loc {
    NSFileManager *fm = NSFileManager.defaultManager;
    NSInteger st = [t.response isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse *)t.response).statusCode : 0;
    NSDictionary *attr = [fm attributesOfItemAtPath:loc.path error:nil];
    long long got = [attr fileSize];
    NSFileHandle *h = [NSFileHandle fileHandleForReadingAtPath:loc.path];
    NSData *head = [h readDataOfLength:20]; [h closeFile];
    uint32_t v[5] = {0};
    if (head.length == 20) memcpy(v, head.bytes, 20);
    BOOL good = st == 200 && head.length == 20 && memcmp(head.bytes, "GDPC", 4) == 0 && (self.expectedSize <= 0 || got == self.expectedSize);
    if (!good) { TCDLog([NSString stringWithFormat:@"download check failed (status %ld, %lld bytes)", (long)st, got]); return; }
    if (v[2] != TCD_GODOT_MAJOR || v[3] != TCD_GODOT_MINOR) {
        TCDLog([NSString stringWithFormat:@"downloaded data needs Godot %u.%u: not used", v[2], v[3]]);
        TCDWrite(@"skip.txt", self.pendingBuild);
        self.wrongEngine = YES;
        return;
    }
    [fm createDirectoryAtPath:TCDDir() withIntermediateDirectories:YES attributes:nil error:nil];
    // don't replace a version that's running right now: the new one is used from the next launch
    NSString *part = TCDFile(@"game.pck.new");
    [fm removeItemAtPath:part error:nil];
    if (![fm moveItemAtPath:loc.path toPath:part error:nil]) { TCDLog(@"couldn't save the download"); return; }
    TCDWrite(@"next.txt", self.pendingBuild);
    TCDLog([NSString stringWithFormat:@"downloaded %@ (%lld bytes)", self.pendingBuild, got]);
}

- (void)URLSession:(NSURLSession *)s task:(NSURLSessionTask *)t didCompleteWithError:(NSError *)e {
    if (![t isKindOfClass:[NSURLSessionDownloadTask class]]) return;
    UIApplication.sharedApplication.idleTimerDisabled = NO;
    [self.progressAlert dismissViewControllerAnimated:YES completion:^{
        if (e) {
            if (e.code != NSURLErrorCancelled) [self ask:@"Download failed" message:@"Check your connection. It'll ask again next time you open the game." ok:@"OK" cancel:nil then:nil];
            TCDLog([NSString stringWithFormat:@"download failed: %@", e.localizedDescription]);
        } else if (self.wrongEngine) {
            [self ask:@"Update needs a new app" message:@"The new version is made with a newer Godot than this app can run. Ask for a new IPA to get it. You can keep playing this version." ok:@"OK" cancel:nil then:nil];
        } else if (TCDExists(@"game.pck.new")) {
            [self ask:@"Update ready" message:@"Close the game fully and open it again to play the new version." ok:@"OK" cancel:nil then:nil];
        } else {
            [self ask:@"Download failed" message:@"The file didn't download properly. It'll ask again next time you open the game." ok:@"OK" cancel:nil then:nil];
        }
    }];
}
@end

// ---- Startup: install a finished download, choose the pack, then check ----
// the iPhone settings and screen fixes the built-in version has, for a downloaded one too
// (Godot reads override.cfg next to the game data; ios_screen.gd is copied there by the game)
static NSString *TCDOverride(void) {
    NSMutableString *s = [NSMutableString stringWithString:
        @"[debug]\n\nfile_logging/enable_file_logging=true\n\n"
        @"[physics]\n\ncommon/physics_interpolation=true\n\n"
        @"[display]\n\nwindow/handheld/orientation=4\nwindow/ios/allow_high_refresh_rate=true\n\n"];
    if (TCDExists(@"ios_screen.gd")) [s appendString:@"[autoload]\n\nIOSScreen=\"*user://update/ios_screen.gd\"\n"];
    return s;
}

static void TCDInstallDownloaded(void) {
    if (!TCDExists(@"game.pck.new")) return;
    TCDRemove(@"game.pck"); TCDRemove(@"ok"); TCDRemove(@"trying");
    if ([NSFileManager.defaultManager moveItemAtPath:TCDFile(@"game.pck.new") toPath:TCDFile(@"game.pck") error:nil]) {
        TCDWrite(@"build.txt", TCDRead(@"next.txt"));
        // settings the built-in version has, for the downloaded one too (Godot reads override.cfg next to the pack)
        TCDWrite(@"override.cfg", TCDOverride());
        TCDLog([NSString stringWithFormat:@"installed downloaded version %@", TCDRead(@"build.txt")]);
    }
    TCDRemove(@"next.txt");
}

__attribute__((constructor)) static void TCDStartup(void) {
    @autoreleasepool {
        TCDInstallDownloaded();
        TCDChoosePack();
    }
}

__attribute__((constructor)) static void TCDScheduleCheck(void) {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil
        queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *n) {
        if (tcdUsingUpdate) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if (TCDExists(@"trying")) { TCDRemove(@"trying"); TCDWrite(@"ok", @"1"); TCDLog(@"downloaded version runs fine"); }
            });
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            tcdUpdater = [TCDUpdater new];
            [tcdUpdater check];
        });
    }];
}
