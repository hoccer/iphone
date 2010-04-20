//
//  HoccerClientDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 20.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HoccerClientDelegate

- (void)hoccerClient: (HoccerClient*)hoccerClient didFailWithError: (NSError *);
- (void)hoccerClientDidFinishLoading: (HoccerClient*)hoccerClient;

@end
