//
//  DownloadController.h
//  Hoccer
//
//  Created by Robert Palmer on 08.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Crypto.h"

@class TransferController;

enum _TransferableState {
	TransferableStatePreparing,
	TransferableStateReady,
	TransferableStateTransferring,
	TransferableStateTransferred
};
typedef enum _TransferableState TransferableState;

@protocol Transferable <NSObject>
@property (retain, nonatomic) id <Cryptor> cryptor;
- (void)startTransfer;
- (void)cancelTransfer;

- (NSString *)url;

- (TransferableState)state;
- (TransferProgress *)progress;
- (NSError *)error;
- (NSInteger)transfersize;

@end

@protocol TransferControllerDelegate <NSObject>

@optional
- (void)transferController: (TransferController *)controller didFinishTransfer: (id)object;
- (void)transferController: (TransferController *)controller didFailWithError: (NSError *)error forTransfer: (id)object;
- (void)transferController: (TransferController *)controller didUpdateProgress: (TransferProgress *)progress forTransfer: (id)object;
- (void)transferController: (TransferController *)controller didPrepareContent: (id)object;

- (void)transferController: (TransferController *)controller didUpdateTotalProgress: (TransferProgress *)progress;
- (void)transferControllerDidFinishAllTransfers: (TransferController *)controller;

@end

@interface TransferController: NSObject {
	NSMutableArray *transferQueue;
	NSMutableArray *activeTransfers;
    TransferProgress* totalProgress;

	id <TransferControllerDelegate> delegate;
}

@property (assign, nonatomic) id <TransferControllerDelegate> delegate;
@property (assign) TransferProgress* totalProgress;

- (BOOL)hasTransfers;
- (void)addContentToTransferQueue: (id <Transferable>) downloadable;
- (void)cancelTransfers;


@end
