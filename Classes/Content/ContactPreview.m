//
//  ContactPreview.m
//  Hoccer
//
//  Created by Robert Palmer on 29.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
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
