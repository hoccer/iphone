//
//  HoccerClient.h
//  Hoccer
//
//  Created by Robert Palmer on 20.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerClientDelegate.h"

@interface HoccerClient : NSObject {
	NSString *userAgent;
	
	id <HoccerClientDelegate> delegate;
}

@property (copy) NSString *userAgent;
@property (nonatomic, assign) id <HoccerClientDelegate> delegate;

@end
