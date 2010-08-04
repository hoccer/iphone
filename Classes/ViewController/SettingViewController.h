//
//  SettingViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 03.05.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

#import "MBProgressHUD.h"


@interface SettingViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
	NSMutableArray *sections;
	
	UINavigationController *parentNavigationController;
	
	@private
	UITableView *tableView;
	UIView * hoccerSettingsLogo;
	
	MBProgressHUD *progressHUD;
}

@property (retain) UINavigationController *parentNavigationController;
@property (retain) IBOutlet UITableView *tableView;
@property (retain) IBOutlet UIView *hoccerSettingsLogo;

@end
