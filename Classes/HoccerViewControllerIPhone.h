//
//  HoccerViewControllerIPhone.h
//  Hoccer
//
//  Created by Robert Palmer on 06.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerViewController.h"

@class ActionElement;

@interface HoccerViewControllerIPhone : HoccerViewController {
	UIViewController *auxiliaryView;
	ActionElement *delayedAction;
	
	BOOL isPopUpDisplayed;
}

@property (nonatomic, retain) UIViewController *auxiliaryView;


@end