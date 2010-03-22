//
//  HoccerAppDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>

@class HoccerViewController;
@class GesturesInterpreter;
@class BaseHoccerRequest;
@class ReceivedContentView;
@class StatusViewController;
@class LocationController;

#import "GesturesInterpreterDelegate.h"
#import "HoccerContent.h"

@interface HoccerAppDelegate : NSObject <UIApplicationDelegate, UIImagePickerControllerDelegate, 
										GesturesInterpreterDelegate, ABPeoplePickerNavigationControllerDelegate,
										UINavigationControllerDelegate> {
    UIWindow *window;
    HoccerViewController *viewController;
	
	ReceivedContentView *receivedContentView;
	StatusViewController *statusViewController;
	
	LocationController *locationController;
																							
	BaseHoccerRequest *request;

	id <HoccerContent> hoccerContent;
	id <HoccerContent> contentToSend;					
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *viewController;
@property (nonatomic, retain) IBOutlet StatusViewController *statusViewController;

@property (nonatomic, retain) IBOutlet LocationController *locationController;

@property (nonatomic, retain) id <HoccerContent> hoccerContent;
@property (nonatomic, retain) id <HoccerContent> contentToSend;

- (void)userDidCancelRequest;
- (void)userDidDismissContent;
- (void)userDidSaveContent;
- (void)didDissmissContentToThrow;

- (void)hideReceivedContentView;



@end

