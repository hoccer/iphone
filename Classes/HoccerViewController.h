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
@class DragUpMenuViewController;
@class HiddenViewScrollViewDelegate;

@interface HoccerViewController : UIViewController {
		
	IBOutlet UILabel *statusLabel;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *cancelButton;
	IBOutlet UILabel *locationLabel;
	
	IBOutlet UIView *infoView;
	IBOutlet UINavigationItem *modeLabel;
	IBOutlet UIProgressView *progressView;	
	IBOutlet UIActivityIndicatorView *activitySpinner;
	
	IBOutlet UIView *successView;
	IBOutlet UIImageView *descriptionImage;
		
	IBOutlet UIScrollView *mainScrollView;
	IBOutlet UIView *downIndicator;
	IBOutlet UIView *backgroundView;
	
		
	IBOutlet HoccerAppDelegate* delegate;
	
	PreviewView *currentPreview;
	CGRect originalFrame;
	
	DragUpMenuViewController *selectionViewController;
	HiddenViewScrollViewDelegate *hiddenViewDelegate;
}

@property (assign) HoccerAppDelegate* delegate;

- (IBAction)onCancel: (id)sender; 
- (IBAction)didSelectHelp: (id)sender;

- (void)setLocation: (MKPlacemark *)placemark withAccuracy: (float) accuracy;
- (void)setProgressUpdate: (CGFloat) percentage;
- (void)setUpdate: (NSString *)update;

- (void)showError: (NSString *)message;
- (void)showSuccessMode;

- (void)setContentPreview: (id <HoccerContent>)content;
- (void)startPreviewFlyOutAniamation;
- (void)resetPreview;

- (IBAction)didDissmissContentToThrow: (id)sender;
- (IBAction)showAbout: (id)sender;

- (void)showConnectionActivity;
- (void)hideConnectionActivity;

@end

