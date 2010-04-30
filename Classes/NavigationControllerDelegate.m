//
//  NavigationControllerDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 26.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "NavigationControllerDelegate.h"


@implementation NavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	CGRect frame = navigationController.navigationBar.frame;
	frame.size.height = 53;
	
	navigationController.navigationBar.frame = frame;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	CGRect viewFrame = viewController.view.frame;
	viewFrame.origin.y = viewFrame.origin.y + 9;
	viewFrame.size.height = viewFrame.size.height - 9;
	
	viewController.view.frame = viewFrame;
}

@end
