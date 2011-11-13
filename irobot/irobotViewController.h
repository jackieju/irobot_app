//
//  irobotViewController.h
//  irobot
//
//  Created by juweihua on 11/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImageOpenCV.h"

@class PocketsphinxController;
@class FliteController;
#import "OpenEarsEventsObserver.h" // We need to import this here in order to use the delegate.

@interface irobotViewController : UIViewController <OpenEarsEventsObserverDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>{
    time_t t_start;
    
    UIImageView *background;    // background image view, showing wall=e face

    UIImageView *left_eye;      // left_eye of robot
    UIImageView *right_eye;     // right eye of robot
    
    OpenEarsEventsObserver *openEarsEventsObserver; // A class whose delegate methods which will allow us to stay informed of changes in the Flite and Pocketsphinx statuses.
	PocketsphinxController *pocketsphinxController; // The controller for Pocketsphinx (voice recognition).
    UITextField *status_view;
    UITextView *textView;
    UITextView *statusView;
    
    NSString *pathToGrammarToStartAppWith;
	NSString *pathToDictionaryToStartAppWith;
    
    // face detection
//    UIImagePickerController *camera;
    CvHaarClassifierCascade *model;
    BOOL detecting;
       UIInterfaceOrientation orientation;
     CGRect face;
     AVCaptureSession*            session;
    UIImage* capturedImage;
     UIImage* detectingImage;
    double last_cmd_time; // last tick count sending move msg to robot
}
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UITextView *statusView;

@property (nonatomic, retain) IBOutlet UIImageView *right_eye;
@property (nonatomic, retain) IBOutlet UIImageView *left_eye;
@property (nonatomic, retain) IBOutlet UIImageView *background;

@property (nonatomic, retain) OpenEarsEventsObserver *openEarsEventsObserver;
@property (nonatomic, retain) PocketsphinxController *pocketsphinxController;
//@property (nonatomic, retain) UIImagePickerController *camera;

@property (nonatomic, copy) NSString *pathToGrammarToStartAppWith;
@property (nonatomic, copy) NSString *pathToDictionaryToStartAppWith;
- (void) onTimer;
    
@property (nonatomic, assign) CvHaarClassifierCascade *model;
@property (assign) BOOL detecting;
- (void)startDetection;

- (void)stopDetection;
- (void) setupCaptureSession;
- (void) faceDetected; // update ui and robot after detected face
- (CvSeq*) detectFace:(UIImage*)viewImage;
@property (nonatomic, retain)   AVCaptureSession*            session;
@property (nonatomic, retain)   UIImage* capturedImage;
@property (nonatomic, retain)   UIImage* detectingImage;
@property (assign) double last_cmd_time;
- (void) sendCmdToRobot:(NSString*) cmd;
@end
