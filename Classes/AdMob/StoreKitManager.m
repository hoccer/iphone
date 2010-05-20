//
//  StoreKitManager.m
//  Hoccer
//
//  Created by Robert Palmer on 20.05.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "StoreKitManager.h"


@implementation StoreKitManager

+ (BOOL)isPropagandaEnabled {
	return ![[NSUserDefaults standardUserDefaults] boolForKey:@"AdFree"];	
}

+ (NSInteger)bannerCount {
	if ([self isPropagandaEnabled]) {
		return 1;
	} else {
		return 0;
	}
}
@end
