//
//  DownloadController.m
//  Hoccer
//
//  Created by Robert Palmer on 08.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "TransferController.h"
#import "HCError.h"

#define CONCURRENT_TRANSFERS 3

@interface TransferController ()

- (void)startTransfer;
- (void)monitorContent: (NSObject <Transferable> *)theContent;
- (void)removeObservers: (NSObject <Transferable> *)theContent;

- (void)error: (NSError *)error forTransfer: (id)object;
- (void)progress: (NSNumber *)progress forTransfer: (id)object;
- (void)state: (TransferableState) state forTransfer: (id)object;

- (void)updateTotalProgress;

@end

@implementation TransferController
@synthesize delegate;
@synthesize totalProgress;

- (id)init {
    if (USES_DEBUG_MESSAGES) {NSLog(@"TransferController: init");}
	self = [super init];
	if (self != nil) {
		transferQueue = [[NSMutableArray alloc] init];
		activeTransfers = [[NSMutableArray alloc] init];
        totalProgress = [[TransferProgress alloc] init];
	}
	
	return self;
}

- (void)addContentToTransferQueue:(id <Transferable>)transferable {
    if (USES_DEBUG_MESSAGES) { NSLog(@"TransferController: addContentToTransferQueue %@", transferable);}
	[transferQueue addObject:transferable];
	[self startTransfer];
}

- (void)cancelTransfers {
    if (USES_DEBUG_MESSAGES) {NSLog(@"TransferController: cancelTransfers");}
	for (id <Transferable> transfer in activeTransfers) {
		[self removeObservers:transfer];
		[transfer cancelTransfer];
	}
	
	[activeTransfers removeAllObjects];
	[transferQueue removeAllObjects];
}

- (BOOL)hasTransfers {	
	return ([activeTransfers count] > 0 || [transferQueue count] > 0);
}

- (void)startTransfer {
    if (USES_DEBUG_MESSAGES) {NSLog(@"TransferController: startTransfer");}
	if ([activeTransfers count] < CONCURRENT_TRANSFERS && [transferQueue count] > 0) {
		NSObject <Transferable> *nextObject = [transferQueue objectAtIndex:0];
		
		[nextObject startTransfer];
		[self monitorContent:nextObject];
		[activeTransfers addObject:nextObject];
		
		[transferQueue removeObjectAtIndex:0];
    }
}

- (void)finalizeTransfer: (NSObject <Transferable> *)object {
    if (USES_DEBUG_MESSAGES) {NSLog(@"TransferController: finalizeTransfer %@, progress = %@", object, totalProgress);}
	[self removeObservers:object];
	[activeTransfers removeObject:object];
    
    if ([activeTransfers count] == 0 && [transferQueue count] == 0) {
        if ([totalProgress completed]) {
            if (USES_DEBUG_MESSAGES) {NSLog(@"TransferController: finalizeTransfer %@, progress completed = %@", object, totalProgress);}
            if ([delegate respondsToSelector:@selector(transferControllerDidFinishAllTransfers:)]) {
                [delegate transferControllerDidFinishAllTransfers:self];
            }
        } else {
            if (USES_DEBUG_MESSAGES) {NSLog(@"TransferController: finalizeTransfer %@, progress incomplete = %@", object, totalProgress);}
            if ([delegate respondsToSelector:@selector(transferController:didFailWithError:forTransfer:)]) {
                HCError * myError = [[HCError alloc] initWithErrorCode:1001 errorText:@"Transfer was incomplete"];
                [delegate transferController:self didFailWithError:myError forTransfer:object];
            }
        }
    }
    
	[self startTransfer];
}

- (void)monitorContent: (NSObject <Transferable> *)theContent {
	[theContent addObserver:self forKeyPath:@"error" options:NSKeyValueObservingOptionNew context:nil];
	[theContent addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
	[theContent addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservers: (NSObject <Transferable> *)theContent {
	[theContent removeObserver:self forKeyPath:@"error"];
	[theContent removeObserver:self forKeyPath:@"progress"];
	[theContent removeObserver:self forKeyPath:@"state"];
}

#pragma mark -
#pragma mark Dispatch Changes

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqual:@"error"]) {
		[self error: [change objectForKey:NSKeyValueChangeNewKey] forTransfer: object];
	}
	
	if ([keyPath isEqual:@"progress"]) {
		[self progress: [change objectForKey:NSKeyValueChangeNewKey] forTransfer: object];
	}
	
	if ([keyPath isEqual:@"state"]) {
		[self state: [[change objectForKey:NSKeyValueChangeNewKey] intValue] forTransfer: object];
	}
}


- (void)error: (NSError *)error forTransfer: (id)object {
	[object retain];
	
	[self finalizeTransfer:object];
	
	if ([delegate respondsToSelector:@selector(transferController:didFailWithError:forTransfer:)]) {
		[delegate transferController:self didFailWithError:error forTransfer:object];
	}
	
	[object release];
}

- (void)progress: (TransferProgress *)progress forTransfer: (id)object {
    //NSLog(@"TransferController: progress forTransfer %@", object);
	if ([delegate respondsToSelector:@selector(transferController:didUpdateProgress:forTransfer:)]) {
        // NSLog(@"TransferController: delegate didUpdateProgress forTransfer %@", object);
		[delegate transferController:self didUpdateProgress:progress forTransfer:object];
	}
    
    [self updateTotalProgress];
}

- (void)state: (TransferableState) state forTransfer: (id)object {
	[object retain];
	switch (state) {
		case TransferableStateTransferred:
			[self finalizeTransfer:object];
			if ([delegate respondsToSelector:@selector(transferController:didFinishTransfer:)]) {
				[delegate transferController:self didFinishTransfer:object];
			}
			
			break;
		case TransferableStateReady:
			if ([delegate respondsToSelector:@selector(transferController:didPrepareContent:)]) {
				[delegate transferController:self didPrepareContent:object];
			}
			break;

		default:
			break;
	}
	[object release];
}

- (void)updateTotalProgress {
    NSInteger total = 0;
    NSInteger transfered = 0;
    
    for (id <Transferable> t in activeTransfers) {
        // NSLog(@"updateTotalProgress: transferable %@, progress = %@", t, t.progress);
        total += t.progress.total;
        transfered += t.progress.done;
    }

    self.totalProgress = [[TransferProgress alloc] initWithTotal:total done:transfered uri:@"total"];
    
    // NSLog(@"updateTotalProgress: total = %i, transfered = %i, percent = %@",total, transfered, [NSNumber numberWithFloat:transfered/(float)total]);
    if ([delegate respondsToSelector:@selector(transferController:didUpdateTotalProgress:)]){
        // NSLog(@"updateTotalProgress: calling didUpdateTotalProgress");
        [delegate transferController:self didUpdateTotalProgress:totalProgress];
    }
}


- (void) dealloc {
	[transferQueue release];
	[activeTransfers release];
	
	[super dealloc];
}


@end
