//
//  HoccerRequest.m
//  Hoccer
//
//  Created by Robert Palmer on 23.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerRequest.h"
#import "HocLocation.h"
#import "HoccerContent.h"


@implementation HoccerRequest

@synthesize location;
@synthesize content;
@synthesize gesture;


+ (HocLocation *)sweepOutWithContent: (HoccerContent *)content location: (HocLocation *)location {
	HoccerRequest *request = [[HoccerRequest alloc] init];
	request.location = location;
	request.content = content;
	request.gesture = @"SweepOut";
	
	return [request autorelease];
}

+ (HocLocation *)sweepInWithLocation: (HocLocation *)location {
	HoccerRequest *request = [[HoccerRequest alloc] init];
	request.location = location;
	request.gesture = @"SweepIn";
	
	return [request autorelease];
}

+ (HocLocation *)throwWithContent: (HoccerContent *)content location: (HocLocation *)location {
	HoccerRequest *request = [[HoccerRequest alloc] init];
	request.location = location;
	request.content = content;
	request.gesture = @"Throw";
	
	return [request autorelease];
}

+ (HocLocation *)catchWithLocation: (HocLocation *)location {
	HoccerRequest *request = [[HoccerRequest alloc] init];
	request.location = location;
	request.gesture = @"Catch";
	
	return [request autorelease];
}

- (void) dealloc {
	[location release];
	[content release];
	[gesture release];
	
	[super dealloc];
}



@end
