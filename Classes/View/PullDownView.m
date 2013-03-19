//
//  PullDownView.m
//  Hoccer
//
//  Created by Ralph on 18.12.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "PullDownView.h"

@implementation PullDownView

@synthesize desktopView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    self.statusLabel.text = NSLocalizedString(@"PullDown_WaitingForThrownData", nil);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	UITouch* touch = [touches anyObject];
//    
//	CGPoint prevLocation = [touch previousLocationInView: self];
//	CGPoint currentLocation = [touch locationInView: self];
//	
//    //NSLog(@"1.a. DesktopView - touchesMoved from %f - %f", prevLocation.x, prevLocation.y);
//    //NSLog(@"1.a. DesktopView - touchesMoved to   %f - %f", currentLocation.x, currentLocation.y);
//    
//    
//    CGRect myRect = self.frame;
//	myRect.origin.y += currentLocation.y - prevLocation.y;
//	self.frame = myRect;
//    
//    CGRect desktopViewRect = desktopView.frame;
//	desktopViewRect.origin.y += currentLocation.y - prevLocation.y;
//	desktopView.frame = desktopViewRect;
//
//}



@end
