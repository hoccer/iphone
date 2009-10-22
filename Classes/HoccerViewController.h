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
@class PreviewView;

@interface HoccerViewController : UIViewController <UIActionSheetDelegate> {
		
	IBOutlet UILabel *statusLabel;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *saveButton;
	IBOutlet UILabel *locationLabel;
	
	IBOutlet UIView *infoView;
	IBOutlet UIProgressView *progressView;	
	IBOutlet UIActivityIndicatorView *activitySpinner;
		
	IBOutlet HoccerAppDelegate* delegate;
	
	PreviewView *currentPreview;
	CGRect originalFrame;
}

@property (assign) HoccerAppDelegate* delegate;

- (IBAction)showActions: (id)sender;
- (IBAction)onCancel: (id)sender; 

- (void)setLocation: (MKPlacemark *)placemark withAccuracy: (float) accuracy;
- (void)setProgressUpdate: (CGFloat) percentage;
- (void)setUpdate: (NSString *)update;

- (void)showError: (NSString *)message;

- (void)setContentPreview: (id <HoccerContent>)content;
- (void)startPreviewFlyOutAniamation;
- (void)resetPreview;

- (IBAction)didDissmissContentToThrow: (id)sender;

- (void)showConnectionActivity;
- (void)hideConnectionActivity;

@end

