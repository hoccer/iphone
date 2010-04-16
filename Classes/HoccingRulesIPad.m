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
	return NO;
}

- (BOOL)hoccerViewControllerMayCatch: (HoccerViewController *)controller {	
	return NO;
}

- (BOOL)hoccerViewControllerMaySweepIn: (HoccerViewController *)controller {
	if (![controller.desktopData hasActiveRequest]) {
		return YES;
	}
	
	return NO;;
}

- (BOOL)hoccerViewControllerMaySweepOut: (HoccerViewController *)controller {
	if ([controller.desktopData count] > 0 && ![controller.desktopData hasActiveRequest]) {
		return YES;
	}
	
	return NO;
}

- (BOOL)hoccerViewControllerMayAddAnotherView: (HoccerViewController *)controller {
	return YES;
}



@end
