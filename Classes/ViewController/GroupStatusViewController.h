//
//  GroupStatusViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 19.04.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatusViewController.h"
@class GroupStatusViewController;

@protocol GroupStatusViewControllerDelegate <NSObject>
@optional
- (void)groupStatusViewController: (GroupStatusViewController *)controller didUpdateSelection: (NSArray *)clients;
@end

@interface GroupStatusViewController : StatusViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray *group;
    UITableView *tableView;
    
    NSMutableArray *selectedClients;
}


@property (retain, nonatomic) NSArray *group;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (retain) id <GroupStatusViewControllerDelegate> delegate;

- (void)setGroup: (NSArray *)group;

@end
