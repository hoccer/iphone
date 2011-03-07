//
//  DownloadController.h
//  Hoccer
//
//  Created by Robert Palmer on 08.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TransferController;

enum _TransferableState {
	TransferableStatePreparing,
	TransferableStateReady,
	TransferableStateTransfering,
	TransferableStateTransferred
};
typedef enum _TransferableState TransferableState;

@protocol Transferable <NSObject>
- (void)startTransfer;
- (void)cancelTransfer;

- (TransferableState)state;
- (NSNumber *)progress;
- (NSError *)error;
@end

@protocol DownloadControllerDelegate <NSObject>

@optional
- (void)transferController: (TransferController *)controller didFinishTransfer: (id)object;
- (void)transferController: (TransferController *)controller didFailWithError: (NSError *)error forTransfer: (id)object;
- (void)transferController: (TransferController *)controller didUpdateProgress: (NSNumber *)progress forTransfer: (id)object;
- (void)transferController:(TransferController *)controller didPrepareContent: (id)object;

@end

@interface TransferController : NSObject {
	NSMutableArray *downloadQueue;
	NSMutableArray *activeDownloads;
	
	id <DownloadControllerDelegate> delegate;
}

@property (assign, nonatomic) id <DownloadControllerDelegate> delegate;

- (BOOL)hasTransfers;
- (void)addContentToTransferQueue: (id <Transferable>) downloadable;
- (void)cancelDownloads;


@end
