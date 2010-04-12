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
@class LocationController;
@class HocItemData;
@class HoccingRulesIPhone;
@class HoccerHistoryController;

@interface HoccerViewController : UIViewController <UIApplicationDelegate, UIImagePickerControllerDelegate, 
						UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate,
						GesturesInterpreterDelegate, DesktopViewDelegate, HocItemDataDelegate> {

	IBOutlet DesktopView *desktopView;
	IBOutlet HoccerAppDelegate* delegate;
		
	HelpScrollView *helpViewController;
	HoccerHistoryController *hoccerHistoryController;

	DesktopDataSource *desktopData;
	GesturesInterpreter *gestureInterpreter;
	LocationController *locationController;
							
	StatusViewController *statusViewController;
	HoccingRulesIPhone *hoccingRules;
							
	CGPoint defaultOrigin;
}

@property (nonatomic, assign) HoccerAppDelegate* delegate;

@property (nonatomic, retain) HelpScrollView *helpViewController;
@property (nonatomic, retain) HoccerHistoryController *hoccerHistoryController;
@property (nonatomic, retain) IBOutlet LocationController *locationController;
@property (nonatomic, retain) IBOutlet GesturesInterpreter *gestureInterpreter;
@property (nonatomic, retain) IBOutlet StatusViewController *statusViewController;

@property (nonatomic, retain) DesktopDataSource *desktopData;
@property (assign) CGPoint defaultOrigin;

- (void)setContentPreview: (HoccerContent *)content;

- (IBAction)toggleSelectContent: (id)sender;
- (IBAction)toggleHelp: (id)sender;
- (IBAction)toggleHistory: (id)sender;

- (IBAction)selectContacts: (id)sender;
- (IBAction)selectImage: (id)sender;
- (IBAction)selectText: (id)sender;
- (IBAction)showHistory: (id)sender;

- (void)showDesktop;

@end

