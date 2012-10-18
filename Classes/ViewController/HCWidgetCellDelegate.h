//
//  HCWidgetCellDelegate.h
//  Hoccer
//
//  Created by Ralph At Hoccer on 18.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HCWidgetCellDelegate <NSObject>

@optional

- (void)toggleButtonPressed:(id)sender;

@end