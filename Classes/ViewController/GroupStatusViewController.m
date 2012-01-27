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


}


- (void)calculateHightForText: (NSString *)text {
    NSInteger rows = [self tableView:self.tableView numberOfRowsInSection:0];
    
    CGFloat height = 0;
    if (rows != 0) {
        height = rows * 60 + 20;        
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
    return [self.group count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
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
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"group_satus_background_enc_on"]] autorelease];
    }
    else {
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"group_satus_background_enc_off"]] autorelease];
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    if ([selectedClients containsObject:client]) {
        cell.imageView.image = [UIImage imageNamed:@"check_on"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"check_off"];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"Restrict transfer to:", nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *client = [group objectAtIndex:indexPath.row];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"] == NO || [[NSUserDefaults standardUserDefaults] boolForKey:@"sendPassword"] == NO) {
        if ([selectedClients containsObject:client]) {
            [selectedClients removeObject:client];
            cell.imageView.image = [UIImage imageNamed:@"check_off"];
        } else {
            [selectedClients addObject:client];
            cell.imageView.image = [UIImage imageNamed:@"check_on"];
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
            cell.imageView.image = [UIImage imageNamed:@"check_off"];
        }
        else {
            if([client objectForKey:@"pubkey_id"]!=nil){
                [selectedClients addObject:client];
                cell.imageView.image = [UIImage imageNamed:@"check_on"];
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




- (CGFloat)tableView:(UITableView *)theTableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:theTableView titleForHeaderInSection:section] != nil) {
        return 20;
    }
    else {
        // If no section header title, no section header needed
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UIView *)tableView:(UITableView *)theTableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:theTableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(0, 0, 320, 19);

    label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bar.png"]];
    label.textColor = [UIColor colorWithRed:0.000 green:0.596 blue:0.555 alpha:1.000];
    label.shadowColor = [UIColor clearColor];
    label.shadowOffset = CGSizeMake(0.0, 0.0);
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textAlignment = UITextAlignmentCenter;
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 19)];
    [view autorelease];
    [view addSubview:label];
    
    return view;
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
