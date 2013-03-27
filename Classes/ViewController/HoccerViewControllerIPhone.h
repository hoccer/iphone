//
//  HoccerViewControllerIPhone.h
//  Hoccer
//
//  Created by Robert Palmer on 06.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerViewController.h"
#import "HelpController.h"
#import "GroupStatusViewController.h"
#import "HocletSelectViewController.h"
#import "ActionElement.h"
// #import "CustomPullToRefresh.h"

@class ActionElement;

@interface HoccerViewControllerIPhone : HoccerViewController <UINavigationControllerDelegate, 
                        GroupStatusViewControllerDelegate, ContentSelectViewControllerDelegate, UITableViewDelegate>
{
	UIViewController *auxiliaryView;
	ActionElement *delayedAction;
	HoccerHistoryController *hoccerHistoryController;
    
	BOOL isPopUpDisplayed;
		
	UINavigationItem *navigationItem;
	
    HelpController *helpController;
    UIButton *groupSizeButton;
    UIButton *encryptionButton;
    
    id <ContentSelectController> activeContentSelectController;

    
    // ### new pulltorefresh
//    CustomPullToRefresh *_ptr;
//    UIScrollView *_refreshScrollView;
    UITableView *_table;
    
    CGFloat desktopViewHeight;
}

@property (nonatomic, retain) UIViewController *auxiliaryView;
@property (nonatomic, retain) HoccerHistoryController *hoccerHistoryController;
@property (nonatomic, retain) UINavigationItem *navigationItem;
//@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (retain, nonatomic) IBOutlet UIScrollView *refreshScrollView;
@property (retain, nonatomic) IBOutlet UITableView *table;



- (void)presentContentSelectViewController: (id <ContentSelectController>)controller;
- (void)dismissContentSelectViewController;
- (void)pressedLeaveChannelMode:(id)sender;
- (void)cancelPopOver;
// - (IBAction)pullDownAction:(id)sender;

@end
