//
//  WifiScanner.h
//  Hoccer
//
//  Created by Robert Palmer on 27.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WifiScanner : NSObject {
	void* wifiHandle;
	
	int (*open)(void *);
	int (*bind)(void *, NSString*);
	int (*close)(void *);
	int (*scan)(void *, NSArray **, void*);
	
	NSArray *scannedNetworks;
	BOOL repeat;
	
	id delegate;
}

@property (readonly) NSArray *bssids;
@property (nonatomic, retain) NSArray *scannedNetworks;

+ (WifiScanner *)sharedScanner;
- (void)scanNetwork;

@end
