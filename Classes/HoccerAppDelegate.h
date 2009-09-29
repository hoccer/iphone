//
//  HoccerAppDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class HoccerViewController;
@class GesturesInterpreter;
@class BaseHoccerRequest;

#import "GesturesInterpreterDelegate.h"
#import "HoccerContent.h"

@interface HoccerAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, 
											UIImagePickerControllerDelegate, GesturesInterpreterDelegate, MKReverseGeocoderDelegate> {
    UIWindow *window;
    UITabBarController *viewController;
	IBOutlet HoccerViewController *hoccerViewController;
												
	NSData *dataToSend;				
											
	CLLocationManager *locationManager;
	GesturesInterpreter *gesturesInterpreter;
	BaseHoccerRequest *request;

	id <HoccerContent> hoccerContent;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *viewController;

@property (nonatomic, retain) NSData *dataToSend;

- (CLLocation *) currentLocation;

- (IBAction)userDidCancelRequest;


@end

