//
//  HoccerClientDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 20.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HoccerConnection;

@protocol HoccerConnectionDelegate <NSObject>

- (void)hoccerConnection: (HoccerConnection *)hoccerConnection didFailWithError: (NSError *)error;
- (void)hoccerConnectionDidFinishLoading: (HoccerConnection *)hoccerConnection;

- (void)hoccerConnection: (HoccerConnection *)hoccerConnection didUpdateStatus: (NSDictionary *)status;
- (void)hoccerConnection: (HoccerConnection *)hoccerConnection didUpdateTransfereProgress: (NSNumber *)progress;

@end
