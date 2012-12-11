//
//  PullToReceiveViewController.m
//  Hoccer
//
//  Created by Ralph At Hoccer on 28.11.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "PullToReceiveViewController.h"

@implementation PullToReceiveViewController

@synthesize tableView;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//
//    }
//    else {
//        CGRect parentFrame = CGRectMake(0.f, 48.f, 320.f, 367.f);
//        [self.view setFrame:parentFrame];
//        [self.tableView setFrame:parentFrame];
//    }
//	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lochblech_bg_pull.png"]];
//    
//    UIView *tbBgView = [[[UIView alloc] init] autorelease];
//    tbBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lochblech_bg_pull.png"]];
//    tbBgView.opaque = YES;
//    self.tableView.backgroundView = tbBgView;
//	self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [tableView reloadData];
}

//- (CGSize)contentSizeForViewInPopover
//{
//    return CGSizeMake(320, 367);
//}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
//    [self setTable:nil];
    [super viewDidUnload];
    
//    [self setRefreshScrollView:nil];
//    
//    [_ptr release], _ptr = nil;
}

- (void)dealloc
{
	[tableView release];
    [super dealloc];
}

@end
