//
//  HoccingRules.h
//  Hoccer
//
//  Created by Robert Palmer on 08.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HoccerViewController;

@protocol HoccingRules <NSObject>

- (BOOL)hoccerViewControllerMayThrow: (HoccerViewController *)controller;
- (BOOL)hoccerViewControllerMayCatch: (HoccerViewController *)controller;
- (BOOL)hoccerViewControllerMaySweepIn: (HoccerViewController *)controller;
- (BOOL)hoccerViewControllerMaySweepOut: (HoccerViewController *)controller;
- (BOOL)hoccerViewControllerMayAddAnotherView: (HoccerViewController *)controller;

@end