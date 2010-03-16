//
//  ReceiveViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReceiveViewController : UIViewController {
	UIView* feeback;
	
	int sweeping;
}

@property (retain) UIView* feedback; 

- (void)startMoveToCenterAnimation;
@end
