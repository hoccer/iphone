//
//  MyViewController.h
//  UITest
//
//  Created by david on 14.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyCLController.h"
#import "MyDownloadController.h"


@interface MyViewController : UIViewController <MyCLControllerDelegate, DownloadControllerDelegate> {
	IBOutlet UILabel * locationLabel;
	IBOutlet UILabel * accuracyLabel;
	IBOutlet UITextView * debugLog;
	
	MyCLController *locationController;
	MyDownloadController *downloadController;

}

@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet UILabel *accuracyLabel;

- (IBAction) testHTTPRequest:(id) sender;

// protocol MyCLControllerDelegate
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;

@end
