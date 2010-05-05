//
//  SettingViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 03.05.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingViewController : UIViewController {
	NSMutableArray *sections;
	
	UINavigationController *parentNavigationController;
	
	@private
	UITableView *tableView;
}

@property (retain) UINavigationController *parentNavigationController;
@property (retain) IBOutlet UITableView *tableView;

@end
