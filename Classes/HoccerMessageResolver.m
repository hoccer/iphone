//
//  HoccerMessageResolver.m
//  Hoccer
//
//  Created by Robert Palmer on 15.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerMessageResolver.h"
#import "HocLocation.h"

#define hoccerMessageErrorDomain @"HoccerErrorDomain"

@interface HoccerMessageResolver ()
- (NSDictionary *)userInfoForNoCatcher;
- (NSDictionary *)userInfoForNoThrower;
- (NSDictionary *)userInfoForNoSecondSweeper;
@end



@implementation HoccerMessageResolver


- (NSError *)messageForLocationInformation:(HocLocation *)hocLocation event: (NSString *)event {
	if ([event isEqual:@"throw"]) {
		return [NSError errorWithDomain:hoccerMessageErrorDomain code:kHoccerMessageNoCatcher userInfo:[self userInfoForNoCatcher]];
	} else if ([event isEqual:@"catch"]) {
		return [NSError errorWithDomain:hoccerMessageErrorDomain code:kHoccerMessageNoThrower userInfo:[self userInfoForNoThrower]];
	} else {
		return [NSError errorWithDomain:hoccerMessageErrorDomain code:kHoccerMessageNoSecondSweeper userInfo:[self userInfoForNoSecondSweeper]];
	}
	
	return nil;
	
}



- (NSDictionary *)userInfoForNoCatcher {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:@"Nobody coughed your content!" forKey:NSLocalizedDescriptionKey];
	
	return [userInfo autorelease];
	
}

- (NSDictionary *)userInfoForNoThrower {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:@"Nothing way thrown to you!" forKey:NSLocalizedDescriptionKey];
	
	return [userInfo autorelease];
	
}

- (NSDictionary *)userInfoForNoSecondSweeper {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:@"The second sweeper was not found!" forKey:NSLocalizedDescriptionKey];
	
	return [userInfo autorelease];
}



@end
