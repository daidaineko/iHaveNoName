//
//  XBMCView.mm
//  Air Mouse
//
//  Created by Martin Guillon on 3/4/11.
//  Copyright 2011 Movea. All rights reserved.
//

#import "XBMCScrollView.h"


@implementation XBMCScrollView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

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

- (void)dealloc {
    [super dealloc];
}


@end
