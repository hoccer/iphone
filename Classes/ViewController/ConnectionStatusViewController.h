//
//  ConnectionStatusViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 02.08.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatusViewController.h"

@class HoccerContent;


@interface ConnectionStatusViewController : StatusViewController {
	HoccerContent *content;
}

@property (retain) HoccerContent* content;

- (void)setUpdate: (NSString *)update;
- (void)setProgressUpdate: (CGFloat) percentage;

@end
