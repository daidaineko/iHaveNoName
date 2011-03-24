//
//  untitled.m
//  MTforiPhone
//
//  Created by Martin Guillon on 8/9/10.
//  Copyright 2010 Ingenieur Recherche, Binocle. All rights reserved.
//

#import "XBMCTouchView.h"
#import "XBMCPageViewController.h"


@implementation XBMCTouchView

@synthesize parent;

- (void)awakeFromNib
{    
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [parent triggerMotion:nil];
////    self.image = [UIImage imageNamed:@"touchpad-mpod-on.png"];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//}
//
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [parent unTriggerMotion:nil];
////    self.image = [UIImage imageNamed:@"touchpad-mpod.png"];
//}

- (void)dealloc 
{
    [parent release];
    [super dealloc];
}

@end
