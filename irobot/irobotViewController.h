//
//  irobotViewController.h
//  irobot
//
//  Created by juweihua on 11/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface irobotViewController : UIViewController {
    time_t t_start;
    UIImageView *background;

    UIImageView *left_eye;
    UIImageView *right_eye;
}
@property (nonatomic, retain) IBOutlet UIImageView *right_eye;
@property (nonatomic, retain) IBOutlet UIImageView *left_eye;
@property (nonatomic, retain) IBOutlet UIImageView *background;
- (void) onTimer;
@end
