//
//  HoccerAppDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class HoccerViewController;
@class GesturesInterpreter;
@class BaseHoccerRequest;
@class StatusViewController;
@class LocationController;

#import "GesturesInterpreterDelegate.h"
#import "HoccerContent.h"

@interface HoccerAppDelegate : NSObject <GesturesInterpreterDelegate> {
    UIWindow *window;
    HoccerViewController *viewController;
	
	StatusViewController *statusViewController;
	
	BaseHoccerRequest *request;
	GesturesInterpreter *gestureInterpreter;
	LocationController *locationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *viewController;
@property (nonatomic, retain) IBOutlet StatusViewController *statusViewController;
@property (nonatomic, retain) IBOutlet LocationController *locationController;
@property (nonatomic, retain) IBOutlet GesturesInterpreter *gestureInterpreter;

@end