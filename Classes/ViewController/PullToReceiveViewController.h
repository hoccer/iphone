//
//  PullToReceiveViewController.h
//  Hoccer
//
//  Created by Ralph At Hoccer on 28.11.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullToReceiveViewController : UIViewController
{
    id delegate;
    
@private
	UITableView *tableView;
}

@property (retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id delegate;

@end