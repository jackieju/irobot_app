//
//  irobotAppDelegate.h
//  irobot
//
//  Created by juweihua on 11/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioSessionManager.h" // Importing OpenEars' AudioSessionManager class header.

@class irobotViewController;

@interface irobotAppDelegate : NSObject <UIApplicationDelegate> {
	AudioSessionManager *audioSessionManager; // This is OpenEars' AudioSessionManager class. 
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet irobotViewController *viewController;
@property (nonatomic, retain) AudioSessionManager *audioSessionManager; // This is OpenEars' AudioSessionManager class.

@end
