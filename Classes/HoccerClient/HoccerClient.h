//
//  HoccerClient.h
//  Hoccer
//
//  Created by Robert Palmer on 20.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerConnectionDelegate.h"

#define kHoccerMessageNoCatcher 2
#define kHoccerMessageNoThrower 3
#define kHoccerMessageNoSecondSweeper 4
#define kHoccerMessageCollision 5

@class BaseHoccerRequest;
@class HocLocation;
@class HoccerContent;
@class HoccerRequest;

@interface HoccerClient : NSObject {
	NSString *userAgent;
	HoccerContent *content;
	
	NSObject <HoccerConnectionDelegate> *delegate;
	
	NSString *gesture;
}

@property (copy) NSString *userAgent;
@property (retain) HoccerContent *content;

@property (nonatomic, assign) NSObject <HoccerConnectionDelegate> *delegate;

- (HoccerConnection *)connectionWithRequest: (HoccerRequest *)request;
- (HoccerConnection *)unstartedConnectionWithRequest:(HoccerRequest *)request;

@end
