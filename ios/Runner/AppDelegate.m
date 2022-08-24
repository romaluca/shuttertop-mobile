#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <uni_links/UniLinksPlugin.h>
@implementation AppDelegate
NSString *STATIC_FILE_HANDLE = @"file://";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.

    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    FlutterMethodChannel* shuttertopChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"app.channel.shared.data"
                                            binaryMessenger:controller];

    [shuttertopChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"getNotification" isEqualToString:call.method]) {
            result(nil);
        } else if ([@"getSharedImage" isEqualToString:call.method]) {
            NSLog(@"SHUTTERTOP Controllo immagini condivise!!");
            NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.shuttertop.app"];
            NSString *path = [shared valueForKey:@"url"];
            NSLog(@"readUrlFromExtension url: %@", path);
            [shared removeObjectForKey:@"url"];  // delete key after read

            if(path.length != 0)
            {
                /*
                NSData *data;
                //Get file path from url shared
                NSString * newFilePathConverted = [STATIC_FILE_HANDLE stringByAppendingString:path];
                NSURL *url = [ NSURL URLWithString: newFilePathConverted ];
                data = [NSData dataWithContentsOfURL:url];
                //Create a regular access path because this app cant preview a shared app group path
                NSString *regularAccessPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *uuid = [[NSUUID UUID] UUIDString];
                //Copy file to a jpg image(ignore extension, will convert from png)
                NSString *uniqueFilePath= [ NSString stringWithFormat: @"/image%@.jpg", uuid];
                regularAccessPath = [regularAccessPath stringByAppendingString:uniqueFilePath];
                NSString * newFilePathConverted1 = [STATIC_FILE_HANDLE stringByAppendingString:regularAccessPath];
                url = [ NSURL URLWithString: newFilePathConverted1 ];
                //Dump existing shared file path data into newly created file.
                [data writeToURL:url atomically:YES];
                //Reset NSUserDefaults to Nil once file is copied.
                NSLog(@"openURL: %@", newFilePathConverted);*/
                result(path);
            } else {
                NSLog(@"openURL: vuoto");
                result(nil);
            }

        } else {
            result(FlutterMethodNotImplemented);
        }
    }];


  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    return [[UniLinksPlugin sharedInstance] application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    NSLog(@"Launch url: %@", url);

    return  YES;
}
@end
