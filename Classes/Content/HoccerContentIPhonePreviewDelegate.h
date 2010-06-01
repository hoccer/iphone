//
//  HoccerContentIPhonePreviewDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 06.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerContentPreviewDelegate.h"


@interface HoccerContentIPhonePreviewDelegate : NSObject  <HoccerContentPreviewDelegate> {
	UIViewController *viewController;
}

@property (retain) UIViewController *viewController;

@end
