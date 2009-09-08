//
//  BaseHoccerRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 08.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseHoccerRequest : NSObject {
	id delegate;

	NSMutableData *receivedData;

	NSHTTPURLResponse *response; 
	id result;
}

@property (assign, nonatomic) id delegate;
@property (retain) NSHTTPURLResponse *response;
@property (retain) id result;

- (id) createJSONFromResult: (NSData *) resultData;


@end
