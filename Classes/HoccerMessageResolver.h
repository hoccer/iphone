//
//  HoccerMessageResolver.h
//  Hoccer
//
//  Created by Robert Palmer on 15.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HocLocation;

#define kHoccerMessageImpreciseLocation 1
#define kHoccerMessageNoCatcher 2
#define kHoccerMessageNoThrower 3
#define kHoccerMessageNoSecondSweeper 4

@interface HoccerMessageResolver : NSObject {

}

- (NSError *)messageForLocationInformation: (HocLocation *)hocLocation;
- (NSError *)messageForLocationInformation:(HocLocation *)hocLocation event: (NSString *)event;

@end
