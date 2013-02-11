//
//  HoccerViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright Hoccer GmbH 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "HoccerContent.h"
#import "GesturesInterpreterDelegate.h"
#import "ItemViewControllerDelegate.h"
#import "DesktopViewDelegate.h"
#import "PullDownViewDelegate.h"
#import "TransferController.h"
#import "MBProgressHUD.h"

#import "HttpClient.h"
#import "Hoccer.h"

#import "ConnectionStatusViewController.h"
#import "ContentSelectController.h"
#import "ErrorViewController.h"
#import "TextPreview.h"
#import "ChannelViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

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
@class HoccingRules;
@class HoccerHistoryController;
@class HCHistoryTVC;
@class SettingViewController;
@class GroupStatusViewController;

@class HCLinccer;

@interface HoccerViewController : UIViewController <UIApplicationDelegate, MFMessageComposeViewControllerDelegate, 
						GesturesInterpreterDelegate, DesktopViewDelegate, PullDownViewDelegate, ItemViewControllerDelegate,
						HCLinccerDelegate, TransferControllerDelegate, ChannelViewControllerDelegate,  ConnectionStatusViewControllerDelegate, ContentSelectViewControllerDelegate,UIActionSheetDelegate, MPMediaPickerControllerDelegate, UIDocumentInteractionControllerDelegate, MBProgressHUDDelegate, ABPeoplePickerNavigationControllerDelegate>
{

	IBOutlet DesktopView *desktopView;
	IBOutlet HoccerAppDelegate* delegate;
		
	SettingViewController *helpViewController;
	//ChannelViewController *channelViewController;
	HistoryData *historyData;

	DesktopDataSource *desktopData;
	GesturesInterpreter *gestureInterpreter;
	
	ConnectionStatusViewController *statusViewController;
	GroupStatusViewController *infoViewController;
    ErrorViewController *errorViewController;

	HttpClient *httpClient;
    
	HoccingRules *hoccingRules;
							
	CGPoint defaultOrigin;

	UILabel *hoccabilityLabel;
	NSDictionary *hoccabilityInfo;
    
    UIPopoverController *musicPopOverController;
		
	HCLinccer *linccer;
	TransferController *transferController;
	BOOL connectionEstablished, fileUploaded, shaked, cipherNeeded, clientSelected, encryptionEnabled;
    
	MBProgressHUD *hud;
    MBProgressHUD *infoHud;
    int hoccerStatus;
	int failcounter;
    
	UIView *errorView;
    ItemViewController *sendingItem;
    HoccerContent *currentContent;
    
    BOOL closeAutoReceive;
    
    UITabBar *tabBar;
    IBOutlet UINavigationController *navigationController;

}

@property (nonatomic, assign) HoccerAppDelegate* delegate;
@property (nonatomic, retain) NSDictionary *hoccabilityInfo;

@property (nonatomic, retain) SettingViewController *helpViewController;
@property (nonatomic, retain) ChannelViewController *channelViewController;
@property (nonatomic, retain) IBOutlet GroupStatusViewController *infoViewController;
@property (nonatomic, retain) IBOutlet GesturesInterpreter *gestureInterpreter;
@property (nonatomic, retain) IBOutlet ConnectionStatusViewController *statusViewController;
@property (nonatomic, retain) IBOutlet ErrorViewController *errorViewController;

@property (nonatomic, assign) IBOutlet UILabel *hoccabilityLabel;

@property (nonatomic, retain) DesktopDataSource *desktopData;
@property (assign) CGPoint defaultOrigin;
@property (readonly) HCLinccer *linccer;
@property (nonatomic, assign) BOOL autoReceiveMode;
@property (nonatomic, retain) IBOutlet UITabBar *tabBar;

- (void)setContentPreview: (HoccerContent *)content;

- (IBAction)toggleSelectContent: (id)sender;
- (IBAction)toggleHelp: (id)sender;
- (IBAction)toggleHistory: (id)sender;
- (IBAction)toggleChannel: (id)sender;

- (IBAction)selectContacts: (id)sender;
- (IBAction)selectImage: (id)sender;
- (IBAction)selectText: (id)sender;
- (IBAction)selectPasteboard: (id)sender;
- (IBAction)selectMedia: (id)sender;
- (IBAction)selectCamera: (id)sender;
- (IBAction)selectMusic: (id)sender;
- (IBAction)selectMyContact: (id)sender;
- (IBAction)selectContact: (id)sender;
- (IBAction)showHistory: (id)sender;

- (IBAction)selectAutoReceive:(id)sender;

- (void)showDesktop;
- (void)willStartDownload:(ItemViewController *)item;

- (NSDictionary *)dictionaryToSend: (ItemViewController *)item;
- (void)showSuccess: (ItemViewController *)item;

- (void)showHud;
- (void)showHudWithMessage: (NSString *)message;
- (void)hideHUD;

- (void)showInfoHudForMode: (NSString *)mode;

- (void)showNetworkError: (NSError *)error;
- (void)ensureViewIsHoccable;

- (void)showTabBar:(BOOL) visible;

- (void)handleError: (NSError *)error;

- (void)presentContentSelectViewController: (id <ContentSelectController>)controller;
- (void)dismissContentSelectViewController;
- (void)showMediaPicker;
- (void) sizeLabel: (UILabel *) label toRect: (CGRect) labelRect;

- (void)retryLastAction;

- (void)switchAutoReceiveMode:(BOOL)on;
- (void)toggleAutoReceiveMode;
- (void)showChannelContactPicker;

- (void)cancelPopOver;

@end

