//
//  HoccerRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerConnectionDelegate.h"

@class BaseHoccerRequest;

@interface HoccerConnection : NSObject {
	NSString *gesture;
	
	BaseHoccerRequest *request;
	NSObject <HoccerConnectionDelegate> *delegate;
}

@property (nonatomic, assign) NSObject <HoccerConnectionDelegate> *delegate;
@property (copy) NSString *gesture;

- (void)cancel;

@end
