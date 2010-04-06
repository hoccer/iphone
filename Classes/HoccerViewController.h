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
#import "HocItemDataDelegate.h"
#import "DesktopViewDelegate.h"


@class HoccerAppDelegate;
@class Preview;
@class DesktopView;
@class SelectContentViewController;
@class StatusViewController;
@class HelpScrollView;
@class ReceivedContentViewController;
@class ContentContainerView;

@class DesktopDataSource;
@class ActionElement;
@class LocationController;
@class HocItemData;
@class HoccingRulesIPhone;

@interface HoccerViewController : UIViewController <UIApplicationDelegate, UIImagePickerControllerDelegate, 
						UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate, 
						GesturesInterpreterDelegate, DesktopViewDelegate, HocItemDataDelegate> {

	IBOutlet DesktopView *desktopView;
	IBOutlet HoccerAppDelegate* delegate;
		
	ReceivedContentViewController *receivedContentViewController;
						
	HelpScrollView *helpViewController;
							
	UIViewController *auxiliaryView;
	BOOL isPopUpDisplayed;
	BOOL allowSweepGesture;
							
	ActionElement *delayedAction;
							
	DesktopDataSource *desktopData;
	GesturesInterpreter *gestureInterpreter;
	LocationController *locationController;
							
	StatusViewController *statusViewController;
							
	HoccingRulesIPhone *hoccingRules;
}

@property (nonatomic, assign) HoccerAppDelegate* delegate;
@property (nonatomic, retain) UIViewController *auxiliaryView;
@property (nonatomic, assign) BOOL allowSweepGesture;

@property (nonatomic, retain) HelpScrollView *helpViewController;
@property (nonatomic, retain) IBOutlet LocationController *locationController;
@property (nonatomic, retain) IBOutlet GesturesInterpreter *gestureInterpreter;
@property (nonatomic, retain) IBOutlet StatusViewController *statusViewController;

@property (nonatomic, retain) DesktopDataSource *desktopData;

- (void)showError: (NSString *)message;

- (void)resetPreview;
- (void)setContentPreview: (HoccerContent *)content;
- (void)presentReceivedContent:(HoccerContent *) hoccerContent;

- (IBAction)toggleSelectContent: (id)sender;
- (IBAction)toggleHelp: (id)sender;

- (IBAction)selectContacts: (id)sender;
- (IBAction)selectImage: (id)sender;
- (IBAction)selectText: (id)sender;

@end

