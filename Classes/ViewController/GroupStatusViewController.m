//
//  GroupStatusViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 19.04.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "GroupStatusViewController.h"


@implementation GroupStatusViewController
@synthesize group;
@synthesize tableView;

- (void)calculateHightForText: (NSString *)text {
    CGRect frame = self.view.frame;
	frame.size.height = [self.group count] * self.tableView.rowHeight;
    self.view.frame = frame;
}

- (void)setGroup: (NSArray *)newGroup {
    if (group != newGroup) {
        [group release];
        group = [newGroup retain];
        [self.tableView reloadData];
        
        [self calculateHightForText:@"bla"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.group count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSLog(@"group %@", group);
    NSDictionary *client = [group objectAtIndex:indexPath.row];
    
    if ([client objectForKey:@"name"] != [NSNull null]) {
        cell.textLabel.text = [client objectForKey:@"name"];
    } else {
        cell.textLabel.text = @"<unknown>";
    }
    
    return cell;
}

- (void)dealloc {
    [group release];
    [tableView release];

    [super dealloc];
}



- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
