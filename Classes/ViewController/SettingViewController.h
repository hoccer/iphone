//
//  SettingViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 03.05.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"


@interface SettingViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate> {
	NSMutableArray *sections;
	
	UINavigationController *parentNavigationController;
	
	@private
	UITableView *tableView;
	UIView * hoccerSettingsLogo;
	
	UITextField *activeField;
	BOOL encrypting;
}

@property (retain) UINavigationController *parentNavigationController;
@property (retain) IBOutlet UITableView *tableView;
@property (retain) IBOutlet UIView *hoccerSettingsLogo;

@end
