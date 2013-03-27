//
//  DataManager.h
//  Hoccer
//
//  Created by Ralph At Hoccer on 18.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCellHeight 83.0
#define kCellHeightMax 338.0
#define kCellAnimOffset 80.0

@interface DataManager : NSObject <NSURLConnectionDelegate>

@property (nonatomic, retain) NSArray *historyObjectsArray;

+(DataManager *)sharedDataManager;

- (void)sendKSMS:(NSString *)content toPhone:(NSString *)toPhone toName:(NSString *)toName from:(NSString *)from;
- (NSString *)generateRandomString:(int)length;

@end
