//
//  StatusViewControllerTest.m
//  Hoccer
//
//  Created by Robert Palmer on 06.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "StatusViewControllerTest.h"

#import "StatusViewController.h"
#import "HocItemData.h"


@implementation StatusViewControllerTest

- (void) testItShouldMonitorAnItem {
	StatusViewController *controller = [[StatusViewController alloc] initWithNibName:@"StatusViewController" 
																			  bundle:[NSBundle bundleForClass:[StatusViewController class]]];
	HocItemData *data = [[HocItemData alloc] init];
	
	controller.hocItemData = data;
	data.status = @"test";
	
	STAssertEqualObjects([controller valueForKey:@"statusLabel"], @"test", @"should be updated to new message");
	
	// [controller release];
	// [data release];
}

@end
