//
//  HoccerRequest.m
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerRequest.h"


@implementation HoccerRequest

@synthesize requestStamp;

- (id) init
{
	self = [super init];
	if (self != nil) {		
		self.requestStamp = [NSDate timeIntervalSinceReferenceDate];
	}
	return self;
}

@end
