//
//  HoccingRulesIPhone.m
//  Hoccer
//
//  Created by Robert Palmer on 06.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccingRulesIPhone.h"
#import "HoccerViewController.h";
#import "DesktopDataSource.h"

@implementation HoccingRulesIPhone

- (BOOL)hoccerViewControllerMayThrow: (HoccerViewController *)controller {
	if ([controller.desktopData count] == 1 && ![controller.desktopData controllerHasActiveRequest]) {
		return YES;
	}
	
	return NO;
}

- (BOOL)hoccerViewControllerMayCatch: (HoccerViewController *)controller {
	if ([controller.desktopData count] == 0 && ![controller.desktopData controllerHasActiveRequest]) {
		return YES;
	}
	
	return NO;
}

- (BOOL)hoccerViewControllerMaySweepIn: (HoccerViewController *)controller {
	if ([controller.desktopData count] == 0 && ![controller.desktopData controllerHasActiveRequest]) {
		return YES;
	}
	
	return NO;;
}

- (BOOL)hoccerViewControllerMaySweepOut: (HoccerViewController *)controller {
	if ([controller.desktopData count] == 1 && ![controller.desktopData controllerHasActiveRequest]) {
		return YES;
	}
	
	return NO;
}

- (BOOL)hoccerViewControllerMayAddAnotherView: (HoccerViewController *)controller {
	if ([controller.desktopData count] == 1) {
		return NO;
	}
	
	return YES;
}

@end