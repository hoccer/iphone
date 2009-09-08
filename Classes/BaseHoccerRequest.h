//
//  BaseHoccerRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 08.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BaseHoccerRequest : NSObject {
	NSMutableData *receivedData;

	NSHTTPURLResponse *response; 
	id result;
}

@property (retain) NSHTTPURLResponse *response;
@property (retain) id result;

@end
