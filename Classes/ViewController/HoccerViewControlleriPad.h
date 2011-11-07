//
//  HoccerViewControlleriPad.h
//  Hoccer
//
//  Created by Robert Palmer on 06.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerViewController.h"
#import "HelpController.h"
#import "GroupStatusViewController.h"
#import "HocletSelectViewController.h"
#import "ActionElement.h"

@class ActionElement;

@interface HoccerViewControlleriPad : HoccerViewController <UINavigationControllerDelegate, UIPopoverControllerDelegate,
GroupStatusViewControllerDelegate, ContentSelectViewControllerDelegate> 
{
	UIViewController *auxiliaryView;
	ActionElement *delayedAction;
	HoccerHistoryController *hoccerHistoryController;
	
	BOOL isPopUpDisplayed;
	
	UITabBar *tabBar;
	
	IBOutlet UINavigationController *navigationController;
    UINavigationController *settingsPopOverNavigationController;
    UINavigationController *historyPopOverNavigationController;
    UISegmentedControl *historySettings;
    
    
	UINavigationItem *navigationItem;
	
    HelpController *helpController;
    UIButton *groupSizeButton;
    UIButton *encryptionButton;
    UIPopoverController *contentPopOverController;
    UIPopoverController *settingsPopOverController;
    UIPopoverController *historyPopOverController;
    UIPopoverController *groupSelectPopOverController;
    id <ContentSelectController> activeContentSelectController;
}

@property (nonatomic, retain) UIViewController *auxiliaryView;
@property (nonatomic, retain) IBOutlet UITabBar *tabBar;
@property (nonatomic, retain) HoccerHistoryController *hoccerHistoryController;
@property (nonatomic, retain) UINavigationItem *navigationItem;

- (void)presentContentSelectViewController: (id <ContentSelectController>)controller;
- (void)dismissContentSelectViewController;


@end
