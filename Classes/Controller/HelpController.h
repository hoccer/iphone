//
//  HelpController.h
//  Hoccer
//
//  Created by Robert Palmer on 04.02.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HelpController : NSObject <UIAlertViewDelegate> {
	UINavigationController *controller;
}

- (id)initWithController: (UINavigationController *)viewController;
- (void)viewDidLoad;
- (void)showTutorial;

@end
