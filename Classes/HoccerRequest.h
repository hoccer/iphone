//
//  HoccerRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HoccerRequest : NSObject {
	NSTimeInterval requestStamp;
}

@property (assign) NSTimeInterval requestStamp;

- (void)cancel;

@end