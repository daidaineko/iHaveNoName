//
//  untitled.h
//  MTforiPhone
//
//  Created by Martin Guillon on 8/9/10.
//  Copyright 2010 Ingenieur Recherche, Binocle. All rights reserved.
//

#ifndef XBMCTOUCHVIEW
#define XBMCTOUCHVIEW
#import <Foundation/Foundation.h>

@class XBMCPageViewController;

@interface XBMCTouchView : UIButton {

    XBMCPageViewController *parent;
}

@property (nonatomic, retain) IBOutlet XBMCPageViewController *parent;

@end

#endif
