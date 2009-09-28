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

@class PeerGroupRequest;
@class PeerGroupPollingRequest;
@class DownloadRequest;
@class GesturesInterpreter;

@class HoccerBaseRequest;

@interface HoccerViewController : UIViewController <MKReverseGeocoderDelegate, GesturesInterpreterDelegate> {
	IBOutlet UILabel *statusLabel;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *saveButton;
	IBOutlet UILabel *locationLabel;
	
	CLLocationManager *locationManager;
	GesturesInterpreter *gesturesInterpreter;

	HoccerBaseRequest *request;
	
	id <HoccerContent> hoccerContent;
	
}

- (IBAction)onCancel: (id)sender; 
- (IBAction)onCatch: (id)sender;
- (void)onThrow: (id)sender;
- (IBAction)save: (id)sender;

@end

