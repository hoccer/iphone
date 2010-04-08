//
//  SweepOutRecognizerDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 08.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SweepOutRecognizer;


@protocol SweepOutRecognizerDelegate <NSObject>

- (void)sweepOutRecognizerDidRecognizeSweepOut: (SweepOutRecognizer *)recognizer;

@end
