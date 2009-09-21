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

@class PeerGroupRequest;
@class PeerGroupPollingRequest;
@class DownloadRequest;

@class HoccerBaseRequest;

@interface HoccerViewController : UIViewController <MKReverseGeocoderDelegate> {
	IBOutlet UILabel *statusLabel;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *saveButton;
	IBOutlet UILabel *locationLabel;
	
	CLLocationManager *locationManager;

	HoccerBaseRequest *request;
	
	id <HoccerContent> hoccerContent;
	
}

- (IBAction)onCancel: (id)sender; 
- (IBAction)onCatch: (id)sender;
- (void)onThrow: (id)sender;
- (IBAction)save: (id)sender;

@end

