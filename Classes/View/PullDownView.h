//
//  PullDownView.h
//  Hoccer
//
//  Created by Ralph on 18.12.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DesktopView/DesktopView.h"

@interface PullDownView : UIView

@property (nonatomic, retain) DesktopView *desktopView;

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;

@end
