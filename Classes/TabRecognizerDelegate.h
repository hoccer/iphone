//
//  TabRecognizerDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 28.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TabRecognizer;


@protocol TabRecognizerDelegate <NSObject>

- (void)tabRecognizer: (TabRecognizer*) recognizer didDetectTabs: (NSInteger)numberOfTabs;

@end
