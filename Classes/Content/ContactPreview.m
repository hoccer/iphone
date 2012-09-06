//
//  ContactPreview.m
//  Hoccer
//
//  Created by Robert Palmer on 29.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import "ContactPreview.h"

@implementation ContactPreview
@synthesize name,otherInfo,image,company;

- (void) dealloc {
	[name release];
    [otherInfo release];
    [image release];
    [company release];
	[super dealloc];
}


@end
