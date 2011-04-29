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
@synthesize delegate;

- (void)viewDidLoad {
    selectedClients = [[NSMutableArray alloc] init];
}


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
        
        BOOL selectionChanged = NO;
        for (NSInteger i = [selectedClients count] - 1; i >= 0 ; i--) {
            NSDictionary *client = [selectedClients objectAtIndex:i];
            if (![group containsObject:client]) {
                [selectedClients removeObject:client];
                selectionChanged = YES;
            }
        }
        
        if (selectionChanged) {
            if ([self.delegate respondsToSelector:@selector(groupStatusViewController:didUpdateSelection:)]) {
                [self.delegate groupStatusViewController:self didUpdateSelection: selectedClients];
            }
        }
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
    
    NSDictionary *client = [group objectAtIndex:indexPath.row];
    if ([client objectForKey:@"name"] != [NSNull null]) {
        cell.textLabel.text = [client objectForKey:@"name"];
    } else {
        NSString *uuid = [client objectForKey:@"id"];
        NSString *tmpName = [NSString stringWithFormat:@"unknown %@", [uuid substringToIndex:8]];
        cell.textLabel.text = tmpName;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([selectedClients containsObject:client]) {
        cell.accessoryType =UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType =UITableViewCellAccessoryNone;        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *client = [group objectAtIndex:indexPath.row];
    if ([selectedClients containsObject:client]) {
        [selectedClients removeObject:client];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [selectedClients addObject:client];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(groupStatusViewController:didUpdateSelection:)]) {
        [self.delegate groupStatusViewController:self didUpdateSelection: selectedClients];
    }
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [group release];
    [tableView release];
    [selectedClients release];

    [super dealloc];
}

@end
