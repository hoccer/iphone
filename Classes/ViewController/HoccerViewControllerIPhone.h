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

@class ActionElement;

@interface HoccerViewControllerIPhone : HoccerViewController <UINavigationControllerDelegate, 
                        GroupStatusViewControllerDelegate, ContentSelectViewControllerDelegate> 
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
    UIButton *encryptionButton;
    
    id <ContentSelectController> activeContentSelectController;
}

@property (nonatomic, retain) UIViewController *auxiliaryView;
@property (nonatomic, retain) IBOutlet UITabBar *tabBar;
@property (nonatomic, retain) HoccerHistoryController *hoccerHistoryController;
@property (nonatomic, retain) UINavigationItem *navigationItem;

- (void)presentContentSelectViewController: (id <ContentSelectController>)controller;
- (void)dismissContentSelectViewController;

@end
