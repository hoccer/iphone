//
//  GroupStatusViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 19.04.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatusViewController.h"


@interface GroupStatusViewController : StatusViewController <UITableViewDataSource, UITableViewDelegate> {
    
    NSArray *group;
    UITableView *tableView;
}


@property (retain, nonatomic) NSArray *group;
@property (nonatomic, retain) IBOutlet UITableView *tableView;


- (void)setGroup: (NSArray *)group;

@end
