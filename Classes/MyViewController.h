//
//  MyViewController.h
//  UITest
//
//  Created by david on 14.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyCLController.h"


@interface MyViewController : UIViewController <UITextFieldDelegate, MyCLControllerDelegate> {
	UITextField *textField;
	UILabel *label;
	NSString *string;
	
	IBOutlet UILabel *locationLabel;
	
	MyCLController *locationController;

}

@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, copy) NSString *string;

- (IBAction)changeGreeting:(id)sender;

- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;

@end
