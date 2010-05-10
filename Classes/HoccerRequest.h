//
//  HoccerRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 23.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HoccerContent;
@class HocLocation;

@interface HoccerRequest : NSObject {
	HocLocation *location;
	HoccerContent *content;
	NSString *gesture;
}

@property (retain) HocLocation *location;
@property (retain) HoccerContent *content;
@property (retain) NSString *gesture;


+ (HoccerRequest *)sweepOutWithContent: (HoccerContent *)content location: (HocLocation *)location;
+ (HoccerRequest *)sweepInWithLocation: (HocLocation *)location;

+ (HoccerRequest *)throwWithContent: (HoccerContent *)content location: (HocLocation *)location;
+ (HoccerRequest *)catchWithLocation: (HocLocation *)location;

@end
