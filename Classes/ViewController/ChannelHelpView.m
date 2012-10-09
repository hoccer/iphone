//
//  ChannelHelpView.m
//  Hoccer
//
//  Created by Ralph At Hoccer on 05.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "ChannelHelpView.h"

@implementation ChannelHelpView

@synthesize channelName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)dealloc {
    [channelName release];
    [super dealloc];
}
@end
