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
#import "HCHistoryTVC.h"
#import "CustomPullToRefresh.h"
#import "PullDownView.h"

@class ActionElement;

@interface HoccerViewControllerIPhone : HoccerViewController <UINavigationControllerDelegate, 
                        GroupStatusViewControllerDelegate, ContentSelectViewControllerDelegate, CustomPullToRefreshDelegate, UITableViewDelegate>
{
	UIViewController *auxiliaryView;
	ActionElement *delayedAction;
	HoccerHistoryController *hoccerHistoryController;
    
	BOOL isPopUpDisplayed;
	
	UITabBar *tabBar;
	
	IBOutlet UINavigationController *navigationController;
	UINavigationItem *navigationItem;
	
    HelpController *helpController;
    UIButton *groupSizeButton;
    UIButton *channelSizeButton;
    UIButton *encryptionButton;
    
    id <ContentSelectController> activeContentSelectController;

    
    // ### new pulltorefresh
    CustomPullToRefresh *_ptr;
//    UIScrollView *_refreshScrollView;
    UITableView *_table;
    
    BOOL isPullDown;
}

@property (nonatomic, retain) UIViewController *auxiliaryView;
@property (nonatomic, retain) IBOutlet UITabBar *tabBar;
@property (nonatomic, retain) HoccerHistoryController *hoccerHistoryController;
@property (nonatomic, retain) HCHistoryTVC *historyTVC;
@property (nonatomic, retain) UINavigationItem *navigationItem;
//@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (retain, nonatomic) IBOutlet UIScrollView *refreshScrollView;
@property (retain, nonatomic) IBOutlet UITableView *table;
@property (retain, nonatomic) IBOutlet PullDownView *pullDownView;
@property (nonatomic, assign) BOOL pullDownFlag;
@property (retain, nonatomic) IBOutlet UIImageView *pullDownAnimationImage;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndi;

- (void)presentContentSelectViewController: (id <ContentSelectController>)controller;
- (void)dismissContentSelectViewController;
- (void)pressedToggleAutoReceive:(id)sender;
- (void)pressedLeaveChannelMode:(id)sender;
- (void)cancelPopOver;
- (IBAction)pullDownAction:(id)sender;

@end
