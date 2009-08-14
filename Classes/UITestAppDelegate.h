//
//  UITestAppDelegate.h
//  UITest
//
//  Created by david on 14.08.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyViewController;

@interface UITestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	
	MyViewController * myViewController;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MyViewController * myViewController;

@end

