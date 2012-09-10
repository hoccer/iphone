//
//  GroupStatusViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 19.04.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "GroupStatusViewController.h"

#define HCGroupListHeight 367

@implementation GroupStatusViewController
@synthesize group;
@synthesize tableView;
@synthesize delegate;
@synthesize selectedClients;

- (void)viewDidLoad {
    selectedClients = [[NSMutableArray alloc] init];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bar.png"]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];


}


- (void)calculateHightForText: (NSString *)text {
    NSInteger rows = [self tableView:self.tableView numberOfRowsInSection:0];
    
    CGFloat height = 0;
    if (rows != 0) {
        height = rows * self.tableView.rowHeight + 20;        
    }

    if (height < HCGroupListHeight) {
        tableView.scrollEnabled = NO;
    } else {
        height = HCGroupListHeight;
        tableView.scrollEnabled = YES;
    }

    CGRect frame = self.view.frame;
    frame.size.height = height;
    self.view.frame = frame;
    
}

- (void)setGroup: (NSArray *)newGroup {
    if (group != newGroup) {
        [group release];
        group = [newGroup retain];
        [self.tableView reloadData];

        [self calculateHightForText: nil];
        
        BOOL selectionChanged = NO;
        
        for (NSDictionary *aClient in selectedClients) {
            if (![group containsObject:aClient]) {
                [selectedClients removeObject:aClient];
                selectionChanged = YES;
            }
        }
        
        //NSDictionary *dummyClient = [NSDictionary dictionaryWithObjectsAndKeys:@"dummy",@"name",@"dummy",@"id", nil];
        //[selectedClients addObject:dummyClient];
        //selectionChanged = YES;
         
        if (selectionChanged) {            
            if (selectedClients.count != 0){
                [[NSUserDefaults standardUserDefaults] setObject:selectedClients forKey:@"selected_clients"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else {
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"selected_clients"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            if ([self.delegate respondsToSelector:@selector(groupStatusViewController:didUpdateSelection:)]) {
                [self.delegate groupStatusViewController:self didUpdateSelection: selectedClients];
            }
            [self.tableView reloadData];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.group.count > 0)
        return [self.group count];
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (self.group.count > 0) {
        
        cell.textLabel.textColor = [UIColor colorWithWhite:0.391 alpha:1.000];
        NSDictionary *client = [group objectAtIndex:indexPath.row];
        if ([client objectForKey:@"name"] != [NSNull null] && ![[client objectForKey:@"name"] isEqualToString:@""]) {
            cell.textLabel.text = [client objectForKey:@"name"];
        } else {
            NSString *uuid = [client objectForKey:@"id"];
            NSString *tmpName = [NSString stringWithFormat:@"#%@", [uuid substringToIndex:8]];
            cell.textLabel.text = tmpName;
        }
        
        if ([client objectForKey:@"pubkey_id"] != nil){
            cell.imageView.image = [UIImage imageNamed:@"dev_enc_on.png"];
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"dev_enc_off.png"];
        }
        
        if ([selectedClients containsObject:client]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = NSLocalizedString(@"No other devices nearby", nil);
        cell.textLabel.textColor = [UIColor colorWithWhite:0.391 alpha:1.000];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"group_rowbg.png"]] autorelease];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"Restrict transfer to:", nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.group.count > 0){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSDictionary *client = [group objectAtIndex:indexPath.row];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"] == NO || [[NSUserDefaults standardUserDefaults] boolForKey:@"sendPassword"] == NO) {
            if ([selectedClients containsObject:client]) {
                [selectedClients removeObject:client];
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                [selectedClients addObject:client];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            if (selectedClients.count != 0){
                [[NSUserDefaults standardUserDefaults] setObject:selectedClients forKey:@"selected_clients"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else {
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"selected_clients"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            if ([self.delegate respondsToSelector:@selector(groupStatusViewController:didUpdateSelection:)]) {
                [self.delegate groupStatusViewController:self didUpdateSelection: selectedClients];
            }
        }
        else {
            if ([selectedClients containsObject:client]) {
                [selectedClients removeObject:client];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else {
                if([client objectForKey:@"pubkey_id"]!=nil){
                    [selectedClients addObject:client];
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            
            if (selectedClients.count != 0){
                [[NSUserDefaults standardUserDefaults] setObject:selectedClients forKey:@"selected_clients"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else {
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"selected_clients"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            
            if ([self.delegate respondsToSelector:@selector(groupStatusViewController:didUpdateSelection:)]) {
                [self.delegate groupStatusViewController:self didUpdateSelection: selectedClients];
            }
        }
    }
}




- (CGFloat)tableView:(UITableView *)theTableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:theTableView titleForHeaderInSection:section] != nil) {
        return 22;
    }
    else {
        // If no section header title, no section header needed
        return 0;
    }
}


- (UIView *)tableView:(UITableView *)theTableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:theTableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(0, 0, 320, 19);

    label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"group_infobg"]];
    label.textColor = [UIColor colorWithWhite:0.90 alpha:1.000];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(-1.0, -1.0);
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textAlignment = UITextAlignmentCenter;
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 19)];
    [view autorelease];
    [view addSubview:label];
    
    return view;
}

- (CGSize)contentSizeForViewInPopover {
    if (self.group.count > 0){
        return CGSizeMake(320, (self.group.count * 44) + 20);
    }
    else {
        return CGSizeMake(320, 62);
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
