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
#import "LocationControllerDelegate.h"

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
@class HistoryData;
@class HoccingRulesIPhone;
@class HoccerHistoryController;

@interface HoccerViewController : UIViewController <UIApplicationDelegate, UIImagePickerControllerDelegate, 
						UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate,
						GesturesInterpreterDelegate, DesktopViewDelegate, HocItemDataDelegate, LocationControllerDelegate> {

	IBOutlet DesktopView *desktopView;
	IBOutlet HoccerAppDelegate* delegate;
		
	HelpScrollView *helpViewController;
	HistoryData *historyData;

	DesktopDataSource *desktopData;
	GesturesInterpreter *gestureInterpreter;
	LocationController *locationController;
							
	StatusViewController *statusViewController;
	HoccingRulesIPhone *hoccingRules;
							
	CGPoint defaultOrigin;

	UILabel *hoccability;
							
	BOOL blocked;
}

@property (nonatomic, assign) HoccerAppDelegate* delegate;

@property (nonatomic, retain) HelpScrollView *helpViewController;
@property (nonatomic, retain) IBOutlet LocationController *locationController;
@property (nonatomic, retain) IBOutlet GesturesInterpreter *gestureInterpreter;
@property (nonatomic, retain) IBOutlet StatusViewController *statusViewController;
@property (nonatomic, assign) IBOutlet UILabel *hoccability;

@property (nonatomic, retain) DesktopDataSource *desktopData;
@property (assign) CGPoint defaultOrigin;
@property (assign) BOOL blocked;

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

