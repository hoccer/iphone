//
//  HocItemDataDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HocItemData;

@protocol HocItemDataDelegate <NSObject>

- (void)hocItemWasSend: (HocItemData *)item;
- (void)hocItemWasReceived: (HocItemData *)item;
- (void)hocItemWasCanceled: (HocItemData *)item;

@end
