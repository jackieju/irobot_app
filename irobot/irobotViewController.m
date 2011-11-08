//
//  irobotViewController.m
//  irobot
//
//  Created by juweihua on 11/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "irobotViewController.h"

@implementation irobotViewController
@synthesize right_eye;
@synthesize left_eye;
@synthesize background;

- (void)dealloc
{
    [background release];
    
    [left_eye release];
    [right_eye release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [background setImage:[UIImage imageNamed:@"irobot2.jpg"]];
    [left_eye  setFrame:CGRectMake(70, 65, 135, 130)];
    [left_eye setImage:[UIImage imageNamed:@"eye_0.png"]];
    left_eye.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"eye_1.png"],
        [UIImage imageNamed:@"eye_2.png"],nil];
    
    [right_eye  setFrame:CGRectMake(280, 65, 135, 130)];
    [right_eye setImage:[UIImage imageNamed:@"eye_0.png"]];
    right_eye.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"eye_1.png"],
        [UIImage imageNamed:@"eye_2.png"],nil];
    
        
    // start timer
    [NSTimer scheduledTimerWithTimeInterval:(1.0)target:self selector:@selector(onTimer) userInfo:nil repeats:YES];	
    //  [t release];
    time(&t_start);

}


- (void)viewDidUnload
{
    [self setBackground:nil];
    [self setLeft_eye:nil];
    [self setRight_eye:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  //  return YES;
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void) onTimer
{
  //  NSLog(@"===>onTimer\n");
    time_t t;
    time(&t);
    long tt = t - t_start;
    NSLog([NSString stringWithFormat:@"diff=%d", tt]);
    if (tt>10){
        t_start = t;
           NSLog(@"===>startAnimating\n");
        left_eye.animationDuration = 0.3;
        left_eye.animationRepeatCount = 1;
        [left_eye startAnimating];
        right_eye.animationDuration = 0.3;
        right_eye.animationRepeatCount = 1;
        [right_eye startAnimating];
           NSLog(@"===>animate end\n");
    }
   /* int h = tt/3600;
    int m = (tt - h*3600)/60;
    int s = (tt - h*3600 - m*60);
    [self.timer setText:[NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s ]];*/
}
@end
