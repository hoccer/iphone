//
//  HoccerClientTestCase.m
//  Hoccer
//
//  Created by Robert Palmer on 20.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <OCMock/OCMock.h>
#import "HoccerClientTestCase.h"
#import "HoccerClient.h"
#import "HoccerClientDelegate.h"

@implementation HoccerClientTestCase

- (BOOL)shouldRunOnMainThread {
	return NO;
}

- (void) testSendingWithHoccerClient {
	id mockedDelegate = [OCMockObject mockForProtocol:@protocol(HoccerClientDelegate)];
	
	HoccerClient *client = [[HoccerClient alloc] init];
	client.userAgent = @"Hoccer/iPhone";
	client.delegate = self;
	
	[client uploadWithGesture:@"sweep"];
}

@end
