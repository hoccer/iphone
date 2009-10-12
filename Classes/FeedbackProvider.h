//
//  FeedbackProvider.h
//  Hoccer
//
//  Created by Robert Palmer on 12.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface FeedbackProvider : NSObject {

}

+ (void)playCatchFeedback;
+ (void)playThrowFeedback;
+ (void)playTapFeedback;


@end
