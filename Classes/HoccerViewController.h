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

@interface HoccerViewController : UIViewController <UIActionSheetDelegate> {
		
	IBOutlet UILabel *statusLabel;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *saveButton;
	IBOutlet UILabel *locationLabel;
	
	IBOutlet UIActivityIndicatorView *activitySpinner;
	
	IBOutlet UIView *previewBox;
	
	IBOutlet HoccerAppDelegate* delegate;
}

@property (assign) HoccerAppDelegate* delegate;

- (IBAction)showActions: (id)sender;
- (IBAction)onCancel: (id)sender; 

- (void)setLocation: (MKPlacemark *)placemark withAccuracy: (float) accuracy;
- (void)setUpdate: (NSString *)update;

- (void)showError: (NSString *)message;

- (void)setContentPreview: (id <HoccerContent>)content;

- (IBAction)didDissmissContentToThrow: (id)sender;

- (void)showConnectionActivity;
- (void)hideConnectionActivity;

@end

