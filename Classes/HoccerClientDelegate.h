//
//  HoccerClientDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 20.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HoccerClient;

@protocol HoccerClientDelegate <NSObject>

- (void)hoccerClient: (HoccerClient*)hoccerClient didFailWithError: (NSError *)error;
- (void)hoccerClientDidFinishLoading: (HoccerClient*)hoccerClient;

@end
