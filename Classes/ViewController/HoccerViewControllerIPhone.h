//
//  HoccerViewControllerIPhone.h
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

@interface HoccerViewControllerIPhone : HoccerViewController <UINavigationControllerDelegate, 
                        GroupStatusViewControllerDelegate, ContentSelectViewControllerDelegate> 
{
	UIViewController *auxiliaryView;
	ActionElement *delayedAction;
	HoccerHistoryController *hoccerHistoryController;
	
	BOOL isPopUpDisplayed;
	
	UIView *tabBar;
	
	IBOutlet UINavigationController *navigationController;
	UINavigationItem *navigationItem;
	
    HelpController *helpController;
    UIButton *groupSizeButton;
    UIButton *encryptionButton;
    
    IBOutlet UIButton *contentSelectButton;
    IBOutlet UIButton *historySelectButton;
    IBOutlet UIButton *settingsSelectButton;

    
    id <ContentSelectController> activeContentSelectController;
}

@property (nonatomic, retain) UIViewController *auxiliaryView;
@property (nonatomic, retain) IBOutlet UIView *tabBar;
@property (nonatomic, retain) HoccerHistoryController *hoccerHistoryController;
@property (nonatomic, retain) UINavigationItem *navigationItem;

- (void)presentContentSelectViewController: (id <ContentSelectController>)controller;
- (void)dismissContentSelectViewController;
- (IBAction)tabBarButtonPressed:(id)sender;
-(void)resetTabBar;

@end
