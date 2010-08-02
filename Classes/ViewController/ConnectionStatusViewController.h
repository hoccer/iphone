//
//  ConnectionStatusViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 02.08.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatusViewController.h"


@interface ConnectionStatusViewController : StatusViewController {
	HoccerController *hoccerController;
}

@property (retain) HoccerController* hoccerController;

- (void)setUpdate: (NSString *)update;
- (void)setProgressUpdate: (CGFloat) percentage;

- (void)monitorHoccerController: (HoccerController *)hoccerController;

@end
