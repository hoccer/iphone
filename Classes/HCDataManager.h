//
//  HCDataManager.h
//  Hoccer
//
//  Created by Ralph At Hoccer on 18.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCHistoryTVC.h"

#define kCellHeight 83.0
#define kCellHeightMax 338.0
#define kCellAnimOffset 80.0

@interface HCDataManager : NSObject

@property (nonatomic, strong) NSArray *historyObjectsArray;
@property (nonatomic, assign) HCHistoryTVC *historyTVC;

+(HCDataManager *)sharedHCDataManager;

@end
