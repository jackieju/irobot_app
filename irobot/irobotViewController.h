//
//  irobotViewController.h
//  irobot
//
//  Created by juweihua on 11/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageOpenCV.h"

@class PocketsphinxController;
@class FliteController;
#import "OpenEarsEventsObserver.h" // We need to import this here in order to use the delegate.

@interface irobotViewController : UIViewController <OpenEarsEventsObserverDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    time_t t_start;
    UIImageView *background;

    UIImageView *left_eye;
    UIImageView *right_eye;
    
    OpenEarsEventsObserver *openEarsEventsObserver; // A class whose delegate methods which will allow us to stay informed of changes in the Flite and Pocketsphinx statuses.
	PocketsphinxController *pocketsphinxController; // The controller for Pocketsphinx (voice recognition).
    UITextField *status_view;
    UITextView *textView;
    
    NSString *pathToGrammarToStartAppWith;
	NSString *pathToDictionaryToStartAppWith;
    
    // face detection
    UIImagePickerController *camera;
    CvHaarClassifierCascade *model;
    BOOL detecting;
       UIDeviceOrientation orientation;
     CGRect face;
}
@property (nonatomic, retain) IBOutlet UITextView *textView;

@property (nonatomic, retain) IBOutlet UIImageView *right_eye;
@property (nonatomic, retain) IBOutlet UIImageView *left_eye;
@property (nonatomic, retain) IBOutlet UIImageView *background;

@property (nonatomic, retain) OpenEarsEventsObserver *openEarsEventsObserver;
@property (nonatomic, retain) PocketsphinxController *pocketsphinxController;
@property (nonatomic, retain) UIImagePickerController *camera;

@property (nonatomic, copy) NSString *pathToGrammarToStartAppWith;
@property (nonatomic, copy) NSString *pathToDictionaryToStartAppWith;
- (void) onTimer;
    
@property (nonatomic, assign) CvHaarClassifierCascade *model;
@property (assign) BOOL detecting;
- (void)startDetection;

- (void)stopDetection;
@end
