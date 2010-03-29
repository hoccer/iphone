//
//  HoccerData.h
//  Hoccer
//
//  Created by Robert Palmer on 24.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerContent.h"


@interface HoccerData : NSObject{
	NSString *filepath;	
	NSData *data;
}

- (id) initWithData: (NSData *)theData filename: (NSString *)filename;

@end
