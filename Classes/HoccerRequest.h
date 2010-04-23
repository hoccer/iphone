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


+ (HocLocation *)sweepOutWithContent: (HoccerContent *)content location: (HocLocation *)location;
+ (HocLocation *)sweepInWithLocation: (HocLocation *)location;

+ (HocLocation *)throwWithContent: (HoccerContent *)content location: (HocLocation *)location;
+ (HocLocation *)catchWithLocation: (HocLocation *)location;

@end
