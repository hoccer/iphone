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
#import "Y60AsyncTestHelper.h"

#import "HocLocation.h"
#import "HoccerVcard.h"
#import "HoccerRequest.h"

@interface MockHoccerClientDelegate : NSObject <HoccerClientDelegate> 
{
	NSInteger hoccerClientDidFailCalls;
	NSInteger hoccerClientDidFinishCalls;
	NSError *error;
}

@property (assign) NSInteger hoccerClientDidFailCalls;
@property (assign) NSInteger hoccerClientDidFinishCalls;
@property (retain) NSError *error;

- (void)hoccerClient: (HoccerClient*)hoccerClient didFailWithError: (NSError *)error;
- (void)hoccerClientDidFinishLoading: (HoccerClient*)hoccerClient;

@end

@implementation MockHoccerClientDelegate
@synthesize hoccerClientDidFailCalls;
@synthesize hoccerClientDidFinishCalls;
@synthesize error;

- (void)hoccerClient: (HoccerClient*)hoccerClient didFailWithError: (NSError *)theError {
	hoccerClientDidFailCalls += 1;
	
	self.error = theError;
}

- (void)hoccerClientDidFinishLoading: (HoccerClient*)hoccerClient {
	hoccerClientDidFinishCalls += 1;
}


- (void) dealloc {
	self.error = nil;
	[super dealloc];
}

@end


@implementation HoccerClientTestCase

- (BOOL)shouldRunOnMainThread {
	return NO;
}


- (void)setUp {
	mockedDelegate = [[MockHoccerClientDelegate alloc] init];
}

- (void)tearDown {
	[mockedDelegate release];
	mockedDelegate = nil; 
}

//- (void) testItFailsWithNoThrowerErrorWhenLonleyUpload {
//	HoccerClient *client = [[HoccerClient alloc] init];
//	client.userAgent = @"Hoccer/iPhone";
//	client.delegate = mockedDelegate;
//	client.hocLocation = [self fakeHocLocation];
//	
//	[client performSelectorOnMainThread: @selector(uploadWithGesture:) withObject:@"Throw" waitUntilDone: NO];
//	GHAssertTrue([Y60AsyncTestHelper waitForTarget:mockedDelegate selector:@selector(hoccerClientDidFailCalls) toBecome:1 atLeast:10], @"should be called once");
//	GHAssertEquals([mockedDelegate.error code], kHoccerMessageNoCatcher, @"should return no catcher error");
//}


//- (void) testItFailsWithNoSecondSweeperErrorWhenLoneySweeper {
//	HoccerClient *client = [[HoccerClient alloc] init];
//	client.userAgent = @"Hoccer/iPhone";
//	client.delegate = mockedDelegate;
//	client.hocLocation = [self fakeHocLocation];
//
//	[client performSelectorOnMainThread: @selector(uploadWithGesture:) withObject:@"SweepIn" waitUntilDone: NO];
//	GHAssertTrue([Y60AsyncTestHelper waitForTarget:mockedDelegate selector:@selector(hoccerClientDidFailCalls) toBecome:1 atLeast:10], @"should be called once");
//	GHAssertEquals([mockedDelegate.error code], kHoccerMessageNoSecondSweeper, @"should return no catcher error");
//}
//
//- (void) testItFailsWithNoCatcherErrorWhenLonleyUpload {
//	HoccerClient *client = [[HoccerClient alloc] init];
//	client.userAgent = @"Hoccer/iPhone";
//	client.delegate = mockedDelegate;
//	client.hocLocation = [self fakeHocLocation];
//	
//	[client performSelectorOnMainThread: @selector(uploadWithGesture:) withObject:@"Catch" waitUntilDone: NO];
//	GHAssertTrue([Y60AsyncTestHelper waitForTarget:mockedDelegate selector:@selector(hoccerClientDidFailCalls) toBecome:1 atLeast:10], @"should be called once");
//	GHAssertEquals([mockedDelegate.error code], kHoccerMessageNoThrower, @"should return no catcher error");
//}

//- (void) testItFailsWithCollisionErrorWhenTwoSweepAtTheSameTime {
//	HoccerClient *client = [[HoccerClient alloc] init];
//	client.userAgent = @"Hoccer/iPhone";
//	client.delegate = mockedDelegate;
//	client.hocLocation = [self fakeHocLocation];
//	[client performSelectorOnMainThread: @selector(uploadWithGesture:) withObject:@"SweepIn" waitUntilDone: NO];
//	
//	HoccerClient *client2 = [[HoccerClient alloc] init];
//	client2.userAgent = @"Hoccer/iPhone";
//	client2.hocLocation = [self fakeHocLocation];
//	[client2 performSelectorOnMainThread: @selector(uploadWithGesture:) withObject:@"SweepIn" waitUntilDone: NO];
//	
//	GHAssertTrue([Y60AsyncTestHelper waitForTarget:mockedDelegate selector:@selector(hoccerClientDidFailCalls) toBecome:1 atLeast:10], @"should be called once");
//	GHAssertEquals([mockedDelegate.error code], kHoccerMessageCollision, @"should return no catcher error");
//}
//

- (void) testItSuccedsWhenTwoPeoplePerformAdequateGesturesOnSameLocation {
	HoccerClient *client = [[HoccerClient alloc] init];
	client.userAgent = @"Hoccer/iPhone";
	client.delegate = mockedDelegate;
	
	HoccerRequest *request = [HoccerRequest sweepOutWithContent:[self fakeContent] location:[self fakeHocLocation]];
	[client performSelectorOnMainThread: @selector(connectionWithRequest:) withObject:request waitUntilDone: NO];
	
	HoccerRequest *request2 = [HoccerRequest sweepInWithLocation:[self fakeHocLocation]];
	MockHoccerClientDelegate *mockedDelegate2 = [[MockHoccerClientDelegate alloc] init];
	HoccerClient *client2 = [[HoccerClient alloc] init];
	client2.userAgent = @"Hoccer/iPhone";
	client2.delegate = mockedDelegate2;
	[client2 performSelectorOnMainThread:@selector(connectionWithRequest:) withObject:request2 waitUntilDone:NO];
	
	GHAssertTrue([Y60AsyncTestHelper waitForTarget:mockedDelegate selector:@selector(hoccerClientDidFinishCalls) toBecome:1 atLeast:10], @"should be called once");
	GHAssertTrue([Y60AsyncTestHelper waitForTarget:mockedDelegate2 selector:@selector(hoccerClientDidFinishCalls) toBecome:1 atLeast:2], @"should be called once");
	
	[mockedDelegate2 release];
	[client release];
	[client2 release];
} 

- (HocLocation *)fakeHocLocation {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = 14;
	coordinate.longitude = 23;
	
	CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:1 horizontalAccuracy:0.01 verticalAccuracy:100 timestamp:[NSDate date]];
	HocLocation *hocLocation = [[HocLocation alloc] initWithLocation:location bssids:nil];
	
	[location release];
	return [hocLocation autorelease];
}

- (HoccerContent *)fakeContent {
	NSData *data = [@"hallo world" dataUsingEncoding: NSASCIIStringEncoding];
	
	return [[HoccerVcard alloc] initWithData:data filename:@"test.vcf"];
}

@end
