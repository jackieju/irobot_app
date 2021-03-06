//
//  irobotViewController.m
//  irobot
//
//  Created by juweihua on 11/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "irobotViewController.h"
#import <AVFoundation/AVFoundation.h>


// import for OpenEars 
#import "AudioSessionManager.h"
#import "PocketsphinxController.h"
//#import "FliteController.h"
#import "OpenEarsEventsObserver.h"
//#import "LanguageModelGenerator.h"
#import "UIImageResizing.h"

@implementation irobotViewController

@synthesize textView;
@synthesize statusView;
@synthesize right_eye;
@synthesize left_eye;
@synthesize background;
// openears
@synthesize pocketsphinxController;
@synthesize openEarsEventsObserver;
@synthesize pathToGrammarToStartAppWith;
@synthesize pathToDictionaryToStartAppWith;

//@synthesize camera;
@synthesize model;
@synthesize avSessionForFaceDetection;
@synthesize capturedImage;
@synthesize detecting;
@synthesize last_cmd_time;
@synthesize detectingImage;;
static CvMemStorage *storage = 0;

// torch mode
@synthesize avSessionForTorch;

- (void)dealloc
{
    [background release];
    
    [left_eye release];
    [right_eye release];
    openEarsEventsObserver.delegate = nil;
	[openEarsEventsObserver release];
    [pocketsphinxController release];
  //  [status_view release];
    [textView release];
    
   // self.camera = nil;
    [statusView release];
    [player1 release];
    [player2 release];
    [_player release];
    [avSessionForFaceDetection release];
    [avSessionForTorch release];
    [super dealloc];
}

#pragma mark -
#pragma mark Lazy Allocation

// Lazily allocated PocketsphinxController.
- (PocketsphinxController *)pocketsphinxController { 
	if (pocketsphinxController == nil) {
		pocketsphinxController = [[PocketsphinxController alloc] init];
	}
	return pocketsphinxController;
}
// Lazily allocated OpenEarsEventsObserver.
- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
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
    
    
    // prepare player
    
    

    
    if (player1)
         [player1 release];
    NSString *soundPath=[[NSBundle mainBundle] pathForResource:@"dance" ofType:@"m4a"];
    NSURL *soundUrl=[[NSURL alloc] initFileURLWithPath:soundPath];
    player1=[[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    [player1 prepareToPlay];
    
    if (player2)
        [player2 release];
    NSString *soundPath2=[[NSBundle mainBundle] pathForResource:@"say_something" ofType:@"mp3"];
    NSURL *soundUrl2=[[NSURL alloc] initFileURLWithPath:soundPath2];
    player2=[[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl2 error:nil];
    [player2 prepareToPlay];
    
    if (player3)
        [player3 release];
    NSString *soundPath3=[[NSBundle mainBundle] pathForResource:@"say_name" ofType:@"mp3"];
    NSURL *soundUrl3=[[NSURL alloc] initFileURLWithPath:soundPath3];
    player3=[[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl3 error:nil];
    [player3 prepareToPlay];
//    [player3 play];
    // init openear
    [self.openEarsEventsObserver setDelegate:self]; // Make this class the delegate of OpenEarsObserver so we can get all of the messages about what OpenEars is doing.

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


    //////////////////////////////
    // initialize openears
    //////////////////////////////
    self.pathToGrammarToStartAppWith = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"7678.languagemodel"]; 
    
       
 
	self.pathToDictionaryToStartAppWith = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"7678.dic"];


    [self.pocketsphinxController startListeningWithLanguageModelAtPath:pathToGrammarToStartAppWith dictionaryAtPath:pathToDictionaryToStartAppWith languageModelIsJSGF:FALSE];
    //////////////////////////////
    // end of initilize openear
    //////////////////////////////
    
    // hide text view
    //textView.hidden = TRUE;
  //  left_eye.hidden = TRUE;
   // right_eye.hidden = TRUE;
    
    // show camera
 /*
    self.camera = [[UIImagePickerController alloc] init];
    camera.sourceType =UIImagePickerControllerSourceTypeCamera;
    camera.delegate = self;
    camera.showsCameraControls = NO;
    camera.cameraOverlayView = self.view;
    [self presentModalViewController:camera animated:YES];
*/
    [statusView setFrame:CGRectMake(0, 0, 480, 65) ];
    [self setupCaptureSession];
    //[self startDetection];
    //[self startTorchMode];
//    [self testFaceDetection:@"testfd2.jpg"];
//    [self testFaceDetection:@"testfd3.jpg"];

  // say hello
    // do action
    [self sendCmdToRobot:@"/m=2=90/m=5=0/m=6=140/d=2000/m=5=120/m=6=50"];
    // play sound
    [self play:@"say_name" ofType:@"mp3"];
    
}

- (void)play:(NSString*)file ofType:(NSString*)type{
    
    // use loud speaker instead of ear speaker
    
 /*  // use mix features
    OSStatus propertySetError = 0;
    UInt32 allowMixing = true;
    
    propertySetError = AudioSessionSetProperty (
                                                kAudioSessionProperty_OverrideCategoryMixWithOthers,  // 1
                                                sizeof (allowMixing),                                 // 2
                                                &allowMixing                                          // 3
                                                );*/
  /*  UInt32 audioCat;
	UInt32 audioCatSize = sizeof(audioCat);
	OSStatus getAudioRouteStatus = AudioSessionGetProperty(kAudioSessionProperty_AudioCategory, &audioCatSize, &audioCat);*/
    // change category
    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    
    // change route to speaker
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    
    
  /*  //    UInt32 doChangeDefaultRoute = 1;
    //    
    //    AudioSessionSetProperty (
    //                             kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
    //                             sizeof (doChangeDefaultRoute),
    //                             &doChangeDefaultRoute
    //                             );
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;  // 1
    
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,                         // 2
                             sizeof (audioRouteOverride),                                      // 3
                             &audioRouteOverride                                               // 4
                             );*/
    if (_player)
        [_player release];

    NSString *soundPath3=[[NSBundle mainBundle] pathForResource:file ofType:type];
    NSURL *soundUrl3=[[NSURL alloc] initFileURLWithPath:soundPath3];
    _player=[[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl3 error:nil];
    [_player setDelegate:self];
    [_player prepareToPlay];
    [_player play];
    

    
 
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *) player  
                      successfully: (BOOL) flag  
{  
    // change category back
    
    // AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCat), &audioCat);
    UInt32 sessionCategory2 = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory2), &sessionCategory2);
} 

- (void)viewDidUnload
{
    [self setBackground:nil];
    [self setLeft_eye:nil];
    [self setRight_eye:nil];
    [self setTextView:nil];
    [self setStatusView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  //  return YES;
    // Return YES for supported orientations
    orientation = interfaceOrientation;
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void) onTimer
{
  //  NSLog(@"===>onTimer\n");
    time_t t;
    time(&t);
    long tt = t - t_start;
   // NSLog([NSString stringWithFormat:@"diff=%d", tt]);
    if (tt>10){
        
        // calibration
        //[self.pocketsphinxController doCalibration];
        
        // wink
        t_start = t;
  //         NSLog(@"===>startAnimating\n");
        left_eye.animationDuration = 0.2;
        left_eye.animationRepeatCount = 1;
        [left_eye startAnimating];
        right_eye.animationDuration = 0.2;
        right_eye.animationRepeatCount = 1;
        [right_eye startAnimating];
     //      NSLog(@"===>animate end\n");
        
         
    }
    self.textView.text = [NSString stringWithFormat:@"Pocketsphinx Input level:%f",[self.pocketsphinxController pocketsphinxInputLevel]]; 
    //pocketsphinxInputLevel is an OpenEars method of the class PocketsphinxController.
    
    // [background setImage:capturedImage];
    //CvSeq* faces = [self detectFace:[capturedImage copy]];
    /*if (faces->total>0){
         [background setImage:capturedImage];
           AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }*/
   /* int h = tt/3600;
    int m = (tt - h*3600)/60;
    int s = (tt - h*3600 - m*60);
    [self.timer setText:[NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s ]];*/
}


// What follows are all of the delegate methods you can optionally use once you've instantiated an OpenEarsEventsObserver and set its delegate to self. 
// I've provided some pretty granular information about the exact phase of the Pocketsphinx listening loop, the Audio Session, and Flite, but I'd expect 
// that the ones that will really be needed by most projects are the following:
//
//- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID;
//- (void) audioSessionInterruptionDidBegin;
//- (void) audioSessionInterruptionDidEnd;
//- (void) audioRouteDidChangeToRoute:(NSString *)newRoute;
//- (void) pocketsphinxDidStartListening;
//- (void) pocketsphinxDidStopListening;
//
// It isn't necessary to have a PocketsphinxController or a FliteController instantiated in order to use these methods.  If there isn't anything instantiated that will
// send messages to an OpenEarsEventsObserver, all that will happen is that these methods will never fire.  You also do not have to create a OpenEarsEventsObserver in
// the same class or view controller in which you are doing things with a PocketsphinxController or FliteController; you can receive updates from those objects in
// any class in which you instantiate an OpenEarsEventsObserver and set its delegate to self.

// An optional delegate method of OpenEarsEventsObserver which delivers the text of speech that Pocketsphinx heard and analyzed, along with its accuracy score and utterance ID.
- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    bool bCmd = false;
	NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID); // Log it.
    
    if ([hypothesis length] == 0)
        return;
    
    // filter result according to content and score
    int recogScore = [recognitionScore intValue];
    if(![hypothesis hasPrefix:@"WALL E"] 
       && ![hypothesis isEqualToString:@"CLEAN MY DESK"] 
       && ![hypothesis hasSuffix:@"SHARE ME SOME LIGHT"]
       && ![hypothesis hasSuffix:@"HANDS"]
       && ![hypothesis isEqualToString:@"DANCE"] 
       && ![hypothesis isEqualToString:@"STOP"] 
       && ![hypothesis isEqualToString:@"PLAY WITH YOURSELF"]
       && ![hypothesis isEqualToString:@"SAY HELLO"]
       && ![hypothesis isEqualToString:@"TRACK MY FACE"]){
        if (recogScore < -800){
            NSLog(@"recognition score is too low (less than -800)");
            return;
        }
    }

    
        if(/*[hypothesis isEqualToString:@"LOOK AT RIGHT"]  || (*/[hypothesis hasPrefix:@"LOOK"] && [hypothesis hasSuffix:@"RIGHT"]) {
            bCmd = true;
            NSLog(@"===>look right");
            // NSURL* url = [NSURL URLWithString:@"http://169.254.203.23/mh/12"];    
            /*   NSMutableURLRequest* request = [NSMutableURLRequest new];    
             [request setURL:url];    
             [request setHTTPMethod:@"GET"];    
             NSHTTPURLRequest* response;    
             NSData* data = [NSURLConnection sendSynchronousRequest:request    
             returningResponse:&response error:nil];    
             [NSString* strRet = [[NSString alloc] initWithData:data encoding:NSUTF8String];    
             NSLog(strRet);    
             [strRet release];    
             */
            
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
            [request setURL:[NSURL URLWithString:@"http://169.254.203.23/mh/12"]];
            [request setHTTPMethod:@"GET"];
            //  NSMutableData* buf = [[NSMutableData alloc] initWithLength:0];
            NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [request release];
        }
        else if([hypothesis hasPrefix:@"LOOK"] && [hypothesis hasSuffix:@"LEFT"]) {
            bCmd = true; NSLog(@"===>look left");
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
            [request setURL:[NSURL URLWithString:@"http://169.254.203.23/mh/11"]];
            [request setHTTPMethod:@"GET"];
            //  NSMutableData* buf = [[NSMutableData alloc] initWithLength:0];
            NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [request release];
        }
        else if([hypothesis isEqualToString:@"LOOK AROUND"] || [hypothesis hasSuffix:@"LOOK AROUND"]) {
            left_eye.animationDuration = 0.5;
            left_eye.animationRepeatCount = 1;
            [left_eye startAnimating];
            bCmd = true; NSLog(@"===>look around");
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
            [request setURL:[NSURL URLWithString:@"http://169.254.203.23/mh/15"]];
            [request setHTTPMethod:@"GET"];
            //  NSMutableData* buf = [[NSMutableData alloc] initWithLength:0];
            NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [request release];
        }
        else if([hypothesis hasSuffix:@"DANCE"]) {
            bCmd = true; NSLog(@"===>DANCE");
            
            // wink
            left_eye.animationDuration = 0.2;
            left_eye.animationRepeatCount = 1;
            [left_eye startAnimating];
         
            // send command to robot
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
            [request setURL:[NSURL URLWithString:@"http://169.254.203.23/dance"]];
            [request setHTTPMethod:@"GET"];
            //  NSMutableData* buf = [[NSMutableData alloc] initWithLength:0];
            NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            // play music
//            [player1 play];
            [self play:@"dance" ofType:@"m4a"];
            [request release];
        }
        else if([hypothesis hasSuffix:@"SAY SOMETHING"]) {
            bCmd = true; NSLog(@"===>SAY SOMETHING");
            
            // wink
            left_eye.animationDuration = 0.2;
            left_eye.animationRepeatCount = 1;
            [left_eye startAnimating];
            
            // send command to robot
       /*     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
            [request setURL:[NSURL URLWithString:@"http://169.254.203.23/dance"]];
            [request setHTTPMethod:@"GET"];
            //  NSMutableData* buf = [[NSMutableData alloc] initWithLength:0];
            NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            [request release];
        */    // play sound
            //[player2 play];
            [self play:@"say_something" ofType:@"mp3"];
        }
        else if([hypothesis hasSuffix:@"SAY HELLO"]) {
            bCmd = true; NSLog(@"===>SAY HELLO");
            
            // wink
            left_eye.animationDuration = 0.2;
            left_eye.animationRepeatCount = 1;
            [left_eye startAnimating];
            
            // do action
            [self sendCmdToRobot:@"/m=5=0/m=6=140/d=3000/m=5=120/m=6=50"];
            // play sound
          //  [player3 play];
            [self play:@"say_name" ofType:@"mp3"];
        }
        else if([hypothesis hasSuffix:@"HANDS"]) {
            bCmd = true; NSLog(@"===>RASIE YOUR HANDS");
            
            // wink
            left_eye.animationDuration = 0.2;
            left_eye.animationRepeatCount = 1;
            [left_eye startAnimating];
            
            [self sendCmdToRobot:@"/m=5=0/m=6=140/d=3000/m=5=120/m=6=50"];
        }
        else if([hypothesis hasSuffix:@"GO"] && [hypothesis hasPrefix:@"WALL E"]) {
            bCmd = true; NSLog(@"===>GO");
            
            // wink
            left_eye.animationDuration = 0.2;
            left_eye.animationRepeatCount = 1;
            [left_eye startAnimating];
            
            [self sendCmdToRobot:@"/m=5=0/m=6=140/g=3000/m=5=120/m=6=50"];
        }
        else if([hypothesis hasSuffix:@"BACKWARD"]) {
            bCmd = true; NSLog(@"===>BACKWARD");
            
            // wink
            left_eye.animationDuration = 0.2;
            left_eye.animationRepeatCount = 1;
            [left_eye startAnimating];
            
            [self sendCmdToRobot:@"/b=2000"];
        }
        else if([hypothesis isEqualToString:@"TRACK MY FACE"] || [hypothesis hasPrefix:@"TRACK"] || [hypothesis hasSuffix:@"FACE"]) {
            left_eye.animationDuration = 0.2;
            left_eye.animationRepeatCount = 1;
            [left_eye startAnimating];
            bCmd = true; NSLog(@"===>TRACK MY FACE");
            if (!self.detecting)
                [self startDetection];
        }        
        else if([hypothesis hasPrefix:@"WALL E SHARE"] || [hypothesis hasSuffix:@"SOME LIGHT"]) {
            left_eye.animationDuration = 0.2;
            left_eye.animationRepeatCount = 1;
            [left_eye startAnimating];
            bCmd = true; NSLog(@"===>WALL E SHARE ME SOME LIGHT");
             [self sendCmdToRobot:@"/mhud=0"];
            [self startTorchMode];
        }
        else if([hypothesis hasPrefix:@"WALL E TURN OFF"]) {
            left_eye.animationDuration = 0.2;
            left_eye.animationRepeatCount = 1;
            [left_eye startAnimating];
            bCmd = true; NSLog(@"===>WALL E TURN OFF LIGHT");
            [self stopTorchMode];
              [self sendCmdToRobot:@"/reset"];
        }
        else if([hypothesis hasPrefix:@"WALL E TAKE PHOTO"] || [hypothesis hasSuffix:@"PHOTO"] ) {
            left_eye.animationDuration = 0.2;
            left_eye.animationRepeatCount = 1;
            [left_eye startAnimating];
            bCmd = true; NSLog(@"===>WALL E TAKE PHOTO");
            [self performSelectorOnMainThread:@selector(takePhoto) withObject:nil waitUntilDone:NO];
            
        }else if([hypothesis isEqualToString:@"TURN AROUND"]) {
            bCmd = true;NSLog(@"===>turn around");
            left_eye.animationDuration = 0.2;
            left_eye.animationRepeatCount = 1;  
            [left_eye startAnimating];
            [self sendCmdToRobot:@"/m=3=180/m=4=180/d=5000/m=3=90/m=4=90"];
        }
        /*else if([hypothesis isEqualToString:@"GO"]) {
            bCmd = true; NSLog(@"===>GO");
            //  NSURL* url = [NSURL URLWithString:@"http://169.254.203.23/g"];  
            // [NSData dataWithContentsOfURL:(NSURL *)url];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
            [request setURL:[NSURL URLWithString:@"http://169.254.203.23/g"]];
            [request setHTTPMethod:@"GET"];
            //  NSMutableData* buf = [[NSMutableData alloc] initWithLength:0];
            NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [request release];
            
            NSLog(@"===>DONE");
        }else if([hypothesis isEqualToString:@"BACKWARD"]) {
            bCmd = true;NSLog(@"===>BACKWARD");
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
            [request setURL:[NSURL URLWithString:@"http://169.254.203.23/b"]];
            [request setHTTPMethod:@"GET"];
            //  NSMutableData* buf = [[NSMutableData alloc] initWithLength:0];
            NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [request release];
        }else if([hypothesis isEqualToString:@"TURN AROUND"]) {
            bCmd = true;NSLog(@"===>turn around");
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
            [request setURL:[NSURL URLWithString:@"http://169.254.203.23/ta"]];
            [request setHTTPMethod:@"GET"];
            //  NSMutableData* buf = [[NSMutableData alloc] initWithLength:0];
            NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [request release];
        }else if([hypothesis isEqualToString:@"LEFT"]) {
            bCmd = true; NSLog(@"===>LEFT");
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
            [request setURL:[NSURL URLWithString:@"http://169.254.203.23/l"]];
            [request setHTTPMethod:@"GET"];
            //  NSMutableData* buf = [[NSMutableData alloc] initWithLength:0];
            NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [request release];
        }   else if([hypothesis isEqualToString:@"RIGHT"]) {
            bCmd = true; NSLog(@"===>right");
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
            [request setURL:[NSURL URLWithString:@"http://169.254.203.23/r"]];
            [request setHTTPMethod:@"GET"];
            //  NSMutableData* buf = [[NSMutableData alloc] initWithLength:0];
            NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [request release];
        }*/
        else if([hypothesis hasPrefix:@"STOP"]) {
            bCmd = true;NSLog(@"===>stop");
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
            [request setURL:[NSURL URLWithString:@"http://169.254.203.23/stop"]];
            [request setHTTPMethod:@"GET"];
            //  NSMutableData* buf = [[NSMutableData alloc] initWithLength:0];
            NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [request release];
        } else {
            
       
            
        }
        // hear what ever, reset background
    [background setImage:[UIImage imageNamed:@"irobot2.jpg"]];
    left_eye.hidden = NO;
    right_eye.hidden = NO;
    
	//self.heardTextView.text = [NSString stringWithFormat:@"Heard: \"%@\"", hypothesis]; // Show it in the status box.
    if ( bCmd ){
        NSLog(@"===>done");
        
        // restart, this is the temp solution to trigger the calibration
   //     [self.pocketsphinxController stopListening];
        
      //  self.startButton.hidden = FALSE;
       // self.stopButton.hidden = TRUE;
       // self.suspendListeningButton.hidden = TRUE;
      //  self.resumeListeningButton.hidden = TRUE;
      /*  [self.pocketsphinxController startListeningWithLanguageModelAtPath:self.pathToGrammarToStartAppWith dictionaryAtPath:self.pathToDictionaryToStartAppWith languageModelIsJSGF:FALSE];
    */
       // self.startButton.hidden = TRUE;
//        self.stopButton.hidden = FALSE;
//        self.suspendListeningButton.hidden = FALSE;
//        self.resumeListeningButton.hidden = TRUE;
    }
    return;
	// This is how to use an available instance of FliteController. We're going to repeat back the command that we heard with the voice we've chosen.
    //	[self.fliteController say:[NSString stringWithFormat:@"You said %@",hypothesis] withVoice:self.secondVoiceToUse];
}

// An optional delegate method of OpenEarsEventsObserver which informs that there was an interruption to the audio session (e.g. an incoming phone call).
- (void) audioSessionInterruptionDidBegin {
	NSLog(@"AudioSession interruption began."); // Log it.
	self.textView.text = @"Status: AudioSession interruption began."; // Show it in the status box.
	[self.pocketsphinxController stopListening]; // React to it by telling Pocketsphinx to stop listening since it will need to restart its loop after an interruption.
}

// An optional delegate method of OpenEarsEventsObserver which informs that the interruption to the audio session ended.
- (void) audioSessionInterruptionDidEnd {
	NSLog(@"AudioSession interruption ended."); // Log it.
	self.textView.text = @"Status: AudioSession interruption ended."; // Show it in the status box.
	// We're restarting the previously-stopped listening loop.
	[self.pocketsphinxController startListeningWithLanguageModelAtPath:self.pathToGrammarToStartAppWith dictionaryAtPath:self.pathToDictionaryToStartAppWith languageModelIsJSGF:FALSE];
}

// An optional delegate method of OpenEarsEventsObserver which informs that the audio input became unavailable.
- (void) audioInputDidBecomeUnavailable {
	NSLog(@"The audio input has become unavailable"); // Log it.
	self.textView.text = @"Status: The audio input has become unavailable"; // Show it in the status box.
	[self.pocketsphinxController stopListening]; // React to it by telling Pocketsphinx to stop listening since there is no available input
}

// An optional delegate method of OpenEarsEventsObserver which informs that the unavailable audio input became available again.
- (void) audioInputDidBecomeAvailable {
	NSLog(@"The audio input is available"); // Log it.
	self.textView.text = @"Status: The audio input is available"; // Show it in the status box.
	[self.pocketsphinxController startListeningWithLanguageModelAtPath:self.pathToGrammarToStartAppWith dictionaryAtPath:self.pathToDictionaryToStartAppWith languageModelIsJSGF:FALSE];
}

// An optional delegate method of OpenEarsEventsObserver which informs that there was a change to the audio route (e.g. headphones were plugged in or unplugged).
- (void) audioRouteDidChangeToRoute:(NSString *)newRoute {
	NSLog(@"Audio route change. The new audio route is %@", newRoute); // Log it.
	self.textView.text = [NSString stringWithFormat:@"Status: Audio route change. The new audio route is %@",newRoute]; // Show it in the status box.
    
	[self.pocketsphinxController stopListening]; // React to it by telling the Pocketsphinx loop to shut down and then start listening again on the new route
	[self.pocketsphinxController startListeningWithLanguageModelAtPath:self.pathToGrammarToStartAppWith dictionaryAtPath:self.pathToDictionaryToStartAppWith languageModelIsJSGF:FALSE];
}

// An optional delegate method of OpenEarsEventsObserver which informs that the Pocketsphinx recognition loop hit the calibration stage in its startup.
// This might be useful in debugging a conflict between another sound class and Pocketsphinx. Another good reason to know when you're in the middle of
// calibration is that it is a timeframe in which you want to avoid playing any other sounds including speech so the calibration will be successful.
- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started."); // Log it.
	self.textView.text = @"Status: Pocketsphinx calibration has started."; // Show it in the status box.
}

// An optional delegate method of OpenEarsEventsObserver which informs that the Pocketsphinx recognition loop completed the calibration stage in its startup.
// This might be useful in debugging a conflict between another sound class and Pocketsphinx.
- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete."); // Log it.
	self.textView.text = @"Status: Pocketsphinx calibration is complete."; // Show it in the status box.
    
/*	self.fliteController.duration_stretch = .9; // Change the speed
	self.fliteController.target_mean = 1.2; // Change the pitch
	self.fliteController.target_stddev = 1.5; // Change the variance
	
    //	[self.fliteController say:@"Welcome to OpenEars." withVoice:self.firstVoiceToUse]; // The same statement with the pitch and other voice values changed.
	
	self.fliteController.duration_stretch = 1.0; // Reset the speed
	self.fliteController.target_mean = 1.0; // Reset the pitch
	self.fliteController.target_stddev = 1.0; // Reset the variance
    */
}

// An optional delegate method of OpenEarsEventsObserver which informs that the Pocketsphinx recognition loop has entered its actual loop.
// This might be useful in debugging a conflict between another sound class and Pocketsphinx.
- (void) pocketsphinxRecognitionLoopDidStart {
    
	NSLog(@"Pocketsphinx is starting up."); // Log it.
	self.textView.text = @"Status: Pocketsphinx is starting up."; // Show it in the status box.
}

// An optional delegate method of OpenEarsEventsObserver which informs that Pocketsphinx is now listening for speech.
- (void) pocketsphinxDidStartListening {
	
	NSLog(@"Pocketsphinx is now listening."); // Log it.
	self.textView.text = @"Status: Pocketsphinx is now listening."; // Show it in the status box.
	
	/*self.startButton.hidden = TRUE; // React to it with some UI changes.
	self.stopButton.hidden = FALSE;
	self.suspendListeningButton.hidden = FALSE;
	self.resumeListeningButton.hidden = TRUE;*/
}

// An optional delegate method of OpenEarsEventsObserver which informs that Pocketsphinx detected speech and is starting to process it.
- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech."); // Log it.
	self.textView.text = @"Status: Pocketsphinx has detected speech."; // Show it in the status box.
}

// An optional delegate method of OpenEarsEventsObserver which informs that Pocketsphinx detected a second of silence, indicating the end of an utterance. 
// This was added because developers requested being able to time the recognition speed without the speech time. The processing time is the time between 
// this method being called and the hypothesis being returned.
- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a second of silence, concluding an utterance."); // Log it.
	self.textView.text = @"Status: Pocketsphinx has detected finished speech."; // Show it in the status box.
}


// An optional delegate method of OpenEarsEventsObserver which informs that Pocketsphinx has exited its recognition loop, most 
// likely in response to the PocketsphinxController being told to stop listening via the stopListening method.
- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening."); // Log it.
	self.textView.text = @"Status: Pocketsphinx has stopped listening."; // Show it in the status box.
}

// An optional delegate method of OpenEarsEventsObserver which informs that Pocketsphinx is still in its listening loop but it is not
// Going to react to speech until listening is resumed.  This can happen as a result of Flite speech being
// in progress on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
// or as a result of the PocketsphinxController being told to suspend recognition via the suspendRecognition method.
- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition."); // Log it.
	self.textView.text = @"Status: Pocketsphinx has suspended recognition."; // Show it in the status box.
}

// An optional delegate method of OpenEarsEventsObserver which informs that Pocketsphinx is still in its listening loop and after recognition
// having been suspended it is now resuming.  This can happen as a result of Flite speech completing
// on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
// or as a result of the PocketsphinxController being told to resume recognition via the resumeRecognition method.
- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition."); // Log it.
	self.textView.text = @"Status: Pocketsphinx has resumed recognition."; // Show it in the status box.
}

// An optional delegate method which informs that Pocketsphinx switched over to a new language model at the given URL in the course of
// recognition. This does not imply that it is a valid file or that recognition will be successful using the file.
- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

// An optional delegate method of OpenEarsEventsObserver which informs that Flite is speaking, most likely to be useful if debugging a
// complex interaction between sound classes. You don't have to do anything yourself in order to prevent Pocketsphinx from listening to Flite talk and trying to recognize the speech.
- (void) fliteDidStartSpeaking {
	NSLog(@"Flite has started speaking"); // Log it.
	self.textView.text = @"Status: Flite has started speaking."; // Show it in the status box.
}

// An optional delegate method of OpenEarsEventsObserver which informs that Flite is finished speaking, most likely to be useful if debugging a
// complex interaction between sound classes.
- (void) fliteDidFinishSpeaking {
	NSLog(@"Flite has finished speaking"); // Log it.
	self.textView.text = @"Status: Flite has finished speaking."; // Show it in the status box.
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OPENEARSLOGGING in OpenEarsConfig.h to learn more."); // Log it.
	self.textView.text = @"Status: Not possible to start recognition loop."; // Show it in the status box.	
}


// for face dectection
/*
- (void)viewDidAppear:(BOOL)animated {
    [self presentModalViewController:camera animated:NO]; 
  //  [self startDetection];
}
*/
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

- (void)testFaceDetection:(NSString*)filename{
    UIImage *viewImage1 = [UIImage imageNamed:filename];
    if(self.model == nil) {
        NSString *file = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2.xml" ofType:@"gz"];
        self.model = (CvHaarClassifierCascade *) cvLoad([file cStringUsingEncoding:NSASCIIStringEncoding], 0, 0, 0);
    }
    CGRect scaled;
    scaled.size = viewImage1.size;
    scaled.size.width /= 2;
    scaled.size.height /= 2;
    viewImage1 = [viewImage1 scaleImage:scaled];
    // Convert to grayscale and equalize.  Helps face detection.
    IplImage *snapshot = [viewImage1 cvGrayscaleImage];
    IplImage *snapshotRotated = cvCloneImage(snapshot);
    cvEqualizeHist(snapshot, snapshot);

    
    storage = cvCreateMemStorage(0);
    
    double t = (double)cvGetTickCount();
    CvSeq* faces = cvHaarDetectObjects(snapshotRotated, self.model, storage,
                                       1.1, 2, CV_HAAR_DO_CANNY_PRUNING,cvSize(30, 30));
    t = (double)cvGetTickCount() - t;
    
    NSLog(@"Face detection time %gms FOUND(%d)", t/((double)cvGetTickFrequency()*1000), faces->total);
    
    
    if (faces->total>0){
        CvRect *r = (CvRect *) cvGetSeqElem(faces, 0);
        
        face.origin.x = (float) r->x;
        face.origin.y = (float) r->y;
        face.size.width = (float) r->width;
        face.size.height = (float) r->height;
        
     /*   face.size.width *= 2;
        face.size.height *= 2;
        face.origin.x *= 2;
        face.origin.y *= 2;
        */
        NSLog(@"face deteced: x=%f, y=%f, width=%f, height=%f", face.origin.x, face.origin.y, face.size.width, face.size.height);
    }
    
    cvReleaseImage(&snapshot);
    cvReleaseImage(&snapshotRotated);
    cvReleaseMemStorage(&storage);


}
- (CvSeq*) detectFace:(UIImage *)viewImage{
    self.detecting = YES;
    
    // load training model
    if(self.model == nil) {
        NSString *file = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2.xml" ofType:@"gz"];
        self.model = (CvHaarClassifierCascade *) cvLoad([file cStringUsingEncoding:NSASCIIStringEncoding], 0, 0, 0);
    }
    
//    NSLog(@"viewImage size :%f, %f", viewImage.size.width, viewImage.size.height);
    //  UIDevice *device = [UIDevice currentDevice];
    
    // CGImageRef screen = [UIImage UIGetScreenImage];
    // UIImage *viewImage = [UIImage imageWithCGImage:screen];
    //  UIImage *viewImage = [UIImage UIGetScreenImage];
    // CGImageRelease(screen);
    
    //UIImage *viewImage = [self.capturedImage copy];
    //   UIImage *viewImage = self.capturedImage;
  /*  
   scaleImage function has problem.
   after scale, the image width and height is not acturate.
   so we scale image outside 
   CGRect scaled;
    scaled.size = viewImage.size;
     
     //    if([device platformType] != UIDevice3GSiPhone) {
     //        scaled.size.width *= .5;
     //        scaled.size.height *= .5;
     //    } else {
     scaled.size.width *= .5;
     scaled.size.height *= .5;
     //    }
     
     //self.preview = viewImage;
     viewImage = [viewImage scaleImage:scaled];
     */
    // Convert to grayscale and equalize.  Helps face detection.
    IplImage *snapshot = [viewImage cvGrayscaleImage];
    IplImage *snapshotRotated = cvCloneImage(snapshot);
    cvEqualizeHist(snapshot, snapshot);
    
    // Rotate image if necessary.  In case phone is being held in 
    // landscape orientation.
    float angle = 0; 
    /*if(orientation == UIInterfaceOrientationLandscapeLeft) {
        angle = -90;
    } else if(orientation == UIInterfaceOrientationLandscapeRight) {
        angle = 90;
    } */
    
    if(angle != 0) {
        CvPoint2D32f center;
        CvMat *translate = cvCreateMat(2, 3, CV_32FC1);
        cvSetZero(translate);
        center.x = viewImage.size.width / 2;
        center.y = viewImage.size.height / 2;
        cv2DRotationMatrix(center, angle, 1.0, translate);
        cvWarpAffine(snapshot, snapshotRotated, translate, CV_INTER_LINEAR + CV_WARP_FILL_OUTLIERS, cvScalarAll(0));
        cvReleaseMat(&translate);   
    }
    
    storage = cvCreateMemStorage(0);
    
    double t = (double)cvGetTickCount();
    CvSeq* faces = cvHaarDetectObjects(snapshotRotated, self.model, storage,
                                       1.1, 2, CV_HAAR_DO_CANNY_PRUNING,
                                       cvSize(5, 5));
    t = (double)cvGetTickCount() - t;
    
    NSLog(@"Face detection time %gms FOUND(%d)", t/((double)cvGetTickFrequency()*1000), faces->total);
    

    if (faces->total>0){
//        [background setImage:capturedImage];
        CvRect *r = (CvRect *) cvGetSeqElem(faces, 0);
        
        face.origin.x = (float) r->x;
        face.origin.y = (float) r->y;
        face.size.width = (float) r->width;
        face.size.height = (float) r->height;
        
    /* scale image outside, so this block of code is not needed
        face.size.width /= .5;
        face.size.height /= .5;
        face.origin.x /= .5;
        face.origin.y /= .5;
        
        face.size.width *= 2;
        face.size.height *= 2;
        face.origin.x *= 2;
        face.origin.y *= 2;*/
        [self performSelectorOnMainThread:@selector(faceDetected) withObject:nil waitUntilDone:NO];
        //textView.frame = face;
       // AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }

    cvReleaseImage(&snapshot);
    cvReleaseImage(&snapshotRotated);
    cvReleaseMemStorage(&storage);
    
    return faces;

}

- (void) sendCmdToRobot:(NSString*) cmd{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://169.254.203.23",cmd]]];
    [request setHTTPMethod:@"GET"];
    //  NSMutableData* buf = [[NSMutableData alloc] initWithLength:0];
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"send cmd to robot: %@", cmd);
//    NSString * s = [[NSString alloc] initWithString:statusView.text];
    statusView.text = [NSString stringWithFormat:@"%@ send cmd to robot: %@", statusView.text, cmd];
  //  [connection release];
    
    [request release];
}


// after faces are detected, calculate the position and send command to robot
- (void) faceDetected{
    double t = (double)cvGetTickCount();
    if (self.last_cmd_time != 0 ){
        // ignore too much request
        if (t-self.last_cmd_time < 500)
            return;
    }
    last_cmd_time = t;
    
  
    NSLog(@"face size:%f, %f", face.size.width, face.size.height);
//    NSLog(@"detectingImage size:%f, %f", detectingImage.size.width, detectingImage.size.height);
    
    /*
     uncomment this block to debug face detection
    background.frame = CGRectMake(0,0,detectingImage.size.width,detectingImage.size.height);
    [background setImage:detectingImage];
    left_eye.hidden = YES;
    right_eye.hidden = YES;
    */
    
    /*float new_width_ci = 480*320/360;
    int new_origin = (480-new_width_ci)/2;
    CGRect f = CGRectMake(face.origin.x*320/360+new_origin, face.origin.y*320/360, face.size.width*320/360, face.size.height*320/360);
    NSLog(@"new face size:%f, %f, %f, %f", f.origin.x, f.origin.y, f.size.width, f.size.height);
    */
    
//    textView.frame = CGRectMake(face.origin.x, face.origin.y, face.size.width, face.size.height);
//    CGSize s = detectingImage.size;
    
 //   CGSize scr_s = [[UIScreen mainScreen] bounds].size;
 //   CGSize scr_s = background.frame.size;
    
    //NSLog(@"screen size:%f, %f", scr_s.width, scr_s.height);
   // float offset_x = s.width-(face.origin.x+face.size.width)- s.width/2; // left right mirrored
    //float offset_y = face.origin.y+(face.size.height/2) - s.height/2;
//    NSLog(@"x=%f, y=%f, offsetx=%f, offsety=%f",s.width-(face.origin.x+face.size.width),  face.origin.y+(face.size.height/2), offset_x, offset_y);
    
//    float x = face.origin.x+face.size.width -30;
//    float y = face.origin.y+(face.size.height/2)+50;
    float x = face.origin.x+face.size.width/2;
    float y = face.origin.y+face.size.height/2;
    float offset_x = x - 60; // 480/8 hardcode because not know how to get real width
    float offset_y = y - 45;  // 360/8  hardcode because not know how to get real width

    NSLog(@"x=%f, y=%f, offsetx=%f, offsety=%f",x, y, offset_x, offset_y);
    statusView.text = [NSString stringWithFormat:@"x=%f, y=%f, offsetx=%f, offsety=%f", x, y, offset_x, offset_y];
    // max error on x axis and y axis, consider center within this ranges.
    // 8:6=480:360
    int max_error_x = 8;
    int max_error_y = 6;
    
    if (fabs(offset_x) > fabs(offset_y)){
        // move horizon first, then vertical
        if (fabs(offset_x) > max_error_x) {
            if (offset_x < 0){
                NSLog(@"move head right");
                [self sendCmdToRobot:@"/mh/12"]; // move head right
//                [self sendCmdToRobot:@"/m=2-6"]; // move head right
            }
            else{
                NSLog(@"move head left");
                [self sendCmdToRobot:@"/mh/11"]; // move head left
//                [self sendCmdToRobot:@"/m=2+6"]; // move head left

            }
        }
        if (fabs(offset_y) > max_error_y) { 
            if (offset_y > 0){
                NSLog(@"move head down");
                [self sendCmdToRobot:@"/mh/14"]; // move head down
            }
            else{
                NSLog(@"move head up");
                [self sendCmdToRobot:@"/mh/13"]; // move head up
            }
        }
    }else{ // move vertical first, then horizon

        if (fabs(offset_y) > max_error_y) {
            if (offset_y > 0)
                [self sendCmdToRobot:@"/mh/14"]; // move head down
            else
                [self sendCmdToRobot:@"/mh/13"]; // move head up
        }        
        if (fabs(offset_x) > max_error_x) {
            if (offset_x < 0)
                [self sendCmdToRobot:@"/mh/12"]; // move head right
//            [self sendCmdToRobot:@"/m=2-6"]; // move head right

            else
                [self sendCmdToRobot:@"/mh/11"]; // move head left
//            [self sendCmdToRobot:@"/m=2+6"]; // move head left

        }    
    }
        
    
    
}

- (UIImage*) rotateImage:(UIImage*) imgsrc{
    UIImage * img = [imgsrc copy];
    
    // rotate image
    CGImageRef imgRef = img.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    
    CGFloat scaleRatio = 1;
    
    
    CGFloat boundHeight;
    
    //   UIImageOrientation orient = capturedImage.imageOrientation;
    
    transform = CGAffineTransformMakeTranslation(0.0, height);
    
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, scaleRatio, -scaleRatio);
    
    CGContextTranslateCTM(context, 0, -height);
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    
    detectingImage = [imageCopy copy];
    
    UIGraphicsEndImageContext();
    [imageCopy release];
    return detectingImage;

}
- (void)detectFaceThread {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    [self retain];
    
    while (self.detecting){
        if (self.capturedImage != nil){
            UIImage * img = [capturedImage copy];
            
            // rotate image
            CGImageRef imgRef = img.CGImage;
            
            CGFloat width = CGImageGetWidth(imgRef);
            
            CGFloat height = CGImageGetHeight(imgRef);
            
            
            CGAffineTransform transform = CGAffineTransformIdentity;
            
            CGRect bounds = CGRectMake(0, 0, width, height);
//            NSLog(@"bouds: %f, %f",width, height);
            
            CGFloat scaleRatio = 0.25f;
            
            
            CGFloat boundHeight;
            
            //   UIImageOrientation orient = capturedImage.imageOrientation;
            
            transform = CGAffineTransformMakeTranslation(0.0, height);
            
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            
            
            UIGraphicsBeginImageContext(bounds.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextScaleCTM(context, scaleRatio, -scaleRatio);
            
            CGContextTranslateCTM(context, 0, -height);
            CGContextConcatCTM(context, transform);
            
            CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
            
            UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
            
            detectingImage = [imageCopy copy];
//              NSLog(@"bouds2: %f, %f",detectingImage.size.width, detectingImage.size.height);
            [self detectFace:detectingImage  ];
            UIGraphicsEndImageContext();
            [imageCopy release];
        }
        [NSThread sleepForTimeInterval:0.1];
    }
    
   /* // If a face is found trigger the shutter otherwise perform
    // face detection again.
    if(faces->total > 0) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [NSThread sleepForTimeInterval:1];
       // [camera takePicture];
        
        CvRect *r = (CvRect *) cvGetSeqElem(faces, 0);
        
        face.origin.x = (float) r->x;
        face.origin.y = (float) r->y;
        face.size.width = (float) r->width;
        face.size.height = (float) r->height;
        
//        if([device platformType] != UIDevice3GSiPhone) {
            face.size.width /= .5;
            face.size.height /= .5;
            face.origin.x /= .5;
            face.origin.y /= .5;
//        } else {
//            face.size.width /= .75; face.size.width += 55 * .75;
//            face.size.height /= .75; face.size.height += 55 * .75;
//            face.origin.x /= .75; face.origin.x += 55 * .75;
//            face.origin.y /= .75; face.origin.y += 55 * .75;
//        }
        
    } else {
        if(self.detecting) {
            [self performSelectorInBackground:@selector(detectFaceThread) withObject:nil];
        }
    }
    */
    [pool release];
    [self release];
}

- (void)startDetection {
    if (avSessionForFaceDetection == nil || !avSessionForFaceDetection.running)
        [self setupCaptureSession];
    self.detecting = YES;
    [self performSelectorInBackground:@selector(detectFaceThread) withObject:nil];
  
}

- (void)stopDetection {
    self.detecting = NO;
    [avSessionForFaceDetection stopRunning];
    [avSessionForFaceDetection release];
    avSessionForFaceDetection = nil;
}


// use avfoundation
// Create and configure a capture session and start it running
- (void)setupCaptureSession 
{
    if (self.avSessionForFaceDetection){
        [self stopTorchMode];
        [self stopDetection];
    }
    NSError *error = nil;
    
    // Create the session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    // Configure the session to produce lower resolution video frames, if your 
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    // Find a suitable AVCaptureDevice
   // AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *device = nil;  
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]; 
    for (AVCaptureDevice *device1 in videoDevices)  
    {  
        if (device1.position == AVCaptureDevicePositionFront)  
        {  
            device = device1;  
            break;  
        }  
    }  
    
    //  couldn't find one on the front, so just get the default video device.  
    if ( ! device)  
    {  
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];  
    }  
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        // Handling the error appropriately.
    }
    [session addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    [session addOutput:output];
    
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
    
    // Specify the pixel format
    output.videoSettings = 
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    
    // If you wish to cap the frame rate to a known value, such as 15 fps, set 
    // minFrameDuration.
    output.minFrameDuration = CMTimeMake(1, 15);
    
    // Start the session running to start the flow of data
    [session startRunning];
    
    // Assign session to an ivar.
    [self setAvSessionForFaceDetection:session];
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
       fromConnection:(AVCaptureConnection *)connection
{ 
    // Create a UIImage from the sample buffer data
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
 //   UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedImage:didFinishSavingWithError:contextInfo:), nil);
    self.capturedImage = image;
    
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer 
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer); 
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, 
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context); 
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context); 
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}
/*
// play sounds/music
- (void) playMusic:(NSSTRING*)src{
    NSString *soundPath=[[NSBundle mainBundle] pathForResource:@"dance" ofType:@"mp3"];
  
    NSURL *soundUrl=[[NSURL alloc] initFileURLWithPath:soundPath];
    
    player=[[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    [player prepareToPlay];

}*/


// torch mode
- (void) stopTorchMode{
    if (avSessionForTorch){
        [avSessionForTorch stopRunning];
        [avSessionForTorch release];
        avSessionForTorch = nil;
    }

}
- (void) startTorchMode{
    [self stopTorchMode];
    if (avSessionForFaceDetection || self.detecting){
         [self stopDetection];
//        sleep(1000);
    }
       
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  
    if (device.torchMode == AVCaptureTorchModeOff)
    {
        // Create an AV session
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        
        // Create device input and add to current session
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error: nil];
        [session addInput:input];
        
        // Create video output and add to current session
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        [session addOutput:output];
        
        // Start session configuration
        [session beginConfiguration];
        [device lockForConfiguration:nil];
        
        // Set torch to on
        [device setTorchMode:AVCaptureTorchModeOn];
        
        [device unlockForConfiguration];
        [session commitConfiguration];
        
        // Start the session
        [session startRunning];
        
        // Keep the session around
        [self setAvSessionForTorch:session];
        
        [output release];
    }
}


// take photo
- (void) takePhoto{
    left_eye.hidden = YES;
    right_eye.hidden = YES;
    [background setImage:[self rotateImage:[capturedImage copy]]];
    return;
   /* sleep(1000);
    
    //UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedImage:didFinishSavingWithError:contextInfo:), nil);
     [background setImage:[UIImage imageNamed:@"irobot2.jpg"]];
    left_eye.hidden = NO;
    right_eye.hidden = NO;*/
}
@end
