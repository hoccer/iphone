//
//  hoccerControllerDataDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HoccerController;

@protocol HoccerControllerDelegate <NSObject>
@optional
- (void)hoccerControllerWillStartUpload: (HoccerController *)item;
- (void)hoccerControllerWillStartDownload: (HoccerController *)item;

- (void)hoccerControllerUploadWasCanceled: (HoccerController *)item;
- (void)hoccerControllerDownloadWasCanceled: (HoccerController *)item;

- (void)hoccerControllerWasClosed: (HoccerController *)item;

- (void)hoccerControllerSaveButtonWasClicked: (HoccerController *)item; 

@end
