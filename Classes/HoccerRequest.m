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


+ (HoccerRequest *)sweepOutWithContent: (HoccerContent *)content location: (HocLocation *)location {
	HoccerRequest *request = [[HoccerRequest alloc] init];
	request.location = location;
	request.content = content;
	request.gesture = @"SweepOut";
	
	return [request autorelease];
}

+ (HoccerRequest *)sweepInWithLocation: (HocLocation *)location {
	HoccerRequest *request = [[HoccerRequest alloc] init];
	request.location = location;
	request.gesture = @"SweepIn";
	
	return [request autorelease];
}

+ (HoccerRequest *)throwWithContent: (HoccerContent *)content location: (HocLocation *)location {
	HoccerRequest *request = [[HoccerRequest alloc] init];
	request.location = location;
	request.content = content;
	request.gesture = @"Throw";
	
	return [request autorelease];
}

+ (HoccerRequest *)catchWithLocation: (HocLocation *)location {
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
