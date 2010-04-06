//
//  HoccingRulesIPhone.h
//  Hoccer
//
//  Created by Robert Palmer on 06.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HoccerViewController;

@interface HoccingRulesIPhone : NSObject {

}

- (BOOL)hoccerViewControllerMayThrow: (HoccerViewController *)controller;
- (BOOL)hoccerViewControllerMayCatch: (HoccerViewController *)controller;
- (BOOL)hoccerViewControllerMaySweepIn: (HoccerViewController *)controller;
- (BOOL)hoccerViewControllerMaySweepOut: (HoccerViewController *)controller;
- (BOOL)hoccerViewControllerMayAddAnotherView: (HoccerViewController *)controller;

@end
