//
//  HoccerClientTestCase.m
//  Hoccer
//
//  Created by Robert Palmer on 20.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerClientTestCase.h"
#import "HoccerClient.h"
#import "HoccerConnectionDelegate.h"
#import "Y60AsyncTestHelper.h"

#import "HocLocation.h"
#import "HoccerVcard.h"
#import "HoccerRequest.h"
#import "HoccerConnection.h"
#import "DeleteRequest.h"

@interface MockHoccerConnectionDelegate : NSObject <HoccerConnectionDelegate> 
{
	NSInteger hoccerClientDidFailCalls;
	NSInteger hoccerClientDidFinishCalls;
	NSError *error;
}

@property (assign) NSInteger hoccerClientDidFailCalls;
@property (assign) NSInteger hoccerClientDidFinishCalls;
@property (retain) NSError *error;

- (void)hoccerConnection: (HoccerConnection*)hoccerConnection didFailWithError: (NSError *)error;
- (void)hoccerConnectionDidFinishLoading: (HoccerConnection*)hoccerConnection;

@end

@implementation MockHoccerConnectionDelegate
@synthesize hoccerClientDidFailCalls;
@synthesize hoccerClientDidFinishCalls;
@synthesize error;

- (void)hoccerConnection: (HoccerConnection*)hoccerConnection didFailWithError: (NSError *)theError {
	hoccerClientDidFailCalls += 1;
	
	self.error = theError;
}

- (void)hoccerConnectionDidFinishLoading: (HoccerConnection*)hoccerConnection {
	hoccerClientDidFinishCalls += 1;
}

- (void)hoccerConnection: (HoccerConnection *)hoccerConnection didUpdateStatus: (NSDictionary *)status; {
}

- (void)hoccerConnection: (HoccerConnection *)hoccerConnection didUpdateTransfereProgress: (NSNumber *)progress; {
	
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
	mockedDelegate = [[MockHoccerConnectionDelegate alloc] init];
}

- (void)tearDown {
	[mockedDelegate release];
	mockedDelegate = nil; 
}
//
//- (void) testItFailsWithNoThrowerErrorWhenLonleyUpload {
//	HoccerClient *client = [[HoccerClient alloc] init];
//	client.userAgent = @"Hoccer/iPhone";
//	client.delegate = mockedDelegate;
//	
//	[client performSelectorOnMainThread: @selector(connectionWithRequest:) withObject:[HoccerRequest throwWithContent:[self fakeContent] location:[self fakeHocLocation]] waitUntilDone: NO];
//	GHAssertTrue([Y60AsyncTestHelper waitForTarget:mockedDelegate selector:@selector(hoccerClientDidFailCalls) toBecome:1 atLeast:10], @"should be called once");
//	GHAssertEquals([mockedDelegate.error code], kHoccerMessageNoCatcher, @"should return no catcher error");
//}
//
//
//- (void) testItFailsWithNoSecondSweeperErrorWhenLoneySweeper {
//	HoccerClient *client = [[HoccerClient alloc] init];
//	client.userAgent = @"Hoccer/iPhone";
//	client.delegate = mockedDelegate;
//
//	[client performSelectorOnMainThread: @selector(connectionWithRequest:) withObject:[HoccerRequest sweepInWithLocation:[self fakeHocLocation]] waitUntilDone: NO];
//	GHAssertTrue([Y60AsyncTestHelper waitForTarget:mockedDelegate selector:@selector(hoccerClientDidFailCalls) toBecome:1 atLeast:10], @"should be called once");
//	GHAssertEquals([mockedDelegate.error code], kHoccerMessageNoSecondSweeper, @"should return no catcher error");
//}
//
//- (void) testItFailsWithNoCatcherErrorWhenLonleyUpload {
//	HoccerClient *client = [[HoccerClient alloc] init];
//	client.userAgent = @"Hoccer/iPhone";
//	client.delegate = mockedDelegate;
//	
//	[client performSelectorOnMainThread: @selector(connectionWithRequest:) withObject:[HoccerRequest throwWithContent:[self fakeContent] location:[self fakeHocLocation]] waitUntilDone: NO];
//	GHAssertTrue([Y60AsyncTestHelper waitForTarget:mockedDelegate selector:@selector(hoccerClientDidFailCalls) toBecome:1 atLeast:10], @"should be called once");
//	GHAssertEquals([mockedDelegate.error code], kHoccerMessageNoCatcher, @"should return no catcher error");
//}

- (void) testItFailsWithCollisionErrorWhenTwoSweepAtTheSameTime {
	HoccerClient *client = [[HoccerClient alloc] init];
	client.userAgent = @"Hoccer/iPhone";
	client.delegate = mockedDelegate;
	
	HocLocation *location = [self fakeHocLocation];

	[client performSelectorOnMainThread: @selector(connectionWithRequest:) withObject:[HoccerRequest sweepOutWithContent:[self fakeContent] location:location] waitUntilDone: NO];
	HoccerClient *client2 = [[HoccerClient alloc] init];
	client2.userAgent = @"Hoccer/iPhone";
	[client2 performSelectorOnMainThread: @selector(connectionWithRequest:) withObject:[HoccerRequest sweepOutWithContent:[self fakeContent] location:location] waitUntilDone: NO];
	
	GHAssertTrue([Y60AsyncTestHelper waitForTarget:mockedDelegate selector:@selector(hoccerClientDidFailCalls) toBecome:1 atLeast:10], @"should be called once");
	GHAssertEquals([mockedDelegate.error code], kHoccerMessageCollision, @"should return no catcher error");
	[NSThread sleepForTimeInterval:1];
}


- (void) testItSuccedsWhenTwoPeoplePerformAdequateGesturesOnSameLocation {
	HoccerClient *client = [[HoccerClient alloc] init];
	client.userAgent = @"Hoccer/iPhone";
	client.delegate = mockedDelegate;
	
	MockHoccerConnectionDelegate *mockedDelegate2 = [[MockHoccerConnectionDelegate alloc] init];
	HoccerClient *client2 = [[HoccerClient alloc] init];
	client2.userAgent = @"Hoccer/iPhone";
	client2.delegate = mockedDelegate2;
	
	HocLocation *location = [self fakeHocLocation];
	HoccerConnection *connection = [client unstartedConnectionWithRequest:[HoccerRequest sweepOutWithContent:[self fakeContent] location: location]];
	[connection performSelectorOnMainThread: @selector(startConnection) withObject:nil waitUntilDone: NO];

	HoccerConnection *connection2 = [client2 unstartedConnectionWithRequest:[HoccerRequest sweepInWithLocation:location]];
	[connection2 performSelectorOnMainThread: @selector(startConnection) withObject:nil waitUntilDone: NO];
		
	GHAssertTrue([Y60AsyncTestHelper waitForTarget:mockedDelegate selector:@selector(hoccerClientDidFinishCalls) toBecome:1 atLeast:10], @"should be called once");
	GHAssertTrue([Y60AsyncTestHelper waitForTarget:mockedDelegate2 selector:@selector(hoccerClientDidFinishCalls) toBecome:1 atLeast:10], @"should be called once");
	
	[mockedDelegate2 release];
	[client release];
	[client2 release];
} 

//- (void)testResourceShouldBeGoneAfterCancel {
//	HoccerClient *client = [[HoccerClient alloc] init];
//	client.userAgent = @"Hoccer/iPhone";
//	client.delegate = mockedDelegate;
//
//	HoccerConnection *connection = [client unstartedConnectionWithRequest:[HoccerRequest sweepOutWithContent:[self fakeContent] location:[self fakeHocLocation]]];
//	
//	[connection performSelectorOnMainThread: @selector(startConnection) withObject:nil waitUntilDone: NO];
//	[NSThread sleepForTimeInterval:1];
//	[connection performSelectorOnMainThread: @selector(cancel) withObject:nil waitUntilDone:NO];
//	
//	[NSThread sleepForTimeInterval:1];
//	
//	NSError *error;
//	NSHTTPURLResponse *response;
//	NSURLRequest *request = [NSURLRequest requestWithURL:connection.eventURL];
//	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//	GHAssertEquals([response statusCode], 410, @"should return 410 status code");
//	
//	[client release];
//}

//- (void)testShouldNotInterceptItselfWhenCanceled {
//	HoccerClient *client = [[HoccerClient alloc] init];
//	client.userAgent = @"Hoccer/iPhone";
//	HoccerConnection *connection = [client unstartedConnectionWithRequest:[HoccerRequest sweepOutWithContent:[self fakeContent] location:[self fakeHocLocation]]];
//	
//	[connection performSelectorOnMainThread: @selector(startConnection) withObject:nil waitUntilDone: NO];
//	[NSThread sleepForTimeInterval:1];
//	[connection performSelectorOnMainThread: @selector(cancel) withObject:nil waitUntilDone:NO];
//	
//	[NSThread sleepForTimeInterval:1];
//	
//	client.delegate = mockedDelegate;
//	connection = [client unstartedConnectionWithRequest:[HoccerRequest sweepOutWithContent:[self fakeContent] location:[self fakeHocLocation]]];
//	[connection performSelectorOnMainThread: @selector(startConnection) withObject:nil waitUntilDone: NO];
//	[NSThread sleepForTimeInterval:3];
//	GHAssertEquals(mockedDelegate.hoccerClientDidFailCalls, 0, [NSString stringWithFormat: @"should be able to sweep, but failed with %@", mockedDelegate.error]);
//	
//	[client release];
//}



// still to implement on the server
//- (void)testItShouldReturnGoneWhenOneClientDeletesResource {
//	HoccerClient *client = [[HoccerClient alloc] init];
//	client.userAgent = @"Hoccer/iPhone";
//	client.delegate = mockedDelegate;
//	
//	MockHoccerConnectionDelegate *mockedDelegate2 = [[MockHoccerConnectionDelegate alloc] init];
//	HoccerClient *client2 = [[HoccerClient alloc] init];
//	client2.userAgent = @"Hoccer/iPhone";
//	client2.delegate = mockedDelegate2;
//	
//	HoccerConnection *connection = [client unstartedConnectionWithRequest:[HoccerRequest sweepOutWithContent:[self fakeContent] location:[self fakeHocLocation]]];
//	[connection performSelectorOnMainThread: @selector(startConnection) withObject:nil waitUntilDone: NO];
//	
//	[NSThread sleepForTimeInterval:0.3];
//	
//	HoccerConnection *connection2 = [client2 unstartedConnectionWithRequest:[HoccerRequest sweepInWithLocation:[self fakeHocLocation]]];
//	[connection2 performSelectorOnMainThread: @selector(startConnection) withObject:nil waitUntilDone: NO];
//
//	[NSThread sleepForTimeInterval:1];
//	[connection cancel];
//
//	// GHAssertTrue([Y60AsyncTestHelper waitForTarget:mockedDelegate selector:@selector(hoccerClientDidFinishCalls) toBecome:1 atLeast:10], @"should be called once");
//	GHAssertTrue([Y60AsyncTestHelper waitForTarget:mockedDelegate2 selector:@selector(hoccerClientDidFinishCalls) toBecome:1 atLeast:10], @"should be called once");
//	
//	[mockedDelegate2 release];
//	[client release];
//	[client2 release];
//}

- (HocLocation *)fakeHocLocation {
	delta += 1;
	
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = 14 + delta;
	coordinate.longitude = 23 + delta;
	
	CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:100 timestamp:[NSDate date]];
	HocLocation *hocLocation = [[HocLocation alloc] initWithLocation:location bssids:nil];
	
	[location release];
	return [hocLocation autorelease];
}

- (HoccerContent *)fakeContent {
	NSData *data = [@"hallo world" dataUsingEncoding: NSASCIIStringEncoding];
	
	return [[HoccerVcard alloc] initWithData:data filename:@"test.vcf"];
}

@end
