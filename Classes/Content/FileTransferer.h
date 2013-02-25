//
//  FileTransferer.h
//  Hoccer
//
//  Created by Robert Palmer on 10.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hoccer.h"
#import "TransferController.h"

@interface FileTransferer : NSObject <Transferable, HCFileCacheDelegate> {
	NSString *idString;
	HCFileCache *fileCache;
	
	NSString *url;
	NSString *filename;
	
	TransferProgress * progress;

	NSError *error;
	TransferableState state;
}

@property (nonatomic, retain) TransferProgress* progress;
@property (nonatomic, retain) NSError* error;
@property (nonatomic, assign) TransferableState state;
// @property (nonatomic, readonly) NSInteger transfersize;

@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSString *url;

@end
