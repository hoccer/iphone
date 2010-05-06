//
//  HoccerProgressView.m
//  Hoccer
//
//  Created by Robert Palmer on 27.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerProgressView.h"
#import <QuartzCore/QuartzCore.h>

@interface HoccerProgressView ()

- (void)setUp;
- (void)recalculatePositions;

@end



@implementation HoccerProgressView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self setUp];
    }
    return self;
}

- (void) dealloc
{
	[progressLeft release];
	[progressRight release];
	[progressCenter release];
	[super dealloc];
}

- (void)awakeFromNib {
	[self setUp];
}

- (void)setUp {
	CGRect frame = self.frame;
	frame.size.height = 19;
	frame.size.width = 187;
	self.frame = frame;
	
	self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"statusbar_progress_track.png"]];
	
	progressLeft = [[CALayer layer] retain]; 
	progressLeft.frame = CGRectMake(0, 0, 7, 19);
	progressLeft.contents = (id)[UIImage imageNamed:@"statusbar_progress_thumb_L.png"].CGImage;
	[self.layer addSublayer:progressLeft];
	
	progressRight = [[CALayer layer] retain];
	progressRight.frame = CGRectMake(20, 0, 7, 19);
	progressRight.contents = (id)[UIImage imageNamed:@"statusbar_progress_thumb_R.png"].CGImage;
	[self.layer addSublayer:progressRight];
	
	progressCenter = [[CALayer layer] retain];
	progressCenter.frame = CGRectMake(7, 0, 13, 19);
	progressCenter.contents = (id)[UIImage imageNamed:@"statusbar_progress_thumb_bg.png"].CGImage;
	[self.layer addSublayer:progressCenter];
}

- (void)recalculatePositions {
	CGFloat progressBarWidth = self.frame.size.width - progressLeft.frame.size.width - progressRight.frame.size.width;
	CGFloat progressWidth = self.progress * progressBarWidth;
	
	CGRect barFrame = progressCenter.frame;
	barFrame.size.width = progressWidth;
	progressCenter.frame = barFrame;
	
	CGRect capFrame = progressRight.frame;
	capFrame.origin.x  = progressLeft.frame.size.width + progressWidth;
	progressRight.frame = capFrame;
}

- (void)drawRect:(CGRect)rect {
    [self recalculatePositions];
}


@end
