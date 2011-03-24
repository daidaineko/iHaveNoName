//
//  XBMCViewController.h
//  Air Mouse
//
//  Created by Martin Guillon on 2/23/11.
//  Copyright 2011 Movea. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XBMCViewController;
@class XBMCTouchView;

@interface XBMCPageViewController : UIViewController {
    XBMCViewController *parent;
    UIImageView* cover;
    UILabel* titleLabel;
    UILabel* genreLabel;
    UILabel* yearLabel;
    UILabel* directorLabel;
    int pageNumber;
    XBMCTouchView* gestureView;

}

@property (nonatomic, retain) IBOutlet XBMCViewController *parent;
@property (nonatomic, retain) IBOutlet XBMCTouchView* gestureView;
@property (nonatomic, retain) IBOutlet UIImageView* cover;
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UILabel* genreLabel;
@property (nonatomic, retain) IBOutlet UILabel* yearLabel;
@property (nonatomic, retain) IBOutlet UILabel* directorLabel;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (id)initWithPageNumber:(int)page;

- (void)handleTap:(UITapGestureRecognizer *)recognizer;
- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer; 
- (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer ;

@end
