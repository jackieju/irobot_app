//
//  irobotAppDelegate.h
//  irobot
//
//  Created by juweihua on 11/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class irobotViewController;

@interface irobotAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet irobotViewController *viewController;

@end
