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
#import <AddressBookUI/AddressBookUI.h>

@class HoccerViewController;
@class GesturesInterpreter;
@class BaseHoccerRequest;
@class ReceivedContentView;

@class WifiScanner;

#import "GesturesInterpreterDelegate.h"
#import "HoccerContent.h"

@interface HoccerAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, 
											UIImagePickerControllerDelegate, GesturesInterpreterDelegate, 
											MKReverseGeocoderDelegate, ABPeoplePickerNavigationControllerDelegate,
											CLLocationManagerDelegate, UINavigationControllerDelegate> 
{
    UIWindow *window;
    HoccerViewController *viewController;
	ReceivedContentView *receivedContentView;
																							
	CLLocationManager *locationManager;
	BaseHoccerRequest *request;

	id <HoccerContent> hoccerContent;
	id <HoccerContent> contentToSend;					
	
	NSDate *lastLocationUpdate;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *viewController;

@property (nonatomic, retain) id <HoccerContent> hoccerContent;
@property (nonatomic, retain) id <HoccerContent> contentToSend;

- (CLLocation *) currentLocation;

- (void)userDidCancelRequest;
- (void)userDidDismissContent;
- (void)userDidSaveContent;

- (void)didDissmissContentToThrow;

- (void)hideReceivedContentView;

@end

