//
//  irobotAppDelegate.m
//  irobot
//
//  Created by juweihua on 11/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "irobotAppDelegate.h"

#import "irobotViewController.h"

@implementation irobotAppDelegate


@synthesize window=_window;
@synthesize audioSessionManager;
@synthesize viewController=_viewController;

// Lazily instantiated AudioSessionManager object. This class can definitely only be instantiated as an object once in the app, so this is a pretty safe way to allocate it.
- (AudioSessionManager *)audioSessionManager {
	if (audioSessionManager == nil) {
		audioSessionManager = [[AudioSessionManager alloc] init];
	}
	return audioSessionManager;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.audioSessionManager startAudioSession];
    // Override point for customization after application launch.
self.window.windowLevel = UIWindowLevelStatusBar + 1.0f; 
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [audioSessionManager release];
    [super dealloc];
}

@end
