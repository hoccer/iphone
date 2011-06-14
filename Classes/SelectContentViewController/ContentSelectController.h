//
//  ContentSelectController.h
//  Hoccer
//
//  Created by Robert Palmer on 08.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HoccerContent;

@protocol ContentSelectController <NSObject>
- (UIViewController *)viewController;
@end

@protocol ContentSelectViewControllerDelegate <NSObject>

@optional
- (void)contentSelectController: (id)controller didSelectContent: (HoccerContent *)content;
- (void)contentSelectControllerDidCancel: (id)controller;
@end
