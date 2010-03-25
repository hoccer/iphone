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


@class HoccerAppDelegate;
@class Preview;
@class PreviewViewController;
@class DesktopViewController;
@class SelectContentViewController;
@class StatusViewController;
@class HelpScrollView;
@class ReceivedContentViewController;


@class ActionElement;


@interface HoccerViewController : UIViewController <UIApplicationDelegate, UIImagePickerControllerDelegate, 
						UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate> {
	IBOutlet UIView *sweepInView;
	IBOutlet UIView *backgroundView;
							
	IBOutlet HoccerAppDelegate* delegate;
		
	PreviewViewController *previewViewController;
	DesktopViewController *desktopViewController;
	ReceivedContentViewController *receivedContentViewController;
						
	HelpScrollView *helpViewController;
							

	UIViewController *auxiliaryView;
	BOOL isPopUpDisplayed;
	BOOL allowSweepGesture;
							
	ActionElement *delayedAction;
}

@property (nonatomic, assign) HoccerAppDelegate* delegate;
@property (nonatomic, retain) UIViewController *auxiliaryView;
@property (nonatomic, assign) BOOL allowSweepGesture;
@property (nonatomic, assign) PreviewViewController* previewViewController;

@property (nonatomic, retain) HelpScrollView *helpViewController;


- (void)showError: (NSString *)message;

- (void)setContentPreview: (id <HoccerContent>)content;
- (void)startPreviewFlyOutAniamation;
- (void)resetPreview;
- (void)setContentPreview: (id <HoccerContent>)content;
- (void)presentReceivedContent:(id <HoccerContent>) hoccerContent;

- (IBAction)didDissmissContentToThrow: (id)sender;

- (IBAction)toggleSelectContent: (id)sender;
- (IBAction)toggleHelp: (id)sender;

- (IBAction)selectContacts: (id)sender;
- (IBAction)selectImage: (id)sender;
- (IBAction)selectText: (id)sender;




@end

