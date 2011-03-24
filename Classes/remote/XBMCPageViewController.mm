//
//  XBMCViewController.mm
//  Air Mouse
//
//  Created by Martin Guillon on 2/23/11.
//  Copyright 2011 Movea. All rights reserved.
//
#import <QuartzCore/CALayer.h>
#import "XBMCPageViewController.h"
#import "XBMCViewController.h"
#import "XBMCTouchView.h"
#import "TheElementsAppDelegate.h"
#import "XBMCHttpInterface.h"

@implementation XBMCPageViewController
@synthesize cover;
@synthesize titleLabel;
@synthesize directorLabel;
@synthesize yearLabel;
@synthesize parent;
@synthesize genreLabel;
@synthesize gestureView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    //_xbmcListener = new XBMCListener();

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center
     addObserver:self
     selector:@selector(friendConnected:)
     name:@"UdpFriendConnected"
     object:nil ];
    
    [center
     addObserver:self
     selector:@selector(friendDisconnected:)
     name:@"UdpFriendDisconnected"
     object:nil ];
    
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [gestureView addGestureRecognizer:recognizer];
    [recognizer release];
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [gestureView addGestureRecognizer:recognizer];
    [recognizer release];
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [gestureView addGestureRecognizer:recognizer];
    [recognizer release];
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [gestureView addGestureRecognizer:recognizer];
    [recognizer release];
    
    UITapGestureRecognizer *doubletaprecognizer;
    doubletaprecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubletaprecognizer.numberOfTapsRequired = 2;
    [gestureView addGestureRecognizer:doubletaprecognizer];
    
    UITapGestureRecognizer *taprecognizer;
    taprecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
     [taprecognizer requireGestureRecognizerToFail:doubletaprecognizer];
    [gestureView addGestureRecognizer:taprecognizer];
    [doubletaprecognizer release];
    [taprecognizer release];
//    
//    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)];
//    recognizer.direction = UISwipeGestureRecognizerDirectionUp;
//    recognizer.delaysTouchesBegan = TRUE;
//    [scrollView addGestureRecognizer:recognizer];
//    [recognizer release];
//    
//    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:delegate action:@selector(hideBottomView:)];
//    recognizer.direction = UISwipeGestureRecognizerDirectionDown;
//    recognizer.delaysTouchesBegan = TRUE;
//    [hideButton addGestureRecognizer:recognizer];
//    [recognizer release];
//    
//    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:delegate action:@selector(switchKeyboard:)];
//    recognizer.direction = UISwipeGestureRecognizerDirectionDown;
//    recognizer.delaysTouchesBegan = TRUE;
//    [switchButton addGestureRecognizer:recognizer];
//    [recognizer release];
//    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:delegate action:@selector(switchKeyboard:)];
//    recognizer.direction = UISwipeGestureRecognizerDirectionUp;
//    recognizer.delaysTouchesBegan = TRUE;
//    [switchButton addGestureRecognizer:recognizer];
//    [recognizer release];
    
//    [center addObserver:self
//               selector:@selector(applicationWillEnterForeground)
//                   name:UIApplicationWillEnterForegroundNotification
//                 object:nil];
//    [center addObserver:self
//               selector:@selector(applicationDidEnterBackground)
//                   name:UIApplicationDidEnterBackgroundNotification
//                 object:nil];
    
}

// Load the view nib and initialize the pageNumber ivar.
- (id)initWithPageNumber:(int)page {
    switch (page) {
        case 0:
            self = [super initWithNibName:@"XBMCButtonsPage" bundle:nil];
            if (self) {
                pageNumber = page;
            }
            break;
        case 1:
            self = [super initWithNibName:@"XBMCGesturePage" bundle:nil];
            if (self) {
                pageNumber = page;
            }
            break;
        default:
            break;
    }
    
    return self;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [parent release];
    [cover release];
    [titleLabel release];
    [yearLabel release];
    [genreLabel release];
    [directorLabel release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [super dealloc];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    //_xbmcListener->stopUdpInterface();
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    //_xbmcListener->startUdpInterface();
}

- (void) viewWillAppear:(BOOL)animated
{   
    switch (pageNumber) {
        case 0:
            break;
        case 1:
        {
            CALayer *layer = cover.layer;
            layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
            CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
            rotationAndPerspectiveTransform.m34 = 1.0 / -600;
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 15.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
            layer.transform = rotationAndPerspectiveTransform;
            break;
        }
        default:
            break;
    }
    
    
}

- (void) viewDidAppear:(BOOL)animated
{   
}

- (void) viewWillDisappear:(BOOL)animated
{   
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer 
{
    if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) 
    {
        [[XBMCHttpInterface sharedInstance] sendCommand:@"Action(4)"];
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) 
    {
        [[XBMCHttpInterface sharedInstance] sendCommand:@"Action(3)"];
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) 
    {
        [[XBMCHttpInterface sharedInstance] sendCommand:@"Action(1)"];
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) 
    {
        [[XBMCHttpInterface sharedInstance] sendCommand:@"Action(2)"];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer 
{
    if ([[XBMCHttpInterface sharedInstance] isSomethingPlaying])
    {
        [[XBMCHttpInterface sharedInstance] stop];
    }
    else
    {
        [[XBMCHttpInterface sharedInstance] sendCommand:@"Action(9)"];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer 
{
    if ([[XBMCHttpInterface sharedInstance] isSomethingPlaying])
    {
        [[XBMCHttpInterface sharedInstance] pause];
    }
    else
    {
        [[XBMCHttpInterface sharedInstance] sendCommand:@"Action(7)"];
    }
}

@end
