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
@class BackgroundViewController;
@class SelectContentViewController;
@class StatusViewController;


@interface HoccerViewController : UIViewController <UIApplicationDelegate, UIImagePickerControllerDelegate, 
						UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate> {
	IBOutlet UIView *sweepInView;
	
	IBOutlet UIView *receiveView;

	IBOutlet HoccerAppDelegate* delegate;
		
	PreviewViewController *previewViewController;
	BackgroundViewController *backgroundViewController;

	UIViewController *popOver;
	BOOL isPopUpDisplayed;
	BOOL allowSweepGesture;
}

@property (nonatomic, assign) HoccerAppDelegate* delegate;
@property (nonatomic, retain) UIViewController *popOver;
@property (nonatomic, assign) BOOL allowSweepGesture;

- (void)showError: (NSString *)message;

- (void)setContentPreview: (id <HoccerContent>)content;
- (void)startPreviewFlyOutAniamation;
- (void)resetPreview;

- (IBAction)didDissmissContentToThrow: (id)sender;

- (IBAction)toggleSelectContent: (id)sender;
- (IBAction)toggleHelp: (id)sender;

- (IBAction)selectContacts: (id)sender;
- (IBAction)selectImage: (id)sender;
- (IBAction)selectText: (id)sender;



@end

