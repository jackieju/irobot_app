//
//  irobotViewController.m
//  irobot
//
//  Created by juweihua on 11/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "irobotViewController.h"

// import for OpenEars 
#import "AudioSessionManager.h"
#import "PocketsphinxController.h"
//#import "FliteController.h"
#import "OpenEarsEventsObserver.h"
//#import "LanguageModelGenerator.h"

@implementation irobotViewController

@synthesize textView;
@synthesize right_eye;
@synthesize left_eye;
@synthesize background;
// openears
@synthesize pocketsphinxController;
@synthesize openEarsEventsObserver;
@synthesize pathToGrammarToStartAppWith;
@synthesize pathToDictionaryToStartAppWith;

- (void)dealloc
{
    [background release];
    
    [left_eye release];
    [right_eye release];
    openEarsEventsObserver.delegate = nil;
	[openEarsEventsObserver release];
    [pocketsphinxController release];
    [status_view release];
    [textView release];
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


  
     // initialize openears
    self.pathToGrammarToStartAppWith = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"7678.languagemodel"]; 
    
       
 
	self.pathToDictionaryToStartAppWith = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"7678.dic"];


    [self.pocketsphinxController startListeningWithLanguageModelAtPath:pathToGrammarToStartAppWith dictionaryAtPath:pathToDictionaryToStartAppWith languageModelIsJSGF:FALSE];

}


- (void)viewDidUnload
{
    [self setBackground:nil];
    [self setLeft_eye:nil];
    [self setRight_eye:nil];
    [self setTextView:nil];
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
        else if([hypothesis isEqualToString:@"LOOK AROUND"]) {
            bCmd = true; NSLog(@"===>look around");
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
            [request setURL:[NSURL URLWithString:@"http://169.254.203.23/mh/15"]];
            [request setHTTPMethod:@"GET"];
            //  NSMutableData* buf = [[NSMutableData alloc] initWithLength:0];
            NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [request release];
        }else if([hypothesis isEqualToString:@"GO"]) {
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
        }
        else if([hypothesis hasPrefix:@"STOP"]) {
            bCmd = true;NSLog(@"===>stop");
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
            [request setURL:[NSURL URLWithString:@"http://169.254.203.23/stop"]];
            [request setHTTPMethod:@"GET"];
            //  NSMutableData* buf = [[NSMutableData alloc] initWithLength:0];
            NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [request release];
        }
    
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
@end
