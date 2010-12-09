//
//  DownloadController.h
//  Hoccer
//
//  Created by Robert Palmer on 08.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadController;

enum _TransferableState {
	TransferableStatePreparing,
	TransferableStateReady,
	TransferableStateTransfering,
	TransferableStateTransferred
};
typedef enum _TransferableState TransferableState;

@protocol Downloadable <NSObject>
- (void)startTransfer;
- (void)cancelTransfer;

- (TransferableState)state;
- (NSNumber *)progress;
- (NSError *)error;
@end

@protocol DownloadControllerDelegate <NSObject>

@optional
- (void)downloadController: (DownloadController *)controller didFinishTransfer: (id)object;
- (void)downloadController: (DownloadController *)controller didFailWithError: (NSError *)error forTransfer: (id)object;
- (void)downloadController: (DownloadController *)controller didUpdateProgress: (NSNumber *)progress forTransfer: (id)object;

@end


@interface DownloadController : NSObject {
	NSMutableArray *downloadQueue;
	NSMutableArray *activeDownloads;
	
	id <DownloadControllerDelegate> delegate;
}

@property (assign, nonatomic) id <DownloadControllerDelegate> delegate;

- (void)addContentToDownloadQueue: (id <Downloadable>) downloadable;
- (void)cancelDownloads;


@end
