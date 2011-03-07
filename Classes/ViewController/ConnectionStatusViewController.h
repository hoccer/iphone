//
//  ConnectionStatusViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 02.08.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatusViewController.h"

@class ConnectionStatusViewController;
@protocol ConnectionStatusViewControllerDelegate <NSObject>
@optional
- (void)connectionStatusViewControllerDidCancel: (ConnectionStatusViewController *)controller;
@end



@interface ConnectionStatusViewController : StatusViewController {
	id <ConnectionStatusViewControllerDelegate> delegate;	
}

@property (assign, nonatomic) id <ConnectionStatusViewControllerDelegate> delegate;

- (void)setUpdate: (NSString *)update;
- (void)setProgressUpdate: (CGFloat) percentage;

@end
