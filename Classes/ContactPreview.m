//
//  ContactPreview.m
//  Hoccer
//
//  Created by Robert Palmer on 29.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "ContactPreview.h"

@implementation ContactPreview
@synthesize name;

- (void) dealloc
{
	[name release];
	
	[super dealloc];
}


@end
