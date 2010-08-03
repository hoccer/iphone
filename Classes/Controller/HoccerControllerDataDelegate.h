//
//  hoccerControllerDataDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HoccerController;
@class HoccerContent;

@protocol HoccerControllerDelegate <NSObject>
@optional
- (void)hoccerControllerWillStartUpload: (HoccerController *)item;
- (void)hoccerControllerWillStartDownload: (HoccerController *)item;

- (void)hoccerController:(HoccerController *)item uploadFailedWithError: (NSError *)error;
- (void)hoccerController:(HoccerController *)item downloadFailedWithError: (NSError *)error;

- (void)hoccerControllerUploadWasCanceled: (HoccerController *)item;
- (void)hoccerControllerDownloadWasCanceled: (HoccerController *)item;

- (void)hoccerControllerWasSent: (HoccerController *)item;
- (void)hoccerControllerWasReceived: (HoccerController *)item;

- (void)hoccerControllerWasClosed: (HoccerController *)item;

- (void)showOptionsForContent: (HoccerContent *)content;

@end
