//
//  HoccingRulesIPad.m
//  Hoccer
//
//  Created by Robert Palmer on 08.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccingRulesIPad.h"
#import "HoccerViewController.h"
#import "DesktopDataSource.h"



@implementation HoccingRulesIPad

- (BOOL)hoccerViewControllerMayThrow: (HoccerViewController *)controller {
	if (!controller.linccer.isRegistered) {
		return NO;
	}
	
	if (![controller.linccer isLinccing]) {
		return YES;
	}
	
	return NO;
}

- (BOOL)hoccerViewControllerMayCatch: (HoccerViewController *)controller {
	if (!controller.linccer.isRegistered) {
        NSLog(@"not registered");
		return NO;
	}
    
	if (![controller.linccer isLinccing]) {
		return YES;
	}
	
	return NO;
}

- (BOOL)hoccerViewControllerMaySweepIn: (HoccerViewController *)controller {
	if (!controller.linccer.isRegistered) {
		return NO;
	}
	
	if (![controller.linccer isLinccing]) {
		return YES;
	}
	
	return NO;
}

- (BOOL)hoccerViewControllerMaySweepOut: (HoccerViewController *)controller {
	if (!controller.linccer.isRegistered) {
		return NO;
	}
	
	if ([controller.desktopData count] > 1 && ![controller.linccer isLinccing]) {
		return YES;
	}
	
	return NO;
}

- (BOOL)hoccerViewControllerMayAddAnotherView: (HoccerViewController *)controller {	
	
	return YES;
}

@end