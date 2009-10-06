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

@interface HoccerViewController : UIViewController {
	IBOutlet UILabel *statusLabel;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *saveButton;
	IBOutlet UILabel *locationLabel;
	
	IBOutlet UIView *previewBox;
	
	id delegate;
}

@property (assign) id delegate;

- (IBAction)onCancel: (id)sender; 
- (IBAction)onCatch: (id)sender;
- (IBAction)parse: (id)sender;

- (void)setLocation: (MKPlacemark *)placemark withAccuracy: (float) accuracy;
- (void)setUpdate: (NSString *)update;

- (void)setLocation: (MKPlacemark *)placemark withAccuracy: (float) accuracy;
- (void)setUpdate: (NSString *)update;

- (void)setContentPreview: (id <HoccerContent>)content;

@end

