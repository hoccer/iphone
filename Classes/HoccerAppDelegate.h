//
//  HoccerAppDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright Hoccer GmbH 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class HoccerViewController;
@class GesturesInterpreter;
@class StatusViewController;

#import "GesturesInterpreterDelegate.h"
#import "HoccerContent.h"
#import "StartAnimationiPhoneViewController.h"

@interface HoccerAppDelegate : NSObject <GesturesInterpreterDelegate> {
    UIWindow *window;
    HoccerViewController *viewController;
	StartAnimationiPhoneViewController *startAnimation;
	BOOL networkReachable;
    
    UIBackgroundTaskIdentifier bgTask;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *viewController;
@property (nonatomic, assign) BOOL networkReachable;
@property (nonatomic, assign) BOOL channelMode;

@end