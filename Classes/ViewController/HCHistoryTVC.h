//
//  HCHistoryTVC.h
//  Hoccer
//
//  Created by Ralph At Hoccer on 18.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCWidgetCellDelegate.h"

@class HoccerViewController;

@interface HCHistoryTVC : UITableViewController <HCWidgetCellDelegate>

@property (retain) UINavigationController *parentNavigationController;
@property (nonatomic, assign) HoccerViewController *hoccerViewController;

- (BOOL)widgetIsOpen:(NSIndexPath *)indexPath;

@end
