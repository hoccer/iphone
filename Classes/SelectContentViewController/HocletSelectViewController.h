//
//  HocletSelectViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 07.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoccerContent.h"

@protocol ContentSelectViewControllerDelegate <NSObject>

@optional
- (void)contentSelectController: (id)controller didSelectContent: (HoccerContent *)content;
- (void)contentSelectControllerDidCancel: (id)controller;
@end

@interface HocletSelectViewController : UITableViewController {
    NSArray *hoclets;
    
    id <ContentSelectViewControllerDelegate> delegate;
}

@property (retain) id <ContentSelectViewControllerDelegate> delegate;
@property (readonly) UIViewController *viewController;

@end
