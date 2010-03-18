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

#import "HoccerContent.h"
#import "GesturesInterpreterDelegate.h"


@class HoccerAppDelegate;
@class Preview;
@class PreviewViewController;
@class ReceiveViewController;
@class SelectContentViewController;
@class StatusViewController;


@interface HoccerViewController : UIViewController {
		
	
	IBOutlet UIView *feedbackView;
	IBOutlet UIView *backgroundView;
	
	IBOutlet UIView *shareView;
	IBOutlet UIView *receiveView;

	IBOutlet HoccerAppDelegate* delegate;
		
	PreviewViewController *previewViewController;
	ReceiveViewController *receiveViewController;

	SelectContentViewController *selectContentViewController;
	BOOL isPopUpDisplayed;
	
	StatusViewController *statusViewController;
}

@property (nonatomic, assign) HoccerAppDelegate* delegate;
@property (nonatomic, retain) IBOutlet StatusViewController* statusViewController;

- (IBAction)onCancel: (id)sender; 
- (IBAction)didSelectHelp: (id)sender;

- (void)showError: (NSString *)message;

- (void)setContentPreview: (id <HoccerContent>)content;
- (void)startPreviewFlyOutAniamation;
- (void)resetPreview;

- (IBAction)didDissmissContentToThrow: (id)sender;
- (IBAction)showAbout: (id)sender;

- (IBAction)toggleSelectContacts: (id)sender;
- (void)showSelectContentView;
- (void)hideSelectContentViewAnimated: (BOOL) animated;
- (void)removeSelectContentViewFromSuperview;

- (IBAction)selectContacts: (id)sender;
- (IBAction)selectImage: (id)sender;
- (IBAction)selectText: (id)sender;

@end

