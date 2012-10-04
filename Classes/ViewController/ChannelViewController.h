//
//  ChannelViewController.h
//  Hoccer
//
//  Created by Ralph At Hoccer on 04.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>
{
	NSMutableArray *sections;
	UINavigationController *parentNavigationController;
	
@private
	UITableView *tableView;
	UITextField *activeField;
}

@property (retain) UINavigationController *parentNavigationController;
@property (retain) IBOutlet UITableView *tableView;

@end