//
//  WifiScanner.m
//  Hoccer
//
//  Created by Robert Palmer on 27.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WifiScanner.h"
#import <dlfcn.h>

@implementation WifiScanner

- (id) init
{
	self = [super init];
	if (self != nil) {
		void* libHandle = dlopen("/System/Library/SystemConfiguration/WiFiManager.bundle/WiFiManager", RTLD_LAZY);

		open = dlsym(libHandle, "Apple80211Open");
		bind = dlsym(libHandle, "Apple80211BindToInterface");
		close = dlsym(libHandle, "Apple80211Close");
		scan  = dlsym(libHandle, "Apple80211Scan");
		
		open(&wifiHandle);
		bind(wifiHandle, @"en0");
		
		repeat = YES;
		[self scanNetwork];
	}
	
	return self;
}

- (void)scanNetwork {
	NSDictionary *parameters = [[NSDictionary alloc] init];
	NSArray *scan_networks;
	scan(wifiHandle, &scan_networks, parameters);
	[parameters release];

	NSLog(@"scan_networks %@", scan_networks);

	if (repeat) {
		[NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(scanNetwork) userInfo:nil repeats:NO];
	}
}

- (NSArray *)bssids 
{
	NSMutableArray *bssids = [[NSMutableArray alloc] init];
	for (NSDictionary *wifiSpot in scanNetworks) {
		[bssids addObject: [wifiSpot valueForKey:@"bssid"]];
	}
	
	return [bssids autorelease];
}





@end
