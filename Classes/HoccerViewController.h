//
//  HoccerViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>

#import "HoccerContent.h"
#import "GesturesInterpreterDelegate.h"
#import "DesktopViewDelegate.h"


@class HoccerAppDelegate;
@class Preview;
@class DesktopViewController;
@class SelectContentViewController;
@class StatusViewController;
@class HelpScrollView;
@class ReceivedContentViewController;
@class ContentContainerView;

@class DesktopDataSource;
@class ActionElement;
@class LocationController;

@interface HoccerViewController : UIViewController <UIApplicationDelegate, UIImagePickerControllerDelegate, 
						UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate, 
						GesturesInterpreterDelegate, DesktopViewDelegate> {
	IBOutlet UIView *backgroundView;
							
	IBOutlet HoccerAppDelegate* delegate;
		
	DesktopViewController *desktopView;
	ReceivedContentViewController *receivedContentViewController;
						
	HelpScrollView *helpViewController;
							
	UIViewController *auxiliaryView;
	BOOL isPopUpDisplayed;
	BOOL allowSweepGesture;
							
	ActionElement *delayedAction;
							
	DesktopDataSource *desktopData;
	GesturesInterpreter *gestureInterpreter;
	LocationController *locationController;
}

@property (nonatomic, assign) HoccerAppDelegate* delegate;
@property (nonatomic, retain) UIViewController *auxiliaryView;
@property (nonatomic, assign) BOOL allowSweepGesture;

@property (nonatomic, retain) HelpScrollView *helpViewController;
@property (nonatomic, retain) IBOutlet LocationController *locationController;
@property (nonatomic, retain) IBOutlet GesturesInterpreter *gestureInterpreter;

- (void)showError: (NSString *)message;

- (void)startPreviewFlyOutAniamation;
- (void)resetPreview;
- (void)setContentPreview: (HoccerContent *)content;
- (void)presentReceivedContent:(HoccerContent *) hoccerContent;

- (IBAction)didDissmissContentToThrow: (id)sender;

- (IBAction)toggleSelectContent: (id)sender;
- (IBAction)toggleHelp: (id)sender;

- (IBAction)selectContacts: (id)sender;
- (IBAction)selectImage: (id)sender;
- (IBAction)selectText: (id)sender;

@end

