//
//  HelpController.h
//  Hoccer
//
//  Created by Robert Palmer on 04.02.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HelpControllerDelegate;


@interface HelpController : NSObject <UIAlertViewDelegate> {

    UINavigationController *tutorialPopOverNavigationController;
    UIPopoverController *tutorialPopOverController;
}

@property (nonatomic, assign) id<HelpControllerDelegate> delegate;

- (void)showTips;

@end


@protocol HelpControllerDelegate <NSObject>
- (void)helpControllerRequestsTutorial;
@end
