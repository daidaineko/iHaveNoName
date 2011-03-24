
#import "XBMCViewController.h"
#import "XBMCPageViewController.h"
#import "TheElementsAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

static NSUInteger kNumberOfPages = 2;

@interface XBMCViewController (PrivateMethods)

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

@end

@implementation XBMCViewController

@synthesize scrollView, viewControllers;
@synthesize parent;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
*/
- (void)viewDidLoad {
	[super viewDidLoad];
	
	// view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++) {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    [controllers release];
	
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    scrollView.layer.borderColor = [UIColor blackColor].CGColor;
    scrollView.layer.borderWidth = 2.0f;
	
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.currentPage = 0;
    
//    UISwipeGestureRecognizer *recognizer;
//    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
//    recognizer.direction = UISwipeGestureRecognizerDirectionDown;
//    recognizer.delaysTouchesBegan = TRUE;
//    [scrollView addGestureRecognizer:recognizer];
//    [recognizer release];
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
    
	
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

//- (void)handleSwipeDown:(UISwipeGestureRecognizer *)recognizer 
//{
//    if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) 
//    {
//        [parent hideBottomView:nil];
//    }
//}
//
//- (void)handleSwipeUp:(UISwipeGestureRecognizer *)recognizer 
//{
//    if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) 
//    {
//        [delegate switchKeyboard:nil];
//    }
//}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= kNumberOfPages) return;
	
    // replace the placeholder if necessary
    XBMCPageViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[XBMCPageViewController alloc] initWithPageNumber:page];
        [controller setParent:self];
        
        [viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
	
    // add the controller's view to the scroll view
    if (nil == controller.view.superview) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [controller viewWillAppear:false];
        [scrollView addSubview:controller.view];
    }
}

#pragma mark -
#pragma mark Scroll View

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (pageControl.currentPage != page)
    {
        pageControl.currentPage = page;
        
        // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
    }
	
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [parent release];
    [viewControllers release];
    [scrollView release];
    [pageControl release];
    [super dealloc];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan");
    //    self.image = [UIImage imageNamed:@"touchpad-mpod-on.png"];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded");
    //    self.image = [UIImage imageNamed:@"touchpad-mpod.png"];
}


#pragma mark -
#pragma mark XBMC

- (void)sendKey:(NSString* )key
{   
//    std::string keystroke = "{"+std::string([key UTF8String])+"}";
//    [self.parent sendKeystroke:keystroke];
}

- (void)triggerMotion
{
//    if ([parent.motionManager inMotionPodSimu])
//    {
//        std::string msg = "6 1";
//        [((MTforiPhoneAppDelegate *)([UIApplication sharedApplication].delegate)) sendMessageToMoveaCore:msg];
//        [parent.motionManager startSendingMotionPodInfos];
//        return;
//    }
}

- (void)unTriggerMotion
{
//    if ([parent.motionManager inMotionPodSimu])
//    {
//        std::string msg = "6 0";
//        [((MTforiPhoneAppDelegate *)([UIApplication sharedApplication].delegate)) sendMessageToMoveaCore:msg];
//        [parent.motionManager stopSendingMotionPodInfos];
//        return;
//    }
}


- (void) viewWillAppear:(BOOL)animated
{   
//    if ([[parent motionManager] inMotionPodSimu] && [((MTforiPhoneAppDelegate *)([UIApplication sharedApplication].delegate)) connectedToFriend])
//    {
//        [[parent motionManager] start];
//    }
}

- (void) viewDidAppear:(BOOL)animated
{   
    [self becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated
{   
//    [[parent motionManager] stop];
}

@end
