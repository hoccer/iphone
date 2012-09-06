//
//  UIAccelerometer+TestPlayback.h
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIAccelerometer (TestPlayback)

- (void)playFile: (NSString *)file;
- (NSArray *)splitLine: (NSString *)line;

@end
