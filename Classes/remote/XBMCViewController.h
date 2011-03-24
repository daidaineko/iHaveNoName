//
//  ScrollViewWithPagingViewController.h
//  ScrollViewWithPaging
//
//  Created by Yuen Ying Kit on 18/05/2010.
//  Url: http://ykyuen.wordpress.com/2010/05/22/iphone-uiscrollview-with-paging-efile://localhost/Volumes/dev/bazaar/AirMouse/Classes/XBMCPageViewController.hxample/
//

#import <UIKit/UIKit.h>

@class MouseViewController;

@interface XBMCViewController : UIViewController <UIScrollViewDelegate> {
	UIScrollView *scrollView;
	UIPageControl *pageControl;
    NSMutableArray *viewControllers;
    //    XBMCListener* _xbmcListener;
    	
    MouseViewController *parent;
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain) IBOutlet MouseViewController *parent;

- (IBAction)changePage:(id)sender;
- (void)sendKey:(NSString* )key;
- (void)triggerMotion;
- (void)unTriggerMotion;	

@end

