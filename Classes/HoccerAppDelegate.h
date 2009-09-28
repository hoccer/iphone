//
//  HoccerAppDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HoccerViewController;

@interface HoccerAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, 
											UIImagePickerControllerDelegate> {
    UIWindow *window;
    UITabBarController *viewController;
												
	NSData *dataToSend;										
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *viewController;

@property (nonatomic, retain) NSData *dataToSend;

@end

