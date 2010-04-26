//
//  HocItemDataDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HoccerConnectionController;

@protocol HocItemDataDelegate <NSObject>
@optional
- (void)hocItemWillStartUpload: (HoccerConnectionController *)item;
- (void)hocItemWillStartDownload: (HoccerConnectionController *)item;

- (void)hocItem:(HoccerConnectionController *)item uploadFailedWithError: (NSError *)error;
- (void)hocItem:(HoccerConnectionController *)item downloadFailedWithError: (NSError *)error;

- (void)hocItemUploadWasCanceled: (HoccerConnectionController *)item;
- (void)hocItemDownloadWasCanceled: (HoccerConnectionController *)item;

- (void)hocItemWasSend: (HoccerConnectionController *)item;
- (void)hocItemWasReceived: (HoccerConnectionController *)item;

@end
