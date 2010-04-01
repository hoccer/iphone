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
@optional
- (void)hocItemWillStartUpload: (HocItemData *)item;
- (void)hocItemWillStartDownload: (HocItemData *)item;

- (void)hocItemUploadFailed: (HocItemData *)item;
- (void)hocItemDownloadFailed: (HocItemData *)item;

- (void)hocItemUploadWasCanceled: (HocItemData *)item;
- (void)hocItemDownloadWasCanceled: (HocItemData *)item;

- (void)hocItemWasSend: (HocItemData *)item;
- (void)hocItemWasReceived: (HocItemData *)item;

@end
