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
#import "ItemViewControllerDelegate.h"
#import "DesktopViewDelegate.h"
#import "TransferController.h"
#import "MBProgressHUD.h"

#import "HttpClient.h"
#import "Hoccer.h"

#import "ConnectionStatusViewController.h"

@class HoccerAppDelegate;
@class Preview;
@class DesktopView;
@class StatusViewController;
@class HelpScrollView;
@class ReceivedContentViewController;
@class ContentContainerView;

@class DesktopDataSource;
@class ItemViewController;
@class HistoryData;
@class HoccingRulesIPhone;
@class HoccerHistoryController;
@class SettingViewController;

@class HCLinccer;

@interface HoccerViewController : UIViewController <UIApplicationDelegate, UIImagePickerControllerDelegate, 
						UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate,
			  			GesturesInterpreterDelegate, DesktopViewDelegate, ItemViewControllerDelegate, 
						HCLinccerDelegate, DownloadControllerDelegate, ConnectionStatusViewControllerDelegate> 
{

	IBOutlet DesktopView *desktopView;
	IBOutlet HoccerAppDelegate* delegate;
		
	SettingViewController *helpViewController;
	HistoryData *historyData;

	DesktopDataSource *desktopData;
	GesturesInterpreter *gestureInterpreter;
	
	ConnectionStatusViewController *statusViewController;
	StatusViewController *infoViewController;

	HttpClient *httpClient;
	HoccingRulesIPhone *hoccingRules;
							
	CGPoint defaultOrigin;

	UILabel *hoccabilityLabel;
	NSDictionary *hoccabilityInfo;
		
	HCLinccer *linccer;
	TransferController *downloadController;
	BOOL connectionEsteblished, fileUploaded;
	
	MBProgressHUD *hud;
}

@property (nonatomic, assign) HoccerAppDelegate* delegate;
@property (nonatomic, retain) NSDictionary *hoccabilityInfo;

@property (nonatomic, retain) SettingViewController *helpViewController;
@property (nonatomic, retain) IBOutlet 	StatusViewController *infoViewController;
@property (nonatomic, retain) IBOutlet GesturesInterpreter *gestureInterpreter;
@property (nonatomic, retain) IBOutlet ConnectionStatusViewController *statusViewController;
@property (nonatomic, assign) IBOutlet UILabel *hoccabilityLabel;

@property (nonatomic, retain) DesktopDataSource *desktopData;
@property (assign) CGPoint defaultOrigin;
@property (readonly) HCLinccer *linccer;

- (void)setContentPreview: (HoccerContent *)content;

- (IBAction)toggleSelectContent: (id)sender;
- (IBAction)toggleHelp: (id)sender;
- (IBAction)toggleHistory: (id)sender;

- (IBAction)selectContacts: (id)sender;
- (IBAction)selectImage: (id)sender;
- (IBAction)selectText: (id)sender;
- (IBAction)showHistory: (id)sender;

- (void)showDesktop;
- (void)willStartDownload:(ItemViewController *)item;

- (NSDictionary *)dictionaryToSend: (ItemViewController *)item;
- (void)showSuccess: (ItemViewController *)item;

- (void)showHud;
- (void)hideHUD;

@end

